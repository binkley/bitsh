# vi: ft=bash
# Source me

function pass {
    local -r expected=''
    local -r actual=''
    "$@"
}

SCENARIO 'Verify framekwork' \
    GIVEN nothing \
    THEN pass
