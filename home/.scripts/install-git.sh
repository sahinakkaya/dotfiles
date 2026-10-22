#!/bin/sh
set -eu

if command -v git >/dev/null 2>&1; then
    exit 0
fi

# chezmoi can clone with its built-in Git, but submodules need the executable.
if [ "$(id -u)" -eq 0 ]; then
    set --
elif command -v sudo >/dev/null 2>&1; then
    set -- sudo
else
    printf 'Installing Git requires root or sudo. Install Git, then rerun install.sh.\n' >&2
    exit 1
fi

case "$(uname -s)" in
    Linux)
        if command -v dnf >/dev/null 2>&1; then
            "$@" dnf install -y git
        elif command -v apt-get >/dev/null 2>&1; then
            "$@" apt-get update
            "$@" apt-get install -y git
        else
            printf 'No supported package manager found. Install Git, then rerun install.sh.\n' >&2
            exit 1
        fi
        ;;
    Darwin)
        if ! command -v port >/dev/null 2>&1; then
            printf 'Install Git or MacPorts and add it to PATH, then rerun install.sh.\n' >&2
            exit 1
        fi
        "$@" port install git
        ;;
    *)
        printf 'Install Git for this operating system, then rerun install.sh.\n' >&2
        exit 1
        ;;
esac

if ! command -v git >/dev/null 2>&1; then
    printf 'Git is still unavailable after installation. Check PATH before rerunning install.sh.\n' >&2
    exit 1
fi
