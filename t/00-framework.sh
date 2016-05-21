# vi: ft=bash
# Source me

function pass {
    return 0
}
_register pass

SCENARIO 'Verify framekwork' \
    GIVEN nothing \
    THEN pass
