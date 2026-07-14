package store

import (
    "context"
    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/GabrielFerreiraMendes/minusframework/services/license-server/internal/model"
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
        return nil, err
    }
    return &Store{pool: pool}, nil
}

func (s *Store) Close() {
    s.pool.Close()
}

func (s *Store) UpsertUser(ctx context.Context, user *model.User) error {
    return s.pool.QueryRow(ctx,
        `INSERT INTO users (github_id, email, display_name, avatar_url)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (github_id) DO UPDATE SET
           email = EXCLUDED.email,
           display_name = EXCLUDED.display_name,
           avatar_url = EXCLUDED.avatar_url,
           updated_at = now()
         RETURNING id, created_at, updated_at`,
        user.GitHubID, user.Email, user.DisplayName, user.AvatarURL,
    ).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
}
