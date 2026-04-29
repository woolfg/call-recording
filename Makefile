.DEFAULT_GOAL := help

OUT_DIR ?= ./call-recordings

.PHONY: help start merge

help:
	@echo "Available commands:"
	@echo "  make start       - Start recording both mic and system audio"
	@echo "  make merge       - Merge the latest mic/system pair into one MP3"
	@echo "  make merge BASE=call-YYYY-MM-DD-HHMMSS"
	@echo "                   - Merge a specific recording pair"
	@echo "  make help        - Show this help message"

start:
	./start_recording.sh

merge:
	@base=""; \
	for candidate in $$(find "$(OUT_DIR)" -maxdepth 1 -type f -name 'call-*-mic.mp3' -printf '%f\n' | sed 's/-mic\.mp3$$//' | sort -r); do \
		if [ -f "$(OUT_DIR)/$$candidate-system.mp3" ]; then \
			base="$$candidate"; \
			break; \
		fi; \
	done; \
	if [ -n "$${BASE:-}" ]; then \
		base="$${BASE}"; \
	fi; \
	if [ -z "$$base" ]; then \
		echo "No mic/system recordings found in $(OUT_DIR)"; \
		exit 1; \
	fi; \
	case "$$base" in \
		*/*) ;; \
		*) base="$(OUT_DIR)/$$base" ;; \
	esac; \
	base="$${base%-mic.mp3}"; \
	base="$${base%-system.mp3}"; \
	base="$${base%-merged.mp3}"; \
	mic_file="$$base-mic.mp3"; \
	system_file="$$base-system.mp3"; \
	output_file="$${OUT:-$$base-merged.mp3}"; \
	if [ ! -f "$$mic_file" ]; then \
		echo "Missing mic file: $$mic_file"; \
		exit 1; \
	fi; \
	if [ ! -f "$$system_file" ]; then \
		echo "Missing system file: $$system_file"; \
		exit 1; \
	fi; \
	echo "Merging:"; \
	echo "  mic:    $$mic_file"; \
	echo "  system: $$system_file"; \
	echo "  output: $$output_file"; \
	ffmpeg -hide_banner -loglevel info -y \
		-i "$$mic_file" \
		-i "$$system_file" \
		-filter_complex "amix=inputs=2:duration=longest:dropout_transition=0" \
		-c:a libmp3lame -q:a 2 \
		"$$output_file"
