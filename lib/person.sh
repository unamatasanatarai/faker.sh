#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# PERSON
# -----------------------------------------------------------------------------

function firstname {
    : <<'DOC'
Generates a random first name.
Usage: fake firstname [male|female]
DOC
    local gender="$1"
    local file="$__DIR/locale/$o_locale/first-name.txt"
    if [[ "$gender" == "male" && -f "$__DIR/locale/$o_locale/first-name-male.txt" ]]; then
        file="$__DIR/locale/$o_locale/first-name-male.txt"
    elif [[ "$gender" == "female" && -f "$__DIR/locale/$o_locale/first-name-female.txt" ]]; then
        file="$__DIR/locale/$o_locale/first-name-female.txt"
    fi
    _pick "$file"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function lastname {
    : <<'DOC'
Generates a random last name.
Usage: fake lastname [male|female]
DOC
    local gender="$1"
    local file="$__DIR/locale/$o_locale/last-name.txt"
    if [[ "$gender" == "male" && -f "$__DIR/locale/$o_locale/last-name-male.txt" ]]; then
        file="$__DIR/locale/$o_locale/last-name-male.txt"
    elif [[ "$gender" == "female" && -f "$__DIR/locale/$o_locale/last-name-female.txt" ]]; then
        file="$__DIR/locale/$o_locale/last-name-female.txt"
    fi
    _pick "$file"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function person {
    : <<'DOC'
Generates a random full name (firstname + lastname).
Usage: fake person [male|female]
DOC
    local gender="$1"
    local old_direct=$_DIRECT_CALL
    _DIRECT_CALL=0
    firstname "$gender"
    local fn="$_RET"
    lastname "$gender"
    local ln="$_RET"
    _RET="$fn $ln"
    _DIRECT_CALL=$old_direct
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function name {
    : <<'DOC'
Alias for person.
Usage: fake name [male|female]
DOC
    person "$@"
}
