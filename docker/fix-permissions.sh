#!/bin/sh
set -eu

APP_USER="vncuser"
APP_HOME="/home/vncuser"

uid="$(id -u "$APP_USER")"
gid="$(id -g "$APP_USER")"

for dir in \
    "$APP_HOME/.config" \
    "$APP_HOME/.local/share" \
    "$APP_HOME/.cache"
do
    mkdir -p "$dir"
    chown -R "$uid:$gid" "$dir"
done