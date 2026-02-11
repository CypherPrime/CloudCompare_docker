#!/usr/bin/env bash
set -eo pipefail

# Virtual display
export DISPLAY=:1
XVFB_W=1280
XVFB_H=800
XVFB_D=24

# Start Xvfb (virtual framebuffer)
Xvfb ${DISPLAY} -screen 0 ${XVFB_W}x${XVFB_H}x${XVFB_D} -nolisten tcp &
XVFB_PID=$!
sleep 1

# Lightweight WM and terminal
fluxbox &
sleep 0.5
xterm -geometry 120x30+10+10 &

# Auto-run CloudCompare if requested
if [ "${RUN_CLOUDCOMPARE:-}" = "1" ]; then
  xterm -geometry 120x30+10+420 -e bash -lc "CloudCompare -O /data/* 2>&1" &
fi

# Run CloudCompare in headless mode (batch processing)
if [ "${HEADLESS_MODE:-}" = "1" ]; then
  # This mode assumes a script or command is provided via environment
  if [ -n "${CC_BATCH_SCRIPT:-}" ]; then
    echo "Running CloudCompare in headless mode with script: ${CC_BATCH_SCRIPT}"
    CloudCompare -BATCH -SILENT -SCRIPT "${CC_BATCH_SCRIPT}" 2>&1
  else
    echo "Headless mode enabled but no CC_BATCH_SCRIPT provided"
    echo "To use headless mode, set CC_BATCH_SCRIPT environment variable"
  fi
fi

# VNC server (on :5900)
x11vnc -display ${DISPLAY} -rfbport 5900 -forever -shared -nopw -repeat -xkb -ncache 10 &
VNC_PID=$!
sleep 1

# noVNC on 6080 (via websockify)
if command -v websockify >/dev/null 2>&1; then
  websockify --web /usr/share/novnc 6080 localhost:5900 &
  NOVNC_PID=$!
else
  echo "websockify not found; ensure 'websockify' is installed" >&2
  exit 127
fi

# Trap and keep foreground
cleanup() {
  kill -TERM ${NOVNC_PID} ${VNC_PID} ${XVFB_PID} || true
}
trap cleanup EXIT

# Show helpful message
cat <<EOF

========================================
CloudCompare VNC/noVNC Server
========================================
noVNC is running at: http://localhost:6080
VNC Server: localhost:5900

Usage:
  - GUI Mode: Access via browser at http://localhost:6080
  - Open files from /data mount point
  - Use xterm to run CloudCompare commands

Quick Commands:
  CloudCompare                           # Launch GUI
  CloudCompare -O /data/file.las         # Open file directly
  CloudCompare -BATCH -SILENT -AUTO_EXIT # Batch mode

Environment Variables:
  RUN_CLOUDCOMPARE=1                    # Auto-launch on startup
  HEADLESS_MODE=1                       # Enable headless processing
  CC_BATCH_SCRIPT=/path/to/script.ccscript  # Batch script

========================================

EOF

# Keep container alive by waiting on noVNC
wait ${NOVNC_PID}
