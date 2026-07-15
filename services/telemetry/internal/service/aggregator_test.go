package service

import (
	"testing"
	"time"
)

func TestAggregatorInterval(t *testing.T) {
	agg := NewAggregator(nil)
	if agg.interval != time.Hour {
		t.Errorf("expected interval 1h, got %v", agg.interval)
	}
}
