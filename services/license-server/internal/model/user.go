package model

import "time"

type User struct {
	ID          string    `json:"id"`
	GitHubID    string    `json:"github_id,omitempty"`
	Email       string    `json:"email"`
	DisplayName string    `json:"display_name"`
	AvatarURL   string    `json:"avatar_url,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
