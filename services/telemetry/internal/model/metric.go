package model

import "time"

type Metric struct {
	ID         string            `json:"id,omitempty"`
	LicenseKey string            `json:"-"`
	MetricName string            `json:"metric_name" binding:"required"`
	MetricType string            `json:"metric_type" binding:"required"`
	Value      float64           `json:"value" binding:"required"`
	Tags       map[string]string `json:"tags,omitempty"`
	Timestamp  time.Time         `json:"timestamp" binding:"required"`
	CreatedAt  time.Time         `json:"created_at,omitempty"`
}
