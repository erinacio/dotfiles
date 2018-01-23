function _check_module_name() {
    if ! (( ${+1} )); then
        echo "$0: Module name required" > /dev/stderr
        return 1
    fi

    if [[ $1 == */.. || $1 == */../* ]]; then
        echo "$0: Module name should not contain '..' directory" > /dev/stderr
        return 1
    fi
}

function load_module() {
    # load_module <module-name> [entry-point]

    _check_module_name "$1" || return 1

    if (( ${+2} )); then
        if [[ $2 == */.. || $2 == */../* ]]; then
            echo "$0: Entry point should not contain '..' directory" > /dev/stderr
            return 1
        fi
    fi

    if (( ${+3} )); then
        echo "$0: Too many arguments" > /dev/stderr
        return 1
    fi

    local _mod_path="${funcsourcetrace[1]%/*/*}/mod/$1"

    if (( ${+2} )); then
        local _entry_path="$_mod_path/$2"
        if [[ -f "$_entry_path" ]]; then
            source "$_entry_path"
            return 0
        else
            echo "$0: Entry point '$2' of module '$1' is not found" > /dev/stderr
            return 2
        fi
    else
        if [[ -f "$_mod_path/init.zsh" ]]; then
            source "$_mod_path/init.zsh"
        elif [[ "$_mod_path" =~ '^.*\.zsh$' ]] && [ -f "$_mod_path" ]; then
            source "$_mod_path"
        elif [[ -f "$_mod_path.zsh" ]]; then
            source "$_mod_path.zsh"
        elif [[ -f "$_mod_path/$(basename $_mod_path).zsh" ]]; then
            source "$_mod_path/$(basename $_mod_path).zsh"
        else
            echo "$0: Module '$1' not found" > /dev/stderr
            return 2
        fi
    fi
}

function sync_module() {
    # sync_module <module-name>

    _check_module_name "$1" || return 1

    local _zsh_custom_dir="${funcsourcetrace[1]%/*/*}"
    local _mod_dir="$_zsh_custom_dir/mod"
    local _mod_path="$_mod_dir/$1"

    if ! type git > /dev/null 2>&1; then
        echo "$0: git not found" > /dev/stderr
        return 1
    fi

    if [[ -d "$_mod_path" ]]; then
        if [[ -d "$_mod_path/.git" ]]; then
            (
            echo git pull
            cd "$_mod_path" && git pull
            )
            return $?
        else
            echo "$0: Module '$1' exists but is not a git repository" > /dev/stderr
            return 1
        fi
    elif [[ -e "$_mod_path" ]]; then
        echo "$0: Module '$1' exists but is not a directory, nor is a git repository" > /dev/stderr
        return 1
    else
        (
        echo git clone --recursive "https://$1" "$_mod_path"
        cd "$_mod_dir" && git clone --recursive "https://$1" "$_mod_path"
        )
        return $?
    fi
}

function load_remote_module() {
    # load_remote_module <module-name> [entry-point]

    load_module $@
    local _error=$?
    if [[ $_error == 2 ]]; then
        if ! _ask_yesno "$0: Download '$1' and then load it?"; then
            return $_error
        fi
        sync_module "$1" && load_module $@
        return $?
    fi
    return $_error
}

function load_comp() {
    _check_module_name "$1" || return 1

    if (( ${+3} )); then
        echo "$0: Too many arguments" > /dev/stderr
        return 1
    fi

    local _mod_path="${funcsourcetrace[1]%/*/*}/mod/$1"

    if ! [[ -d "$_mod_path" ]]; then
        echo "$0: Module '$1' not found" > /dev/stderr
        return 2
    fi
    
    if (( ${+2} )); then
        local _comp_path="$_mod_path/$2"
    else
        local _comp_path="$_mod_path"
    fi

    if ! [[ -d "$_comp_path" ]]; then
        echo "$0: Module '$1' exists but '$_comp_path' is not a directory" > /dev/stderr
        return 3
    fi

    fpath+="$_comp_path"
}

function load_remote_comp() {
    load_comp $@
    local _error=$?
    if [[ $_error == 2 ]]; then
        if ! _ask_yesno "$0: Download '$1' and then load it?"; then
            return $_error
        fi
        sync_module "$1" && load_comp $@
        return $?
    fi
    return $_error
}
