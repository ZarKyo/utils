#!/bin/bash
#
# Shared Bash library. Source this file from other scripts:
#   . ~/utils/bin/utils.sh
#
# Functions:
#   print_status <TAG> <message>  Colored output. Tags: PRIMARY SUCCESS ERROR WARNING INFO DEBUG
#   check_root                    Exit if not running as root.
#

# From halpomeranz/dfis
declare -A TextColor

# Terminal escape codes to color text
# \033[STYLE;TEXT_COLOR;BG_COLORm
TextColor=(
    ['PRIMARY']='\033[0;37m'  # WHITE text
    ['SUCCESS']='\033[0;32m'  # GREEN text
    ['ERROR']='\033[0;31m'    # RED text
    ['WARNING']='\033[0;33m'  # YELLOW text
    ['INFO']='\033[0;34m'     # BLUE text
    ['DEBUG']='\033[0;36m'    # PURPLE text
)

NC='\033[0m'                  # No Color

print_status() {
    local tag="$1"
    local msg="$2"
    local tclr=${TextColor[$tag]:-$NC}
    local ts

    ts="$(date '+%Y-%m-%d %H:%M:%S')"

    if [[ "$tag" == "ERROR" ]]; then
        printf "${tclr}%s - [%s] - %s${NC}\n" "$ts" "$tag" "$msg" >&2
    else
        printf "${tclr}%s - [%s] - %s${NC}\n" "$ts" "$tag" "$msg"
    fi
    [[ -n "${LOG:-}" ]] && printf "%s - [%s] - %s\n" "$ts" "$tag" "$msg" >> "$LOG"
}

# Check root rights
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "ERROR" "This script must be run as root !"
        exit 1
    fi
}

