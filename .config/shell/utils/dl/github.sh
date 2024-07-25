#!/bin/bash

# github.sh - GitHub content downloader
#
# This script handles the downloading of content from GitHub repositories.
# It is designed to be called by an external command with specific parameters.
#
# Function: download_from_github
# Usage: download_from_github username repo branch filepath dest_path interactive force
#
# Parameters:
#   $1 username: GitHub username
#   $2 repo: Repository name
#   $3 branch: Branch name or 'latest' for the latest release/default branch
#   $4 filepath: Path to file or directory within the repository
#   $5 dest_path: Local destination path for downloaded content
#   $6 interactive: Flag for interactive mode ('-i' if active)
#   $7 force: Flag to force overwrite ('--force' if active)
#
# Behavior:
# 1. Repository download:
#    - If filepath is '.', downloads the entire repository/branch
# 2. Directory download:
#    - If filepath points to a directory, downloads its contents
# 3. File download:
#    - If filepath points to a file, downloads that specific file
# 4. Interactive mode:
#    - When $6 is '-i', allows user to select specific files/directories to download
# 5. Force overwrite:
#    - When $7 is '--force', overwrites existing files in the destination
# 6. Latest release/default branch:
#    - When $3 is 'latest', automatically determines the latest release or default branch
#
# The function ensures all content is downloaded to the specified destination path (or current directory if not specified),
# without recreating the full directory structure from the repository.

# Function to get the default branch or latest release
get_latest_branch() {
    local username=$1
    local repo=$2
    local api_url="https://api.github.com/repos/$username/$repo"
    
    # First, try to get the latest release
    local latest_release
    latest_release=$(curl -s "${api_url}/releases/latest" | jq -r .tag_name)
    
    if [ "$latest_release" != "null" ] && [ -n "$latest_release" ]; then
        echo "$latest_release"
        return 0
    fi
    
    # If no releases, get the default branch
    local default_branch
    default_branch=$(curl -s "$api_url" | jq -r .default_branch)
    
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
        return 0
    fi
    
    # If all else fails, return "main" as a fallback
    echo "main"
}

# Function to select GitHub items interactively
select_github_items() {
    local username=$1 repo=$2 branch=$3 filepath=$4
    local api_url="https://api.github.com/repos/$username/$repo/contents/$filepath?ref=$branch"
    local items
    items=$(curl -s "$api_url" | jq -r '.[] | [.name, .type] | @tsv')
    
    if [ -z "$items" ]; then
        logs error "Failed to fetch directory contents or directory is empty."
        return 1
    fi

    local selected_items
    selected_items=$(echo "$items" | awk -F'\t' '{printf "%s %s\n", $1, ($2=="file" ? "📄" : "📁")}' | gum choose --no-limit --header "⬇️ Select files and directories")
    echo "$selected_items" | sed 's/ 📄$//' | sed 's/ 📁$//' | tr '\n' ' '
}

# Function to download from GitHub
download_from_github() {
    local username=$1 repo=$2 branch=$3 filepath=$4 dest_path=$5 interactive=$6 force=$7
    
    # Handle 'latest' branch
    if [ "$branch" = "latest" ]; then
        branch=$(get_latest_branch "$username" "$repo")
        logs info "Latest branch/release: $branch"
    fi
    
    logs info "🐱 $username/$repo [🌿 $branch] 📁 $filepath"
    mkdir -p "$dest_path"
    cd "$dest_path" || return 1
    local url="https://codeload.github.com/$username/$repo/tar.gz/$branch"
    local extract_dir="$repo-${branch#v}"  # Remove 'v' prefix if present
    local filter=""

    # Determine the filter based on the filepath
    if [ "$filepath" = "." ]; then
        filter="$extract_dir/*"
    elif [[ "$filepath" == *"."* ]]; then
        filter="$extract_dir/$filepath"
    else
        filter="$extract_dir/$filepath/*"
    fi

    # Handle interactive mode
    if [ "$interactive" = "-i" ] && [ "$filepath" != "." ] && [[ "$filepath" != *"."* ]]; then
        local selected_items
        selected_items=$(select_github_items "$username" "$repo" "$branch" "$filepath")
        if [ -z "$selected_items" ]; then
            logs info "No items selected. Exiting."
            return 0
        fi
        filter=$(for item in $selected_items; do echo "$extract_dir/$filepath/$item"; done | tr '\n' ' ')
    fi

    download_and_extract_github_files "$url" "$extract_dir" "$filter" "$force" "$filepath"
}

# Function to download and extract GitHub files
download_and_extract_github_files() {
    local url=$1 extract_dir=$2 filter=$3 force=$4 filepath=$5

    gum spin --spinner dot --title "Downloading from GitHub..." -- \
        curl -L "$url" -o /tmp/repo.tar.gz

    local tar_command="tar -xzvf /tmp/repo.tar.gz"
    [ "$force" = "--force" ] && tar_command+=" --overwrite"
    tar_command+=" --wildcards"

    # Calculate the number of directories to strip from the extracted files
    local strip_components=1
    if [ "$filepath" != "." ]; then
        strip_components=$(echo "$filepath" | grep -o "/" | wc -l)
        strip_components=$((strip_components + 2))  # Add 2 to handle the repo and branch directory
    fi
    tar_command+=" --strip-components=$strip_components"

    # Add each item in the filter to the tar command
    for item in $filter; do
        tar_command+=" '$item'"
    done

    # Execute the tar command and capture its output
    local extraction_output
    extraction_output=$(eval "$tar_command" 2>&1)
    local extraction_status=$?

    rm /tmp/repo.tar.gz

    if [ $extraction_status -eq 0 ]; then
        logs info "✅ Extracted files successfully"
        return 0
    else
        logs error "Extraction failed: $extraction_output"
        return 1
    fi
}

