if isdarwin && type gfind NUL; then
    # assume that if gfind is found, the entire findutils is available

    alias 'bsd-find'='/usr/bin/find'
    alias 'bsd-locate'='/usr/bin/locate'
    alias 'bsd-xargs'='/usr/bin/xargs'

    alias 'find'='/usr/local/bin/gfind'
    alias 'locate'='/usr/local/bin/glocate'
    alias 'updatedb'='/usr/local/bin/gupdatedb'
    alias 'xargs'='/usr/local/bin/gxargs'
fi
