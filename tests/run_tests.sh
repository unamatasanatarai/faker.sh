#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# FAKER MATRIX TEST RUNNER (500% COVERAGE)
# -----------------------------------------------------------------------------

export LC_ALL=en_US.UTF-8
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

echo "Starting Faker Matrix Tests..."
echo "------------------------------"

# 1. CORE MATRIX: LOCALE X COMMAND X ARGUMENT
locales=("en" "pl" "de")

# Simple tasks (Fixed regex)
simple_tasks=(
    "country:^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻżäöüÄÖÜß .-]+$"
    "country_abbr:^[A-Z]{2,3}$"
    "city:^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻżäöüÄÖÜß .-]+$"
    "street_name:^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻżäöüÄÖÜß0-9. -]+$"
    "postcode:^[0-9-]+$"
    "job_title:^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻżäöüÄÖÜß .-]+$"
    "company:^[A-Z][A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻżäöüÄÖÜß .-]+.*$"
    "url:^https?://.*$"
    "uuid:^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
    "phone_number:^\+[0-9]{2} [0-9]{3} [0-9]{3} [0-9]{3}$"
)

# Gendered tasks
gender_tasks=("firstname" "lastname" "person" "name" "email")
genders=("" "male" "female")

for loc in "${locales[@]}"; do
    echo "Testing Locale: $loc"
    
    # Run simple tasks
    for item in "${simple_tasks[@]}"; do
        task="${item%%:*}"
        regex="${item#*:}"
        assert "[$loc] $task" "$FAKE $task --locale $loc" "$regex"
    done
    
    # Run gendered tasks
    for task in "${gender_tasks[@]}"; do
        regex="^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹżäöüÄÖÜß .]+$"
        [[ "$task" == "email" ]] && regex="^[^@]+@[^@.]+\.[a-z]+$"
        
        for g in "${genders[@]}"; do
            assert "[$loc] $task ${g:-default}" "$FAKE $task $g --locale $loc" "$regex"
        done
    done
    
    # Run Range tasks
    assert "[$loc] number (none)" "$FAKE number --locale $loc" "^[0-9]+$"
    assert "[$loc] number (10 20)" "$FAKE number 10 20 --locale $loc" "^(1[0-9]|20)$"
    assert "[$loc] date (none)" "$FAKE date --locale $loc" "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
    assert "[$loc] date after" "$FAKE date after --locale $loc" "^2[0-9]{3}-[0-9]{2}-[0-9]{2}$"
    assert "[$loc] time (none)" "$FAKE time --locale $loc" "^[0-9]{2}:[0-9]{2}:[0-9]{2}$"
    assert "[$loc] time after" "$FAKE time after 14:00:00 --locale $loc" "^(1[4-9]|2[0-3]):[0-9]{2}:[0-9]{2}$"
    assert "[$loc] lorem (none)" "$FAKE lorem --locale $loc" "^[a-z]+$"
    assert "[$loc] lorem 10" "$FAKE lorem 10 --locale $loc" "^[a-z]+( [a-z]+){9}$"

    # EXTRA PRESSURE: Every task with --count 3 and --seed 123
    echo "  Applying Combinatorial Pressure (Flags)..."
    for item in "${simple_tasks[@]}"; do
        task="${item%%:*}"
        regex="${item#*:}"
        out=$( $FAKE $task --locale $loc --count 3 --seed 123 )
        cnt=$( echo "$out" | grep -cE "$regex" )
        [[ $cnt -eq 3 ]] && ((PASSED++)) || { echo "FAILED: [$loc] $task --count 3"; ((FAILED++)); }
    done
    for task in "${gender_tasks[@]}"; do
        regex="^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŹż .]+$"
        [[ "$task" == "email" ]] && regex="^[^@]+@[^@.]+\.[a-z]+$"
        for g in "${genders[@]}"; do
            out=$( $FAKE $task $g --locale $loc --count 3 --seed 123 )
            cnt=$( echo "$out" | grep -cE "$regex" )
            [[ $cnt -eq 3 ]] && ((PASSED++)) || { echo "FAILED: [$loc] $task $g --count 3"; ((FAILED++)); }
        done
    done
done

# 2. GLOBAL FLAG COMBINATIONS
echo "Testing Global Flag Matrix..."
# Using --count and verifying multi-line output matches pattern per line
combo_out=$( $FAKE city --count 5 --seed 1 --locale pl )
combo_cnt=$( echo "$combo_out" | grep -cE "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż ]+$" )
[[ $combo_cnt -eq 5 ]] && echo "Test: Global --count 5 --seed 1... PASSED" || echo "Test: Global --count 5 --seed 1... FAILED"
[[ $combo_cnt -eq 5 ]] && ((PASSED++)) || ((FAILED++))

assert "Global: --seed consistency" "$FAKE uuid --seed 42" "^[0-9a-f-]{36}$"
uuid1=$( $FAKE uuid --seed 42 )
uuid2=$( $FAKE uuid --seed 42 )
[[ "$uuid1" == "$uuid2" ]] && echo "Test: Seed consistency... PASSED" || echo "Test: Seed consistency... FAILED"
[[ "$uuid1" == "$uuid2" ]] && ((PASSED++)) || ((FAILED++))

# 3. SYSTEM TESTS
assert "System: help" "$FAKE help" "Faker in Bash"
assert "System: invalid" "$FAKE invalid_task" "Faker in Bash"

# 4. UTILITY INTERNAL TESTS
echo "Running Utility Internal Tests..."
source "$__DIR/../lib/utils.sh"
o_locale="en"
__DIR="$__DIR/.."
_random 0
[[ $_RET -eq 0 ]] && echo "Test: _random 0... PASSED" || echo "Test: _random 0... FAILED"

# 5. STRESS & UNIQUENESS
echo -n "Test: Stress (Count 1000)... "
[[ $( $FAKE number --count 1000 | wc -l ) -eq 1000 ]] && echo "PASSED" || echo "FAILED"
echo -n "Test: UUID Batch Uniqueness (100)... "
[[ $( $FAKE uuid --count 100 | sort | uniq | wc -l ) -eq 100 ]] && echo "PASSED" || echo "FAILED"

echo "------------------------------"
echo "Final Summary: $PASSED passed ($FAILED failed)"

[[ $FAILED -gt 0 ]] && exit 1
exit 0
