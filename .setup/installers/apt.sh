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
