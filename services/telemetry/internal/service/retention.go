package service

import (
	"context"
	"log"
	"time"

	"github.com/GabrielFerreiraMendes/minusframework/services/telemetry/internal/store"
)

type Retention struct {
	store *store.Store
}

func NewRetention(s *store.Store) *Retention {
	return &Retention{store: s}
}

func (r *Retention) Run(ctx context.Context) {
	tiers := []struct {
		days int
		tier string
	}{
		{7, "starter"},
		{30, "pro"},
	}

	for _, t := range tiers {
		deleted, err := r.store.Exec(ctx,
			`DELETE FROM spans
             WHERE license_key IN (
               SELECT license_key FROM subscriptions
               WHERE plan_tier = $1 AND status = 'active'
             )
             AND start_time < now() - make_interval(days => $2)`,
			t.tier, t.days,
		)
		if err != nil {
			log.Printf("Retention cleanup for %s failed: %v", t.tier, err)
		} else if deleted > 0 {
			log.Printf("Deleted %d old spans for %s tier", deleted, t.tier)
		}
	}
}
