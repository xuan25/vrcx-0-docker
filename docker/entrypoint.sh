#!/bin/sh
set -eu

: "${VNC_PASSWORD:?VNC_PASSWORD must be set}"

install -d -m 700 /tmp/tigervnc

umask 077
printf '%s\n' "$VNC_PASSWORD" | vncpasswd -f > /tmp/tigervnc/passwd

exec "$@"