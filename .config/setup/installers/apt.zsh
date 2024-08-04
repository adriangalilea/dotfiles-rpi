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
    local repo_suite="${4:-*}"  # Default to '*' if not provided
    local repo_component="${5:-*}"  # Default to '*' if not provided

    # Define keyring and list file paths
    local keyring_file="/etc/apt/keyrings/${repo_name}.gpg"
    local list_file="/etc/apt/sources.list.d/${repo_name}.list"

    echo "Adding ${repo_name} repository..."

    # Create keyrings directory if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings

    # Download and add GPG key if it doesn't exist or is empty
    if [ ! -s "$keyring_file" ]; then
        if curl -fsSL "$gpg_key_url" | sudo gpg --dearmor -o "$keyring_file"; then
            echo "${repo_name} GPG key added."
        else
            echo "Failed to download or add ${repo_name} GPG key. Skipping repository addition."
            return 1
        fi
    else
        echo "${repo_name} GPG key already exists. Skipping addition."
    fi

    # Check if repository entry already exists
    local repo_entry="deb [signed-by=${keyring_file}] ${repo_url} ${repo_suite} ${repo_component}"
    if grep -qF "$repo_entry" "$list_file" 2>/dev/null; then
        echo "${repo_name} repository entry already exists. Skipping addition."
    else
        # Add repository entry to sources list
        echo "$repo_entry" | sudo tee -a "$list_file" > /dev/null
        echo "${repo_name} repository entry added."
    fi

    # Update package list
    echo "Updating package list..."
    if sudo apt-get update -qq; then
        echo "${repo_name} repository process completed successfully."
    else
        echo "Failed to update package list. Please check the repository entry."
        return 1
    fi
}
