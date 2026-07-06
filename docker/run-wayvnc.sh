#!/bin/bash
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
wayland_display="${WAYLAND_DISPLAY:-wayland-0}"
wayvnc_config="/tmp/wayvnc/config"

export XDG_RUNTIME_DIR="$runtime_dir"
export WAYLAND_DISPLAY="$wayland_display"
export WLR_BACKENDS="${WLR_BACKENDS:-headless}"
export WLR_HEADLESS_OUTPUTS="${WLR_HEADLESS_OUTPUTS:-1}"
export WLR_LIBINPUT_NO_DEVICES="${WLR_LIBINPUT_NO_DEVICES:-1}"
export WLR_RENDERER="${WLR_RENDERER:-pixman}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"

cage_pid=""
wayvnc_pid=""
websockify_pid=""

cleanup() {
    local pid

    for pid in "$websockify_pid" "$wayvnc_pid" "$cage_pid"; do
        if [ -n "$pid" ]; then
            kill "$pid" 2>/dev/null || true
        fi
    done

    for pid in "$websockify_pid" "$wayvnc_pid" "$cage_pid"; do
        if [ -n "$pid" ]; then
            wait "$pid" 2>/dev/null || true
        fi
    done
}

trap 'cleanup; exit 0' INT TERM

install -d -m 700 "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

rm -f "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"

dbus-run-session -- cage -- /opt/vnc/app-session.sh &
cage_pid=$!

for _ in {1..100}; do
    if [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
        break
    fi

    if ! kill -0 "$cage_pid" 2>/dev/null; then
        wait "$cage_pid" 2>/dev/null || true
        echo "Cage exited before creating the Wayland socket." >&2
        exit 70
    fi

    sleep 0.1
done

if [ ! -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
    echo "Timed out waiting for Wayland socket: $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" >&2
    cleanup
    exit 70
fi

wayvnc --config="$wayvnc_config" &
wayvnc_pid=$!

websockify --web /usr/share/novnc 6080 localhost:5900 &
websockify_pid=$!

# Restart the container if any part of the display pipeline exits.
wait -n "$cage_pid" "$wayvnc_pid" "$websockify_pid" || true

cleanup

# Non-zero so Compose can use restart: on-failure.
exit 42
