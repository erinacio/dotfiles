function paths () {
    local _paths=("${(@s/:/)PATH}")
    for p in $_paths; do
        echo "$p"
    done
}
