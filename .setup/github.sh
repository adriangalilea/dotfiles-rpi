#!/bin/zsh

process_package() {
    local package=$1
    IFS=':' read -r repo binary_name <<< "$package"

    local latest_release_json
    if ! latest_release_json=$(fetch_latest_release "$repo"); then
        echo "Failed to fetch latest release"
        return 1
    fi

    local version
    if ! version=$(echo -E "$latest_release_json" | jq -r '.tag_name'); then
        echo "Failed to extract version"
        return 1
    fi

    local assets_json
    if ! assets_json=$(echo -E "$latest_release_json" | jq '.assets'); then
        echo "Failed to extract assets"
        return 1
    fi

    local asset_url
    if ! asset_url=$(find_best_asset "$assets_json"); then
        echo "Failed to find best asset"
        return 1
    fi

    if ! download_and_extract_asset "$asset_url" "$binary_name"; then
        echo "Failed to download or extract asset"
        return 1
    fi

    if ! command -v "$binary_name" &> /dev/null; then
        echo "Installation failed"
        return 1
    fi

    return 0
}

install_from_github() {
    local github_packages=("$@")

    for package in "${github_packages[@]}"; do
        IFS=':' read -r repo binary_name <<< "$package"

        if [[ ! "$package" =~ ^[^:]+:[^:]+$ ]]; then
            echo "❌ Invalid package format: $package. Expected format: owner/repo:binary_name"
            continue
        fi

        repo=$(echo "$repo" | xargs)
        binary_name=$(echo "$binary_name" | xargs)

        if ! error=$(process_package "$package" 2>&1); then
            echo "❌ Skipping $package: $error"
        else
            echo "📦 '$binary_name' was installed! ✅"
        fi
    done
}
