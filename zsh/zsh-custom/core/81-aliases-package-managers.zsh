if type sudo NUL; then
    _sudo='sudo'
else
    _sudo=''
fi

## Common package manager verbs
# pacadd: Install a package
# pacrm: Uninstall a package
# pacupd: Update all packages
# pacfind: Search for a package
# pacinfo: Query information of a package
# pacls: List all installed packages

# pacman
if type pacman NUL; then
    alias pacadd="$_sudo pacman -S --needed"
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
    alias pacrm="$_sudo apt remove"
    alias pacupd="$_sudo apt update && $_sudo apt upgrade"
    alias pacfind='apt search'
    alias pacinfo='apt show'
    alias pacls='apt list'
fi

# dnf
if type dnf NUL; then
    alias pacadd="$_sudo dnf --color always install"
    alias pacrm="$_sudo dnf --color always remove"
    alias pacupd="$_sudo dnf --color always upgrade"
    alias pacfind='dnf --color always search'
    alias pacinfo='dnf --color always info'
    alias pacls='dnf --color always list installed'
fi

# zypper
if type zypper NUL; then
    alias pacadd="$_sudo zypper --color in"
    alias pacrm="$_sudo zypper --color rm"
    alias pacupd="$_sudo zypper --color up"
    alias pacfind='zypper --color se'
    alias pacinfo='zypper --color if'
    alias pacls='zypper --color se --installed-only'
fi

# homebrew
if type brew NUL; then
    alias pacadd='brew install'
    alias pacrm='brew uninstall'
    alias pacupd='brew upgrade'
    alias pacfind='brew search'
    alias pacinfo='brew info'
    alias pacls='brew list'

    # homebrew specific
    alias pacedit='brew edit'
    alias pacopt='brew options'
fi
