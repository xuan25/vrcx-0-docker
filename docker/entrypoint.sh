#!/bin/sh
set -eu

: "${VNC_PASSWORD:?VNC_PASSWORD must be set}"
VNC_USERNAME="${VNC_USERNAME:-vnc}"

install -d -m 700 /tmp/wayvnc

umask 077
cat > /tmp/wayvnc/config <<EOF
address=127.0.0.1
port=5900
enable_auth=true
username=$VNC_USERNAME
password=$VNC_PASSWORD
relax_encryption=true
EOF

exec "$@"
