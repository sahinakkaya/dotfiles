#!/bin/sh
# Called only before the initial password-store clone.
set -eu

# Read prompts from the terminal even when install.sh is piped into sh.
if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    echo "Password-store setup needs a terminal to generate/register an SSH key. Rerun the installer interactively." >&2
    exit 1
fi

key="$HOME/.ssh/id_ed25519"
if [ ! -e "$key" ] && [ -f "$HOME/.ssh/id_rsa" ]; then
    key="$HOME/.ssh/id_rsa"
fi

if [ ! -e "$key" ]; then
    printf 'No default SSH key found. Press Enter to generate %s (Ctrl-C to stop): ' "$key" >&3
    IFS= read -r answer <&3
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    key_user=$(id -un)
    key_host=$(uname -n)
    if [ -z "$key_host" ]; then
        echo "Could not determine the hostname for the SSH key comment." >&3
        exit 1
    fi
    ssh-keygen -t ed25519 -f "$key" -C "$key_user@$key_host" <&3 >&3 2>&3
fi

printf '\nAdd this public key to your account at:\nhttps://git.sahinakkaya.dev/user/settings/keys\n\n' >&3
if [ -f "$key.pub" ]; then
    cat "$key.pub" >&3
else
    # Recover the public half without modifying an existing private key.
    ssh-keygen -y -f "$key" <&3 >&3 2>&3
fi
printf '\nIf you use a different SSH identity, register that key instead.\n' >&3
printf 'Press Enter once the key is registered to clone the password store (Ctrl-C to stop): ' >&3
IFS= read -r answer <&3
