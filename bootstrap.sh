#!/usr/bin/env bash
#
# One-shot bootstrap for a fresh machine. Clones (or updates) the dotfiles
# repo and hands off to install.sh.
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/reinaldooli/dotfiles/main/bootstrap.sh)"
#
# Use the `bash -c "$(curl ...)"` form, NOT `curl ... | bash`: install.sh
# prompts for a git identity, and piping would feed it the script instead
# of the terminal.
#
# Overridable via env:
#   DOTFILES_DIR    where to clone       (default ~/.dev/github.com/reinaldooli/dotfiles)
#   DOTFILES_REPO   clone URL            (default HTTPS, no SSH key needed yet)
#   DOTFILES_BRANCH branch to check out  (default main)
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dev/github.com/reinaldooli/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/reinaldooli/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1" >&2; }

# git ships with the Xcode Command Line Tools, so we need those before we
# can clone anything. install.sh checks again — it must work standalone.
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  info "Waiting for the installation to finish..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "Existing clone found at $DOTFILES_DIR — updating..."
  git -C "$DOTFILES_DIR" pull --ff-only
elif [[ -e "$DOTFILES_DIR" ]]; then
  error "$DOTFILES_DIR exists but is not a git clone. Move it aside and retry."
  exit 1
else
  info "Cloning $DOTFILES_REPO into $DOTFILES_DIR..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

info "Running install.sh..."
exec "$DOTFILES_DIR/install.sh"
