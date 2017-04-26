autoload -Uz compinit
if [[ $(date +'%j') > $(date +'%j' -r "${HOME}/.zcompdump") ]]; then
    compinit
else
    compinit -C
fi
zmodload -i zsh/complist
