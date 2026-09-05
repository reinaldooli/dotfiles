# --- Shell options ---

# Typing a directory name on its own changes into it -- `src/api` instead of
# `cd src/api`. This is also what makes a bare `..` work without an alias.
setopt AUTO_CD

# Every cd pushes onto the directory stack, so `cd -` toggles back to where
# you were and `cd -2`, `cd -3`, ... jump to earlier directories.
# `d` (03-navigation.sh) prints the stack with its numbers.
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS   # keep repeats out of the stack
setopt PUSHD_SILENT        # don't dump the stack after every cd
