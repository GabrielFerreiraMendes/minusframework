.PHONY: run test migrate

run:
	go run ./cmd/server

test:
	go test ./...

migrate:
	psql "$(DATABASE_URL)" -f migrations/001_initial.sql
	psql "$(DATABASE_URL)" -f migrations/002_audit_log.sql
