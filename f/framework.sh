# vi: ft=bash
# Source me

function _bad_syntax {
    local -r order=$1
    shift
    local valid="$@"
    valid="${valid// / or }"
    readonly valid

    local -r stack=($(caller 1))
    local -r previous=${stack[1]}

    echo "$0: Bad scenario: No $valid $order $previous: $scenario" >&2
    exit 3
}

function _print_result {
    local -r stack=($(caller 1))
    local -r previous=${stack[1]}

    echo -n '- '

    if (( 0 == exit_code ))
    then
        if ! $quiet
        then
            echo "${pgreen}PASS${preset} $description"
        fi
    elif (( 1 == exit_code ))
    then
        echo "$expected" >$tmpdir/expected
        (( 1 < $(wc -l $tmpdir/expected | cut -d' ' -f1))) \
            && local -r expected_sep=$'\n' || local -r expected_sep=' '
        echo "$actual" >$tmpdir/actual
        (( 1 < $(wc -l $tmpdir/actual | cut -d' ' -f1))) \
            && local -r actual_sep=$'\n' || local -r actual_sep=' '
        $color && local -r color_flag=always || color_flag=never
        cat <<EOM
${pred}FAIL${preset} $description
- ${pbold}Scenario:$preset $scenario
- '$previous' expected${expected_sep}${pcyan}$expected${preset}
- But got${actual_sep}${pcyan}$actual${preset}
- ${pbold}Difference:$reset
$(git --no-pager diff --color=$color_flag --word-diff=plain $tmpdir/expected $tmpdir/actual | sed 1,4d)
- ${pbold}Standard out:$preset
$(<$stdout)
- ${pbold}Standard err:$preset
$(<$stderr)
EOM
    else
        cat <<EOE
${pmagenta}ERROR${preset} $description
- ${pbold}Scenario:$preset $scenario
- $previous exited $exit_code
- ${pbold}Standard out:$preset
$(<$stdout)
- ${pbold}Standard err:$preset
$(<$stderr)
EOE
    fi

    return $exit_code
}

function _end {
    local exit_code=$?
    _print_result
}

function AND {
    local exit_code=$?
    case $exit_code in
    0 ) "$@" ;;
    * ) _print_result ;;
    esac
}

function THEN {
    local exit_code=$?
    case $exit_code in
    0 ) "$@" ;;
    * ) _print_result ;;
    esac
}

function WHEN {
    "$@"
}

function nothing {
    "$@"
}

function GIVEN {
    "$@"
}

function _maybe_debug_if_not_passed {
    if $debug && [[ -t 0 && -t 1 ]]
    then
        trap 'cd $old_pwd' RETURN
        local -r old_pwd=$PWD
        cd $tmpdir
        echo ">> Dropping into shell (exited $exit_code): $scenario"
        $SHELL -i
    fi
}

function SCENARIO {
    trap 'rm -rf $tmpdir' RETURN
    local -r tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
    local -r stdout=$tmpdir/stdout
    local -r stderr=$tmpdir/stderr

    local scenario=${FUNCNAME}
    for arg
    do
        case $arg in
        *\'* ) scenario="$scenario \"$arg\"" ;;
        *' '* | *\"* ) scenario="$scenario '$arg'" ;;
        * ) scenario="$scenario $arg" ;;
        esac
    done
    readonly scenario

    local -r description="$1"
    shift

    case $1 in
    GIVEN ) "$@" _end ;;
    * ) _bad_syntax after GIVEN ;;
    esac

    local exit_code=$?

    (( 0 != exit_code )) && _maybe_debug_if_not_passed

    case $exit_code in
    0 ) let ++passed ;;
    1 ) let ++failed  ;;
    * ) let ++errored  ;;
    esac

    return $exit_code
}
