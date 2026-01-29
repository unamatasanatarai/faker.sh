#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# FAKER TEST RUNNER
# -----------------------------------------------------------------------------

__DIR="${0%/*}"
FAKE="$__DIR/../fake"

FAILED=0
PASSED=0

function assert {
    local label="$1"
    local cmd="$2"
    local pattern="$3"
    
    echo -n "Test: $label... "
    local output
    output=$($cmd)
    
    if [[ "$output" =~ $pattern ]]; then
        echo "PASSED"
        ((PASSED++))
    else
        echo "FAILED"
        echo "  Expected: $pattern"
        echo "  Got: $output"
        ((FAILED++))
    fi
}

echo "Starting Faker Tests..."
echo "-----------------------"

export LC_ALL=en_US.UTF-8

# --- EXHAUSTIVE COMMAND TESTS ---
echo "Running Exhaustive Command Tests..."

# COMMANDS X GENDER X LOCALE
for loc in "en" "pl"; do
    for g in "" "male" "female"; do
        label="[Locale: $loc, Gender: ${g:-default}]"
        assert "$label person" "$FAKE person $g --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż ]+ [A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż ]+$"
        assert "$label firstname" "$FAKE firstname $g --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż ]+$"
        assert "$label lastname" "$FAKE lastname $g --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż ]+$"
        # Using a more robust regex for email to handle multi-byte characters reliably across environments
        assert "$label email" "$FAKE email $g --locale $loc" "^[^@]+@[^@.]+\.[a-z]+$"
    done
done

# LOCATION & MISC X LOCALE
for loc in "en" "pl"; do
    label="[Locale: $loc]"
    assert "$label country" "$FAKE country --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż -]+$"
    assert "$label country_abbr" "$FAKE country_abbr --locale $loc" "^[A-Z]{2,3}$"
    assert "$label city" "$FAKE city --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż ]+$"
    assert "$label street_name" "$FAKE street_name --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż0-9. ]+$"
    assert "$label postcode" "$FAKE postcode --locale $loc" "^[0-9-]+$"
    assert "$label job_title" "$FAKE job_title --locale $loc" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż ]+$"
    assert "$label company" "$FAKE company --locale $loc" "^[A-Z][A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż ]+.*$"
    assert "$label url" "$FAKE url --locale $loc" "^https?://.*$"
    assert "$label uuid" "$FAKE uuid --locale $loc" "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
    assert "$label number" "$FAKE number --locale $loc" "^[0-9]+$"
    assert "$label lorem" "$FAKE lorem --locale $loc" "^[a-z]+$"
done

# RANGE VARIANTS
assert "Number range (100-200)" "$FAKE number 100 200" "^(1[0-9][0-9]|200)$"
assert "Date before (2010-2024)" "$FAKE date before" "^20(1[0-9]|2[0-4])-[0-9]{2}-[0-9]{2}$"
assert "Date after (2026-2030)" "$FAKE date after" "^20(2[6-9]|30)-[0-9]{2}-[0-9]{2}$"
assert "Time after 14:00:01" "$FAKE time after 14:00:01" "^(1[4-9]|2[0-3]):[0-9]{2}:[0-9]{2}$"
assert "Time before 10:00:00" "$FAKE time before 10:00:00" "^0[0-9]:[0-9]{2}:[0-9]{2}$"
assert "Lorem count (10)" "$FAKE lorem 10" "^[a-z]+( [a-z]+){9}$"

# GLOBAL OPTIONS
# --count
echo -n "Test: Global --count 5... "
count_check=$($FAKE city --count 5 | grep -v "^$" | wc -l)
if [[ $count_check -eq 5 ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED (Got $count_check)"
    ((FAILED++))
fi

# --seed
echo -n "Test: Global --seed 789 reproducibility... "
seed1=$($FAKE person --seed 789)
seed2=$($FAKE person --seed 789)
if [[ "$seed1" == "$seed2" ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED ($seed1 != $seed2)"
    ((FAILED++))
fi

# Lorem contiguous line
echo -n "Test: Lorem contiguous line (50 words)... "
lorem_check=$($FAKE lorem 50)
lorem_lines=$(echo "$lorem_check" | wc -l)
if [[ $lorem_lines -eq 1 ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED ($lorem_lines lines)"
    ((FAILED++))
fi

echo "-----------------------"
echo "Summary: $PASSED passed, $FAILED failed"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
