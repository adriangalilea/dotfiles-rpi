#!/bin/zsh

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

# Global variables for rate limiting
RATE_LIMIT_REMAINING=60
RATE_LIMIT_RESET=0

check_rate_limit() {
    local current_time=$(date +%s)

    if [[ $RATE_LIMIT_REMAINING -gt 0 && $current_time -lt $RATE_LIMIT_RESET ]]; then
        return 0
    fi

    local response=$(curl -s -i "https://api.github.com/rate_limit")
    RATE_LIMIT_REMAINING=$(echo "$response" | grep -i 'x-ratelimit-remaining:' | awk -F': ' '{print $2}' | tr -d '\r')
    RATE_LIMIT_RESET=$(echo "$response" | grep -i 'x-ratelimit-reset:' | awk -F': ' '{print $2}' | tr -d '\r')

    RATE_LIMIT_RESET=$(date -d @$RATE_LIMIT_RESET +%s)

    if [[ $RATE_LIMIT_REMAINING -le 0 ]]; then
        local wait_time=$((RATE_LIMIT_RESET - current_time))
        if [[ $wait_time -gt 0 ]]; then
            echo "⏳ Rate limit exceeded. Sleeping for $wait_time seconds..."
            sleep $wait_time
        fi
        check_rate_limit
    fi
}

fetch_latest_release() {
    local repo=$1
    if [[ $RATE_LIMIT_REMAINING -le 0 ]]; then
        check_rate_limit
    fi
    local url="https://api.github.com/repos/$repo/releases/latest"
    local response=$(curl -s "$url")
    RATE_LIMIT_REMAINING=$((RATE_LIMIT_REMAINING - 1))
    if [[ -z "$response" ]]; then
        echo "Failed to fetch latest release for $repo."
        return 1
    fi
    echo -E "$response"
}

extract_release_info() {
    local latest_release_json=$1
    local version=$(echo -E "$latest_release_json" | jq -r '.tag_name')
    if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Failed to extract version" >&2
        return 1
    fi

    local assets=$(echo -E "$latest_release_json" | jq -c '.assets')
    if [[ -z "$assets" || "$assets" == "null" || "$assets" == "[]" ]]; then
        echo "No assets found in the release" >&2
        return 1
    fi

    local simplified_assets=$(echo -E "$assets" | jq -c '[.[] | {name: .name, url: .browser_download_url}]')
    if [[ -z "$simplified_assets" ]]; then
        echo "Failed to extract asset information" >&2
        return 1
    fi

    echo "$version"
    echo "$simplified_assets"
}

find_best_asset() {
    local assets=$1
    local arch_pattern="aarch64|arm64"
    local os_pattern="linux"
    local file_types=("tar.xz" "tar.gz" "zip" "AppImage" "tgz")
    local best_asset=""
    local max_score=0

    while read -r asset; do
        local asset_name=$(echo -E "$asset" | jq -r '.name' | tr '[:upper:]' '[:lower:]')
        local asset_url=$(echo -E "$asset" | jq -r '.url')
        local score=0

        [[ $asset_name =~ $arch_pattern ]] && ((score += 10))
        [[ $asset_name =~ $os_pattern ]] && ((score += 5))

        for ((i=0; i<${#file_types[@]}; i++)); do
            if [[ $asset_name =~ ${file_types[i]} ]]; then
                ((score += 5 - i))
                break
            fi
        done

        if ((score > max_score)); then
            max_score=$score
            best_asset=$asset_url
        fi
    done < <(echo -E "$assets" | jq -c '.[]')

    if [[ -z "$best_asset" ]]; then
        echo "No suitable asset found for $arch_pattern on $os_pattern." >&2
        return 1
    fi

    echo "$best_asset"
}


download_and_extract_asset() {
    local asset_url=$1
    local binary_name=$2

    local tmp_dir="/tmp/$binary_name"
    local tmp_file="$tmp_dir/$(basename "$asset_url")"

    mkdir -p "$tmp_dir"
    if ! curl -s -L "$asset_url" -o "$tmp_file"; then
        echo "Failed to download $asset_url"
        return 1
    fi

    case "$tmp_file" in
        *.tar.gz|*.tar.xz|*.tgz|*.tar)
            tar -xf "$tmp_file" -C "$tmp_dir" || { echo "Failed to extract $tmp_file"; return 1; }
            ;;
        *.zip)
            unzip -q "$tmp_file" -d "$tmp_dir" || { echo "Failed to unzip $tmp_file"; return 1; }
            ;;
        *.AppImage|*.sh)
            chmod +x "$tmp_file"
            sudo mv "$tmp_file" /usr/local/bin/"$binary_name" || { echo "Failed to move $binary_name"; return 1; }
            ;;
        *.deb)
            sudo dpkg -i "$tmp_file" || { echo "Failed to install $tmp_file"; return 1; }
            ;;
        *.rpm)
            sudo rpm -i "$tmp_file" || { echo "Failed to install $tmp_file"; return 1; }
            ;;
        *)
            echo "Unsupported file format: $tmp_file"
            return 1
            ;;
    esac

    [ -f "$tmp_file" ] && rm "$tmp_file"

    local extracted_file=$(find "$tmp_dir" -type f -executable -print -quit)
    if [ -z "$extracted_file" ]; then
        echo "$binary_name not found in the extracted files."
        return 1
    fi

    if [[ "$extracted_file" != *"$binary_name"* ]]; then
        mv "$extracted_file" "$tmp_dir/$binary_name"
        extracted_file="$tmp_dir/$binary_name"
    fi

    sudo mv "$extracted_file" /usr/local/bin/"$binary_name" || { echo "Failed to move $binary_name to /usr/local/bin/"; return 1; }
    sudo chmod +x /usr/local/bin/"$binary_name"
    rm -rf "$tmp_dir"
}


run_with_spinner() {
    local title=$1
    shift
    gum spin --spinner dot --title "$title" --show-output -- zsh -c "source /home/adrian/.setup/utils.sh; $*"
}

