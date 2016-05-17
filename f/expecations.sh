# vi: ft=bash
# Source me

function exit_with {
    local expected=$1
    shift
    local actual=$?

    (( expected == actual ))
    AND "$@"
}

function on_stderr {
    case $1 in
    - ) local expected=$(</dev/stdin) ;;
    * ) local expected="$1" ;;
    esac
    shift

    local actual="$(<$tmpdir/err)"

    [[ "$expected" == "$actual" ]]
    AND "$@"
}

function on_stdout {
    case $1 in
    - ) local expected="$(</dev/stdin)" ;;
    * ) local expected="$1" ;;
    esac
    shift

    local actual="$(<$tmpdir/out)"

    [[ "$expected" == "$actual" ]]
    AND "$@"
}
