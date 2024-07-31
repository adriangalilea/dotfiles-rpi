#!/bin/zsh

source ./installers/github/utils.zsh

# TODO check [jpillora/instaler](https://github.com/jpillora/installer)
# TODO check [@codelinkx gist](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4699831#gistcomment-4699831)
    
process_package() {
    local repo=$1
    local binary=$2
    local latest_release_json version assets asset_url asset

    echo "🌐 $repo 📦 $binary"
    if ! latest_release_json=$(run_with_spinner "🔍 looking for the right version..." "fetch_latest_release $repo"); then
        log "❌ Failed to fetch the latest release for $repo" "error"
        return 1
    fi

    if ! { read -r version; read -r assets; } < <(extract_release_info "$latest_release_json"); then
        log "❌ Failed to extract release information" "error"
        return 1
    fi
    update_static_line "🌐 $repo 📦 $binary 🏷️ $version"

    if [[ -n "$asset" ]]; then
        asset_url=$(echo "$assets" | jq -r --arg asset "$asset" '.[] | select(.name == $asset) | .browser_download_url')
    else
        asset_url=$(run_with_spinner "🧠 Selecting the right binary..." "find_best_asset '$assets'")
    fi

    if [[ -z "$asset_url" ]]; then
        log "❌ Failed to find best asset" "error"
        return 1
    fi

    local asset_name=$(echo "$asset_url" | awk -F/ '{print $NF}')
    if ! run_with_spinner "⚙️ Installing..." "download_and_extract_asset '$asset_url' '$binary'"; then
        log "❌ Failed to download or extract asset" "error"
        return 1
    fi

    if ! command -v "$binary" &> /dev/null; then
        log "❌ Installation failed: $binary not found in PATH" "error"
        return 1
    fi
    update_static_line "🌐 $repo 📦 $binary 🏷️ $version installed ✅"
    return 0
}

install_from_github() {
    log "Installing binaries from github..." debug
    log "Number of arguments: $#" debug
    log "Arguments: $@" debug

    if [[ $# -eq 0 ]]; then
        log "❌ No arguments provided to install_from_github" "error"
        return 1
    fi

    while (( $# >= 2 )); do
        local repo="$1"
        local binary="$2"
        local asset="$3"
        shift 3

        log "Processing repo: $repo" debug
        log "Processing binary: $binary" debug

        if [[ -z "$repo" || -z "$binary" ]]; then
            log "❌ Invalid package format. Expected format: owner/repo binary" "error"
            continue
        fi

        if ! process_package "$repo" "$binary"; then
            update_static_line "❌ Skipping $repo $binary: Failed to process package"
        fi
    done

    if (( $# > 0 )); then
        log "❌ Odd number of arguments. Last argument ignored: $1" "error"
    fi

    echo
}
