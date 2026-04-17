#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config
# -----------------------------

# Pattern for the system audio source, usually a monitor source
# e.g. bluez_output.CC_41_AB_02_98_41.1.monitor
SYSTEM_PATTERN="bluez_output.*\.monitor"

# Pattern for the microphone source, real input, not monitor
# e.g.  alsa_output.usb-Samson_Technologies_Samson_Q2U_Microphone-00.analog-stereo.monitor
MIC_PATTERN="Q2U"

# Output format: wav or mp3
FORMAT="mp3"

# MP3 quality, only used when FORMAT=mp3
# 2 is very good VBR quality
MP3_QUALITY="2"

# Target directory
OUT_DIR="./call-recordings"

# -----------------------------
# Resolve devices
# -----------------------------

mkdir -p "$OUT_DIR"

SYSTEM_SOURCE="$(pactl list short sources | awk '{print $2}' | grep -E "$SYSTEM_PATTERN" | head -n 1)"
MIC_SOURCE="$(pactl list short sources | awk '{print $2}' | grep -E "$MIC_PATTERN" | grep -v "\.monitor$" | head -n 1)"

if [[ -z "${SYSTEM_SOURCE}" ]]; then
  echo "Could not find system source"
  exit 1
fi

if [[ -z "${MIC_SOURCE}" ]]; then
  echo "Could not find mic source"
  exit 1
fi

TIMESTAMP="$(date +%F-%H%M%S)"
BASE="${OUT_DIR}/call-${TIMESTAMP}"

echo "System source: $SYSTEM_SOURCE"
echo "Mic source:    $MIC_SOURCE"
echo "Output dir:    $OUT_DIR"
echo

# -----------------------------
# Start recording
# -----------------------------

if [[ "$FORMAT" == "wav" ]]; then
  SYSTEM_FILE="${BASE}-system.wav"
  MIC_FILE="${BASE}-mic.wav"

  ffmpeg \
    -hide_banner \
    -loglevel info \
    -f pulse -i "$SYSTEM_SOURCE" \
    -f pulse -i "$MIC_SOURCE" \
    -map 0:a -c:a pcm_s16le "$SYSTEM_FILE" \
    -map 1:a -c:a pcm_s16le "$MIC_FILE"

elif [[ "$FORMAT" == "mp3" ]]; then
  SYSTEM_FILE="${BASE}-system.mp3"
  MIC_FILE="${BASE}-mic.mp3"

  ffmpeg \
    -hide_banner \
    -loglevel info \
    -f pulse -i "$SYSTEM_SOURCE" \
    -f pulse -i "$MIC_SOURCE" \
    -map 0:a -c:a libmp3lame -q:a "$MP3_QUALITY" "$SYSTEM_FILE" \
    -map 1:a -c:a libmp3lame -q:a "$MP3_QUALITY" "$MIC_FILE"

else
  echo "Unsupported FORMAT: $FORMAT"
  echo "Use wav or mp3"
  exit 1
fi