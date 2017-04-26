######################### override.zsh #########################
zstyle ':completion:*:corrections'  format $'%{\e[0m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:descriptions' format $'%{\e[0m%}%B%d%b%{\e[0m%}'
zstyle ':completion:*:warnings'     format $'%{\e[0m%}No matches for:%{\e[0m%} %d'
zstyle ':completion:*'              menu select=1
zstyle ':completion:*'              use-cache on
zstyle ':completion:*'              cache-path ~/.zsh/cache

######################### report-time.zsh #########################
export REPORTTIME=1

######################### keybindings.zsh #########################
# Make the delete key (or Fn + Delete on the Mac) work instead of outputting a ~
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
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

######################### colors.zsh #########################
autoload colors; colors

# The variables are wrapped in \%\{\%\}. This should be the case for every
# variable that does not contain space.
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
  eval PR_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
  eval PR_BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done

eval RESET='$reset_color'
export PR_RED PR_GREEN PR_YELLOW PR_BLUE PR_WHITE PR_BLACK
export PR_BOLD_RED PR_BOLD_GREEN PR_BOLD_YELLOW PR_BOLD_BLUE
export PR_BOLD_WHITE PR_BOLD_BLACK

# Clear LSCOLORS
unset LSCOLORS

######################### setopts.zsh #########################
# ===== Basics
setopt no_beep # don't beep on error
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)

# ===== Changing Directories
setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt cdablevarS # if argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory
setopt pushd_ignore_dups # don't push multiple copies of the same directory onto the directory stack

# ===== Expansion and Globbing
setopt extended_glob # treat #, ~, and ^ as part of patterns for filename generation

# ===== History
setopt append_history # Allow multiple terminal sessions to all append to one zsh command history
setopt extended_history # save timestamp of command and duration
setopt inc_append_history # Add comamnds as they are typed, don't wait until shell exit
setopt hist_expire_dups_first # when trimming history, lose oldest duplicates first
setopt hist_ignore_dups # Do not write events to history that are duplicates of previous events
setopt hist_ignore_space # remove command line from history list when first character on the line is a space
setopt hist_find_no_dups # When searching history don't display results already cycled through twice
setopt hist_reduce_blanks # Remove extra blanks from each command line being added to history
setopt hist_verify # don't execute, just expand history
setopt share_history # imports new commands and appends typed commands to history

# ===== Completion
setopt always_to_end # When completing from the middle of a word, move the cursor to the end of the word
setopt auto_menu # show completion menu on successive tab press. needs unsetop menu_complete to work
setopt auto_name_dirs # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt complete_in_word # Allow completion from within a word/phrase

unsetopt menu_complete # do not autoselect the first completion entry

# ===== Correction
setopt correct # spelling correction for commands
setopt correctall # spelling correction for arguments

# ===== Prompt
setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt transient_rprompt # only show the rprompt on the current prompt

# ===== Scripts and Functions
setopt multios # perform implicit tees or cats when multiple redirections are attempted

######################### history.zsh #########################
HISTSIZE=10000
SAVEHIST=9000
HISTFILE=~/.zsh_history

######################### os-release.zsh #########################
if which lsb_release > /dev/null ; then
    LSB_ID=$(lsb_release -si)
    LSB_RELEASE=$(lsb_release -sr)
fi

######################### no-correction.zsh #########################
unsetopt correct
unsetopt correct_all

######################### common-alias.zsh #########################
alias cls='printf "\033c"'
alias l='ls -lah'
alias l.='ls -d .* --color=auto'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=auto "--ignore=NTUSER.DAT*" "--ignore=ntuser.dat*" --ignore=ntuser.ini'
alias lsa='ls -lah'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

alias vi='vim'
alias vimz="vim $ZSH_CUSTOM_DIR/custom.zsh"
alias cdz="cd $ZSH_CUSTOM_DIR"

# from zsh-lovers
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g CA="2>&1 | cat -A"
alias -g C='| wc -l'
alias -g D="DISPLAY=:0.0"
alias -g DN=/dev/null
alias -g ED="export DISPLAY=:0.0"
alias -g EG='|& egrep'
alias -g EH='|& head'
alias -g EL='|& less'
alias -g ELS='|& less -S'
alias -g ETL='|& tail -20'
alias -g ET='|& tail'
alias -g F=' | fmt -'
alias -g G='| egrep'
alias -g H='| head'
alias -g HL='|& head -20'
alias -g Sk="*~(*.bz2|*.gz|*.tgz|*.zip|*.z)"
alias -g LL="2>&1 | less"
alias -g L="| less"
alias -g LS='| less -S'
alias -g MM='| most'
alias -g M='| more'
alias -g NE="2> /dev/null"
alias -g NS='| sort -n'
alias -g NUL="> /dev/null 2>&1"
alias -g PIPE='|'
alias -g R=' > /c/aaa/tee.txt '
alias -g RNS='| sort -nr'
alias -g S='| sort'
alias -g TL='| tail -20'
alias -g T='| tail'
alias -g US='| sort -u'
alias -g VM=/var/log/messages
alias -g X0G='| xargs -0 egrep'
alias -g X0='| xargs -0'
alias -g XG='| xargs egrep'
alias -g X='| xargs'

######################### extra-alias.zsh #########################
if type sudo NUL; then
    _sudo='sudo'
else
    _sudo=''
fi

# pacman
if type pacman NUL; then
    alias pacadd="$_sudo pacman -S --needed"
    alias pacins="$_sudo pacman -U"
    alias pacrm="$_sudo pacman -Rs"
    alias pacupd="$_sudo pacman -Syu"
    alias pacfind='pacman -Ss'
    alias pacinfo='pacman -Si'
    alias pacls='pacman -Q'
fi

# pacaur
if type pacaur NUL; then
    # assume we have pacman installed'
    alias pacadd='pacaur -S --needed'
    alias pacupd='pacaur -Syu'
    alias pacfind='pacaur -Ss'
    alias pacinfo='pacaur -Si'
fi

# apt & dpkg
if type apt NUL; then
    alias pacadd="$_sudo apt install"
    alias pacins="$_sudo apt install"
    alias pacrm="$_sudo apt remove"
    alias pacupd="$_sudo apt update && sudo apt upgrade"
    alias pacfind='apt search'
    alias pacinfo='apt show'
    alias pacls='apt list'
fi

# dnf
if type dnf NUL; then
    alias pacadd="$_sudo dnf --color install"
    alias pacins="$_sudo dnf --color install"
    alias pacrm="$_sudo dnf --color remove"
    alias pacupd="$_sudo dnf --color upgrade"
    alias pacfind="$_sudo dnf --color search"
    alias pacinfo='dnf --color info'
    alias pacls='dnf --color list installed'
fi

# zypper
if type zypper NUL; then
    alias pacadd="$_sudo zypper --color in"
    alias pacins="$_sudo zypper --color in"
    alias pacrm="$_sudo zypper --color rm"
    alias pacupd="$_sudo zypper --color up"
    alias pacfind='zypper --color se'
    alias pacinfo='zypper --color if'
    alias pacls='zypper --color se --installed-only'
fi

# systemctl
if type systemctl NUL; then
    alias srvstart="$_sudo systemctl start"
    alias srvstop="$_sudo systemctl stop"
    alias srvrestart="$_sudo systemctl restart"
    alias srven="$_sudo systemctl enable"
    alias srvdis="$_sudo systemctl disable"
    alias srvmask="$_sudo systemctl mask"
    alias srvunmask="$_sudo systemctl unmask"
    alias srvreload="$_sudo systemctl daemon-reload"
    alias srvstat='systemctl status'
fi

# docker
if type docker NUL; then
    alias docker="$_sudo docker"
fi
