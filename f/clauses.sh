# vi: ft=bash
# Source me

function new_repo {
    local -r stack=($(caller 0))
    local -r previous=${stack[1]}

    case $previous in
    GIVEN ) ;;
    * ) _bad_syntax before GIVEN ;;
    esac

    local -r repo_dir=$tmpdir/git
    git init $repo_dir >$stdout 2>$stderr
    AND "$@"
}

function in_repo {
    (cd $repo_dir; "$@")
}

function with_commit {
    local -r file=$1
    local -r message="$2"
    shift 2

    uuidgen >$file
    {
        git add $file
        git commit $file -m "$message"
    } >$stdout 2>$stderr
    AND "$@"
}
