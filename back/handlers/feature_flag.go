package handlers

import (
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
	"sync"
)

var mutex = &sync.Mutex{}

type FeatureFlagHandler struct {
	featureFlagService *services.FeatureFlagService
}

func NewFeatureFlagHandler(db *gorm.DB) *FeatureFlagHandler {
	featureFlagService := services.NewFeatureFlagService(db)
	return &FeatureFlagHandler{featureFlagService: featureFlagService}
}

func (h *FeatureFlagHandler) GetFeatureFlag(c *gin.Context) {
	featureName := c.Param("name")
	mutex.Lock()
	defer mutex.Unlock()
	flag, err := h.featureFlagService.GetFeatureFlag(featureName)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Feature flag not found"})
	} else {
		c.JSON(http.StatusOK, gin.H{featureName: flag})
	}
}

func (h *FeatureFlagHandler) SetFeatureFlag(c *gin.Context) {
	featureName := c.Param("name")
	var flag bool
	if err := c.ShouldBindJSON(&flag); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	mutex.Lock()
	defer mutex.Unlock()
	err := h.featureFlagService.SetFeatureFlag(featureName, flag)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	} else {
		c.Status(http.StatusNoContent)
	}
}

func (h *FeatureFlagHandler) GetFeatureFlags(c *gin.Context) {
	mutex.Lock()
	defer mutex.Unlock()
	flags, err := h.featureFlagService.GetFeatureFlags()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err})
	} else {
		c.JSON(http.StatusOK, flags)
	}
}
