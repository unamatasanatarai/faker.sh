#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# LOCATION
# -----------------------------------------------------------------------------

function country {
    : <<'DOC'
Generates a random country name.
Usage: fake country
DOC
    _pick "$__DIR/locale/$o_locale/country.txt"
    _RET="${_RET%%|*}"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function country_abbr {
    : <<'DOC'
Generates a random country abbreviation (ISO 3166-1 alpha-2).
Usage: fake country_abbr
DOC
    _pick "$__DIR/locale/$o_locale/country.txt"
    _RET="${_RET#*|}"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function city {
    : <<'DOC'
Generates a random city name.
Usage: fake city
DOC
    _pick "$__DIR/locale/$o_locale/city.txt"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function street_name {
    : <<'DOC'
Generates a random street name.
Usage: fake street_name
DOC
    _pick "$__DIR/locale/$o_locale/street-name.txt"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function number {
    : <<'DOC'
Generates a random number within a range.
Usage: fake number [min] [max]
Defaults: min=1, max=9999
DOC
    local min="${1:-1}"
    local max="${2:-9999}"
    _random_range "$min" "$max"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function postcode {
    : <<'DOC'
Generates a random 5-digit postcode.
Usage: fake postcode
DOC
    local pattern="#####"
    local result=""
    local i char
    for (( i=0; i<${#pattern}; i++ )); do
        char="${pattern:i:1}"
        if [[ "$char" == "#" ]]; then
            _random 10
            result+="$_RET"
        else
            result+="$char"
        fi
    done
    _RET="$result"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}
