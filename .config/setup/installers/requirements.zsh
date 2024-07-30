#!/bin/zsh

source "${0:A:h}/../lib/ui.zsh"
source "${0:A:h}/apt.zsh"
source "${0:A:h}/github/utils.zsh"
source "${0:A:h}/github/main.zsh"

install_gum() {
    echo "Installing gum..."
    add_repository "charm" "https://repo.charm.sh/apt/gpg.key" "https://repo.charm.sh/apt/ * *" "/etc/apt/sources.list.d/charm.list"
    
    # Update package lists
    echo "Updating APT packages..."
    if sudo apt-get update -qq; then
        echo "APT updated."
        echo
    else
        echo "Failed to update package lists."
        echo
        return 1
    fi
    
    # Install gum package quietly, suppressing most output
    echo "Installing gum..."
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gum > /dev/null 2>&1; then
        echo "gum installed. ✅"
        echo
    else
        echo "Error installing gum."
        echo
        return 1
    fi
}

install_cue() {
    log "Installing cue..." debug
    if ! install_from_github "cue-lang/cue" "cue"; then
        log "Failed to install cue" error
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
