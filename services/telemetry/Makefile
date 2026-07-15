.PHONY: run test migrate

run:
	go run ./cmd/server

test:
	go test ./...

migrate:
	psql "$(DATABASE_URL)" -f migrations/001_spans.sql
	psql "$(DATABASE_URL)" -f migrations/002_metrics.sql
