#!/bin/sh
set -eu

export NO_AT_BRIDGE="${NO_AT_BRIDGE:-1}"

/opt/app.AppImage --appimage-extract-and-run &
launcher_pid=$!

uid="$(id -u)"
process_name="${VRCX_PROCESS_NAME:-vrcx-0}"
seen_process=0

for _ in $(seq 1 300); do
    if pgrep -u "$uid" -x "$process_name" >/dev/null 2>&1; then
        seen_process=1
        break
    fi

    sleep 0.1
done

if [ "$seen_process" -ne 1 ]; then
    wait "$launcher_pid" 2>/dev/null || true
    echo "VRCX-0 process did not appear." >&2
    exit 70
fi

while pgrep -u "$uid" -x "$process_name" >/dev/null 2>&1; do
    sleep 0.5
done

wait "$launcher_pid" 2>/dev/null || true

echo "VRCX-0 process exited." >&2
