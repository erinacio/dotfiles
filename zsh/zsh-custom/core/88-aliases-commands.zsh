## Enable ls coloring
if ismsys; then
    alias ls='ls --color=auto "--ignore=NTUSER.DAT*" "--ignore=ntuser.dat*" --ignore=ntuser.ini'
elif islinux; then
    alias ls='ls --color=auto'
elif isdarwin; then
    export CLICOLOR=1
    export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
fi

## ls related aliases
alias l='ls -lah'
alias l.='ls -d .*'
alias la='ls -lAh'
alias ll='ls -lh'
alias lsa='ls -lah'

## cd
alias cdbin='cd "$HOME/.local/bin"'
alias cdsrc='cd "$HOME/src"'
alias cdproj='cd "$HOME/Projects"'
alias cdmisc='cd "$HOME/Miscellaneous"'
if type go NUL; then
    alias cdgo='cd "$GOPATH"'
fi

## grep related aliases
alias grep="grep --color=auto"
alias egrep='grep -E'
alias fgrep='grep -F'

## checksum calculator in coreutils
if isdarwin && type gmd5sum NUL; then
    alias md5sum=gmd5sum
    alias sha1sum=gsha1sum
    alias sha224sum=gsha224sum
    alias sha256sum=gsha256sum
    alias sha384sum=gsha384sum
    alias sha512sum=gsha512sum
fi

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
