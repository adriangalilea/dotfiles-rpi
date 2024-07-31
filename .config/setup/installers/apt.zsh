#!/bin/zsh

move_legacy_apt_keys() {
    local legacy_keyring="/etc/apt/trusted.gpg"
    local new_keyring_dir="/etc/apt/keyrings"

    if [[ -f "$legacy_keyring" ]]; then
        log "Moving legacy APT keys to new location..." debug
        sudo mkdir -p "$new_keyring_dir"
        sudo cp "$legacy_keyring" "$new_keyring_dir/legacy-trusted.gpg"
        sudo apt-key del $(sudo apt-key list | grep -E '^pub' | awk '{print $2}' | cut -d'/' -f2)
        sudo mv "$legacy_keyring" "${legacy_keyring}.bak"
        log "Legacy APT keys moved." debug
    else
        log "No legacy APT keyring found. Skipping key migration." debug
    fi
}

update_package_lists() {
    log "Updating APT packages..." debug 
    move_legacy_apt_keys
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

    echo "Adding $repo_name repository..."

    if [ ! -f "/etc/apt/keyrings/${repo_name}.gpg" ]; then
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL "$gpg_key_url" | sudo gpg --dearmor -o "/etc/apt/keyrings/${repo_name}.gpg"; then
            echo "deb [signed-by=/etc/apt/keyrings/${repo_name}.gpg] $repo_url" | sudo tee "$repo_list_file" > /dev/null
            echo "$repo_name GPG key added."
            sudo apt update
        else
            echo "Failed to add $repo_name GPG key. Skipping repository addition."
            return 1
        fi
    else
        echo "$repo_name GPG key already exists. Skipping addition."
    fi

    echo "$repo_name repository process completed."
}
