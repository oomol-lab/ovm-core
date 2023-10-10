#!/bin/bash

RED='\e[0;31m'
GREEN='\e[1;32m'
BLUE='\e[0;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
GRAY='\e[0;90m'
CLEAR='\e[0m'

export RED GREEN BLUE MAGENTA CYAN GRAY CLEAR

printColorized() {
    NC='\e[0m'
    printf "${1}${2}${NC}"
}

panic() {
    printf "$@\n" >&2
    exit 1
}

print() {
    printf "${1}"
} 

eecho() {
    printf "$1\n"
}

section(){
    printf " ${MAGENTA}● ${1}${CLEAR}"
    eecho "\n"
}

log_info(){
    eecho " ${GREEN}►${CLEAR} ${BLUE}${1}${CLEAR}"
}

log_error() {
    eecho " ${RED}►${CLEAR} ${RED}${1}${CLEAR}"
    eecho ""
}

log_fatal() {
    eecho ""
    eecho " ${RED}►${CLEAR} ${RED}${1}${CLEAR}"

    exit 1
}

