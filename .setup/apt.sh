#!/bin/zsh

update_package_lists() {
    log "Updating package lists..." "blue"
    if sudo apt-get update -qq; then
        log "Package lists updated successfully." "green"
        return 0
    else
        log "Failed to update package lists." "red"
        return 1
    fi
}

install_apt_packages() {
    local apt_packages=("$@")

    log "Installing required packages..." "blue"
    
    # Update package lists
    update_package_lists || return 1

    # Install packages quietly, suppressing most output
    log "Installing APT packages..." "blue"
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${apt_packages[@]}" > /dev/null 2>&1; then
        log "APT packages installed successfully." "green"
    else
        log "Error installing APT packages." "red"
        return 1
    fi
}

add_charm_repository() {
    log "Adding Charm repository..." "blue"
    
    if [ ! -f /etc/apt/keyrings/charm.gpg ]; then
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg; then
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
            log "Charm GPG key added." "blue"
            update_package_lists
        else
            log "Failed to add Charm GPG key. Skipping Charm repository addition." "red"
            return 1
        fi
    else
        log "Charm GPG key already exists. Skipping addition." "yellow"
    fi

    log "Charm repository process completed." "green"
}

install_pip_packages() {
    log "Installing pip packages..." "blue"
    local pip_output
    pip_output=$(sudo pip3 install --break-system-packages -q dtj tldr 2>&1)
    
    if [ $? -eq 0 ]; then
        log "Pip packages installed successfully." "green"
    else
        log "Error installing pip packages. Details:" "red"
        echo "$pip_output"
        log "PIP package installation failed. Continuing with setup..." "yellow"
    fi
}
