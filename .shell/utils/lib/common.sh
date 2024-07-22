#!/bin/bash

# Function to check if a command is available
command_exists() {
    type "$1" &> /dev/null
}

# Function to check required commands
check_required_commands() {
    local missing_commands=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done

    if (( ${#missing_commands[@]} > 0 )); then
        logs error "The following required commands are missing:"
        for cmd in "${missing_commands[@]}"; do
            logs error "  - $cmd"
        done
        logs error "Please install them and try again."
        exit 1
    fi
}

# Function to parse GitHub input
parse_github_input() {
    local input=$1
    local -n ref_username=$2
    local -n ref_repo=$3
    local -n ref_branch=$4
    local -n ref_filepath=$5

    if [[ $input =~ ^git: ]]; then
        local repo=$(echo "$input" | cut -d':' -f2)
        ref_username=$(echo "$repo" | cut -d'/' -f1)
        ref_repo=$(echo "$repo" | cut -d'/' -f2)
        local branch_and_path=$(echo "$input" | cut -d':' -f3-)
        
        if [[ "$branch_and_path" == *:* ]]; then
            ref_branch=$(echo "$branch_and_path" | cut -d':' -f1)
            ref_filepath=$(echo "$branch_and_path" | cut -d':' -f2-)
        else
            ref_filepath=$branch_and_path
        fi
    elif [[ $input =~ ^https://github.com ]]; then
        ref_username=$(echo "$input" | sed -E 's|https://github.com/([^/]+)/.*|\1|')
        ref_repo=$(echo "$input" | sed -E 's|https://github.com/[^/]+/([^/]+)/blob/.*|\1|')
        ref_branch=$(echo "$input" | sed -E 's|.*/blob/([^/]+)/.*|\1|')
        ref_filepath=$(echo "$input" | sed -E 's|.*/blob/[^/]+/(.*)|\1|')
    else
        echo "Error: Invalid GitHub input format: $input" >&2
        return 1
    fi
}
