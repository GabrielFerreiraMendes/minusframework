# Task 3 Report: WebSocket Hub + Connection Token

**Status:** Complete
**Commit:** `5fafa39` — feat: add WebSocket hub with connection token auth

## Files Created

- `services/feature-flags/internal/service/hub.go` — Client/room management with Register, Unregister, Broadcast, BroadcastFlagUpdate, BroadcastFlagDelete
- `services/feature-flags/internal/handler/ws.go` — Token issue (API Key protected, 30s TTL), WebSocket upgrade with JWT validation, ping/pong keepalive

## Files Modified

- `services/feature-flags/cmd/server/main.go` — Hub initialization, ws routes (`POST /api/v1/ws/token` under API Key group, `GET /ws` public)
- `services/feature-flags/go.mod` / `go.sum` — Added `github.com/gorilla/websocket v1.5.3`

## Verification

- `go build ./...` from `services/feature-flags/` — **PASSED**

## Architecture Notes

- `POST /api/v1/ws/token` — protected by `APIKeyRequired` middleware (Task 2), issues a JWT with 30s TTL containing `license_key` and `environment_id`
- `GET /ws` — public, validates the token from query param, upgrades to WebSocket, registers client in the Hub per `license_key:environment_id` room
- Hub rooms map `license_key:environment_id` to a set of connected clients
- writePump sends initial flag state on connect + periodic pings every 30s
- readPump handles pong responses with 60s deadline, unregisters on disconnect
