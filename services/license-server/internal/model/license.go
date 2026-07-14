package model

import "time"

type License struct {
	ID             string     `json:"id"`
	UserID         string     `json:"user_id"`
	LicenseKey     string     `json:"license_key"`
	LicenseType    string     `json:"license_type"`
	Status         string     `json:"status"`
	MaxActivations int        `json:"max_activations"`
	ExpiresAt      *time.Time `json:"expires_at,omitempty"`
	CreatedAt      time.Time  `json:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at"`
}

type Activation struct {
	ID          string    `json:"id"`
	LicenseID   string    `json:"license_id"`
	DeviceID    string    `json:"device_id"`
	DeviceName  string    `json:"device_name"`
	IPAddress   string    `json:"ip_address,omitempty"`
	ActivatedAt time.Time `json:"activated_at"`
	LastSeenAt  time.Time `json:"last_seen_at"`
}
