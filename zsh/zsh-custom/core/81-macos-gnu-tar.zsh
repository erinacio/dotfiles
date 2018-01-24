if isdarwin && type gtar NUL; then
    alias bsd-tar='/usr/bin/tar'

    alias tar='/usr/local/bin/gtar'
fi
