package service

import (
	"context"
	"log"
	"time"

	"github.com/GabrielFerreiraMendes/minusframework/services/telemetry/internal/store"
)

type Aggregator struct {
	store    *store.Store
	interval time.Duration
	stopCh   chan struct{}
}

func NewAggregator(s *store.Store) *Aggregator {
	return &Aggregator{
		store:    s,
		interval: time.Hour,
		stopCh:   make(chan struct{}),
	}
}

func (a *Aggregator) Start(ctx context.Context) {
	ticker := time.NewTicker(a.interval)
	defer ticker.Stop()

	a.runOnce(ctx)

	for {
		select {
		case <-ticker.C:
			a.runOnce(ctx)
		case <-a.stopCh:
			log.Println("Aggregator stopped")
			return
		}
	}
}

func (a *Aggregator) Stop() {
	close(a.stopCh)
}

func (a *Aggregator) runOnce(ctx context.Context) {
	log.Println("Running hourly aggregation...")

	_, err := a.store.Exec(ctx,
		`INSERT INTO spans_hourly (hour, license_key, service_name, operation_name, count, error_count, p50_ms, p95_ms, p99_ms)
         SELECT
           date_trunc('hour', start_time) as hour,
           license_key,
           service_name,
           operation_name,
           COUNT(*) as count,
           COUNT(*) FILTER (WHERE status = 'error') as error_count,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY duration_ms) as p50_ms,
           percentile_cont(0.95) WITHIN GROUP (ORDER BY duration_ms) as p95_ms,
           percentile_cont(0.99) WITHIN GROUP (ORDER BY duration_ms) as p99_ms
         FROM spans
         WHERE start_time >= date_trunc('hour', now() - interval '1 hour')
           AND start_time < date_trunc('hour', now())
         GROUP BY hour, license_key, service_name, operation_name
         ON CONFLICT (hour, license_key, service_name, operation_name) DO NOTHING`,
	)
	if err != nil {
		log.Printf("Span aggregation failed: %v", err)
	}

	_, err = a.store.Exec(ctx,
		`INSERT INTO metrics_hourly (hour, license_key, metric_name, metric_type, sum, count, min, max, avg)
         SELECT
           date_trunc('hour', timestamp) as hour,
           license_key,
           metric_name,
           metric_type,
           SUM(value) as sum,
           COUNT(*) as count,
           MIN(value) as min,
           MAX(value) as max,
           AVG(value) as avg
         FROM metrics
         WHERE timestamp >= date_trunc('hour', now() - interval '1 hour')
           AND timestamp < date_trunc('hour', now())
         GROUP BY hour, license_key, metric_name, metric_type
         ON CONFLICT (hour, license_key, metric_name, metric_type) DO NOTHING`,
	)
	if err != nil {
		log.Printf("Metric aggregation failed: %v", err)
	}

	log.Println("Aggregation complete")
}
