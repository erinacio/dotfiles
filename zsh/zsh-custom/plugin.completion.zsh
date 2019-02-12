0=${${(%):-%N}:a}
git_clone_if_not_exists -0 completion https://github.com/zsh-users/zsh-completions.git "${0:h}/zsh-completions"
fpath+="${0:h}/zsh-completions/src"
