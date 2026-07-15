CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE spans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_key TEXT NOT NULL,
    trace_id TEXT NOT NULL,
    span_id TEXT NOT NULL,
    parent_span_id TEXT,
    operation_name TEXT NOT NULL,
    service_name TEXT NOT NULL,
    span_kind TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    duration_ms NUMERIC GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (end_time - start_time)) * 1000
    ) STORED,
    status TEXT NOT NULL DEFAULT 'ok',
    tags JSONB DEFAULT '{}',
    events JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE spans_hourly (
    hour TIMESTAMPTZ NOT NULL,
    license_key TEXT NOT NULL,
    service_name TEXT NOT NULL,
    operation_name TEXT NOT NULL,
    count INT NOT NULL DEFAULT 0,
    error_count INT NOT NULL DEFAULT 0,
    p50_ms NUMERIC,
    p95_ms NUMERIC,
    p99_ms NUMERIC
);

CREATE INDEX idx_spans_trace ON spans(license_key, trace_id);
CREATE INDEX idx_spans_time ON spans(license_key, start_time DESC);
CREATE INDEX idx_spans_errors ON spans(license_key, status) WHERE status = 'error';
