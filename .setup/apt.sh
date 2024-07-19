#!/bin/zsh

update_package_lists() {
    gum log --structured --level info "Updating package lists..."
    if sudo apt-get update -qq; then
        gum log --structured --level info "Package lists updated successfully."
        return 0
    else
        gum log --structured --level error "Failed to update package lists."
        return 1
    fi
}

install_apt_packages() {
    local apt_packages=("$@")
    gum log --structured --level info "Installing required packages..."
    
    # Update package lists
    update_package_lists || return 1
    # Install packages quietly, suppressing most output
    gum log --structured --level info "Installing APT packages..."
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${apt_packages[@]}" > /dev/null 2>&1; then
        gum log --structured --level info "APT packages installed successfully."
    else
        gum log --structured --level error "Error installing APT packages."
        return 1
    fi
}

add_charm_repository() {
    gum log --structured --level info "Adding Charm repository..."
    
    if [ ! -f /etc/apt/keyrings/charm.gpg ]; then
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg; then
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ *"* | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
            gum log --structured --level info "Charm GPG key added."
            update_package_lists
        else
            gum log --structured --level error "Failed to add Charm GPG key. Skipping Charm repository addition."
            return 1
        fi
    else
        gum log --structured --level warn "Charm GPG key already exists. Skipping addition."
    fi
    gum log --structured --level info "Charm repository process completed."
}

install_pip_packages() {
    gum log --structured --level info "Installing pip packages..."
    local pip_output
    pip_output=$(sudo pip3 install --break-system-packages -q dtj tldr 2>&1)
    
    if [ $? -eq 0 ]; then
        gum log --structured --level info "Pip packages installed successfully."
    else
        gum log --structured --level error "Error installing pip packages. Details:"
        echo "$pip_output"
        gum log --structured --level warn "PIP package installation failed. Continuing with setup..."
    fi
}
