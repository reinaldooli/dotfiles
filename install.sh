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

# --- Git user configuration ---
info "Configuring git user..."
read -rp "Enter your full name for git: " git_name
read -rp "Enter your email for git: " git_email

if [[ -z "$git_name" || -z "$git_email" ]]; then
  error "Name and email cannot be empty."
  exit 1
fi

sed -i'' -e "s/name = Your Name/name = $git_name/" "$DOTFILES_DIR/dotfiles/git/.gitconfig"
sed -i'' -e "s/email = your@email.com/email = $git_email/" "$DOTFILES_DIR/dotfiles/git/.gitconfig"
info "Git configured for $git_name <$git_email>"

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install applications via Brewfile
if [[ -f ./Brewfile ]]; then
  info "Installing applications from Brewfile..."
  brew bundle --file=./Brewfile
else
  warn "Warning: Brewfile not found in current directory"
fi

# Install Zap ZSH plugin manager
if [[ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}/zap" ]]; then
  info "Installing Zap ZSH plugin manager..."
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
  info "Removing .zshrc so stow can manage it..."
  rm -f ~/.zshrc
fi

# Re-source Homebrew env just in case
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- Stow dotfiles ---
info "Linking dotfiles with stow..."
for dir in "$DOTFILES_DIR"/dotfiles/*/; do
  pkg="$(basename "$dir")"
  info "Stowing $pkg..."
  backup_conflicts "$dir"
  stow -d "$DOTFILES_DIR/dotfiles" -t "$HOME" "$pkg"
done

# Optionally restart the shell
exec zsh -l

info "Done! You may need to restart your shell for all changes to take effect."
