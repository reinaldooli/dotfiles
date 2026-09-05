#!/usr/bin/env bash
set -euo pipefail

# Install Xcode Command Line Tools if not already installed
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/backup/$(date +%Y%m%d_%H%M%S)"

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$1" >&2; }

# Backs up existing files that would be overwritten by stow.
# Walks the package directory and checks if each target in $HOME
# is a real file (not a symlink already managed by stow).
backup_conflicts() {
  local pkg_dir="$1"
  local had_conflicts=false

  while IFS= read -r -d '' file; do
    local rel="${file#"$pkg_dir"/}"
    local target="$HOME/$rel"

    if [[ -e "$target" && ! -L "$target" ]]; then
      had_conflicts=true
      local backup_path="$BACKUP_DIR/$rel"
      mkdir -p "$(dirname "$backup_path")"
      mv "$target" "$backup_path"
      warn "Backed up $target -> $backup_path"
    fi
  done < <(find "$pkg_dir" -type f -print0)

  if $had_conflicts; then
    info "Backups saved to $BACKUP_DIR"
  fi
}

# --- Git per-machine config ---
# The tracked .gitconfig ends with `[include] path = ~/.gitconfig.local`,
# and git applies includes in order, so values written below override the
# shared config. We only generate this file if it does not already exist —
# re-running install.sh will never clobber local tweaks.
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ -f "$GITCONFIG_LOCAL" ]]; then
  info "Existing $GITCONFIG_LOCAL found — leaving it untouched."
else
  info "Configuring per-machine git identity..."
  read -rp "Enter your full name for git: " git_name
  read -rp "Enter your email for git: " git_email
  read -rp "Enter your SSH signing key (leave blank to add later): " git_signingkey

  if [[ -z "$git_name" || -z "$git_email" ]]; then
    error "Name and email cannot be empty."
    exit 1
  fi

  {
    echo "[user]"
    echo "	name = $git_name"
    echo "	email = $git_email"
    [[ -n "$git_signingkey" ]] && echo "	signingkey = $git_signingkey"
  } > "$GITCONFIG_LOCAL"

  info "Wrote $GITCONFIG_LOCAL"

  # Seed ~/.config/git/allowed_signers so this machine can verify its own
  # signed commits. The tracked .gitconfig points allowedSignersFile here;
  # the file itself is per-machine (it pairs an identity with a public key).
  if [[ -n "$git_signingkey" ]]; then
    ALLOWED_SIGNERS="$HOME/.config/git/allowed_signers"
    mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
    if [[ ! -f "$ALLOWED_SIGNERS" ]] || ! grep -qF "$git_signingkey" "$ALLOWED_SIGNERS"; then
      echo "$git_email $git_signingkey" >> "$ALLOWED_SIGNERS"
      info "Added signing key to $ALLOWED_SIGNERS"
    fi
  fi
fi

# --- Zsh per-machine overrides directory ---
# .zshrc sources ~/.zsh.local.d/*.sh after the shared config. Make sure
# the directory exists so users have an obvious place to drop overrides.
mkdir -p "$HOME/.zsh.local.d"

# --- Homebrew ---
# Apple Silicon installs to /opt/homebrew, Intel to /usr/local. Resolving the
# prefix instead of hardcoding it is what lets this script run on both; the
# previous hardcoded /opt/homebrew/bin/brew aborted the whole script on Intel
# (set -e) before it ever reached stow.
find_brew() {
  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  command -v brew 2>/dev/null
}

BREW="$(find_brew || true)"

if [[ -z "$BREW" ]]; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW="$(find_brew || true)"
  if [[ -z "$BREW" ]]; then
    error "Homebrew finished installing but 'brew' was not found on this system."
    exit 1
  fi
fi

# .zshrc sources ~/.zsh.d/01-env.sh, which runs shellenv itself, but login
# shells read .zprofile first and some tooling never sources .zshrc at all.
if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
  echo "eval \"\$($BREW shellenv)\"" >> "$HOME/.zprofile"
  info "Added brew shellenv to ~/.zprofile"
fi

eval "$("$BREW" shellenv)"

# Install applications via Brewfile
if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
  info "Installing applications from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  warn "Brewfile not found at $DOTFILES_DIR/Brewfile"
fi

# Install Zap ZSH plugin manager
if [[ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}/zap" ]]; then
  info "Installing Zap ZSH plugin manager..."
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
  info "Removing .zshrc so stow can manage it..."
  rm -f ~/.zshrc
fi

# --- Stow dotfiles ---
info "Linking dotfiles with stow..."
for dir in "$DOTFILES_DIR"/dotfiles/*/; do
  pkg="$(basename "$dir")"
  info "Stowing $pkg..."
  backup_conflicts "$dir"
  stow -d "$DOTFILES_DIR/dotfiles" -t "$HOME" "$pkg"
done

info "Done! Starting a fresh login shell..."

# Replace this process with a login shell so the new config is live.
exec zsh -l
