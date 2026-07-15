package service

import (
	"context"
	"encoding/json"
	"log"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/redis/go-redis/v9"
)

type Client struct {
	Conn          *websocket.Conn
	LicenseKey    string
	EnvironmentID string
	Send          chan []byte
}

type Hub struct {
	mu       sync.RWMutex
	rooms    map[string]map[*Client]bool
	redis    *redis.Client
	redisCtx context.Context
}

func NewHub(redisURL string) *Hub {
	opts, err := redis.ParseURL(redisURL)
	var rdb *redis.Client
	if err == nil {
		rdb = redis.NewClient(opts)
	}
	return &Hub{
		rooms:    make(map[string]map[*Client]bool),
		redis:    rdb,
		redisCtx: context.Background(),
	}
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

func (h *Hub) StartRedisListener() {
	if h.redis == nil {
		return
	}
	pubsub := h.redis.PSubscribe(h.redisCtx, "flags:*")
	defer pubsub.Close()
	ch := pubsub.Channel()
	for msg := range ch {
		var payload struct {
			LicenseKey    string      `json:"license_key"`
			EnvironmentID string      `json:"environment_id"`
			FlagKey       string      `json:"flag_key"`
			Enabled       bool        `json:"enabled"`
			Variant       interface{} `json:"variant,omitempty"`
			Action        string      `json:"action"`
		}
		if err := json.Unmarshal([]byte(msg.Payload), &payload); err != nil {
			continue
		}
		switch payload.Action {
		case "toggle":
			h.BroadcastFlagUpdate(payload.LicenseKey, payload.EnvironmentID, payload.FlagKey, payload.Enabled, payload.Variant)
		case "delete":
			h.BroadcastFlagDelete(payload.LicenseKey, payload.EnvironmentID, payload.FlagKey)
		}
	}
}

func (h *Hub) PublishToggle(licenseKey, environmentID, flagKey string, enabled bool, variant interface{}) {
	if h.redis == nil {
		return
	}
	data, _ := json.Marshal(map[string]interface{}{
		"license_key": licenseKey, "environment_id": environmentID,
		"flag_key": flagKey, "enabled": enabled, "variant": variant, "action": "toggle",
	})
	h.redis.Publish(h.redisCtx, "flags:"+licenseKey+":"+environmentID, data)
}

func (h *Hub) PublishDelete(licenseKey, environmentID, flagKey string) {
	if h.redis == nil {
		return
	}
	data, _ := json.Marshal(map[string]interface{}{
		"license_key": licenseKey, "environment_id": environmentID,
		"flag_key": flagKey, "action": "delete",
	})
	h.redis.Publish(h.redisCtx, "flags:"+licenseKey+":"+environmentID, data)
}
