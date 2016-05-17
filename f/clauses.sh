# vi: ft=bash
# Source me

function new_repo {
    local -r repo_dir=$tmpdir/git
    git init $repo_dir >/dev/null
    "$@"
}

function in_repo {
    trap 'cd $old_pwd' RETURN
    local -r old_pwd=$PWD
    cd $repo_dir
    "$@"
}
