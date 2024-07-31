#!/bin/zsh

source ./installers/github/utils.zsh

# TODO check [jpillora/instaler](https://github.com/jpillora/installer)
# TODO check [@codelinkx gist](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4699831#gistcomment-4699831)
    
process_package() {
    local ghUsername="$1"
    local ghReponame="$2"
    local binaries=("${@:3}")

    local latest_release_json version assets

    echo "📦 $ghReponame"
    if ! latest_release_json=$(run_with_spinner "🔍 looking for the right version..." "fetch_latest_release $ghUsername $ghReponame"); then
        log "Debug: fetch_latest_release output: $latest_release_json" "debug"
        log "❌ Failed to fetch the latest release for $ghReponame" "error"
        return 1
    fi

    if ! { read -r version; read -r assets; } < <(extract_release_info "$latest_release_json"); then
        log "❌ Failed to extract release information" "error"
        log "Debug: extract_release_info failed" "debug"
        log "Debug: Latest release JSON:" "debug"
        log "$latest_release_json" "debug"
        return 1
    fi

    if [[ -z "$version" || -z "$assets" ]]; then
        log "❌ Failed to extract version or assets" "error"
        log "Debug: Extracted version: $version" "debug"
        log "Debug: Extracted assets: $assets" "debug"
        return 1
    fi

    update_static_line "📦 $ghReponame 🏷️ $version"

    if [[ -n "$asset" ]]; then
        asset_url=$(echo "$assets" | jq -r --arg asset "$asset" '.[] | select(.name == $asset) | .browser_download_url')
    else
        asset_url=$(run_with_spinner "🧠 Selecting the right name..." "find_best_asset '$assets'")
    fi

    if [[ -z "$asset_url" ]]; then
        log "❌ Failed to find best asset" "error"
        return 1
    fi

    local asset_name=$(echo "$asset_url" | awk -F/ '{print $NF}')
    local tmp_dir="/tmp/github_install_$(date +%s)"
    mkdir -p "$tmp_dir"

    if ! run_with_spinner "⬇️ Downloading..." "download_asset '$asset_url' '$tmp_dir'"; then
        log "❌ Failed to download asset" "error"
        cleanup "$tmp_dir"
        return 1
    fi

    local tmp_file="$tmp_dir/$asset_name"
    if ! run_with_spinner "📦 Extracting..." "extract_asset '$tmp_file' '$tmp_dir'"; then
        log "❌ Failed to extract asset" "error"
        cleanup "$tmp_dir"
        return 1
    fi

    for binary in "${binaries[@]}"; do
        if ! run_with_spinner "⚙️ Installing $binary..." "install_binary '$tmp_dir' '$binary' '$tmp_file'"; then
            log "❌ Installation failed for $binary" "error"
            cleanup "$tmp_dir"
            return 1
        fi
    done

    cleanup "$tmp_dir"

    for binary in "${binaries[@]}"; do
        if ! command -v "$binary" &> /dev/null; then
            log "❌ Installation verification failed: $binary not found in PATH" "error"
            return 1
        fi
    done
    
    update_static_line "📦 $ghReponame 🏷️ $version installed ✅"
    return 0
}

install_from_github() {
    log "Installing binaries from GitHub..." debug
    log "Number of arguments: $#" debug
    log "Arguments: $*" debug

    if [[ $# -lt 3 ]]; then
        log "❌ Insufficient arguments provided to install_from_github" "error"
        log "Usage: install_from_github ghUsername ghReponame binary1 [binary2 ...]" "error"
        return 1
    fi

    local ghUsername="$1"
    local ghReponame="$2"
    local binaries=("${@:3}")
    
    if ! process_package "$ghUsername" "$ghReponame" "${binaries[@]}"; then
        update_static_line "❌ Skipping $ghReponame: Failed to process package"
    fi

    echo
}

