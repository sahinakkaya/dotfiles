#!/bin/sh
set -eu

case "${1:-}" in
    false) exit 0 ;;
    true) ;;
    *) echo "Expected personalSecrets flag (true or false) from install.sh." >&2; exit 1 ;;
esac

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

if [ -t 0 ]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi

sh "$SCRIPT_DIR/.install-password-manager.sh"
sh "$SCRIPT_DIR/.scripts/login-bitwarden.sh" "$SCRIPT_DIR/.password-manager.json"
python3 "$SCRIPT_DIR/.scripts/import-gpg-key.py" "$SCRIPT_DIR/.password-manager.json"
