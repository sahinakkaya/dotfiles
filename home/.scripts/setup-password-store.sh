#!/bin/sh
# Configure GPG pinentry and prepare the store after applying templates.
set -eu

config=$1
remote=$(jq -er '.pass_git_remote | select(type == "string" and length > 0)' "$config")
key_id=$(jq -er '.pass_gpg_id | select(type == "string" and length > 0)' "$config")
case "$(uname -s)" in
Darwin)
    pinentry_program=$(command -v pinentry-mac || true)
    if [ -z "$pinentry_program" ] && [ -x /Applications/MacPorts/pinentry-mac.app/Contents/MacOS/pinentry-mac ]; then
        pinentry_program=/Applications/MacPorts/pinentry-mac.app/Contents/MacOS/pinentry-mac
    fi
    ;;
*)
    pinentry_program=$(command -v pinentry || true)
    ;;
esac
if [ -z "$pinentry_program" ]; then
    echo "No suitable pinentry program is installed." >&2
    exit 1
fi
gpg_home=${GNUPGHOME:-"$HOME/.gnupg"}
agent_config="$gpg_home/gpg-agent.conf"

umask 077
mkdir -p "$gpg_home"
chmod 700 "$gpg_home"
# Fast path: leave an already correct configuration untouched, without staging
# a replacement file. Require exactly one canonical directive.
if [ -f "$agent_config" ] && PINENTRY_PROGRAM="$pinentry_program" awk '
    /^[[:space:]]*pinentry-program[[:space:]]+/ {
        count++
        if ($0 != "pinentry-program " ENVIRON["PINENTRY_PROGRAM"]) invalid = 1
    }
    END { exit !(count == 1 && !invalid) }
' "$agent_config"; then
    :
else
    temporary_config=$(mktemp "$gpg_home/gpg-agent.conf.XXXXXX")
    trap 'rm -f "$temporary_config"' EXIT
    trap 'exit 1' HUP INT TERM

    # Preserve other settings and replace any active pinentry-program directives.
    current_config="$agent_config"
    if [ ! -e "$current_config" ]; then
        current_config=/dev/null
    fi
    PINENTRY_PROGRAM="$pinentry_program" awk '
        /^[[:space:]]*pinentry-program[[:space:]]+/ {
            if (!replaced++) print "pinentry-program " ENVIRON["PINENTRY_PROGRAM"]
            next
        }
        { print }
        END {
            if (!replaced) print "pinentry-program " ENVIRON["PINENTRY_PROGRAM"]
        }
    ' "$current_config" > "$temporary_config"
    cat "$temporary_config" > "$agent_config"
    chmod 600 "$agent_config"
    gpgconf --kill gpg-agent
fi

export PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:-"$HOME/.password-store"}
if [ ! -e "$PASSWORD_STORE_DIR" ]; then
    script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
    sh "$script_dir/prepare-password-store-ssh.sh"
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
