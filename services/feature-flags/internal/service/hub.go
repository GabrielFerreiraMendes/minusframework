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
