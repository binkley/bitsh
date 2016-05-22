#!/bin/bash

offline=
update=
args=("$@")
for i in $(seq 0 $(($# - 1)))
do
    arg="${args[i]}"
    case $arg in
    -o ) offline=-o ; unset args[i] ;;
    -u ) update=-u ; unset args[i] ;;
    -* ) ;;
    * ) break ;;
    esac
done
set -- "${args[@]}"

{
    pushd $(dirname $0)
    readonly root_dir=$(pwd -P)
    popd
} >/dev/null
readonly dot_script=$root_dir/.$(basename $0)

$root_dir/run-from-url $offline $update https://raw.githubusercontent.com/binkley/shell/master/plain-bash-testing/run-tests $dot_script "$@"
