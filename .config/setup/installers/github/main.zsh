#!/bin/zsh

source ./installers/github/utils.zsh

# TODO check [jpillora/instaler](https://github.com/jpillora/installer)
# TODO check [@codelinkx gist](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4699831#gistcomment-4699831)
    
process_package() {
    local repo=$1
    local binary=$2
    local latest_release_json version assets asset_url

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

    if ! asset_url=$(run_with_spinner "🧠 Selecting the right binary..." "find_best_asset '$assets'"); then
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

    while (( $# > 0 )); do
        local repo="$1"
        shift
        local binaries=()

        log "Processing repo: $repo" debug
        log "Remaining arguments: $@" debug

        # Ensure we have at least one binary
        if [[ -n "$1" && "$1" != *"/"* ]]; then
            binaries+=("$1")
            shift
            log "Added binary: ${binaries[-1]}" debug
        fi

        # Add any additional binaries
        while (( $# > 0 )) && [[ -n "$1" && "$1" != *"/"* ]]; do
            binaries+=("$1")
            shift
            log "Added additional binary: ${binaries[-1]}" debug
        done

        if (( ${#binaries[@]} == 0 )); then
            log "❌ Invalid package format for $repo. Expected format: owner/repo binary1 [binary2 ...]" "error"
            continue
        fi

        log "Binaries for $repo: ${binaries[*]}" debug

        for binary in "${binaries[@]}"; do
            if [[ -n "$binary" ]]; then
                log "Processing binary: $binary" debug
                if ! process_package "$repo" "$binary"; then
                    update_static_line "❌ Skipping $repo $binary: Failed to process package"
                fi
            else
                log "Skipping empty binary for $repo" debug
            fi
        done
    done
    echo
}
