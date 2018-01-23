function _ask_yesno {
    read "answer?$1 (Y/n)"
    case ${answer:0:1} in
        n|N )
            return 1
        ;;
        * )
            return 0
        ;;
    esac
}
