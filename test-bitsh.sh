#!/bin/bash

set -e

function setup_colors()
{
    [[ -t 1 ]] || return
    local -r ncolors=$(tput colors)
    [[ -n "$ncolors" && ncolors -ge 8 ]] || return
    pblack=$(tput setaf 0)
    pred=$(tput setaf 1)
    pgreen=$(tput setaf 2)
    pyellow=$(tput setaf 3)
    pblue=$(tput setaf 4)
    pmagenta=$(tput setaf 5)
    pcyan=$(tput setaf 6)
    pwhite=$(tput setaf 7)
    prev=$(tput rev)
    pbold=$(tput bold)
    preset=$(tput sgr0)
}

function setup_diff()
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
Usage: $0 [-c|--color][-d|--debug]|[-q|--quiet] <script> [test_scripts]
EOU
}

function enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o pipefail
    set -o xtrace
    echo "$0: Called with $@"
}

[[ -t 1 ]] && color=true || color=false
quiet=false
while getopts :cdq-: opt
do
    [[ - == $opt ]] && opt=${OPTARG%%=*} OPTARG=${OPTARG#*=}
    case $opt in
    c | color ) color=true ;;
    d | debug ) enable_debug "$@" ;;
    q | quiet ) quiet=true ;;
    * ) print_usage >&2 ; exit 3 ;;
    esac
done
shift $((OPTIND - 1))

$color && setup_colors

case $# in
0 ) print_usage >&2 ; exit 3 ;;
esac

setup_diff

{
    pushd $(dirname $0)
    rootdir=$(pwd -P)
    popd
} >/dev/null

. $rootdir/bitsh.sh
. $rootdir/test-functions.sh

for t in "$@"
do
    if [[ -d "$t" ]]
    then
        scenarios=($t/*.sh)
    else
        scenarios=($t)
    fi
done
set -- "${scenarios[@]}"

let passed=0 failed=0 errored=0 || true
for t in "$@"
do
    if ! $quiet
    then
        echo "${pbold}Scenario ${t##*/}:${preset}"
    fi
    . $t
done

if ! $quiet
then
    (( 0 == passed )) && ppassed= || ppassed=${pgreen}
    (( 0 == failed )) && pfailed= || pfailed=${pred}
    (( 0 == errored )) && perrored= || perrored=${pred}
    cat <<EOS
${pbold}Summary${preset}: ${ppassed}$passed PASSED${preset}, ${pfailed}$failed FAILED${preset}, ${perrored}$errored ERRORED${preset}
EOS
fi

if (( 0 < errored ))
then
    exit 2
elif (( 0 < failed ))
then
    exit 1
fi
