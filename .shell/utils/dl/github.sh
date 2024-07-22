#!/bin/bash

# Function to download from GitHub
download_from_github() {
    local username=$1 repo=$2 branch=$3 filepath=$4 dest_path=$5 interactive=$6 force=$7

    logs info "🐱 $username/$repo [🌿 $branch] 📁 $filepath"
    mkdir -p "$dest_path"
    cd "$dest_path" || return 1

    local is_file=false
    [[ "$filepath" == *"."* ]] && is_file=true

    local url="https://codeload.github.com/$username/$repo/tar.gz/$branch"
    local tar_options="-xzv"
    local extract_dir="$repo-$branch"
    [ "$filepath" != "." ] && extract_dir+="/$filepath"

    local filter=""
    if [[ $is_file = true ]]; then
        if [[ $interactive = "-i" ]]; then
            logs warn "-i used but provided a specific file, nothing to choose."
        fi
        filter=$(basename "$filepath")
        extract_dir=$(dirname "$extract_dir")  # Remove the filename from extract_dir
    elif [[ $interactive = "-i" ]]; then
        filter=$(select_github_items "$username" "$repo" "$branch" "$filepath")
        if [ -z "$filter" ]; then
            logs info "No items selected. Exiting."
            return 0
        fi
    fi

    [ -n "$DEBUG" ] && echo "Using filter: $filter"

    download_and_extract_github_files "$url" "$extract_dir" "$filter" "$force"
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

# Function to download and extract GitHub files
download_and_extract_github_files() {
    local url=$1 extract_dir=$2 filter=$3 force=$4

    gum spin --spinner dot --title "Downloading from GitHub..." -- \
        curl -L "$url" -o /tmp/repo.tar.gz

    local tar_command="tar $tar_options -f /tmp/repo.tar.gz"
    [ "$force" = "--force" ] && tar_command+=" --overwrite"

    if [ -n "$filter" ]; then
        for item in $filter; do
            tar_command+=" --wildcards '$extract_dir/$item'"
        done
    else
        tar_command+=" '$extract_dir'"
    fi

    local strip_components=$(echo "$extract_dir" | tr -cd '/' | wc -c)
    strip_components=$((strip_components + 1))
    tar_command+=" --strip-components=$strip_components"

    [ -n "$DEBUG" ] && echo "Extracting with command: $tar_command"

    local extraction_output
    extraction_output=$(bash -c "$tar_command" 2>&1)
    local extraction_status=$?

    rm /tmp/repo.tar.gz

    if [ $extraction_status -eq 0 ]; then
        logs info "✅ Extracted files from $filepath"
        return 0
    else
        logs error "Extraction failed: $extraction_output"
        return 1
    fi
}
