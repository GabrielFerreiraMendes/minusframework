### Task 4 Report: Redis Pub/Sub + Rollout Evaluator

**Commit:** `35f4a521`  
**Status:** Complete

---

**Files Created:**
- `services/feature-flags/internal/service/evaluator.go` — deterministic rollout evaluator using CRC32 hashing with `Context`, `Evaluator`, `IsEnabled`, and `Bucket` methods

**Files Modified:**
- `services/feature-flags/internal/service/hub.go` — added Redis client fields (`redis *redis.Client`, `redisCtx context.Context`), changed `NewHub()` to `NewHub(redisURL string)`, added `StartRedisListener`, `PublishToggle`, `PublishDelete` methods
- `services/feature-flags/internal/handler/flags.go` — added `hub *service.Hub` field to `FlagHandler`, updated `NewFlagHandler` to accept hub, publishes toggle events via `h.hub.PublishToggle()` after successful `UpsertFlagValue`
- `services/feature-flags/cmd/server/main.go` — reads `REDIS_URL` env var (defaults to `redis://localhost:6379`), passes to `NewHub`, starts `hub.StartRedisListener()` in goroutine, passes hub to `NewFlagHandler`
- `services/feature-flags/internal/store/postgres.go` — added `GetFlagByID` method for flag key lookup during toggle
- `services/feature-flags/go.mod` / `go.sum` — added `github.com/redis/go-redis/v9` dependency

**Key Design Decisions:**
- Redis is optional — `NewHub` handles parse errors gracefully (rdb = nil), and all Redis methods are no-ops when `h.redis == nil`
- `GetFlagByID` added to store to resolve flag key from ID during toggle publishing
- Redis listener uses `PSubscribe` with `flags:*` pattern to receive cross-instance toggle/delete events

**Verification:**
- `go build ./...` passes with no errors
