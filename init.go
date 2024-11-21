package main

import (
	"github.com/joho/godotenv"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func init() {
	initLogger()
	initEnviron()
}

func initLogger() {
	// initialize logger
	config := zap.NewProductionConfig()
	config.Encoding = "console"
	config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	config.EncoderConfig.EncodeTime = zapcore.RFC3339TimeEncoder
	config.OutputPaths = []string{"stdout"}
	config.ErrorOutputPaths = []string{"stderr"}

	logger, _ := config.Build()

	zap.ReplaceGlobals(logger)
}

func initEnviron() {
	// check .env file
	if err := godotenv.Load(); err != nil {
		zap.S().Warn("No .env file found")
	} else {
		zap.S().Info("Loaded .env file")
	}
}
