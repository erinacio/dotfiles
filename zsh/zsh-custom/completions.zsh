load_remote_comp github.com/zsh-users/zsh-completions src
if ! ismsys; then
    load_remote_comp github.com/docker/cli contrib/completion/zsh
fi
