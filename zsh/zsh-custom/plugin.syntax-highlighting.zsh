0=${${(%):-%N}:a}
git_clone_if_not_exists -0 syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git "${0:h}/zsh-syntax-highlighting" \
    && source "${0:h}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
