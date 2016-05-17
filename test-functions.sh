# vi: ft=bash
# Source me

function _print_result
{
    local stack=($(caller 1))
    local previous=${stack[1]}

    echo -n '* '

    if (( 0 == exit_code ))
    then
        if ! $quiet
        then
            echo "${pgreen}PASS${preset} $test_name"
        fi
    elif (( 1 == exit_code ))
    then
        cat <<EOM
${pred}FAIL${preset} $test_name
- $previous expected ${pcyan}$expected${preset}
- But got ${pcyan}$actual${preset}
- Difference:
$(diff <(echo "$expected") <(echo "$actual"))
- Standard out:
$(<$tmpdir/out)
- Standard err:
$(<$tmpdir/err)
EOM
    else
        cat <<EOE
${pmagenta}ERROR${preset} $test_name
- Previous: $previous
- Exit code: $exit_code
- Standard out:
$(<$tmpdir/out)
- Standard err:
$(<$tmpdir/err)
EOE
    fi

    return $exit_code
}
