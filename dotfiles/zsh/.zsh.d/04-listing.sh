# --- Listing ---
# `ls` deliberately stays the real ls (GNU coreutils, put on PATH in
# 01-env.sh). eza is a different program with overlapping but incompatible
# flags, so aliasing ls to it makes familiar invocations do surprising things:
#
#   ls -lh   ->  in eza, -h is --header (a header row), not --human-readable
#   ls -G    ->  in eza, -G is --grid; in BSD ls it enables colour
#
# eza gets its own names instead, so both tools stay predictable.
if command -v eza >/dev/null 2>&1; then
  # general use
  alias e='eza'
  alias l='eza -lbF'                                                     # list, size, type
  alias ll='eza -lbGF --git'                                             # long list
  alias llm='eza -lbGF --git --sort=modified'                            # long list, modified date sort
  alias la='eza -lba --icons=always --color-scale'                       # all, with icons
  alias lax='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale' # all list
  alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

  # speciality views
  alias lS='eza -1'                                                      # one column, just names
  alias lt='eza --tree --level=2'                                        # tree

  # eza equivalents of the two ls flags that do not carry over
  alias lsh='eza -lb'                                                    # like `ls -lh`: long, human-readable sizes (-b = KiB/MiB)
  alias lsd='eza -ld'                                                    # like `ls -ld`: the directory entry itself, not its contents
fi
# No else branch on purpose. A machine without eza should lose these aliases
# quietly -- the previous version printed a warning on every new shell and
# `return 1`, which aborted the rest of the file.
