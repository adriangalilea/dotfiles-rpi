#!/bin/zsh

source "${0:A:h}/../lib/ui.zsh"
source "${0:A:h}/apt.zsh"
source "${0:A:h}/github/utils.zsh"
source "${0:A:h}/github/main.zsh"

REQUIRED_BINS=("gum" "cue" "jq")

install_gum() {
    echo "Installing gum..."

    if [ "$(uname)" = "Darwin" ]; then
        echo "Detected macOS."

        # Check if Homebrew is installed
        if ! command -v brew &>/dev/null; then
            echo "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Install gum using Homebrew
        if brew install gum; then
            echo "gum installed. ✅"
        else
            echo "Error installing gum."
            return 1
        fi
    else
        echo "Detected Linux."

        # Add repository and key using the add_repository function
        add_repository "charm" "https://repo.charm.sh/apt/gpg.key" "deb [signed-by=/usr/share/keyrings/charm-archive-keyring.gpg] https://repo.charm.sh/apt/ * *" "/etc/apt/sources.list.d/charm.list"

        # Update package lists and install gum
        if sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gum > /dev/null 2>&1; then
            echo "gum installed. ✅"
        else
            echo "Error installing gum."
            return 1
        fi
    fi
}

install_cue() {
    log "Installing cue..." debug
    if ! install_from_github "cue-lang" "cue" "cue"; then
        log "Failed to install cue" error
        return 1
    fi
    log "cue installed successfully." info
}

install_jq() {
    log "Installing jq..." debug
    if ! install_from_github "jqlang" "jq" "jq"; then
        log "Failed to install jq" error
        return 1
    fi
    log "jq installed successfully." info
}

install_requirements() {
    for bin in "${REQUIRED_BINS[@]}"; do
        if ! command -v "$bin" &> /dev/null; then
            "install_$bin"
        else
            log "$bin is already installed." debug
        fi
    done
}

check_requirements_installed() {
    for bin in "${REQUIRED_BINS[@]}"; do
        if ! command -v "$bin" &> /dev/null; then
            return 1
        fi
    done
    return 0
}
