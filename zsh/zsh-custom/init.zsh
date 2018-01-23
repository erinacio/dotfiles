local _zsh_custom_dir="${funcsourcetrace[1]%/*}"
export ZSH_CUSTOM_DIR="$_zsh_custom_dir"

for f in "$_zsh_custom_dir"/core/*.zsh; do
    if [ -f "$f" ]; then
        source "$f"
    fi
done

source "$_zsh_custom_dir/modules.zsh"
unfunction load_module

source "$_zsh_custom_dir/prompt.zsh"
source "$_zsh_custom_dir/custom.zsh"
