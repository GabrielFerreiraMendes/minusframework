package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/GabrielFerreiraMendes/minusframework/services/feature-flags/internal/model"
	"github.com/GabrielFerreiraMendes/minusframework/services/feature-flags/internal/service"
	"github.com/GabrielFerreiraMendes/minusframework/services/feature-flags/internal/store"
)

type FlagHandler struct {
	store *store.Store
	hub   *service.Hub
}

func NewFlagHandler(s *store.Store, h *service.Hub) *FlagHandler {
	return &FlagHandler{store: s, hub: h}
}

func (h *FlagHandler) List(c *gin.Context) {
	userID, _ := c.Get("user_id")
	licenseKey, err := h.store.GetLicenseKeyByUserID(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to resolve license key"})
		return
	}
	envID := c.Query("environment_id")
	flags, err := h.store.ListFlags(c.Request.Context(), licenseKey, envID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to list flags"})
		return
	}
	c.JSON(http.StatusOK, flags)
}

func (h *FlagHandler) Create(c *gin.Context) {
	var req model.CreateFlagRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	userID, _ := c.Get("user_id")
	licenseKey, err := h.store.GetLicenseKeyByUserID(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to resolve license key"})
		return
	}
	flag := &model.Flag{
		LicenseKey: licenseKey,
		Key: req.Key, Name: req.Name, Description: req.Description,
		FlagType: req.FlagType, DefaultVariant: req.DefaultVariant,
	}
	exists, err := h.store.FlagKeyExists(c.Request.Context(), licenseKey, req.Key)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to check flag key"})
		return
	}
	if exists {
		c.JSON(http.StatusConflict, gin.H{"error": "flag key already exists"})
		return
	}
	if err := h.store.CreateFlag(c.Request.Context(), flag); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create flag"})
		return
	}
	h.store.CreateAuditLog(c.Request.Context(), licenseKey, nil, "flag.created", "flag", flag.ID, nil, flag)
	c.JSON(http.StatusCreated, flag)
}

func (h *FlagHandler) Update(c *gin.Context) {
	id := c.Param("id")
	var req model.CreateFlagRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	flag := &model.Flag{ID: id, Key: req.Key, Name: req.Name, Description: req.Description, FlagType: req.FlagType, DefaultVariant: req.DefaultVariant}
	if err := h.store.UpdateFlag(c.Request.Context(), flag); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update flag"})
		return
	}
	c.JSON(http.StatusOK, flag)
}

func (h *FlagHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	userID, _ := c.Get("user_id")
	licenseKey, err := h.store.GetLicenseKeyByUserID(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to resolve license key"})
		return
	}
	if err := h.store.DeleteFlag(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete flag"})
		return
	}
	h.store.CreateAuditLog(c.Request.Context(), licenseKey, nil, "flag.deleted", "flag", id, nil, nil)
	c.JSON(http.StatusOK, gin.H{"status": "deleted"})
}

type toggleRequest struct {
	Enabled           bool   `json:"enabled"`
	EnvironmentID     string `json:"environment_id" binding:"required"`
	RolloutPercentage *int   `json:"rollout_percentage,omitempty"`
}

func (h *FlagHandler) Toggle(c *gin.Context) {
	id := c.Param("id")
	var req toggleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	userID, _ := c.Get("user_id")
	licenseKey, err := h.store.GetLicenseKeyByUserID(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to resolve license key"})
		return
	}
	rollout := 100
	if req.RolloutPercentage != nil {
		rollout = *req.RolloutPercentage
	}
	flag, err := h.store.GetFlagByID(c.Request.Context(), id, licenseKey)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "flag not found"})
		return
	}
	value := &model.FlagValue{FlagID: id, EnvironmentID: req.EnvironmentID, Enabled: req.Enabled, RolloutPercentage: rollout}
	if err := h.store.UpsertFlagValue(c.Request.Context(), value); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update flag value"})
		return
	}
	h.hub.PublishToggle(licenseKey, req.EnvironmentID, flag.Key, req.Enabled, nil)
	h.store.CreateAuditLog(c.Request.Context(), licenseKey, nil, "flag.toggled", "flag_value", value.ID, nil, value)
	c.JSON(http.StatusOK, value)
}
