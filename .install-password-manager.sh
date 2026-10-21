#!/bin/sh
set -eu

if command -v pass >/dev/null 2>&1 &&
   command -v gpg >/dev/null 2>&1 &&
   command -v git >/dev/null 2>&1 &&
   command -v pinentry >/dev/null 2>&1; then
    exit 0
fi

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
