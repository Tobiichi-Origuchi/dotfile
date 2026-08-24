#!/bin/sh
set -eu

# Keep fish startup (including tools.fish) inside the home being restored even
# when chezmoi is invoked from a session with stale environment.d values.
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
export ANDROID_HOME="$XDG_DATA_HOME/Android/Sdk"

cd "$HOME"

if ! command -v fish >/dev/null 2>&1; then
    printf '%s\n' 'fish is not installed; install it and run chezmoi apply again' >&2
    exit 1
fi

# Keep this list as the source of truth for the universal fish_user_paths.
# shellcheck disable=SC2016 # $HOME is intentionally expanded by fish.
fish -c 'set -U fish_user_paths "$CARGO_HOME/bin" "$HOME/.local/bin" "$ANDROID_HOME/tools" "$ANDROID_HOME/tools/bin" "$ANDROID_HOME/platform-tools"'
