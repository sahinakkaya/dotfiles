#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

if [ -t 0 ]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi

sh "$SCRIPT_DIR/.install-password-manager.sh"
python3 "$SCRIPT_DIR/.scripts/import-gpg-key.py" "$SCRIPT_DIR/.password-manager.json"
sh "$SCRIPT_DIR/.scripts/setup-password-store.sh" "$SCRIPT_DIR/.password-manager.json"
