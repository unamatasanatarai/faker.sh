#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# UTILS
# -----------------------------------------------------------------------------

function _random {
    : <<'DOC'
Internal helper to generate a random number up to max.
Uses SRANDOM if available (and no seed), otherwise falls back to 30-bit RANDOM.
Sets _RET to the result.
DOC
    local max=$1
    if (( max <= 0 )); then
        _RET=0
        return
    fi
    
    local r
    if [[ -n $o_seed ]]; then
        # Use seedable RANDOM if seed is provided
        r=$(( RANDOM * 32768 + RANDOM ))
    elif [[ -n $SRANDOM ]]; then
        # Use cryptographically secure SRANDOM if available
        r=$SRANDOM
    else
        # Fallback to high-entropy RANDOM
        r=$(( RANDOM * 32768 + RANDOM ))
    fi
    _RET=$(( r % max ))
}

function _random_range {
    : <<'DOC'
Internal helper to generate a random number within a range [min, max].
Sets _RET to the result.
DOC
    local min=$1
    local max=$2
    _random $(( max - min + 1 ))
    _RET=$(( _RET + min ))
}

function _pick {
    : <<'DOC'
Internal helper to pick a random line from a file.
Uses memory caching to avoid repeated file reads.
Sets _RET to the picked line.
DOC
    local file="$1"
    if [[ ! -f "$file" ]]; then
        _RET=""
        return 1
    fi

    # Generate a safe cache variable name
    local cache_id="${file//[^a-zA-Z0-9]/_}"
    local cache_var="__C_${cache_id}"
    local count_var="__L_${cache_id}"

    # If not cached, load into global array
    if [[ -z "${!count_var}" ]]; then
        # readarray can target a dynamic variable name in Bash 4.4+
        readarray -t "$cache_var" < "$file"
        eval "$count_var=\${#$cache_var[@]}"
    fi

    local count="${!count_var}"
    if (( count == 0 )); then
        _RET=""
        return 1
    fi

    _random "$count"
    local idx="$_RET"
    eval "_RET=\${$cache_var[$idx]}"
}
