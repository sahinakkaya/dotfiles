#!/bin/sh
# Configure GPG pinentry and prepare the store after applying templates.
set -eu

config=$1

# Install dependencies before reading configuration or accessing the store.
run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

case "$(uname -s)" in
Darwin)
    pinentry_available=false
    if command -v pinentry-mac >/dev/null 2>&1 ||
       [ -x /opt/homebrew/bin/pinentry-mac ]; then
        pinentry_available=true
    fi
    ;;
*)
    pinentry_available=false
    if command -v pinentry >/dev/null 2>&1; then
        pinentry_available=true
    fi
    ;;
esac

if ! command -v pass >/dev/null 2>&1 ||
   ! command -v gpg >/dev/null 2>&1 ||
   ! command -v git >/dev/null 2>&1 ||
   [ "$pinentry_available" != true ] ||
   ! command -v jq >/dev/null 2>&1; then
    case "$(uname -s)" in
    Linux)
        if command -v dnf >/dev/null 2>&1; then
            run_as_root dnf install -y pass gnupg2 git pinentry jq
        elif command -v apt-get >/dev/null 2>&1; then
            run_as_root apt-get update
            run_as_root apt-get install -y pass gnupg git pinentry-curses jq
        else
            echo "This bootstrap supports Fedora and Debian Linux." >&2
            exit 1
        fi
        ;;
    Darwin)
        if ! command -v brew >/dev/null 2>&1; then
            echo "Install homebrew first and add /opt/homebrew/bin to PATH." >&2
            exit 1
        fi
        brew install pass gnupg2 git pinentry-mac jq
        ;;
    *)
        echo "Unsupported operating system." >&2
        exit 1
        ;;
    esac
fi

if ! command -v python3 >/dev/null 2>&1; then
    case "$(uname -s)" in
        Linux)
            if command -v dnf >/dev/null 2>&1; then
                run_as_root dnf install -y python3
            else
                run_as_root apt-get update
                run_as_root apt-get install -y python3
            fi
            ;;
        Darwin)
            sudo port install python314
            sudo port select --set python3 python314
            ;;
        *) echo "Unsupported operating system." >&2; exit 1 ;;
    esac
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
remote=$(jq -er '.pass_git_remote | select(type == "string" and length > 0)' "$config")
key_id=$(jq -er '.pass_gpg_id | select(type == "string" and length > 0)' "$config")
case "$(uname -s)" in
Darwin)
    brew_prefix=$(brew --prefix)
    if [ ! -x "$brew_prefix/bin/pinentry-touchid" ]; then
        brew trust --formula jorgelbg/tap/pinentry-touchid
        brew install jorgelbg/tap/pinentry-touchid
    fi
    pinentry_mac="$brew_prefix/bin/pinentry-mac"
    touchid_program="$brew_prefix/bin/pinentry-touchid"
    fallback_program=$(gpgconf --list-components | awk -F: '$1 == "pinentry" { print $3 }')

    if [ ! -x "$pinentry_mac" ] || [ ! -x "$touchid_program" ] || [ -z "$fallback_program" ]; then
        echo "Homebrew pinentry-mac and pinentry-touchid must be installed." >&2
        exit 1
    fi
    if [ "$fallback_program" != "$brew_prefix/opt/pinentry/bin/pinentry" ]; then
        echo "Unexpected Homebrew pinentry component path: $fallback_program" >&2
        exit 1
    fi

    # Do not use `pinentry-touchid -fix`: on a mixed Homebrew/MacPorts system
    # it can select the MacPorts binary from PATH. GnuPG's generic pinentry
    # component must instead resolve to Homebrew pinentry-mac explicitly.
    rm -f "$fallback_program"
    ln -s "$pinentry_mac" "$fallback_program"
    defaults write org.gpgtools.common DisableKeychain -bool yes
    pinentry_program=$touchid_program
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
gpgconf --kill gpg-agent

export PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:-"$HOME/.password-store"}
# The GPG key is needed by pass, independently of Bitwarden-backed templates.
python3 "$script_dir/import-gpg-key.py" "$config"
if [ ! -e "$PASSWORD_STORE_DIR" ]; then
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

if [ "$(uname -s)" = Darwin ] && ! security find-generic-password -s GnuPG >/dev/null 2>&1; then
    entry_file=$(find "$PASSWORD_STORE_DIR" -type f -name '*.gpg' -print -quit)
    if [ -z "$entry_file" ]; then
        echo "Password store has no entries to decrypt; Touch ID will bootstrap on its first use." >&2
        exit 0
    fi
    entry=${entry_file#"$PASSWORD_STORE_DIR"/}
    entry=${entry%.gpg}
    echo "Unlock the GPG key once in the Homebrew pinentry-mac prompt." >&2
    pass show "$entry" >/dev/null
    if ! security find-generic-password -s GnuPG >/dev/null 2>&1; then
        echo "pinentry-touchid did not create its GnuPG Keychain item." >&2
        exit 1
    fi
fi
