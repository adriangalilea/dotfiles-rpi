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
    log "Installing APT packages: ${apt_packages[*]}" debug 
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${apt_packages[@]}" > /dev/null 2>&1; then
        log "APT packages installed successfully. ✅" info
    else
        log "Error installing APT packages." error
        return 1
    fi
}

add_repository() {
    local repo_name="$1"
    local gpg_key_url="$2"
    local repo_url="$3"

    # Define keyring and list file paths
    local keyring_file="/etc/apt/keyrings/${repo_name}.gpg"
    local list_file="/etc/apt/sources.list.d/${repo_name}.list"

    echo "Adding ${repo_name} repository..."

    # Create keyrings directory if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings

    # Download and add GPG key if it doesn't exist
    if [ ! -f "$keyring_file" ]; then
        if curl -fsSL "$gpg_key_url" | sudo gpg --dearmor -o "$keyring_file"; then
            echo "${repo_name} GPG key added."
        else
            echo "Failed to download or add ${repo_name} GPG key. Skipping repository addition."
            return 1
        fi
    else
        echo "${repo_name} GPG key already exists. Skipping addition."
    fi

    # Add repository entry to sources list
    echo "deb [signed-by=${keyring_file}] ${repo_url} * *" | sudo tee "$list_file" > /dev/null

    # Update package list
    if sudo apt update; then
        echo "${repo_name} repository process completed."
    else
        echo "Failed to update package list. Please check the repository entry."
        return 1
    fi
}
