#!/bin/bash

# Function to fetch the latest release and extract tag_name
fetch_latest_release() {
    local repo=$1
    local latest_release
    latest_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest")

    if [[ $? -ne 0 || -z "$latest_release" ]]; then
        echo "Error: Failed to fetch latest release for $repo."
        exit 1
    fi
    
    local tag_name
    tag_name=$(echo "$latest_release" | jq -r '.tag_name')

    if [[ $? -ne 0 || -z "$tag_name" ]]; then
        echo "Error: Failed to extract tag_name from JSON."
        exit 1
    fi

    echo "$tag_name"
}

# Function to find asset URL based on architecture
find_asset_url() {
    local repo=$1
    local tag_name=$2
    local arch=$3

    local release_url="https://api.github.com/repos/$repo/releases/tags/$tag_name"
    local release_data
    release_data=$(curl -s "$release_url")

    if [[ $? -ne 0 || -z "$release_data" ]]; then
        echo "Error: Failed to fetch release data for $repo."
        exit 1
    fi

    local asset_url
    asset_url=$(echo "$release_data" | jq -r --arg arch "$arch" '.assets[] | select(.name | contains($arch)).browser_download_url')

    if [[ $? -ne 0 || -z "$asset_url" ]]; then
        echo "Error: Failed to find asset URL for the architecture $arch."
        exit 1
    fi

    echo "$asset_url"
}

# Main function to initiate the script
main() {
    local repo="helix-editor/helix"
    local arch="aarch64-linux"
    local tag_name=$(fetch_latest_release "$repo")

    if [[ -z "$tag_name" ]]; then
        echo "Error: tag_name is empty."
        exit 1
    fi

    local asset_url=$(find_asset_url "$repo" "$tag_name" "$arch")

    if [[ -z "$asset_url" ]]; then
        echo "Error: asset_url is empty."
        exit 1
    fi

    echo "Downloading asset from $asset_url..."
    curl -L "$asset_url" -o /tmp/helix.tar.xz

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download the asset."
        exit 1
    fi

    echo "Extracting /tmp/helix.tar.xz..."
    tar -xf /tmp/helix.tar.xz -C /tmp

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract the asset."
        exit 1
    fi

    echo "Installation completed successfully."
}

main

