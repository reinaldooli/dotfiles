# dotfiles

Personal dotfiles for macOS. Managed with [GNU Stow](https://www.gnu.org/software/stow/), so each file in `$HOME` is a symlink back into this repo. `git pull` is the upgrade — every linked file instantly reflects the new content.

## Layout

```
.
├── Brewfile                 # apps and CLIs installed via `brew bundle`
├── bootstrap.sh             # curl-able entrypoint: clones the repo, runs install.sh
├── install.sh               # provisions the machine and stows the packages
└── dotfiles/                # one stow package per tool
    ├── ghostty/
    ├── git/
    ├── nvim/
    ├── vim/
    ├── wezterm/
    └── zsh/
```

Each subdirectory under `dotfiles/` is a stow package. The directory tree inside it mirrors `$HOME` — for example `dotfiles/git/.gitconfig` is linked to `~/.gitconfig`. Anything that is not inside a package is never linked anywhere, so config files belong in a package, not at the repo root.

### Zsh load order

`.zshrc` sources `~/.zsh.d/*.sh` in order, so the numeric prefixes are the dependency order, not decoration:

| File | Responsibility |
| --- | --- |
| `00-options.sh` | `setopt` — `AUTO_CD`, directory stack |
| `01-env.sh` | Homebrew prefix, GNU userland on `PATH`, `$EDITOR` |
| `02-plugins.sh` | Zap and its plugins, `compinit` |
| `03-navigation.sh` | `..`, `...`, `cd -`, `d` |
| `04-listing.sh` | `eza` aliases |
| `05-git.sh` | git aliases (vendored from oh-my-zsh) |

`01-env.sh` has to run before `04-listing.sh` because it is what puts GNU `ls` on `PATH`; `02-plugins.sh` runs `compinit` before `05-git.sh` uses `compdef`.

## Install

On a fresh machine — nothing to clone by hand, just run:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/reinaldooli/dotfiles/main/bootstrap.sh)"
```

`bootstrap.sh` installs the Xcode Command Line Tools (for `git`), clones this
repo to `~/.dev/github.com/reinaldooli/dotfiles`, and runs `install.sh`. If the
clone already exists it does a `git pull --ff-only` instead, so the same command
is both "install" and "update".

The clone is permanent, not a temp checkout: stow links every file in `$HOME`
back into it, so deleting the directory breaks every symlink.

Use the `bash -c "$(curl ...)"` form rather than `curl ... | bash` — `install.sh`
prompts for your git identity, and piping would feed it the script text instead
of your keyboard.

Override the defaults with env vars if needed:

```sh
DOTFILES_DIR=~/dotfiles \
DOTFILES_REPO=git@github.com:reinaldooli/dotfiles.git \
DOTFILES_BRANCH=main \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/reinaldooli/dotfiles/main/bootstrap.sh)"
```

(The default clone URL is HTTPS on purpose — a fresh machine has no SSH key yet.
Switch the remote to SSH afterwards with `git remote set-url origin git@github.com:reinaldooli/dotfiles.git`.)

If you already have the repo checked out, `./install.sh` on its own still works
and can be run from any directory.

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

Or re-run the bootstrap one-liner from anywhere — it pulls and re-runs
`install.sh`, which is idempotent.

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

### Shell navigation

`AUTO_CD` is on, so a bare directory name changes into it — `src/api` instead of `cd src/api`. That also covers `..`, which is a real directory. Deeper hops are not, so they are aliases:

| Type | Result |
| --- | --- |
| `foo` | `cd foo` |
| `..` | up 1 |
| `...` | up 2 |
| `....` | up 3 |
| `.....` | up 4 |
| `......` | up 5 |
| `-` | back to the previous directory |
| `d` | print the numbered directory stack |

`AUTO_PUSHD` keeps every `cd` on a stack, so after `d` you can jump straight to an earlier entry with `cd -2`, `cd -3`, and so on.

### Listing: `ls` and `eza`

`ls` is left alone — it stays the real `ls` (GNU coreutils, put on `PATH` by `01-env.sh`). `eza` is a *different program* whose flags overlap with `ls` but do not match, so aliasing `ls` to it makes familiar commands do surprising things:

| You type | GNU `ls` | `eza` |
| --- | --- | --- |
| `-h` | human-readable sizes | **`--header`** — adds a header row |
| `-G` | (BSD) enable colour | `--grid` |

So `eza` gets its own names instead: `e`, `l`, `ll`, `llm`, `la`, `lax`, `lx`, `lS`, `lt`, plus `lsh` (`eza -lb` — the `ls -lh` analogue) and `lsd` (`eza -ld` — the `ls -ld` analogue). All of them are defined only if `eza` is actually installed.

### Other tools

Same pattern applies wherever a tool supports it:

- **nvim:** add a `lua/local.lua` and `pcall(require, "local")` from your init.
- **wezterm:** already wired up. `~/.wezterm.local.lua` must **return a table** of settings — e.g. `return { font_size = 14 }` — which `.wezterm.lua` merges into `config`. It cannot assign to `config` directly, because `dofile` runs the file as its own chunk that cannot see the caller's locals.
- **ghostty:** `config-file = ~/.config/ghostty/config.local`.

## Adding a new tool

1. Create `dotfiles/<tool>/` with the tool's files at their `$HOME`-relative paths.
2. Re-run `./install.sh` (or just `stow -d dotfiles -t ~ <tool>`).
3. If the tool has machine-specific bits, decide on a `.local` convention for it and document it here.
