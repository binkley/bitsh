#!/bin/bash

export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '

function _setup_colors()
{
    [[ -t 1 ]] || return
    local -r ncolors=$(tput colors)
    [[ -n "$ncolors" && ncolors -ge 8 ]] || return
    pgreen=$(printf "\e[32m")
    pred=$(printf "\e[31m")
    pboldred=$(printf "\e[31;1m")
    pcheckmark=$(printf "\xE2\x9C\x93")
    pballotx=$(printf "\xE2\x9C\x97")
    pinterrobang=$(printf "\xE2\x80\xBD")
    preset=$(printf "\e[0m")
}

function _setup_diff()
{
    if [[ -n $(which dwdiff 2>/dev/null) ]]
    then
        shopt -s expand_aliases
        if $color
        then
            alias diff='dwdiff -c -l -A best'
        else
            alias diff='dwdiff -A best'
        fi
    fi
}

function print_usage()
{
    cat <<EOU
Usage: $0 [-c|--color][-d|--debug]|[-q|--quiet] <script> [tes__t_scripts]
EOU
}

function _enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o pipefail
    set -o xtrace
    echo "$0: Called with $@"
}

function _register {
    case $# in
    1 ) local -r name=$1 arity=0 ;;
    2 ) local -r name=$1 arity=$2 ;;
    esac
    read -d '' -r wrapper <<EOF
function $name {
    # Original function
    $(declare -f $name | sed '1,2d;$d')

    __e=\$?
    shift $arity
    if (( 0 < __e || 0 == \$# ))
    then
        __tally \$__e
    else
        "\$@"
        __e=\$?
        __tally \$__e
    fi
}
EOF
    eval "$wrapper"
}

let __passed=0 __failed=0 __errored=0
function __tally {
    local -r __e=$1
    $__tallied && return $__e
    __tallied=true
    case $__e in
    0 ) let ++__passed ;;
    1 ) let ++__failed ;;
    * ) let ++__errored ;;
    esac
    _print_result $__e
    return $__e
}

[[ -t 1 ]] && color=true || color=false
quiet=false
while getopts :cdq-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    c | color ) color=true ;;
    d | debug ) _enable_debug "$@" ;;
    q | quiet ) quiet=true ;;
    * ) print_usage >&2 ; exit 3 ;;
    esac
done
shift $((OPTIND - 1))

$color && _setup_colors

case $# in
0 ) print_usage >&2 ; exit 3 ;;
esac

_setup_diff

{
    pushd $(dirname $0)
    rootdir=$(pwd -P)
    popd
} >/dev/null

. $rootdir/bitsh.sh

for f in $rootdir/f/*.sh
do
    . $f
done

for t in "$@"
do
    if [[ -d "$t" ]]
    then
        set -- $(find $t -type f -name \*.sh)
    else
        set -- $t
    fi
done

for t in "$@"
do
    if ! $quiet
    then
        s=${t##*/}
        s=${s%.sh}
        echo "${pbold}Script $s:${preset}"
    fi
    let __last_passed=$__passed
    let __last_failed=$__failed
    let __last_errorer=$__errored
    pushd $PWD >/dev/null
    . $t
    popd >/dev/null
    let __t_passed=$((__passed - __last_passed))
    let __t_failed=$((__failed - __last_failed))
    let __t_errored=$((__errored - __last_errored))
    if ! $quiet
    then
        all=()
        (( 0 == __t_errored )) || all+=("$__t_errored errored")
        (( 0 == __t_failed )) || all+=("$__t_failed failed")
        (( 0 == __t_passed )) || all+=("$__t_passed passed")
        echo "${all[@]}"
    fi
done

if ! $quiet
then
    (( 0 == __passed )) && ppassed= || ppassed=${pgreen}
    (( 0 == __failed )) && pfailed= || pfailed=${pred}
    (( 0 == __errored )) && perrored= || perrored=${pboldred}
    cat <<EOS
${pbold}Summary${preset}: ${ppassed}$__passed PASSED${preset}, ${pfailed}$__failed FAILED${preset}, ${perrored}$__errored ERRORED${preset}
EOS
fi

if (( 0 < __errored ))
then
    exit 2
elif (( 0 < __failed ))
then
    exit 1
fi
