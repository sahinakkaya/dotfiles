#!/bin/sh

set -e # -e: exit on error

step() {
  printf '\n==> %s\n' "$*" >&2
}

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  install_tmpdir=$(mktemp -d)
  trap 'rm -rf -- "$install_tmpdir"' 0
  trap 'exit 130' INT
  trap 'exit 143' TERM
  step 'Downloading the chezmoi installer'
  if [ "$(command -v curl)" ]; then
    curl -fL --progress-bar https://get.chezmoi.io -o "$install_tmpdir/install.sh"
  elif [ "$(command -v wget)" ]; then
    wget -O "$install_tmpdir/install.sh" https://get.chezmoi.io
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  step 'Downloading and installing chezmoi'
  if [ -t 2 ]; then
    # Upstream downloads silently; show activity until it exits.
    sh "$install_tmpdir/install.sh" -b "$bin_dir" > "$install_tmpdir/install.log" 2>&1 &
    install_pid=$!
    trap 'kill "$install_pid" 2>/dev/null || :; exit 130' INT
    trap 'kill "$install_pid" 2>/dev/null || :; exit 143' TERM
    while kill -0 "$install_pid" 2>/dev/null; do
      for frame in '|' '/' '-' '\'; do
        printf '\r  %s Installing chezmoi...' "$frame" >&2
        sleep 0.2
      done
    done
    install_status=0
    wait "$install_pid" || install_status=$?
    printf '\r\033[2K' >&2
    cat "$install_tmpdir/install.log" >&2
    [ "$install_status" -eq 0 ] || exit "$install_status"
  else
    sh "$install_tmpdir/install.sh" -b "$bin_dir"
  fi
  rm -rf -- "$install_tmpdir"
  trap - 0 INT TERM
else
  chezmoi=chezmoi
  step 'Using the installed chezmoi'
fi

# Set up dependencies and credentials before rendering password-backed templates.
export CHEZMOI_INITIAL_SETUP=1
step 'Initializing dotfiles and machine settings'
"$chezmoi" init --progress=true --recurse-submodules=false sahinakkaya
source_dir="$("$chezmoi" source-path)"
if ! command -v git >/dev/null 2>&1; then
    step 'Installing Git for submodules and repository updates'
    sh "$source_dir/.scripts/install-git.sh"
fi
headless="$("$chezmoi" execute-template '{{ .headless }}')"
if [ "$headless" = false ]; then
    step 'Downloading dotfile submodules'
    "$chezmoi" git -- submodule update --init --recursive --progress
fi
personal_secrets="$("$chezmoi" execute-template '{{ .personalSecrets }}')"
if [ "$personal_secrets" = true ]; then
    step 'Setting up the password manager and personal credentials'
fi
sh "$source_dir/.bootstrap-password-manager.sh" "$personal_secrets"
unset CHEZMOI_INITIAL_SETUP
step 'Applying dotfiles and installing required packages'
exec "$chezmoi" apply --less-interactive --progress=true

