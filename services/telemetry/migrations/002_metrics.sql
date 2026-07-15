CREATE TABLE metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_key TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    metric_type TEXT NOT NULL,
    value NUMERIC NOT NULL,
    tags JSONB DEFAULT '{}',
    timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE metrics_hourly (
    hour TIMESTAMPTZ NOT NULL,
    license_key TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    metric_type TEXT NOT NULL,
    sum NUMERIC NOT NULL,
    count INT NOT NULL DEFAULT 0,
    min NUMERIC,
    max NUMERIC,
    avg NUMERIC
);

CREATE INDEX idx_metrics_time ON metrics(license_key, metric_name, timestamp DESC);
