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

# Basic functionality
assert "Firstname" "$FAKE firstname" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż]+$"
assert "UUID" "$FAKE uuid" "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
assert "Date" "$FAKE date" "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"

# Seedable randomness
out1=$($FAKE number --seed 123)
out2=$($FAKE number --seed 123)
if [[ "$out1" == "$out2" ]]; then
    echo "Test: Seed Reproducibility... PASSED"
    ((PASSED++))
else
    echo "Test: Seed Reproducibility... FAILED"
    ((FAILED++))
fi

# Bulk generation
out_cnt=$($FAKE person --count 5 | wc -l)
if [[ $out_cnt -eq 5 ]]; then
    echo "Test: Bulk Count... PASSED"
    ((PASSED++))
else
    echo "Test: Bulk Count... FAILED (Got $out_cnt)"
    ((FAILED++))
fi

# Locale support
assert "Polish Locale" "$FAKE country --locale pl" "^[A-Za-zŻżĄąĆćĘęŁłŃńÓóŚśŹźŻż ]+$"

echo "-----------------------"
echo "Summary: $PASSED passed, $FAILED failed"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
