#!/bin/bash

{
    pushd $(dirname $0)
    root_dir=$(pwd -P)
    popd
} >/dev/null

$root_dir/run-from-url https://raw.githubusercontent.com/binkley/shell/master/plain-bash-testing/run-tests $root_dir/.$(basename $0) "$@"
