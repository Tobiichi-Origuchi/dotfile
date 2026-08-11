#!/bin/sh
set -eu

timer="$HOME/.config/systemd/user/dotfiles-sync.timer"

if [ ! -f "$timer" ]; then
    printf '%s\n' 'dotfiles-sync.timer was not restored' >&2
    exit 1
fi

# Enable directly on disk so bootstrap does not require a running user manager.
systemctl --user --root=/ enable --no-reload dotfiles-sync.timer

# Start it immediately when a user manager is available. Otherwise the enabled
# link takes effect automatically at the next login.
if systemctl --user daemon-reload >/dev/null 2>&1; then
    systemctl --user start dotfiles-sync.timer
else
    printf '%s\n' 'dotfiles-sync.timer is enabled and will start at the next user-manager login'
fi
