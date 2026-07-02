#!/bin/sh
set -eu

is_visible() {
    window_id="$1"

    xwininfo -id "$window_id" -stats 2>/dev/null \
        | grep -q 'Map State: IsViewable' || return 1

    ! xprop -id "$window_id" _NET_WM_STATE 2>/dev/null \
        | grep -q '_NET_WM_STATE_HIDDEN'
}

window_area() {
    xwininfo -id "$1" -stats 2>/dev/null | awk '
        /Width:/  { width = $2 }
        /Height:/ { height = $2 }
        END {
            if (width && height) print width * height
            else print 0
        }
    '
}

largest_visible_client() {
    best_window=""
    best_area=0

    for window_id in $(wmctrl -l | awk '{print $1}'); do
        is_visible "$window_id" || continue

        area="$(window_area "$window_id")"

        if [ "$area" -gt "$best_area" ]; then
            best_window="$window_id"
            best_area="$area"
        fi
    done

    printf '%s\n' "$best_window"
}

openbox &

/opt/app.AppImage --appimage-extract-and-run &

main_window=""
candidate=""
stable_count=0
attempt=0

# Wait for the VRCX-0 main window to appear and remain stable.
while [ "$attempt" -lt 300 ]; do
    current="$(largest_visible_client || true)"

    if [ -n "$current" ] && [ "$current" = "$candidate" ]; then
        stable_count=$((stable_count + 1))
    else
        candidate="$current"
        stable_count=1
    fi

    if [ "$stable_count" -ge 10 ]; then
        main_window="$candidate"
        break
    fi

    attempt=$((attempt + 1))
    sleep 0.1
done

if [ -z "$main_window" ]; then
    echo "VRCX-0 main window did not appear." >&2
    exit 70
fi

# Force the sole VRCX-0 window into fullscreen mode.
wmctrl -i -r "$main_window" -b add,fullscreen 2>/dev/null || {
    echo "Could not fullscreen VRCX-0 window." >&2
    exit 71
}

echo "Monitoring VRCX-0 main window: $main_window"

# Exit when the window is hidden, minimized, unmapped, or destroyed.
missing_count=0

while :; do
    if is_visible "$main_window"; then
        missing_count=0
    else
        missing_count=$((missing_count + 1))

        if [ "$missing_count" -ge 4 ]; then
            echo "VRCX-0 main window disappeared or was minimized." >&2
            exit 42
        fi
    fi

    sleep 0.5
done
