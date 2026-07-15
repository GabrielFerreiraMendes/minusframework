package store

import (
	"context"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Store struct {
	pool *pgxpool.Pool
}

func NewPostgres(ctx context.Context, dsn string) (*Store, error) {
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}
	return &Store{pool: pool}, nil
}

func (s *Store) Close() {
	s.pool.Close()
}

func (s *Store) ValidateLicenseKey(ctx context.Context, licenseKey string) (bool, error) {
	var exists bool
	err := s.pool.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM licenses WHERE license_key = $1 AND status = 'active')`,
		licenseKey,
	).Scan(&exists)
	return exists, err
}

func (s *Store) Exec(ctx context.Context, sql string, args ...interface{}) (int64, error) {
	tag, err := s.pool.Exec(ctx, sql, args...)
	return tag.RowsAffected(), err
}

func (s *Store) Query(ctx context.Context, sql string, args ...interface{}) (pgx.Rows, error) {
	return s.pool.Query(ctx, sql, args...)
}
