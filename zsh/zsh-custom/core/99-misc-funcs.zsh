function paths () {
    local _paths=("${(@s/:/)PATH}")
    for p in $_paths; do
        echo "$p"
    done
}

function cdtmp () {
    mkdir -p "/tmp/${USER}" && pushd "/tmp/${USER}"
}

function newtmp () {
    local _tmpdir="$(/usr/bin/mktemp -d "/tmp/tmp.$USER.$(/bin/date +%Y%m%d-%H%M%S).XXXXXXXX")"
    mkdir -p "$_tmpdir" && pushd "$_tmpdir"
}
