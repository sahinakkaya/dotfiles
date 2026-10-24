#!/bin/sh
set -eu

case "${1:-}" in
    false) exit 0 ;;
    true) ;;
    *) echo "Expected personalSecrets flag (true or false)." >&2; exit 1 ;;
esac

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"
config="$SCRIPT_DIR/password-manager.json"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
marker="$state_dir/bitwarden-bootstrap"
# Include the CLI profile location so a different profile gets its own check.
fingerprint=$( { cat "$config"; printf '\n%s\n' "${BITWARDENCLI_APPDATA_DIR:-}"; } | cksum)

# Source-read hooks also run during routine previews and updates. Avoid loading
# nvm or invoking package managers once the required tools are available.
if ! command -v bw >/dev/null 2>&1 ||
   ! command -v jq >/dev/null 2>&1 ||
   [ ! -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
    sh "$SCRIPT_DIR/install-password-manager.sh"
elif [ -f "$marker" ] && [ "$(cat "$marker")" = "$fingerprint" ]; then
    exit 0
fi
sh "$SCRIPT_DIR/login-bitwarden.sh" "$config"
umask 077
mkdir -p "$state_dir"
printf '%s\n' "$fingerprint" > "$marker"
