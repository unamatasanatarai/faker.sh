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

function _time_to_seconds {
    local IFS=:
    local h m s
    read h m s <<< "$1"
    # Use 10# to force base-10 and handle leading zeros
    _RET=$(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
}

function _seconds_to_time {
    local s=$1
    local h=$(( s / 3600 ))
    local m=$(( (s % 3600) / 60 ))
    local sec=$(( s % 60 ))
    printf -v _RET "%02d:%02d:%02d" "$h" "$m" "$sec"
}

function time {
    : <<'DOC'
Generates a random time in HH:MM:SS format within an optional range.
Usage: fake time [after HH:MM:SS] [before HH:MM:SS]
DOC
    local after=0
    local before=86399 # 23:59:59
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            after)
                _time_to_seconds "$2"
                after=$_RET
                shift 2
                ;;
            before)
                _time_to_seconds "$2"
                before=$_RET
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    _random_range "$after" "$before"
    _seconds_to_time "$_RET"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}
