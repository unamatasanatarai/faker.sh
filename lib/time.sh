#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# TIME
# -----------------------------------------------------------------------------

function date {
    : <<'DOC'
Generates a random date in YYYY-MM-DD format.
Usage: fake date [before|after]
DOC
    local opt="$1"
    local year month day
    if [[ "$opt" == "after" ]]; then
        _random_range 2026 2030
    elif [[ "$opt" == "before" ]]; then
        _random_range 2010 2024
    else
        _random_range 2000 2025
    fi
    year=$_RET
    _random_range 1 12; printf -v month "%02d" "$_RET"
    _random_range 1 28; printf -v day "%02d" "$_RET"
    _RET="$year-$month-$day"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function time {
    : <<'DOC'
Generates a random time in HH:MM:SS format.
Usage: fake time
DOC
    local hour minute second
    _random_range 0 23; printf -v hour "%02d" "$_RET"
    _random_range 0 59; printf -v minute "%02d" "$_RET"
    _random_range 0 59; printf -v second "%02d" "$_RET"
    _RET="$hour:$minute:$second"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}
