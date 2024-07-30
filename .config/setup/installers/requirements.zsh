#!/bin/zsh

source ../lib/ui.zsh

install_gum() {
    log "Installing gum..." debug
    log "Adding Charm repository..." debug
    if [ ! -f /etc/apt/keyrings/charm.gpg ]; then
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg; then
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
            log "Charm GPG key added." debug
            sudo apt update
        else
            log "Failed to add Charm GPG key. Skipping Charm repository addition." error
            return 1
        fi
    else
        log "Charm GPG key already exists. Skipping addition." debug
    fi
    log "Charm repository process completed." debug

    if ! sudo apt update && sudo apt install gum -y; then
        log "Failed to install gum." error
        return 1
    fi
    log "gum installed successfully." info
}

install_cue() {
    log "Installing cue..." debug
    local cue_version="v0.6.0"
    local cue_url="https://github.com/cue-lang/cue/releases/download/${cue_version}/cue_${cue_version}_linux_amd64.tar.gz"
    
    if ! curl -L "${cue_url}" | sudo tar zx -C /usr/local/bin cue; then
        log "Failed to download and install cue." error
        return 1
    fi
    sudo chmod +x /usr/local/bin/cue
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
