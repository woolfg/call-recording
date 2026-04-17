.DEFAULT_GOAL := help

.PHONY: help start

help:
	@echo "Available commands:"
	@echo "  make start  - Start recording both mic and system audio"
	@echo "  make help   - Show this help message"

start:
	./start_recording.sh
