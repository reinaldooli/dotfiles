# --- Directory navigation ---
# AUTO_CD (00-options.sh) already makes a bare `..` work, since `..` is a real
# directory. `...` and deeper are not, so they need aliases.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias -- -='cd -'   # back to the previous directory
alias d='dirs -v'   # numbered directory stack; jump with `cd -2`, `cd -3`, ...
