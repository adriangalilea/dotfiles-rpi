#!/bin/zsh

increase_swap_size() {
    local new_size=$1
    local current_size

    if [[ -z "$new_size" ]]; then
        gum log --structured --level error "Please provide the new swap size in MB."
        return 1
    fi

    current_size=$(grep CONF_SWAPSIZE /etc/dphys-swapfile | cut -d= -f2)

    if (( current_size >= new_size )); then
        gum log --structured --level warn "Current swap size ($current_size MB) is already greater than or equal to requested size ($new_size MB). Skipping."
        return 0
    fi
    
    gum log --structured --level info "Increasing swap from $current_size MB to $new_size MB"
    
    local result
    result=$(sudo sed -i "s/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=${new_size}/" /etc/dphys-swapfile)
    if (( $? != 0 )); then
        gum log --structured --level error "Failed to update swap size in /etc/dphys-swapfile"
        return 1
    fi
    
    result=$(sudo systemctl restart dphys-swapfile.service)
    if (( $? != 0 )); then
        gum log --structured --level error "Failed to restart dphys-swapfile service"
        return 1
    fi
    
    gum log --structured --level info "Swap size increased to ${new_size}MB."
}

get_system_info() {
    local arch=$(uname -m)
    local os=$(uname -s)
    
    gum log --structured --level debug "Raw arch: $arch"
    gum log --structured --level debug "Raw OS: $os"

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

    gum log --structured --level debug "Processed arch: $arch"
    gum log --structured --level debug "Processed OS: $os"

    echo "$arch"
    echo "$os"
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
        gum log --structured --level error "Failed to update SSH configuration"
        return 1
    fi
    
    # Restart SSH service
    if (( $+commands[systemctl] )); then
        result=$(sudo systemctl restart sshd)
    else
        result=$(sudo service ssh restart)
    fi
    
    if (( $? != 0 )); then
        gum log --structured --level error "Failed to restart SSH service"
        return 1
    fi
    
    gum log --structured --level info "Clipboard forwarding set up and SSH service restarted."
}
