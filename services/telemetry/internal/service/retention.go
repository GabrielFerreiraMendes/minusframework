package service

import (
	"context"
	"log"
	"time"

	"github.com/GabrielFerreiraMendes/minusframework/services/telemetry/internal/store"
)

type Retention struct {
	store  *store.Store
	stopCh chan struct{}
}

func NewRetention(s *store.Store) *Retention {
	return &Retention{
		store:  s,
		stopCh: make(chan struct{}),
	}
}

func (r *Retention) Start(ctx context.Context) {
	ticker := time.NewTicker(24 * time.Hour)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			r.runOnce(ctx)
		case <-r.stopCh:
			log.Println("Retention stopped")
			return
		}
	}
}

func (r *Retention) Stop() {
	close(r.stopCh)
}

func (r *Retention) runOnce(ctx context.Context) {
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
			log.Printf("Retention cleanup (spans) for %s failed: %v", t.tier, err)
		} else if deleted > 0 {
			log.Printf("Deleted %d old spans for %s tier", deleted, t.tier)
		}

		metricsDeleted, err := r.store.Exec(ctx,
			`DELETE FROM metrics
             WHERE license_key IN (
               SELECT license_key FROM subscriptions
               WHERE plan_tier = $1 AND status = 'active'
             )
             AND timestamp < now() - make_interval(days => $2)`,
			t.tier, t.days,
		)
		if err != nil {
			log.Printf("Retention cleanup (metrics) for %s failed: %v", t.tier, err)
		} else if metricsDeleted > 0 {
			log.Printf("Deleted %d old metrics for %s tier", metricsDeleted, t.tier)
		}
	}
}
