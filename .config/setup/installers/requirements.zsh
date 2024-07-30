#!/bin/zsh

source ../lib/ui.zsh
source ./apt.zsh
source ./github/utils.zsh
source ./repo.zsh

install_gum() {
    log "Installing gum..." debug
    add_repository "charm" "https://repo.charm.sh/apt/gpg.key" "https://repo.charm.sh/apt/ * *" "/etc/apt/sources.list.d/charm.list"
    install_apt_packages "gum"
}

install_cue() {
    log "Installing cue..." debug
    local cue_version="v0.6.0"
    local cue_url="https://github.com/cue-lang/cue/releases/download/${cue_version}/cue_${cue_version}_linux_amd64.tar.gz"
    
    if ! download_and_extract_asset "$cue_url" "cue"; then
        log "Failed to download and install cue." error
        return 1
    fi
    log "cue installed successfully." info
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
