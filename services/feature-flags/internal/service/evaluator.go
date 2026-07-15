package service

import (
	"hash/crc32"
)

type Context struct {
	UserID  string
	GroupID string
}

type Evaluator struct{}

func NewEvaluator() *Evaluator { return &Evaluator{} }

func (e *Evaluator) IsEnabled(licenseKey, flagKey string, rolloutPercentage int, ctx Context) bool {
	if rolloutPercentage >= 100 {
		return true
	}
	if rolloutPercentage <= 0 {
		return false
	}
	return e.Bucket(licenseKey, flagKey, ctx.UserID) < rolloutPercentage
}

func (e *Evaluator) Bucket(licenseKey, flagKey, userID string) int {
	key := licenseKey + ":" + flagKey + ":" + userID
	hash := crc32.ChecksumIEEE([]byte(key))
	return int(hash % 100)
}
