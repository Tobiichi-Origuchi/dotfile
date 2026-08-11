#!/bin/sh
set -eu

# Phase 10: install mise and the user-scoped development tools. The system
# package restore runs later as phase 20 and may rely on this Rust toolchain.

# environment.d is not active yet during the first chezmoi apply. Derive every
# bootstrap path from this restore's HOME so stale values cannot leak in from
# the invoking session.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"
export MISE_CARGO_HOME="$XDG_DATA_HOME/cargo"
export MISE_RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$MISE_CARGO_HOME"
export RUSTUP_HOME="$MISE_RUSTUP_HOME"
export PATH="$HOME/.local/bin:$CARGO_HOME/bin:$PATH"

# Keep mise's project/config discovery inside the home being restored.
cd "$HOME"

mise_bin="$HOME/.local/bin/mise"

if [ ! -x "$mise_bin" ]; then
    installer=$(mktemp)
    trap 'rm -f "$installer"' EXIT HUP INT TERM

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://mise.run -o "$installer"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$installer" https://mise.run
    else
        printf '%s\n' 'mise installation requires curl or wget' >&2
        exit 1
    fi

    MISE_INSTALL_PATH="$mise_bin" sh "$installer"
    rm -f "$installer"
    trap - EXIT HUP INT TERM
fi

# Installs rust=stable and usage=latest from ~/.config/mise/config.toml.
"$mise_bin" install --yes

for crate in cargo-audit cargo-update markdown2pdf; do
    "$mise_bin" exec rust@stable -- cargo install --locked "$crate"
done

# uv itself deliberately remains owned by the system package manager.
if ! command -v uv >/dev/null 2>&1; then
    printf '%s\n' 'uv is not installed; install the system package and run chezmoi apply again' >&2
    exit 1
fi

uv tool install procpath
