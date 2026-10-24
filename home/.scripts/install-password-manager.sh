#!/bin/sh
set -eu

# jq is used by login-bitwarden.sh to read configuration and CLI status.
if ! command -v jq >/dev/null 2>&1; then
    case "$(uname -s)" in
        Linux)
            if [ "$(id -u)" -eq 0 ]; then
                set --
            else
                set -- sudo
            fi
            if command -v dnf >/dev/null 2>&1; then
                "$@" dnf install -y jq
            elif command -v apt-get >/dev/null 2>&1; then
                "$@" apt-get update
                "$@" apt-get install -y jq
            else
                echo "No supported package manager found for jq." >&2
                exit 1
            fi
            ;;
        Darwin) brew install jq ;;
        *) echo "Unsupported operating system." >&2; exit 1 ;;
    esac
fi

# nvm is a Bash function; bootstrap invokes this script with sh.
bash <<'BASH'
set -eo pipefail
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
bw_available=false
if command -v bw >/dev/null 2>&1; then
    bw_available=true
fi

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    # curl is needed only when bootstrapping nvm.
    if ! command -v curl >/dev/null 2>&1; then
        case "$(uname -s)" in
            Linux)
                if [[ $(id -u) -eq 0 ]]; then
                    privilege=()
                else
                    privilege=(sudo)
                fi
                if command -v dnf >/dev/null 2>&1; then
                    "${privilege[@]}" dnf install -y curl
                elif command -v apt-get >/dev/null 2>&1; then
                    "${privilege[@]}" apt-get update
                    "${privilege[@]}" apt-get install -y curl
                else
                    echo "Unsupported Linux package manager." >&2
                    exit 1
                fi
                ;;
            Darwin) sudo port install curl ;;
            *) echo "Unsupported operating system." >&2; exit 1 ;;
        esac
    fi
    release="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest)"
    version="$(printf '%s\n' "$release" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
    if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Could not determine the latest nvm release." >&2
        exit 1
    fi
    mkdir -p "$NVM_DIR"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$version/install.sh" -o "$NVM_DIR/install.sh"
    PROFILE=/dev/null METHOD=script bash "$NVM_DIR/install.sh"
fi

source "$NVM_DIR/nvm.sh" --no-use
resolved="$(nvm version 'lts/*' || true)"
if [ "$resolved" = N/A ]; then
    nvm install 'lts/*'
    resolved="$(nvm version 'lts/*')"
fi
if [ "$(nvm version default || true)" != "$resolved" ]; then
    nvm alias default "$resolved"
fi
nvm use --silent default
if ! command -v bw >/dev/null 2>&1; then
    npm install -g @bitwarden/cli
fi
bw --version
if [ "$bw_available" = true ]; then
    exit 0
fi

# A symlink alone would still require Node to be on the caller's PATH.
mkdir -p "$HOME/.local/bin"
if [ -e "$HOME/.local/bin/bw" ] || [ -L "$HOME/.local/bin/bw" ]; then
    echo "Refusing to overwrite $HOME/.local/bin/bw; check that it is on PATH." >&2
    exit 1
fi
{
    printf '#!/bin/bash\nset -e\nexport NVM_DIR=%q\n' "$NVM_DIR"
    cat <<'WRAPPER'
source "$NVM_DIR/nvm.sh" --no-use
nvm use --silent default
exec "$NVM_BIN/bw" "$@"
WRAPPER
} > "$HOME/.local/bin/bw"
chmod 755 "$HOME/.local/bin/bw"
BASH
