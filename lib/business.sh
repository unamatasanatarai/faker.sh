#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# BUSINESS
# -----------------------------------------------------------------------------

function job_title {
    : <<'DOC'
Generates a random job title.
Usage: fake job_title
DOC
    _pick "$__DIR/locale/$o_locale/job-title.txt"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function company {
    : <<'DOC'
Generates a random company name.
Usage: fake company
DOC
    local old_direct=$_DIRECT_CALL
    _DIRECT_CALL=0
    lastname
    local name="$_RET"
    _pick "$__DIR/locale/$o_locale/company-suffix.txt"
    _RET="$name $_RET"
    _DIRECT_CALL=$old_direct
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function url {
    : <<'DOC'
Generates a random URL.
Usage: fake url
DOC
    local old_direct=$_DIRECT_CALL
    _DIRECT_CALL=0
    company
    local comp="${_RET// /}"
    comp="${comp,,}"
    _pick "$__DIR/locale/$o_locale/email.txt"
    local dom="$_RET"
    _RET="https://www.${comp}.${dom}"
    _DIRECT_CALL=$old_direct
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}
