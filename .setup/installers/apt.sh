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
        gum log --structured --level info "APT packages installed successfully.✅"
    else
        gum log --structured --level error "Error installing APT packages."
        return 1
    fi
}
