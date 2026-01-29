#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# MISC
# -----------------------------------------------------------------------------

function email {
    : <<'DOC'
Generates a random e-mail address.
Usage: fake email [male|female]
DOC
    local gender="$1"
    local old_direct=$_DIRECT_CALL
    _DIRECT_CALL=0
    firstname "$gender"
    local fn="${_RET,,}"
    lastname "$gender"
    local ln="${_RET,,}"
    _pick "$__DIR/locale/$o_locale/email.txt"
    local dom="$_RET"
    _RET="${fn}.${ln}@${dom}"
    _DIRECT_CALL=$old_direct
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function phone_number {
    : <<'DOC'
Generates a random phone number in +## ### ### ### format.
Usage: fake phone_number
DOC
    local pattern="+## ### ### ###"
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

function uuid {
    : <<'DOC'
Generates a random UUID v4.
Usage: fake uuid
DOC
    local i char
    local res=""
    for ((i=0; i<32; i++)); do
        _random 16
        printf -v char "%x" "$_RET"
        res+="$char"
    done
    res="${res:0:12}4${res:13}"
    _random 4
    local y_opts=("8" "9" "a" "b")
    res="${res:0:16}${y_opts[_RET]}${res:17}"
    _RET="${res:0:8}-${res:8:4}-${res:12:4}-${res:16:4}-${res:20:12}"
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}

function lorem {
    : <<'DOC'
Generates random words (lorem ipsum).
Usage: fake lorem [count]
DOC
    local cnt="${1:-1}"
    local words=()
    local i
    local old_direct=$_DIRECT_CALL
    _DIRECT_CALL=0
    for (( i=0; i<cnt; i++ )); do
        _pick "$__DIR/locale/$o_locale/lorem.txt"
        words+=("$_RET")
    done
    _RET="${words[*]}"
    _DIRECT_CALL=$old_direct
    [[ $_DIRECT_CALL -eq 1 ]] && printf "%s\n" "$_RET"
}
