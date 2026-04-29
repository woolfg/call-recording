# Linux Call Recorder

Record arbitrary video calls on Linux by capturing audio directly from your microphone and your headphone or speaker output, independent of the video call platform.

## Why this exists

On Linux, different video call tools behave differently. Some are browser-based, some are native apps, some expose audio devices in odd ways, and some are just annoying to automate consistently.

The idea of this project is simple:

- connect directly to the **microphone input**
- connect directly to the **headphone or speaker output monitor**
- record both into **separate audio files**
- work with **any video call platform** because the recorder does not care whether the call happens in Zoom, Google Meet, Teams, Jitsi, Slack, Discord, or anything else

This gives you a generic building block for later processing, for example:

- transcription
- summarization
- speaker separation workflows
- archiving important calls
- post-processing with your own scripts or AI tools

## How it works

The script uses:

- `pactl` to discover audio sources from PulseAudio or PipeWire
- `grep` patterns to find the correct microphone and output monitor devices
- `ffmpeg` to record both streams at the same time
- timestamp-based filenames so every recording is stored with its start time

Instead of recording from a specific video conferencing application, the script records:

1. **your microphone**
2. **your active system output**, usually the monitor of your Bluetooth headphones, USB headset, speakers, or other playback device

Because of that, it works across platforms and applications.

## Features

- records **mic** and **system output** separately
- configurable matching of devices via standard `grep` patterns
- timestamped output filenames
- simple start command:

  ```bash
  ./start_recording.sh
  ```

  or

  ```bash
  make start
  ```

## Merge mic and system audio

After recording, combine the two generated tracks into one MP3:

```bash
make merge
```

By default this merges the latest matching `call-*-mic.mp3` and
`call-*-system.mp3` pair from `call-recordings/` and writes:

```text
call-recordings/call-YYYY-MM-DD-HHMMSS-merged.mp3
```

To merge a specific recording:

```bash
make merge BASE=call-2026-04-29-101120
```

You can also pass a full base path or set a custom output:

```bash
make merge BASE=call-recordings/call-2026-04-29-101120 OUT=call-recordings/call-2026-04-29-101120-mix.mp3
```
