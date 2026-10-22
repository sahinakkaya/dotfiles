#!/bin/sh
# Keep the normal CLI profile logged in for chezmoi's Bitwarden templates.
set -eu

config=$1
server=$(jq -er '.bw_server | select(type == "string" and length > 0)' "$config")
user=$(jq -er '.bw_user | select(type == "string" and length > 0)' "$config")
status=$(bw status)
state=$(printf '%s\n' "$status" | jq -er '.status')

case "$state" in
    unauthenticated)
        bw config server "$server" >/dev/null
        echo "Log in to Vaultwarden for chezmoi's SSH key templates." >&2
        # Preserve interactive password/2FA prompts, but do not print a session token.
        bw login "$user" >/dev/null
        ;;
    locked|unlocked)
        if ! printf '%s\n' "$status" | jq -e \
            --arg server "$server" --arg user "$user" \
            '.serverUrl == $server and .userEmail == $user' >/dev/null; then
            echo "Bitwarden CLI is logged into a different server or account; check bw status before continuing." >&2
            exit 1
        fi
        ;;
    *)
        echo "Unexpected Bitwarden CLI status." >&2
        exit 1
        ;;
esac
