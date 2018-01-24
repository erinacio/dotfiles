if isdarwin && type gindent NUL; then
    alias 'bsd-indent'='/usr/bin/indent'

    alias 'indent'='/usr/local/bin/gindent'
    alias 'texinfo2man'='/usr/local/bin/gtexinfo2man'
fi
