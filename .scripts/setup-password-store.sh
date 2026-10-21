#!/bin/sh
# Configure GPG pinentry and prepare the store before rendering templates.
set -eu

config=$1
remote=$(jq -er '.pass_git_remote | select(type == "string" and length > 0)' "$config")
key_id=$(jq -er '.pass_gpg_id | select(type == "string" and length > 0)' "$config")
pinentry_program=$(command -v pinentry)
gpg_home=${GNUPGHOME:-"$HOME/.gnupg"}
agent_config="$gpg_home/gpg-agent.conf"

umask 077
mkdir -p "$gpg_home"
chmod 700 "$gpg_home"
touch "$agent_config"
chmod 600 "$agent_config"
temporary_config=$(mktemp "$gpg_home/gpg-agent.conf.XXXXXX")
trap 'rm -f "$temporary_config"' EXIT
trap 'exit 1' HUP INT TERM

# Preserve other settings and replace any active pinentry-program directives.
PINENTRY_PROGRAM="$pinentry_program" awk '
    /^[[:space:]]*pinentry-program[[:space:]]+/ {
        if (!replaced++) print "pinentry-program " ENVIRON["PINENTRY_PROGRAM"]
        next
    }
    { print }
    END {
        if (!replaced) print "pinentry-program " ENVIRON["PINENTRY_PROGRAM"]
    }
' "$agent_config" > "$temporary_config"
if ! cmp -s "$agent_config" "$temporary_config"; then
    cat "$temporary_config" > "$agent_config"
    gpgconf --kill gpg-agent
fi

export PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:-"$HOME/.password-store"}
if [ ! -e "$PASSWORD_STORE_DIR" ]; then
    mkdir -p "$(dirname -- "$PASSWORD_STORE_DIR")"
    git clone -- "$remote" "$PASSWORD_STORE_DIR"
fi
if [ ! -d "$PASSWORD_STORE_DIR" ]; then
    echo "The password-store path is not a directory." >&2
    exit 1
fi
if [ ! -e "$PASSWORD_STORE_DIR/.gpg-id" ]; then
    pass init "$key_id"
fi
