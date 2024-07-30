#!/bin/zsh

source ../lib/ui.zsh
source ./apt.zsh
source ./github/utils.zsh

install_gum() {
    echo "Installing gum..."
    add_repository "charm" "https://repo.charm.sh/apt/gpg.key" "https://repo.charm.sh/apt/ * *" "/etc/apt/sources.list.d/charm.list"
    install_apt_packages "gum"
}

install_cue() {
    log "Installing cue..." debug
    local repo="cue-lang/cue"
    local binary="cue"
    local latest_release_json version assets asset_url

    if ! latest_release_json=$(fetch_latest_release "$repo"); then
        log "Failed to fetch the latest release for $repo" error
        return 1
    fi

    if ! { read -r version; read -r assets; } < <(extract_release_info "$latest_release_json"); then
        log "Failed to extract release information for $repo" error
        return 1
    fi

    log "Latest cue version: $version" debug

    if ! asset_url=$(find_best_asset "$assets"); then
        log "Failed to find best asset for $repo" error
        return 1
    fi

    if ! download_and_extract_asset "$asset_url" "$binary"; then
        log "Failed to download or extract asset for $repo" error
        return 1
    fi

    if ! command -v "$binary" &> /dev/null; then
        log "Installation failed: $binary not found in PATH" error
        return 1
    fi

    log "cue $version installed successfully." info
}

install_requirements() {
    if ! command -v gum &> /dev/null; then
        install_gum
    else
        log "gum is already installed." debug
    fi

    if ! command -v cue &> /dev/null; then
        install_cue
    else
        log "cue is already installed." debug
    fi
}
