### Task 4: Redis Pub/Sub + Rollout Evaluator

**Files:**
- Create: `services/feature-flags/internal/service/evaluator.go`
- Modify: `services/feature-flags/internal/service/hub.go` (Redis integration)
- Modify: `services/feature-flags/internal/handler/flags.go` (publish toggle via hub)
- Modify: `services/feature-flags/cmd/server/main.go` (start Redis listener)

---

### Step 1: Create service/evaluator.go

```go
package service

import (
    "hash/crc32"
)

type Context struct {
    UserID  string
    GroupID string
}

type Evaluator struct{}

func NewEvaluator() *Evaluator { return &Evaluator{} }

func (e *Evaluator) IsEnabled(licenseKey, flagKey string, rolloutPercentage int, ctx Context) bool {
    if rolloutPercentage >= 100 { return true }
    if rolloutPercentage <= 0 { return false }
    return e.Bucket(licenseKey, flagKey, ctx.UserID) < rolloutPercentage
}

func (e *Evaluator) Bucket(licenseKey, flagKey, userID string) int {
    key := licenseKey + ":" + flagKey + ":" + userID
    hash := crc32.ChecksumIEEE([]byte(key))
    return int(hash % 100)
}
```

### Step 2: Modify hub.go — add Redis pub/sub

Add these imports:
```go
import (
    "context"
    "github.com/redis/go-redis/v9"
)

type Hub struct {
    mu       sync.RWMutex
    rooms    map[string]map[*Client]bool
    redis    *redis.Client
    redisCtx context.Context
}

func NewHub(redisURL string) *Hub {
    opts, err := redis.ParseURL(redisURL)
    var rdb *redis.Client
    if err == nil { rdb = redis.NewClient(opts) }
    return &Hub{
        rooms:    make(map[string]map[*Client]bool),
        redis:    rdb,
        redisCtx: context.Background(),
    }
}

func (h *Hub) StartRedisListener() {
    if h.redis == nil { return }
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
        if err := json.Unmarshal([]byte(msg.Payload), &payload); err != nil { continue }
        switch payload.Action {
        case "toggle":
            h.BroadcastFlagUpdate(payload.LicenseKey, payload.EnvironmentID, payload.FlagKey, payload.Enabled, payload.Variant)
        case "delete":
            h.BroadcastFlagDelete(payload.LicenseKey, payload.EnvironmentID, payload.FlagKey)
        }
    }
}

func (h *Hub) PublishToggle(licenseKey, environmentID, flagKey string, enabled bool, variant interface{}) {
    if h.redis == nil { return }
    data, _ := json.Marshal(map[string]interface{}{
        "license_key": licenseKey, "environment_id": environmentID,
        "flag_key": flagKey, "enabled": enabled, "variant": variant, "action": "toggle",
    })
    h.redis.Publish(h.redisCtx, "flags:"+licenseKey+":"+environmentID, data)
}

func (h *Hub) PublishDelete(licenseKey, environmentID, flagKey string) {
    if h.redis == nil { return }
    data, _ := json.Marshal(map[string]interface{}{
        "license_key": licenseKey, "environment_id": environmentID,
        "flag_key": flagKey, "action": "delete",
    })
    h.redis.Publish(h.redisCtx, "flags:"+licenseKey+":"+environmentID, data)
}
```

### Step 3: Modify handler/flags.go — publish toggle via hub

Add `hub *service.Hub` field to FlagHandler:
```go
type FlagHandler struct {
    store *store.Store
    hub   *service.Hub
}

func NewFlagHandler(s *store.Store, h *service.Hub) *FlagHandler {
    return &FlagHandler{store: s, hub: h}
}
```

In the `Toggle` method, after `UpsertFlagValue` succeeds, add:
```go
h.hub.PublishToggle(licenseKey, req.EnvironmentID, existingFlag.Key, req.Enabled, nil)
```

Note: you need to get the flag's key from the DB or from `c.Param("id")`. Use `h.store.GetFlagByID(ctx, id)` or pass the flag key from the toggle request.

### Step 4: Modify main.go

Change `hub := service.NewHub()` to:
```go
redisURL := os.Getenv("REDIS_URL")
if redisURL == "" { redisURL = "redis://localhost:6379" }
hub := service.NewHub(redisURL)
go hub.StartRedisListener()
```

Update `handler.NewFlagHandler(db)` to `handler.NewFlagHandler(db, hub)`.

### Step 5: Build and commit

```bash
cd services/feature-flags && go build ./...
git add services/feature-flags/
git commit -m "feat: add rollout evaluator and Redis pub/sub broadcast"
```
