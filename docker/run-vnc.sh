#!/bin/sh
set -u

vnc_pid=""
novnc_pid=""

cleanup() {
    [ -n "$novnc_pid" ] && kill "$novnc_pid" 2>/dev/null || true
    [ -n "$vnc_pid" ] && kill "$vnc_pid" 2>/dev/null || true

    [ -n "$novnc_pid" ] && wait "$novnc_pid" 2>/dev/null || true
    [ -n "$vnc_pid" ] && wait "$vnc_pid" 2>/dev/null || true
}

trap 'cleanup; exit 0' INT TERM

vncserver -list -cleanstale >/dev/null 2>&1 || true

vncserver \
    -fg \
    -autokill yes \
    -PasswordFile /tmp/tigervnc/passwd \
    -xstartup /opt/vnc/xstartup \
    :1 &
vnc_pid=$!

sleep 0.5

/usr/share/novnc/utils/novnc_proxy \
    --vnc localhost:5901 \
    --listen 6080 &
novnc_pid=$!

# app-session.sh exits when VRCX-0 is minimized, hidden, or closed.
# TigerVNC then exits because -autokill is enabled.
wait "$vnc_pid" || true

cleanup

# Non-zero so Compose can use restart: on-failure.
exit 42
