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
    local expected
    case $1 in
    - ) read -d '' -r expected || true ;;
    * ) local expected="$1" ;;
    esac
    shift

    local actual="$(<$tmpdir/err)"

    [[ "$expected" == "$actual" ]]
    AND "$@"
}

function on_stdout {
    local expected
    case $1 in
    - ) read -d '' -r expected || true ;;
    * ) expected="$1" ;;
    esac
    shift

    local actual="$(<$tmpdir/out)"

    [[ "$expected" == "$actual" ]]
    AND "$@"
}
