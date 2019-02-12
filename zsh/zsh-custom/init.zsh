0=${${(%):-%N}:a}
ZSH_CUSTOM_DIR="${0:h}"
ZSH_NESTED="$ZSH_NESTED${ZSH_NESTED+ }$$"
zsh_nested=("${(s. .)ZSH_NESTED}")
typeset -gxr ZSH_CUSTOM_DIR
typeset -gxr ZSH_NESTED
typeset -ar zsh_nested

pre_scripts=(
plugin.completion
)

post_scripts=(
plugin.syntax-highlighting
)

typeset -ar pre_scripts
typeset -ar post_scripts

no_dynamic=0
if (( $UID == 0 )) || (( $NO_DYNAMIC )); then
    no_dynamic=1
fi

typeset -r no_dynamic

## Options
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

setopt always_to_end
setopt auto_menu
setopt auto_name_dirs
setopt complete_in_word
setopt list_packed
setopt hash_list_all
unsetopt menu_complete

setopt extended_glob
setopt null_glob
unsetopt glob_dots
unsetopt sh_word_split
setopt unset

setopt append_history
setopt extended_history
setopt inc_append_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt share_history

setopt correct
setopt interactive_comments

unsetopt hup
setopt long_list_jobs
setopt notify

setopt prompt_subst
setopt transient_rprompt

setopt multios

unsetopt beep


## ZSH internal envs

HISTFILE=${HISTFILE:-${ZDOTDIR:-${HOME}}/.zsh_history}
HISTSIZE=5000
SAVEHIST=10000

DIRSTACKSIZE=${DIRSTACKSIZE:-50}

NOCOR=${NOCOR:-0}
NOMENU=${NOMENU:-0}
NOPRECMD=${NOPRECMD:-0}
COMMAND_NOT_FOUND=${COMMAND_NOT_FOUND:-0}
ZSH_NO_DEFAULT_LOCALE=${ZSH_NO_DEFAULT_LOCALE:-0}

REPORT_TIME=1


## Core helper functions
function has_command {
    (( ${+commands[$1]} ))
}

function ask_yesno {
    local default_ret=0
    while true; do
        case $1 in
            -y) default_ret=0; shift 1;;
            -n) default_ret=1; shift 1;;
            -h)
                echo "$0: [-y|-n] prompt"
                echo "options:"
                echo "    -y  default to yes"
                echo "    -n  default to no"
                return 255;;
            -*)
                echo "$0: unknown option $1" >&2
                return 255;;
            *) break;;
        esac
    done
    local prompt="${*:-Yes or no?}"
    local answer
    if (( $default_ret == 0 )); then
        read -k 1 "answer?$prompt (Y/n)"
    else
        read -k 1 "answer?$prompt (y/N)"
    fi
    case ${answer:0:1} in
        y|Y) return 0;;
        n|N) return 1;;
        *)   return $default_ret;;
    esac
}

_kernel_name="$(command uname -s)"

function is_linux {
    [[ $_kernel_name == "Linux" ]]
}

function is_darwin {
    [[ $_kernel_name == "Darwin" ]]
}

function is_freebsd {
    [[ $_kernel_name == "FreeBSD" ]]
}

function is_openbsd {
    [[ $_kernel_name == "OpenBSD" ]]
}

function is_cygwin {
    [[ $_kernel_name == CYGWIN_NT-* ]]
}

function is_msys {
    [[ $_kernel_name == "${MSYSTEM}_NT-"* ]]
}

function is_ssh {
    [[ -n $SSH_TTY ]]
}


## SCM helper functions
function git_repo_root {
    git rev-parse --show-toplevel 2>/dev/null
}

function git_simple_status {
    local display_branch=0
    local display_remote_branch=0
    while (( ${#argv} > 0 )); do
        case $1 in
            -b)
                display_branch=1
                shift 1
                ;;
            -r)
                display_remote_branch=1
                shift 1
                ;;
            -h)
                echo "$0 [-b] [-r]"
                echo 'options:'
                echo '    -b  show branch info'
                echo '    -r  also show tracking remote branch info if possible'
                return 0
                ;;
            -*)
                echo "$0: unknown option $1"
                return 255
                ;;
            *)
                printf '%s: unknown argument %q\n' "$0" "$1"
                return 255
                ;;
        esac
    done

    if ! has_command git; then
        echo "$0: no git command found" >&2
        return 2
    fi

    local git_status=$(command git status -sb --no-column --no-ahead-behind --no-renames 2>/dev/null)
    if [[ -z $git_status ]]; then
        return 1
    fi
    local lines=("${(f)git_status}")
    local branch_line_parts=("${(s. .)lines[1]}")
    local branch_parts=("${(s:...:)branch_line_parts[2]}")
    local branch="$branch_parts[1]"
    local remote_branch="$branch_parts[2]"
    local stat_first_line="$lines[2]"
    if (( $display_branch )); then
        if [[ $branch == "HEAD" ]]; then
            command git rev-parse --short HEAD 2>/dev/null || echo '?unknown?'
        elif [[ -z $remote_branch ]]; then
            echo "$branch"
        elif (( $display_remote_branch )); then
            echo "$branch $remote_branch"
        else
            echo "$branch"
        fi
    fi
    if [[ -z $stat_first_line ]]; then
        echo "clean"
    else
        echo "dirty"
    fi
}

function git_is_repo {
    [[ -n $1 && -f "$1/.git/HEAD" && -d "$1/.git/objects" && -d "$1/.git/refs" ]]
}

function git_clone_if_not_exists {
    local always_yes=0
    while true; do
        case $1 in
            -y) always_yes=1; shift 1;;
            -0) 0=$2; shift 2;;
            -h) echo "$0 [-y] [-0 NAME] remote-url local-dir"
                echo "options:"
                echo "    -y       clone if not exists without confirm"
                echo '    -0 NAME  use NAME as $0'
                return 0;;
            -*) echo "$0: unknown option $1" >&2; return 255;;
            *)  break;;
        esac
    done

    if (( ${#argv} > 2)); then
        echo "$1: too many arguments" >&2
        return 255
    fi

    local remote_url="$1"
    local local_dir="$2:a"

    if [[ -z $remote_url ]]; then
        echo "$0: remote url not specified" >&2
        return 255
    fi
    if [[ -z $local_dir ]]; then
        echo "$0: local dir not specified" >&2
        return 255
    fi
    if git_is_repo "$local_dir"; then
        return 0
    fi
    if [[ -e $local_dir ]]; then
        echo "$0: $local_dir already exists but is not a git repo" >&2
        return 255
    fi
    if (( $always_yes )) || ask_yesno "$0: $local_dir is empty, clone from $remote_url?"; then
        command git clone "$remote_url" "$local_dir"
        return $?
    else
        return 1
    fi
}


## Editor
if [[ -z $EDITOR ]]; then
    if has_command nano; then
        export EDITOR=${commands[nano]}
    fi
    if has_command vi; then
        export EDITOR=${commands[vi]}
    fi
    if has_command emacs; then
        export EDITOR=${commands[emacs]}
    fi
    if has_command vim; then
        export EDITOR=${commands[vim]}
    fi
    if is_darwin && has_command mvim; then
        export EDITOR=${commands[mvim]}
    fi
fi


## Preload
if (( $no_dynamic )); then
else
    for script in $pre_scripts; do
        if [[ $script == */* ]]; then
            echo "error: invalid script name $script" >&2
            continue
        fi
        source "$ZSH_CUSTOM_DIR/$script.zsh"
    done
fi


## Colors, from grml zsh config
# Colors on GNU ls(1)
if ls --color=auto / >/dev/null 2>&1; then
    ls_options+=( --color=auto )
# Colors on FreeBSD and OSX ls(1)
elif ls -G / >/dev/null 2>&1; then
    ls_options+=( -G )
fi
# Natural sorting order on GNU ls(1)
# OSX and IllumOS have a -v option that is not natural sorting
if ls --version |& grep -q 'GNU' >/dev/null 2>&1 && ls -v / >/dev/null 2>&1; then
    ls_options+=( -v )
fi
# Color on GNU and FreeBSD grep(1)
if grep --color=auto -q "a" <<< "a" >/dev/null 2>&1; then
    grep_options+=( --color=auto )
fi

if [[ "$TERM" != dumb ]]; then
    #a1# List files with colors (\kbd{ls \ldots})
    alias ls="command ls ${ls_options:+${ls_options[*]}}"
    #a1# List all files, with colors (\kbd{ls -la \ldots})
    alias la="command ls -la ${ls_options:+${ls_options[*]}}"
    #a1# List files with long colored list, without dotfiles (\kbd{ls -l \ldots})
    alias ll="command ls -l ${ls_options:+${ls_options[*]}}"
    #a1# List files with long colored list, human readable sizes (\kbd{ls -hAl \ldots})
    alias lh="command ls -hAl ${ls_options:+${ls_options[*]}}"
    #a1# List files with long colored list, append qualifier to filenames (\kbd{ls -l \ldots})\\&\quad(\kbd{/} for directories, \kbd{@} for symlinks ...)
    alias l="command ls -l ${ls_options:+${ls_options[*]}}"
else
    alias la='command ls -la'
    alias ll='command ls -l'
    alias lh='command ls -hAl'
    alias l='command ls -l'
fi

has_command dircolors && eval $(dircolors -b)
if is_darwin || is_freebsd; then
    export CLICOLOR=1
    export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
fi

## Misc
# automatically remove duplicates from these arrays
typeset -U path PATH cdpath CDPATH fpath FPATH manpath MANPATH

# Load a few modules
for mod in parameter complist deltochar mathfunc ; do
    zmodload -i zsh/${mod} 2>/dev/null || print "Notice: no ${mod} available :("
done && builtin unset -v mod

zmodload -a  zsh/stat    zstat
zmodload -a  zsh/zpty    zpty
zmodload -ap zsh/mapfile mapfile


## Completion
COMPDUMPFILE=${COMPDUMPFILE:-${ZDOTDIR:-${HOME}}/.zcompdump}
if autoload -Uz compinit ; then
    compinit -d ${COMPDUMPFILE}
fi

# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*'       insert-unambiguous true
zstyle ':completion:*:corrections'     format $'%d (errors: %e)'
zstyle ':completion:*:correct:*'       original true

# activate color-completion
zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

# format on completion
zstyle ':completion:*:descriptions'    format $'completing %B%d%b'

# automatically complete 'cd -<tab>' and 'cd -<ctrl-d>' with menu
# zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

# insert all expansions for expand completer
zstyle ':completion:*:expand:*'        tag-order all-expansions
zstyle ':completion:*:history-words'   list false

# activate menu
zstyle ':completion:*:history-words'   menu yes

# ignore duplicate entries
zstyle ':completion:*:history-words'   remove-all-dups yes
zstyle ':completion:*:history-words'   stop yes

# match uppercase from lowercase
zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

# separate matches into groups
zstyle ':completion:*:matches'         group 'yes'
zstyle ':completion:*'                 group-name ''

zstyle ':completion:*:messages'        format '%d'
zstyle ':completion:*:options'         auto-description '%d'

# describe options in full
zstyle ':completion:*:options'         description 'yes'

# on processes completion complete all user processes
zstyle ':completion:*:processes'       command 'ps -au$USER'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# provide verbose completion information
zstyle ':completion:*'                 verbose true

# recent (as of Dec 2007) zsh versions are able to provide descriptions
# for commands (read: 1st word in the line) that it will list for the user
# to choose from. The following disables that, because it's not exactly fast.
zstyle ':completion:*:-command-:*:'    verbose false

# set format for warnings
zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

# define files to ignore for zcompile
zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:'          prompt 'correct to: %e'

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# Search path for sudo completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                           /usr/local/bin  \
                                           /usr/sbin       \
                                           /usr/bin        \
                                           /sbin           \
                                           /bin            \
                                           /usr/X11R6/bin

# provide .. as a completion
zstyle ':completion:*' special-dirs ..

zstyle ':completion:*'              menu select=1
zstyle ':completion:*'              use-cache on
zstyle ':completion:*'              cache-path ~/.zsh/cache

# run rehash on completion so new installed program are found automatically:
function _force_rehash () {
    (( CURRENT == 1 )) && rehash
    return 1
}

zstyle -e ':completion:*' completer '
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
        _last_try="$HISTNO$BUFFER$CURSOR"
        reply=(_complete _match _ignored _prefix _files)
    else
        if [[ $words[1] == (rm|mv) ]] ; then
            reply=(_complete _files)
        else
            reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
        fi
    fi'

zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
    $(hostname)
    "$_ssh_config_hosts[@]"
    "$_ssh_hosts[@]"
    "$_etc_hosts[@]"
    localhost
)
zstyle ':completion:*:hosts' hosts $hosts

# use generic completion system for programs not yet defined; (_gnu_generic works
# with commands that provide a --help option with "standard" gnu-like output.)
for compcom in cp deborphan df feh fetchipac gpasswd head hnb ipacsum mv \
               pal stow uname ; do
    [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom


## ZLE Keybindings
# Make the delete key (or Fn + Delete on the Mac) work instead of outputting a ~
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
key[ShiftTab]=${terminfo[kcbt]}

# setup key accordingly
[[ -n "${key[Home]}"    ]]   && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"     ]]   && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"  ]]   && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"  ]]   && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"      ]]   && bindkey  "${key[Up]}"       up-line-or-beginning-search
[[ -n "${key[Down]}"    ]]   && bindkey  "${key[Down]}"     down-line-or-beginning-search
[[ -n "${key[Left]}"    ]]   && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"   ]]   && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[ShiftTab]}" ]]  && bindkey  "${key[ShiftTab]}" reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        echoti smkx
    }
    function zle-line-finish () {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi


## Colors
autoload -Uz colors && colors


## Prompt
typeset -ga prompt_tag_functions

function prompt_local_setup {
    prompt_opts=('cr' 'percent' 'sp')
    if (( $no_dynamic )); then
        PS1="$(_prompt_local_prompt)"
    else
        prompt_opts+=subst
        PS1='$(_prompt_local_prompt)'
    fi
    PS2='\`%_> '
    PS3='?# '
    PS4='+%N:%i:%_> '
}

function _prompt_local_prompt {
    print "%{$reset_color%}"
    print -n "%{$fg_bold[blue]%}#%{$reset_color%}"
    print -n " %{$fg_no_bold[cyan]%}%n%{$reset_color%}@%{$fg_no_bold[green]%}%M%{$reset_color%}"
    print -n ":%{$fg_bold[yellow]%}%~%{$reset_color%}"
    if (( $UID )); then
        for tag in $prompt_tag_functions; do
            local content="$($tag)"
            [[ -n $content ]] && print -n " %{$reset_color%}($content%{$reset_color%})"
        done
    fi
    print
    print -n "%{$reset_color%}%(?.%{$fg_no_bold[green]%}.%{$fg_bold[red]%})%%%{$reset_color%} "
}

# Do it after prompt function defined
if autoload -Uz promptinit && promptinit; then
    prompt_themes+=( 'local' )
    prompt_themes=("${(@on)prompt_themes}")

    prompt 'local'
fi

function _prompt_tag_git {
    local simple_status="$(git_simple_status -b -r)"
    if (( $? )) || [[ -z $simple_status ]]; then
        return
    fi
    local status_parts=("${(f)simple_status}")
    local branch_parts=("${(s. .)status_parts[1]}")
    print -n "%Bgit%b:%{$fg_no_bold[green]$branch_parts[1]"
    case $status_parts[2] in
        clean) ;;
        dirty) print -n "$fg_bold[red]!";;
        *) print -n "$fg_no_bold[red]?";;
    esac
    [[ -n $branch_parts[2] ]] && print -n -- "$reset_color->$fg_no_bold[cyan]$branch_parts[2]"
    print -n '%}'
}
prompt_tag_functions+=_prompt_tag_git

function _prompt_tag_proxy {
    local proxies=()
    [[ -n $ALL_PROXY   || -n $all_proxy   ]] && proxies+=all
    [[ -n $HTTP_PROXY  || -n $http_proxy  ]] && proxies+=http
    [[ -n $HTTPS_PROXY || -n $https_proxy ]] && proxies+=https
    [[ -n $FTP_PROXY   || -n $ftp_proxy   ]] && proxies+=ftp
    [[ -n $RSYNC_PROXY || -n $rsync_proxy ]] && proxies+=rsync
    (( ${#proxies} )) && print -n "%Bproxy%b:${(j.,.)proxies}"
}
prompt_tag_functions+=_prompt_tag_proxy


## Aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g DN=/dev/null
alias -g NUL="> /dev/null 2>&1"
alias -g NE="2> /dev/null"

if has_command sudo && has_command docker; then
    alias docker='sudo docker'
fi


## Other helper functions
function cdz {
    builtin cd "$ZSH_CUSTOM_DIR"
}

function viz {
    ${EDITOR:-vi} "${ZDOTDIR:-${HOME}}/.zshrc"
}

function vienv {
    ${EDITOR:-vi} "${ZDOTDIR:-${HOME}}/.zshenv"
}

# smart cd function, allows switching to /etc when running 'cd /etc/fstab'
function cd {
    if (( ${#argv} == 1 )) && [[ -f ${1} ]]; then
        [[ ! -e ${1:h} ]] && return 1
        print "Correcting ${1} to ${1:h}"
        builtin cd ${1:h}
    else
        builtin cd "$@"
    fi
}


if (( $no_dynamic )); then
else
    for script in $post_scripts; do
        if [[ $script == */* ]]; then
            echo "error: invalid script name $script" >&2
            continue
        fi
        source "$ZSH_CUSTOM_DIR/$script.zsh"
    done
fi
