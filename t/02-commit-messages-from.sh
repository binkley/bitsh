# vi: ft=bash
# Source me

function _save_commit_messages {
    commit_messages+=("$1")
}

function has_commits {
    local -r count=$1
    shift

    local commit_messages=()
    commit_messages_from _save_commit_messages HEAD
    "$@"
}

SCENARIO 'Count commits' \
    GIVEN new_repo \
        AND with_commit some-file 'First commit'
    WHEN nothing \
    THEN has_commits 1
