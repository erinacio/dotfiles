# Fork from honukai zsh theme https://github.com/oskarkrawczyk/honukai-iterm-zsh
prompt off
setopt PROMPT_SUBST

# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo $HOST
}

# Directory info.
local current_dir='${PWD/#$HOME/~}'

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$reset_color%}("
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%})"
YS_VCS_PROMPT_DIRTY="%{$fg_bold[red]%}!"
YS_VCS_PROMPT_CLEAN=""

# Git info.
if ! [[ "$(uname -s)" =~ '^CYGWIN|^MSYS|^MINGW' ]]; then
    local git_info='$(git_prompt_info)'
    ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
    ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
    ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"
else
    local git_info=''
fi

# Python virtualenv info
if ! [[ "$(uname -s)" =~ '^CYGWIN|^MSYS|^MINGW' ]]; then
    local venv_info='$(ys_venv_prompt_info)'
    function ys_venv_prompt_info() {
        if [ -n "${VIRTUAL_ENV}" ]; then
            local _venv_basename="${VIRTUAL_ENV##*/}"
            if [[ "$_venv_basename" == ".venv" ]]; then  # pipenv local virtualenv
                local _venv_basename="${${VIRTUAL_ENV%/*}##*/}"
            fi
            echo -n " %{$reset_color%}(venv:%{$fg[green]%}$_venv_basename%{$reset_color%})"
        fi
    }
else
    local venv_info=''
fi

if [[ "$USER" != "root" ]]; then
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%{$fg[cyan]%}%n\
%{$fg[white]%}@\
%{$fg[green]%}$(box_name)\
%{$fg[white]%}:\
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${venv_info}\
${git_info}\
$PROMPT_POSTFIX
%(?.%{$fg_no_bold[green]%}.%{$fg_bold[red]%})$ %{$reset_color%}"
else
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%{$fg[cyan]%}%n\
%{$fg[white]%}@\
%{$fg[green]%}$(box_name)\
%{$fg[white]%}:\
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%}\
${venv_info}\
${git_info}\
$PROMPT_POSTFIX
%(?.%{$fg_no_bold[green]%}.%{$fg_bold[red]%})$ %{$reset_color%}"
fi
