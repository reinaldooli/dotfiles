# dotfiles

Personal dotfiles for macOS. Managed with [GNU Stow](https://www.gnu.org/software/stow/), so each file in `$HOME` is a symlink back into this repo. `git pull` is the upgrade — every linked file instantly reflects the new content.

## Layout

```
.
├── Brewfile                 # apps and CLIs installed via `brew bundle`
├── install.sh               # one-shot bootstrap (see below)
└── dotfiles/                # one stow package per tool
    ├── ghostty/
    ├── git/
    ├── nvim/
    ├── vim/
    └── zsh/
```

Each subdirectory under `dotfiles/` is a stow package. The directory tree inside it mirrors `$HOME` — for example `dotfiles/git/.gitconfig` is linked to `~/.gitconfig`.

## Install

On a fresh machine:

```sh
git clone https://github.com/reinaldooli/dotfiles.git ~/.dev/github.com/reinaldooli/dotfiles
cd ~/.dev/github.com/reinaldooli/dotfiles
./install.sh
```

`install.sh` will:

1. Install Xcode Command Line Tools and Homebrew if missing.
2. Run `brew bundle` against the `Brewfile`.
3. Install the [Zap](https://www.zapzsh.com/) zsh plugin manager.
4. Prompt for git name/email/signing key and write them to `~/.gitconfig.local` (skipped if the file already exists).
5. Create `~/.zsh.local.d/` for per-machine zsh overrides.
6. Stow every package under `dotfiles/`, backing up any pre-existing real files to `backup/<timestamp>/`.

## Updating

```sh
cd ~/.dev/github.com/reinaldooli/dotfiles
git pull
```

Because everything is symlinked, that's it. New shared config in the repo is live immediately. Local overrides (see below) are untouched.

## Shared config vs. per-machine overrides

The split is deliberate: the repo holds config that's the same everywhere, and each machine adds its own bits in untracked files outside the stow tree.

### Git

- **Shared:** `dotfiles/git/.gitconfig` — aliases, colors, signing settings (format, paths), etc.
- **Local:** `~/.gitconfig.local` — identity and anything machine-specific (work email, SSH signing program path, host-specific aliases).
- **Local:** `~/.config/git/allowed_signers` — public keys trusted to verify signed commits. Identity-shaped, so it's not tracked. `install.sh` seeds it with your own signing key on first run; add more lines (one per signer) as needed.

The tracked `.gitconfig` ends with:

```ini
[include]
    path = ~/.gitconfig.local
```

Git applies includes in order, so anything in `~/.gitconfig.local` overrides the shared config. Example:

```ini
[user]
    name = Reinaldo Oliveira
    email = work@example.com
    signingkey = ssh-ed25519 AAAA...
```

### Zsh

- **Shared:** `dotfiles/zsh/.zsh.d/*.sh` — env vars, plugin setup, aliases.
- **Local:** `~/.zsh.local.d/*.sh` — per-machine PATH entries, work-only aliases, secrets-loading shims.

`.zshrc` sources the shared dir first, then the local dir, so local files can extend or override anything from the repo. The local directory lives outside the stow tree on purpose — files dropped into `~/.zsh.d/` would actually land inside the repo (because that path is itself a symlink back into it).

### Other tools

Same pattern applies wherever a tool supports it:

- **nvim:** add a `lua/local.lua` and `pcall(require, "local")` from your init.
- **wezterm:** `pcall(dofile, wezterm.home_dir .. "/.wezterm.local.lua")`.
- **ghostty:** `config-file = ~/.config/ghostty/config.local`.

## Adding a new tool

1. Create `dotfiles/<tool>/` with the tool's files at their `$HOME`-relative paths.
2. Re-run `./install.sh` (or just `stow -d dotfiles -t ~ <tool>`).
3. If the tool has machine-specific bits, decide on a `.local` convention for it and document it here.
