#!/bin/sh

# ANSI color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
ORANGE='\033[0;33m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Utility Functions
print_center() {
    text="$1"
    color="$2"
    width=$(tput cols)
    textwidth=${#text}
    padding=$(( (width - textwidth) / 2 ))
    printf "%${padding}s" ''
    printf "${color}%s${NC}\n" "$text"
}

print_line() {
    width=$(tput cols)
    printf '%*s\n' "${width}" '' | tr ' ' '-'
}

human_readable_time() {
    local seconds=$1
    local suffix=$2
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600 ))
    local minutes=$(( (seconds % 3600) / 60 ))

    if [ $days -gt 0 ]; then
        printf "%d days%s" $days "$suffix"
    elif [ $hours -gt 0 ]; then
        printf "%d hours%s" $hours "$suffix"
    elif [ $minutes -gt 0 ]; then
        printf "%d minutes%s" $minutes "$suffix"
    else
        printf "%d seconds%s" $seconds "$suffix"
    fi
}

# System Info Functions
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        uname -s
    fi
}

get_cpu_info() {
    model=$(grep "Model" /proc/cpuinfo | cut -d: -f2 | xargs)
    cores=$(grep -c ^processor /proc/cpuinfo)
    echo "$model ($cores cores)"
}

get_ip_address() {
    hostname -I | awk '{print $1}'
}

get_login_info() {
    current_ip=$(who -u | awk '{print $NF}' | tr -d '()')
    last -5 -F -i | awk -v current_ip="$current_ip" '
    function get_seconds(date_str) {
        cmd = "date -d \"" date_str "\" +%s"
        cmd | getline timestamp
        close(cmd)
        return timestamp
    }
    function format_date(date_str) {
        cmd = "date -d \"" date_str "\" \"+%y/%m/%d %H:%M\""
        cmd | getline formatted
        close(cmd)
        return formatted
    }
    NR == 1 && $1 != "reboot" {
        current_time = get_seconds("now")
        login_time = get_seconds($4 " " $5 " " $6 " " $7)
        time_diff = current_time - login_time
        printf "Current session:\t%d\t%s\t%s\t%s\n", time_diff, format_date($4 " " $5 " " $6 " " $7), $3, $3
    }
    NR > 1 && $1 != "reboot" && !printed_last_login {
        current_time = get_seconds("now")
        login_time = get_seconds($4 " " $5 " " $6 " " $7)
        time_diff = current_time - login_time
        printf "Last login:\t%d\t%s\t%s\t%s\n", time_diff, format_date($4 " " $5 " " $6 " " $7), $3, $3
        printed_last_login = 1
    }
    '
}

print_login_info() {
    get_login_info | {
        read -r current_session_line
        read -r last_login_line

        current_session_type=$(echo "$current_session_line" | cut -f1)
        current_session_seconds=$(echo "$current_session_line" | cut -f2)
        current_session_date=$(echo "$current_session_line" | cut -f3)
        current_session_ip=$(echo "$current_session_line" | cut -f4 | xargs)

        last_login_type=$(echo "$last_login_line" | cut -f1)
        last_login_seconds=$(echo "$last_login_line" | cut -f2)
        last_login_date=$(echo "$last_login_line" | cut -f3)
        last_login_ip=$(echo "$last_login_line" | cut -f4 | xargs)

        # Determine the IP color
        if [ "$current_session_ip" != "$last_login_ip" ]; then
            current_ip_color="$ORANGE"
            last_ip_color="$ORANGE"
            ip_reset="$NC"
        else
            current_ip_color="$NC"
            last_ip_color="$NC"
        fi

        # Print current session
        printf "${YELLOW}%-16s${NC} %s\t%s\tfrom\t${current_ip_color}%s${NC}\n" "$current_session_type" "$(human_readable_time "$current_session_seconds")" "$current_session_date" "$current_session_ip"

        # Print last login session
        printf "${YELLOW}%-16s${NC} %s\t%s\tfrom\t${last_ip_color}%s${NC}\n" "$last_login_type" "$(human_readable_time "$last_login_seconds" " ago")" "$last_login_date" "$last_login_ip"
    }
}

# Main Script
print_line
print_center "Welcome to $(hostname)" "$BLUE"
print_center "$(get_ip_address)" "${NC}"
print_line
printf "\n"
printf "${GRAY}System:${NC}\n"
printf "  ${BLUE}%-14s${NC} %s\n" "OS:" "$(get_os)"
printf "  ${BLUE}%-14s${NC} %s\n" "Architecture:" "$(uname -m)"
printf "  ${BLUE}%-14s${NC} %s\n" "CPU:" "$(get_cpu_info)"
printf "\n"
printf "${GRAY}Resources:${NC}\n"
printf "  ${CYAN}%-14s${NC} %s\n" "Memory:" "$(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
printf "  ${CYAN}%-14s${NC} %s\n" "Disk:" "$(df -h / | awk '/\// {print $3 " / " $2 " (" $5 ")"}')"
printf "\n"
printf "${GRAY}Status:${NC}\n"
printf "  ${GREEN}%-14s${NC} %s\n" "Date:" "$(date)"
printf "  ${GREEN}%-14s${NC} %s\n" "Uptime:" "$(uptime -p)"
printf "  ${GREEN}%-14s${NC} %s\n" "Load:" "$(cat /proc/loadavg | cut -d " " -f1-3)"
printf "\n"
print_login_info
printf "\n"
print_line
