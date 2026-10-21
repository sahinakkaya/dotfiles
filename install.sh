#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Make user-installed Ansible and Yolk available in this shell.
export PATH="$HOME/.local/bin:${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"

# Let GPG pinentry prompt on this terminal, including from Ansible tasks.
if [ -t 0 ]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi

if ! command -v ansible >/dev/null 2>&1; then
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "pip3 is required to install Ansible. Install Python 3 and pip first." >&2
        exit 1
    fi

    pip3 install --user ansible
    export PATH="$(python3 -m site --user-base)/bin:$PATH"
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "ansible-playbook is unavailable. Check your Ansible installation and PATH." >&2
    exit 1
fi

# Install CLI dependencies before the interactive Vaultwarden login.
ansible-playbook -i localhost, "$SCRIPT_DIR/ansible/setup.yml" --ask-become-pass --tags bootstrap
# Ansible cannot change this shell's PATH; activate its default Node for bw.
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh" --no-use
nvm use --silent default
python3 "$SCRIPT_DIR/scripts/import-gpg-key.py" "$SCRIPT_DIR/ansible/vars/main.yml"

ansible-playbook -i localhost, "$SCRIPT_DIR/ansible/setup.yml" --ask-become-pass --skip-tags bootstrap

export YOLK_DIR="$SCRIPT_DIR"
yolk git submodule update --init --recursive
yolk sync
