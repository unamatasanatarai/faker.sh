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

# SYSTEM TESTS (Help/Invalid)
assert "Help command" "$FAKE help" "Faker in Bash"
assert "No args (Help)" "$FAKE" "Faker in Bash"
assert "Invalid task (Help)" "$FAKE invalid_task_name" "Faker in Bash"

# UTILITY EDGE CASES
echo "Running Utility Edge Case Tests..."

# Mocking environment for internal tests
source "$__DIR/../lib/utils.sh"
o_locale="en"
__DIR="$__DIR/.."

# Test _random with max <= 0
_random 0
if [[ $_RET -eq 0 ]]; then
    echo "Test: _random 0... PASSED"
    ((PASSED++))
else
    echo "Test: _random 0... FAILED"
    ((FAILED++))
fi

# Test _pick with non-existent file
_pick "/tmp/non_existent_file_12345"
if [[ $? -eq 1 && "$_RET" == "" ]]; then
    echo "Test: _pick non-existent... PASSED"
    ((PASSED++))
else
    echo "Test: _pick non-existent... FAILED"
    ((FAILED++))
fi

# Test _pick with empty file
touch /tmp/empty_faker_test
_pick "/tmp/empty_faker_test"
if [[ $? -eq 1 && "$_RET" == "" ]]; then
    echo "Test: _pick empty file... PASSED"
    ((PASSED++))
else
    echo "Test: _pick empty file... FAILED"
    ((FAILED++))
fi
rm /tmp/empty_faker_test

# Test time with unknown arg
assert "Time unknown arg" "$FAKE time unknown" "^[0-9]{2}:[0-9]{2}:[0-9]{2}$"

# EXTREME TESTS
echo "Running Extreme Tests..."

# 1. UUID Uniqueness in batch
echo -n "Test: UUID Uniqueness (100 items)... "
uuid_check=$( $FAKE uuid --count 100 | sort | uniq | wc -l )
if [[ $uuid_check -eq 100 ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED (Only $uuid_check unique values)"
    ((FAILED++))
fi

# 2. Deep Combinatorial Flags
echo -n "Test: Deep Combinatorial (pl male --count 5 --seed 1)... "
combo_out=$( $FAKE person male --locale pl --count 5 --seed 1 )
combo_cnt=$( echo "$combo_out" | grep -cE "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż ]+ [A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż ]+$" )
if [[ $combo_cnt -eq 5 ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED (Got $combo_cnt/5 valid lines)"
    ((FAILED++))
fi

# 3. Stress Test (Performance & Integrity)
echo -n "Test: Stress Test (Count 1000)... "
stress_check=$( $FAKE number --count 1000 | grep -E "^[0-9]+$" | wc -l )
if [[ $stress_check -eq 1000 ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED ($stress_check lines valid)"
    ((FAILED++))
fi

# 4. Internal Cache Audit (_pick)
echo -n "Test: Internal Cache Audit... "
# Trigger caching
_pick "$__DIR/locale/en/city.txt"
city_cache_var="__C_${__DIR//[^a-zA-Z0-9]/_}_locale_en_city_txt"
if [[ -n "${!city_cache_var}" ]]; then
    echo "PASSED"
    ((PASSED++))
else
    echo "FAILED (Cache variable not found)"
    ((FAILED++))
fi

# 5. Strict Pattern: Phone Number
assert "Strict Phone Validation" "$FAKE phone_number" "^\+[0-9]{2} [0-9]{3} [0-9]{3} [0-9]{3}$"

# 6. Strict Pattern: Postcode (en)
assert "Strict Postcode Validation (en)" "$FAKE postcode --locale en" "^[0-9]{5}$"

echo "-----------------------"
echo "Summary: $PASSED passed, $FAILED failed"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
