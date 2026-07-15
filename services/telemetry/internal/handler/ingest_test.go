package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/GabrielFerreiraMendes/minusframework/services/telemetry/internal/middleware"
	"github.com/GabrielFerreiraMendes/minusframework/services/telemetry/internal/model"
)

type mockStore struct {
	validateFn func(ctx context.Context, licenseKey string) (bool, error)
	insertFn   func(ctx context.Context, spans []model.Span) error
	metricFn   func(ctx context.Context, m *model.Metric) error
}

func (m *mockStore) BatchInsertSpans(ctx context.Context, spans []model.Span) error {
	if m.insertFn != nil {
		return m.insertFn(ctx, spans)
	}
	return nil
}

func (m *mockStore) InsertMetric(ctx context.Context, metric *model.Metric) error {
	if m.metricFn != nil {
		return m.metricFn(ctx, metric)
	}
	return nil
}

type mockLicenseValidator struct {
	validateFn func(ctx context.Context, licenseKey string) (bool, error)
}

func (m *mockLicenseValidator) ValidateLicenseKey(ctx context.Context, licenseKey string) (bool, error) {
	if m.validateFn != nil {
		return m.validateFn(ctx, licenseKey)
	}
	return true, nil
}

func setupRouter(store Store, validator middleware.LicenseValidator) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewIngestHandler(store)
	r.GET("/api/v1/config", h.GetConfig)
	ingest := r.Group("/v1", middleware.APIKeyRequired(validator))
	ingest.POST("/traces", h.IngestTraces)
	ingest.POST("/metrics", h.IngestMetrics)
	return r
}

func TestIngestTracesMissingAPIKey(t *testing.T) {
	r := setupRouter(&mockStore{}, &mockLicenseValidator{})

	body := `{"trace_id":"abc","spans":[]}`
	req := httptest.NewRequest("POST", "/v1/traces", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 Unauthorized, got %d", w.Code)
	}
}

func TestIngestTracesInvalidAPIKey(t *testing.T) {
	validator := &mockLicenseValidator{
		validateFn: func(ctx context.Context, licenseKey string) (bool, error) {
			return false, nil
		},
	}
	r := setupRouter(&mockStore{}, validator)

	body := `{"trace_id":"abc","spans":[]}`
	req := httptest.NewRequest("POST", "/v1/traces", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", "INVALID-KEY")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusForbidden {
		t.Fatalf("expected 403 Forbidden, got %d", w.Code)
	}
}

func TestIngestTracesBadBody(t *testing.T) {
	validator := &mockLicenseValidator{
		validateFn: func(ctx context.Context, licenseKey string) (bool, error) {
			return true, nil
		},
	}
	r := setupRouter(&mockStore{}, validator)

	body := `{invalid json`
	req := httptest.NewRequest("POST", "/v1/traces", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", "MF-TEST-KEY")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 BadRequest, got %d", w.Code)
	}
}

func TestIngestTracesStoreError(t *testing.T) {
	store := &mockStore{
		insertFn: func(ctx context.Context, spans []model.Span) error {
			return assertAnError("db error")
		},
	}
	validator := &mockLicenseValidator{
		validateFn: func(ctx context.Context, licenseKey string) (bool, error) {
			return true, nil
		},
	}
	r := setupRouter(store, validator)

	body := `{"trace_id":"abc","spans":[{"span_id":"s1","operation_name":"op","service_name":"svc","span_kind":"internal","start_time":"2026-07-15T00:00:00Z","end_time":"2026-07-15T00:01:00Z"}]}`
	req := httptest.NewRequest("POST", "/v1/traces", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", "MF-TEST-KEY")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500 InternalServerError, got %d", w.Code)
	}
}

func TestIngestMetricsSuccess(t *testing.T) {
	store := &mockStore{
		insertFn: func(ctx context.Context, spans []model.Span) error {
			return nil
		},
		metricFn: func(ctx context.Context, m *model.Metric) error {
			return nil
		},
	}
	validator := &mockLicenseValidator{
		validateFn: func(ctx context.Context, licenseKey string) (bool, error) {
			return true, nil
		},
	}
	r := setupRouter(store, validator)

	metric := map[string]interface{}{
		"metric_name": "requests_total",
		"metric_type": "counter",
		"value":       1.0,
		"tags":        map[string]string{"method": "GET"},
		"timestamp":   "2026-07-15T00:00:00Z",
	}
	body, _ := json.Marshal(metric)
	req := httptest.NewRequest("POST", "/v1/metrics", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", "MF-TEST-KEY")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", w.Code)
	}

	var resp map[string]interface{}
	json.NewDecoder(w.Body).Decode(&resp)
	if resp["accepted"] != true {
		t.Fatalf("expected accepted=true, got %v", resp["accepted"])
	}
}

func TestIngestMetricsMissingAPIKey(t *testing.T) {
	r := setupRouter(&mockStore{}, &mockLicenseValidator{})

	body := `{"metric_name":"test","metric_type":"counter","value":1,"timestamp":"2026-07-15T00:00:00Z"}`
	req := httptest.NewRequest("POST", "/v1/metrics", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 Unauthorized, got %d", w.Code)
	}
}

func TestGetConfigPublic(t *testing.T) {
	r := setupRouter(&mockStore{}, &mockLicenseValidator{})

	req := httptest.NewRequest("GET", "/api/v1/config", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", w.Code)
	}

	var resp map[string]interface{}
	json.NewDecoder(w.Body).Decode(&resp)
	if resp["flush_interval_seconds"] != float64(60) {
		t.Fatalf("expected flush_interval_seconds=60, got %v", resp["flush_interval_seconds"])
	}
	if resp["max_batch_size"] != float64(100) {
		t.Fatalf("expected max_batch_size=100, got %v", resp["max_batch_size"])
	}
	if resp["version"] != "1.0" {
		t.Fatalf("expected version=1.0, got %v", resp["version"])
	}
}

type customError struct{ msg string }

func (e *customError) Error() string { return e.msg }

func assertAnError(msg string) error {
	return &customError{msg: msg}
}
