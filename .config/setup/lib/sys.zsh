#!/bin/zsh

increase_swap_size() {
    local new_size=$1
    local current_size

    log "Increasing swap size..." debug

    if [[ -z "$new_size" ]]; then
        log "Please provide the new swap size in MB." error
        return 1
    fi

    current_size=$(grep CONF_SWAPSIZE /etc/dphys-swapfile | cut -d= -f2)

    if (( current_size >= new_size )); then
        log "Current swap size ($current_size MB) is already greater than or equal to requested size ($new_size MB). Skipping." debug
        echo
        return 0
    fi
    
    log "Increasing swap from $current_size MB to $new_size MB" debug
    
    local result
    result=$(sudo sed -i "s/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=${new_size}/" /etc/dphys-swapfile)
    if (( $? != 0 )); then
        log "Failed to update swap size in /etc/dphys-swapfile" error
        echo
        return 1
    fi
    
    result=$(sudo systemctl restart dphys-swapfile.service)
    if (( $? != 0 )); then
        log "Failed to restart dphys-swapfile service" error
        echo
        return 1
    fi
    
    log "Swap size increased to ${new_size}MB." info
    echo
}

setup_custom_motd() {
    local custom_motd_path="${1:-$HOME/.config/motd/custom_motd.sh}"
    local wrapper_path="/etc/update-motd.d/99-custom-motd"
    local sshd_config="/etc/ssh/sshd_config"
    local backup_dir="$HOME/.local/share/motd_backups"
    local date_stamp=$(date +"%Y%m%d_%H%M%S")
    local changes_made=0

    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"

    # Check if custom MOTD script exists
    if [[ ! -f "$custom_motd_path" ]]; then
        log "Custom MOTD script not found at $custom_motd_path" error
        echo
        return 1
    fi

    # Check and update PrintLastLog in sshd_config
    if ! grep -q "^PrintLastLog no" "$sshd_config"; then
        log "Updating PrintLastLog setting in sshd_config..." debug
        sudo cp "$sshd_config" "$backup_dir/sshd_config.bak_${date_stamp}"
        sudo sed -i 's/^PrintLastLog.*/PrintLastLog no/' "$sshd_config"
        if ! grep -q "^PrintLastLog no" "$sshd_config"; then
            echo "PrintLastLog no" | sudo tee -a "$sshd_config" > /dev/null
        fi
        changes_made=1
    else
        log "PrintLastLog already set to no in sshd_config" debug
    fi

    # Check for 10-uname file
    if [[ -f "/etc/update-motd.d/10-uname" ]]; then
        log "Backing up and removing 10-uname..." debug
        sudo cp "/etc/update-motd.d/10-uname" "$backup_dir/10-uname.bak_${date_stamp}"
        sudo rm "/etc/update-motd.d/10-uname"
        changes_made=1
    else
        log "10-uname not found, skipping..." debug
    fi

    # Create or update the custom MOTD wrapper
    local current_wrapper_content=""
    if [[ -f "$wrapper_path" ]]; then
        current_wrapper_content=$(cat "$wrapper_path")
    fi
    local new_wrapper_content="#!/bin/bash
export TERM=xterm-256color
$custom_motd_path"

    if [[ "$current_wrapper_content" != "$new_wrapper_content" ]]; then
        log "Updating custom MOTD wrapper..." debug
        echo "$new_wrapper_content" | sudo tee "$wrapper_path" > /dev/null
        sudo chmod 755 "$wrapper_path"
        changes_made=1
    else
        log "Custom MOTD wrapper is up to date" debug
    fi

    # Verify PAM configuration
    local pam_files=("/etc/pam.d/sshd" "/etc/pam.d/login")
    for pam_file in $pam_files; do
        if ! sudo grep -q "pam_motd.so.*motd=/run/motd.dynamic" "$pam_file"; then
            log "Expected PAM configuration not found in $pam_file" warn
            log "You may need to manually add: session optional pam_motd.so motd=/run/motd.dynamic" warn
        else
            log "PAM configuration in $pam_file is correct." debug
        fi
    done

    # Restart SSH service only if changes were made
    if (( changes_made == 1 )); then
        log "Changes made, restarting SSH service..." info
        sudo systemctl restart ssh
        log "Custom MOTD setup complete. Backups stored in $backup_dir" info
        log "Please test by logging in again." info
    else
        log "No changes were necessary. Custom MOTD setup is already correct." debug
    fi
    echo
}

get_system_info() {
    local arch=$(uname -m)
    local os=$(uname -s)
    
    log "Raw arch: $arch" debug
    log "Raw OS: $os" debug

    case $arch in
        x86_64)
            arch="x86_64|amd64"
            ;;
        aarch64|arm64)
            arch="aarch64|arm64"
            ;;
        armv7l)
            arch="armv7l|armv7"
            ;;
        *)
            arch="$arch"
            ;;
    esac

    case $os in
        Linux*)
            os="linux"
            ;;
        Darwin*)
            os="macos"
            ;;
        *)
            os=$(echo "$os" | tr '[:upper:]' '[:lower:]')
            ;;
    esac

    log "Processed arch: $arch" debug
    log "Processed OS: $os" debug

    echo "$arch"
    echo "$os"
    echo
}

setup_ssh_clipboard_forwarding() {
    local SSHD_CONFIG="/etc/ssh/sshd_config"
    local result
    
    # Enable X11 forwarding in sshd_config
    result=$(sudo sed -i.bak -e 's/^#X11Forwarding no/X11Forwarding yes/' \
                    -e 's/^X11Forwarding no/X11Forwarding yes/' \
                    -e 's/^#X11Forwarding yes/X11Forwarding yes/' \
                    -e 's/^#X11DisplayOffset 10/X11DisplayOffset 10/' \
                    -e 's/^#X11UseLocalhost yes/X11UseLocalhost yes/' \
                    -e '/^#X11Forwarding no/a X11Forwarding yes' \
                    -e '/^#X11Forwarding yes/a X11Forwarding yes' \
                    -e '/^#X11DisplayOffset 10/a X11DisplayOffset 10' \
                    -e '/^#X11UseLocalhost yes/a X11UseLocalhost yes' \
                    "$SSHD_CONFIG")
    
    if (( $? != 0 )); then
        log "Failed to update SSH configuration" error
        echo
        return 1
    fi
    
    # Restart SSH service
    if (( $+commands[systemctl] )); then
        result=$(sudo systemctl restart sshd)
    else
        result=$(sudo service ssh restart)
    fi
    
    if (( $? != 0 )); then
        log "Failed to restart SSH service" error
        echo
        return 1
    fi
    
    log "Clipboard forwarding set up and SSH service restarted." info
    echo
}

