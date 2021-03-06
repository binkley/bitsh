# vi: ft=bash
# Source me

function check_status {
    git status >$stdout 2>$stderr
}

SCENARIO 'New repo' \
    GIVEN new_repo \
    WHEN check_status \
    THEN exit_with 0 \
        AND on_stdout - <<'EOO'
On branch master

Initial commit

nothing to commit (create/copy files and use "git add" to track)
EOO
