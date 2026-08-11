#!/bin/sh
set -eu

unit=/usr/lib/systemd/user/foot-server.socket

if [ ! -f "$unit" ]; then
    printf '%s\n' 'foot-server.socket is unavailable; install Foot and run chezmoi apply again' >&2
    exit 1
fi

# --root=/ makes systemctl edit the unit links directly instead of requiring a
# running user manager during bootstrap. --no-reload avoids contacting it.
systemctl --user --root=/ enable --no-reload foot-server.socket
