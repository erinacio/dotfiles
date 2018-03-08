## Modify completion settings
zstyle ':completion:*:corrections'  format $'%{\e[0m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:descriptions' format $'%{\e[0m%}%B%d%b%{\e[0m%}'
zstyle ':completion:*:warnings'     format $'%{\e[0m%}No matches for:%{\e[0m%} %d'
zstyle ':completion:*'              menu select=1
zstyle ':completion:*'              use-cache on
zstyle ':completion:*'              cache-path ~/.zsh/cache

## Report time for long-running commands
export REPORTTIME=1

## throw and catch
autoload throw catch

## Keybindings
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

## Colors
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

## Options
# ===== Basics
setopt no_beep # don't beep on error
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)

# ===== Changing Directories
# setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
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

# ===== Prompt
setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt transient_rprompt # only show the rprompt on the current prompt

# ===== Scripts and Functions
setopt multios # perform implicit tees or cats when multiple redirections are attempted

setopt null_glob

unsetopt autopushd
