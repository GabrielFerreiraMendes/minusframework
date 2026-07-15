package service

import (
	"testing"
)

func TestRetentionTTL(t *testing.T) {
	ret := NewRetention(nil)
	if ret == nil {
		t.Error("expected non-nil retention")
	}
}
