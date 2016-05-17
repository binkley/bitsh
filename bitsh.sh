# vi: ft=bash
# Source me

# Commit message from 1) single commit, or 2) range of commits.
function commit_messages_from {
    case $# in
    2 ) local -r callback=$1 start="$2" end="$3" ;;
    3 ) local -r callback=$1 start="$2^" end="$3" ;;
    * ) echo "$0: Usage: $0 <callback> <start> [end]" >&2 ; return 2 ;;
    esac

    if ! [[ function == $(type -t $callback) ]]
    then
        echo "$0: Not a function: $callback" >&2
        return 2
    fi

    git rev-list --reverse $start..$end \
        | while read hash
    do
        local message="$(git --no-pager log --no-color -n 1 --pretty=format:%B $hash)"
        $callback "$message"
    done
}
