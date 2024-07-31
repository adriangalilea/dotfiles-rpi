#!/bin/zsh

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
    local username=$1
    local name=$2
    
    if [[ $RATE_LIMIT_REMAINING -le 0 ]]; then
        check_rate_limit
    fi
    local url="https://api.github.com/repos/$username/$name/releases/latest"
    local response=$(curl -s "$url")
    RATE_LIMIT_REMAINING=$((RATE_LIMIT_REMAINING - 1))
    if [[ -z "$response" ]]; then
        echo "Failed to fetch latest release for $name."
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
    local arch_pattern="aarch64|arm64|armv7l"
    local os_pattern="linux"
    local file_types=("tar.xz" "tar.gz" "tgz" "tar.bz2" "tbz2" "zip" "AppImage" "deb" "bin" "run")
    local best_asset=""
    local max_score=0
    while read -r asset; do
        local asset_name=$(echo -E "$asset" | jq -r '.name' | tr '[:upper:]' '[:lower:]')
        local asset_url=$(echo -E "$asset" | jq -r '.url')
        local score=0
        local is_valid_type=false
        for type in "${file_types[@]}"; do
            if [[ $asset_name == *.$type ]]; then
                is_valid_type=true
                break
            fi
        done
        if ! $is_valid_type; then
            continue
        fi
        [[ $asset_name =~ $arch_pattern ]] && ((score += 10))
        [[ $asset_name =~ $os_pattern ]] && ((score += 5))
        for ((i=0; i<${#file_types[@]}; i++)); do
            if [[ $asset_name == *.${file_types[i]} ]]; then
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

#!/bin/zsh

# Download the asset
download_asset() {
    local asset_url=$1
    local tmp_dir=$2
    local tmp_file="$tmp_dir/$(basename "$asset_url")"
    
    if ! curl -s -L "$asset_url" -o "$tmp_file"; then
        echo "Failed to download $asset_url"
        return 1
    fi
    echo "$tmp_file"
}

# Extract the downloaded asset
extract_asset() {
    local tmp_file=$1
    local tmp_dir=$2
    
    case "$tmp_file" in
        *.tar.gz|*.tar.xz|*.tgz|*.tar|*.tar.bz2|*.tbz2)
            tar -xf "$tmp_file" -C "$tmp_dir" || return 1
            ;;
        *.zip)
            unzip -q "$tmp_file" -d "$tmp_dir" || return 1
            ;;
        *.AppImage|*.sh|*.bin|*.run)
            chmod +x "$tmp_file"
            return 0
            ;;
        *.deb)
            sudo dpkg -i "$tmp_file" > /dev/null || return 1
            return 0
            ;;
        *)
            echo "Unsupported file format: $tmp_file"
            return 1
            ;;
    esac
    return 0
}

# Find and install a single binary
install_binary() {
    local tmp_dir=$1
    local binary=$2
    local tmp_file=$3
    
    if [[ "$tmp_file" == *.AppImage || "$tmp_file" == *.sh || "$tmp_file" == *.bin || "$tmp_file" == *.run ]]; then
        sudo cp "$tmp_file" /usr/local/bin/"$binary" || return 1
    else
        local extracted_file=$(find "$tmp_dir" -type f -executable -name "*$binary*" -print -quit)
        if [ -z "$extracted_file" ]; then
            extracted_file=$(find "$tmp_dir" -type f -executable -print -quit)
        fi
        if [ -z "$extracted_file" ]; then
            echo "$binary not found in the extracted files."
            return 1
        fi
        if [[ "$extracted_file" != *"$binary"* ]]; then
            mv "$extracted_file" "$tmp_dir/$binary"
            extracted_file="$tmp_dir/$binary"
        fi
        sudo mv "$extracted_file" /usr/local/bin/"$binary" || return 1
    fi
    sudo chmod +x /usr/local/bin/"$binary"
    return 0
}

# Clean up temporary files
cleanup() {
    local tmp_dir=$1
    rm -rf "$tmp_dir"
}
