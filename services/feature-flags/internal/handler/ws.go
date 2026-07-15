package handler

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/websocket"

	"github.com/GabrielFerreiraMendes/minusframework/services/feature-flags/internal/service"
	"github.com/GabrielFerreiraMendes/minusframework/services/feature-flags/internal/store"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

type WSHandler struct {
	store     *store.Store
	hub       *service.Hub
	jwtSecret string
}

func NewWSHandler(s *store.Store, h *service.Hub) *WSHandler {
	return &WSHandler{store: s, hub: h, jwtSecret: os.Getenv("JWT_SECRET")}
}

type WSTokenClaims struct {
	LicenseKey    string `json:"license_key"`
	EnvironmentID string `json:"environment_id"`
	jwt.RegisteredClaims
}

func (h *WSHandler) IssueToken(c *gin.Context) {
	licenseKey, _ := c.Get("license_key")
	envID := c.Query("environment_id")
	if envID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "environment_id is required"})
		return
	}
	now := time.Now()
	claims := WSTokenClaims{
		LicenseKey:    licenseKey.(string),
		EnvironmentID: envID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(30 * time.Second)),
			IssuedAt:  jwt.NewNumericDate(now),
			ID:        generateTokenID(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, _ := token.SignedString([]byte(h.jwtSecret))
	c.JSON(http.StatusOK, gin.H{"token": tokenString, "expires_in": 30})
}

func generateTokenID() string {
	b := make([]byte, 8)
	rand.Read(b)
	return hex.EncodeToString(b)
}

func (h *WSHandler) HandleWebSocket(c *gin.Context) {
	tokenStr := c.Query("token")
	if tokenStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing token"})
		return
	}
	claims := &WSTokenClaims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
		return []byte(h.jwtSecret), nil
	})
	if err != nil || !token.Valid {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid or expired token"})
		return
	}
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}
	client := &service.Client{
		Conn: conn, LicenseKey: claims.LicenseKey,
		EnvironmentID: claims.EnvironmentID, Send: make(chan []byte, 256),
	}
	h.hub.Register(client)
	flags, _ := h.store.ListFlags(c.Request.Context(), claims.LicenseKey, claims.EnvironmentID)
	initMsg, _ := json.Marshal(map[string]interface{}{"type": "connected", "flags": flags})
	client.Send <- initMsg
	go h.writePump(client)
	go h.readPump(client)
}

func (h *WSHandler) writePump(client *service.Client) {
	ticker := time.NewTicker(30 * time.Second)
	defer func() { ticker.Stop(); client.Conn.Close() }()
	for {
		select {
		case message, ok := <-client.Send:
			client.Conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				client.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			w, _ := client.Conn.NextWriter(websocket.TextMessage)
			w.Write(message)
			w.Close()
		case <-ticker.C:
			client.Conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			client.Conn.WriteMessage(websocket.PingMessage, nil)
		}
	}
}

func (h *WSHandler) readPump(client *service.Client) {
	defer func() { h.hub.Unregister(client); client.Conn.Close() }()
	client.Conn.SetReadLimit(512)
	client.Conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	client.Conn.SetPongHandler(func(string) error {
		client.Conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})
	for {
		_, _, err := client.Conn.ReadMessage()
		if err != nil {
			break
		}
	}
}
