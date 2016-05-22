#!/bin/bash

{
    pushd $(dirname $0)
    readonly root_dir=$(pwd -P)
    popd
} >/dev/null
readonly dot_script=$root_dir/.$(basename $0)

bash $root_dir/run-from-url https://raw.githubusercontent.com/binkley/shell/master/plain-bash-testing/run-tests $dot_script "$@"
