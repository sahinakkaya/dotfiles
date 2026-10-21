#!/bin/sh
set -eu

if ! command -v pass >/dev/null 2>&1 ||
   ! command -v gpg >/dev/null 2>&1 ||
   ! command -v git >/dev/null 2>&1 ||
   ! command -v pinentry >/dev/null 2>&1; then
    case "$(uname -s)" in
    Linux)
        if ! command -v dnf >/dev/null 2>&1; then
            echo "This bootstrap currently supports Fedora Linux only." >&2
            exit 1
        fi
        sudo dnf install -y pass gnupg2 git pinentry
        ;;
    Darwin)
        if ! command -v port >/dev/null 2>&1; then
            echo "Install MacPorts first and add /opt/local/bin to PATH." >&2
            exit 1
        fi
        sudo port install pass gnupg2 git pinentry
        ;;
    *)
        echo "Unsupported operating system." >&2
        exit 1
        ;;
    esac
fi

if ! command -v python3 >/dev/null 2>&1; then
    case "$(uname -s)" in
        Linux) sudo dnf install -y python3 ;;
        Darwin)
            sudo port install python313
            sudo port select --set python3 python313
            ;;
        *) echo "Unsupported operating system." >&2; exit 1 ;;
    esac
fi

if command -v bw >/dev/null 2>&1; then
    exit 0
fi

# nvm is a Bash function; the chezmoi hook invokes this script with sh.
bash <<'BASH'
set -eo pipefail
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    # curl is needed only when bootstrapping nvm.
    if ! command -v curl >/dev/null 2>&1; then
        case "$(uname -s)" in
            Linux) sudo dnf install -y curl ;;
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
