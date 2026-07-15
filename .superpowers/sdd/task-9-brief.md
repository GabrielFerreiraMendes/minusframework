### Task 3: WebSocket Hub + Connection Token

**Files:**
- Create: `services/feature-flags/internal/handler/ws.go`
- Create: `services/feature-flags/internal/service/hub.go`
- Modify: `services/feature-flags/cmd/server/main.go`

**Interfaces:**
- Produces: `POST /api/v1/ws/token` — issues single-use connection token (30s TTL), auth by API Key (X-API-Key)
- Produces: `GET /ws` — upgrades to WebSocket with token validation
- Produces: Hub manages all WebSocket connections per `license_key:environment_id`
- The `APIKeyRequired` middleware (from Task 2) protects the token endpoint
- The `JWTAuthRequired` middleware (from Task 2) protects the `/api/v1/*` routes

---

### Step 1: Create service/hub.go

```go
package service

import (
    "encoding/json"
    "log"
    "sync"
    "github.com/gorilla/websocket"
)

type Client struct {
    Conn          *websocket.Conn
    LicenseKey    string
    EnvironmentID string
    Send          chan []byte
}

type Hub struct {
    mu    sync.RWMutex
    rooms map[string]map[*Client]bool
}

func NewHub() *Hub {
    return &Hub{rooms: make(map[string]map[*Client]bool)}
}

func (h *Hub) roomKey(licenseKey, environmentID string) string {
    return licenseKey + ":" + environmentID
}

func (h *Hub) Register(client *Client) {
    h.mu.Lock()
    defer h.mu.Unlock()
    key := h.roomKey(client.LicenseKey, client.EnvironmentID)
    if h.rooms[key] == nil {
        h.rooms[key] = make(map[*Client]bool)
    }
    h.rooms[key][client] = true
    log.Printf("Client registered: %s (room: %s)", client.Conn.RemoteAddr(), key)
}

func (h *Hub) Unregister(client *Client) {
    h.mu.Lock()
    defer h.mu.Unlock()
    key := h.roomKey(client.LicenseKey, client.EnvironmentID)
    if clients, ok := h.rooms[key]; ok {
        if _, exists := clients[client]; exists {
            delete(clients, client)
            close(client.Send)
            if len(clients) == 0 {
                delete(h.rooms, key)
            }
        }
    }
}

func (h *Hub) Broadcast(licenseKey, environmentID string, message interface{}) error {
    h.mu.RLock()
    defer h.mu.RUnlock()
    key := h.roomKey(licenseKey, environmentID)
    clients := h.rooms[key]
    data, _ := json.Marshal(message)
    for client := range clients {
        select {
        case client.Send <- data:
        default:
        }
    }
    return nil
}

func (h *Hub) BroadcastFlagUpdate(licenseKey, environmentID, flagKey string, enabled bool, variant interface{}) {
    h.Broadcast(licenseKey, environmentID, map[string]interface{}{
        "type": "flag_updated", "flag": flagKey, "enabled": enabled, "variant": variant,
    })
}

func (h *Hub) BroadcastFlagDelete(licenseKey, environmentID, flagKey string) {
    h.Broadcast(licenseKey, environmentID, map[string]interface{}{
        "type": "flag_deleted", "flag": flagKey,
    })
}
```

### Step 2: Create handler/ws.go

```go
package handler

import (
    "crypto/rand"
    "encoding/hex"
    "encoding/json"
    "log"
    "net/http"
    "os"
    "time"
    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"
    "github.com/gorilla/websocket"
    "github.com/minusframework/minusframework/services/feature-flags/internal/service"
    "github.com/minusframework/minusframework/services/feature-flags/internal/store"
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
    // Send initial flag state
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
            if !ok { client.Conn.WriteMessage(websocket.CloseMessage, []byte{}); return }
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
    for { _, _, err := client.Conn.ReadMessage(); if err != nil { break } }
}
```

### Step 3: Wire in main.go

After `r := gin.Default()` and before `jwtSecret := os.Getenv("JWT_SECRET")`:

```go
hub := service.NewHub()
```

After the JWT-protected `api` group:

```go
wsHandler := handler.NewWSHandler(db, hub)
wsAPI := r.Group("/api/v1", middleware.APIKeyRequired(db))
wsAPI.POST("/ws/token", wsHandler.IssueToken)
r.GET("/ws", wsHandler.HandleWebSocket)
```

Add imports for `"github.com/minusframework/minusframework/services/feature-flags/internal/service"` and `"github.com/minusframework/minusframework/services/feature-flags/internal/handler"`.

### Step 4: Commit

```bash
git add services/feature-flags/
git commit -m "feat: add WebSocket hub with connection token auth"
```
