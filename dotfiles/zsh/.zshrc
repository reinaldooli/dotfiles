# Source shared config from this repo (managed via stow).
for config_file in ~/.zsh.d/*.sh; do
  [ -r "$config_file" ] && source "$config_file"
done

# Source per-machine overrides (untracked, lives outside the stow tree).
# Drop any *.sh in ~/.zsh.local.d to extend or override the shared config.
if [ -d ~/.zsh.local.d ]; then
  for config_file in ~/.zsh.local.d/*.sh; do
    [ -r "$config_file" ] && source "$config_file"
  done
fi
