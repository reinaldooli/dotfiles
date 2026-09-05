export EDITOR=vim
export GIT_EDITOR="$EDITOR"

# --- Homebrew ---
# Apple Silicon installs Homebrew under /opt/homebrew, Intel under
# /usr/local. Resolve it at runtime instead of hardcoding one of them, so
# the same config works on every machine.
#
# ~/.zprofile normally runs shellenv already; the guard keeps a nested or
# re-sourced shell from prepending the same entries to PATH twice.
if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$_brew" ]]; then
      eval "$("$_brew" shellenv)"
      break
    fi
  done
  unset _brew
fi

# --- GNU userland ---
# macOS ships BSD ls/find/sed/awk. Homebrew keeps the GNU builds off PATH by
# default, exposing them under each formula's gnubin directory under their
# plain names (ls, find, sed, awk) rather than the g-prefixed ones.
#
# This is a PATH entry rather than `alias sed=gsed` on purpose: aliases only
# exist in interactive shells, so a script would silently get the BSD tool
# and behave differently from the same command typed at the prompt.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  for _formula in coreutils findutils gnu-sed gawk; do
    _gnubin="$HOMEBREW_PREFIX/opt/$_formula/libexec/gnubin"
    [[ -d "$_gnubin" ]] && PATH="$_gnubin:$PATH"
  done
  unset _formula _gnubin
  export PATH
fi
