## Enable ls coloring
if ismsys; then
    alias ls='ls --color=auto "--ignore=NTUSER.DAT*" "--ignore=ntuser.dat*" --ignore=ntuser.ini'
elif islinux; then
    alias ls='ls --color=auto'
elif isdarwin && type gls NUL; then
    alias ls="gls --color=auto"
fi

## ls related aliases
alias l='ls -lah'
alias l.='ls -d .*'
alias la='ls -lAh'
alias ll='ls -lh'
alias lsa='ls -lah'

## grep related aliases
alias grep="grep --color=auto"
alias egrep='grep -E'
alias fgrep='grep -F'

## docker
if ! isdarwin && type sudo NUL && type docker NUL; then
    alias docker-orig="$(which docker)"
    alias docker='sudo docker'
fi

## others
function _regist_zsh_custom_aliases() {
    local _zsh_custom_dir="${funcsourcetrace[1]%/*/*}"
    alias cdz="cd '$_zsh_custom_dir'"
    alias vimz="vim '$_zsh_custom_dir/custom.zsh'"
    alias cdmod="cd '$_zsh_custom_dir/mod'"
    alias vimmod="vim '$_zsh_custom_dir/modules.zsh'"
    alias vimcomp="vim '$_zsh_custom_dir/completions.zsh'"
}
_regist_zsh_custom_aliases
unfunction _regist_zsh_custom_aliases
