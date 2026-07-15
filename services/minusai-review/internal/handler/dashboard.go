package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/GabrielFerreiraMendes/minusframework/services/minusai-review/internal/store"
)

type DashboardHandler struct {
	store *store.Store
}

func NewDashboardHandler(s *store.Store) *DashboardHandler {
	return &DashboardHandler{store: s}
}

func (h *DashboardHandler) Index(c *gin.Context) {
	email, _ := c.Get("email")
	c.HTML(http.StatusOK, "index.html", gin.H{"email": email})
}

func (h *DashboardHandler) ReviewDetail(c *gin.Context) {
	id := c.Param("id")
	review, err := h.store.GetReview(c.Request.Context(), id)
	if err != nil {
		c.HTML(http.StatusNotFound, "error.html", gin.H{"error": "Review not found"})
		return
	}
	c.HTML(http.StatusOK, "review.html", gin.H{"review": review})
}
