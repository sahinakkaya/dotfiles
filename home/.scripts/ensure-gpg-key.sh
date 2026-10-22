#!/bin/sh
# Keep routine source reads limited to the local key check and recovery if needed.
set -eu

# install.sh explicitly imports the key after installing its dependencies.
if [ "${CHEZMOI_INITIAL_SETUP:-0}" = 1 ]; then
    exit 0
fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"
if [ -t 0 ]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi
python3 "$SCRIPT_DIR/import-gpg-key.py" "$SCRIPT_DIR/../.password-manager.json"
