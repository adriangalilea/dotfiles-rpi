#!/bin/zsh

update_package_lists() {
    log "Updating APT packages..." debug 
    if sudo apt-get update -qq; then
        log "APT updated." debug 
        echo
        return 0
    else
        log "Failed to update package lists." error 
        echo
        return 1
    fi
}

install_apt_packages() {
    local apt_packages=("$@")
    
    # Update package lists
    update_package_lists || return 1
    # Install packages quietly, suppressing most output
    log "Installing APT packages..." debug 
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${apt_packages[@]}" > /dev/null 2>&1; then
        log "APT packages installed. ✅" info 
        echo
    else
        log "Error installing APT packages." error 
        echo
        return 1
    fi
}

add_repository() {
    local repo_name="$1"
    local gpg_key_url="$2"
    local repo_url="$3"
    local repo_list_file="$4"

    log "Adding $repo_name repository..." debug

    if [ ! -f "/etc/apt/keyrings/${repo_name}.gpg" ]; then
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL "$gpg_key_url" | sudo gpg --dearmor -o "/etc/apt/keyrings/${repo_name}.gpg"; then
            echo "deb [signed-by=/etc/apt/keyrings/${repo_name}.gpg] $repo_url" | sudo tee "$repo_list_file" > /dev/null
            log "$repo_name GPG key added." debug
            sudo apt update
        else
            log "Failed to add $repo_name GPG key. Skipping repository addition." error
            return 1
        fi
    else
        log "$repo_name GPG key already exists. Skipping addition." debug
    fi

    log "$repo_name repository process completed." debug
}
