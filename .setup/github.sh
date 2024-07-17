#!/bin/zsh

download_and_extract_asset() {
    local asset_url=$1
    local binary_name=$2

    local tmp_dir="/tmp/$binary_name"
    local tmp_file="$tmp_dir/$(basename "$asset_url")"

    mkdir -p "$tmp_dir"
    if ! curl -s -L "$asset_url" -o "$tmp_file"; then
        echo "❌ Failed to download $asset_url"
        return 1
    fi

    case "$tmp_file" in
        *.tar.gz|*.tar.xz|*.tgz|*.tar)
            tar -xf "$tmp_file" -C "$tmp_dir" || { echo "❌ Failed to extract $tmp_file"; return 1; }
            ;;
        *.zip)
            unzip -q "$tmp_file" -d "$tmp_dir" || { echo "❌ Failed to unzip $tmp_file"; return 1; }
            ;;
        *.AppImage|*.sh)
            chmod +x "$tmp_file"
            sudo mv "$tmp_file" /usr/local/bin/"$binary_name" || { echo "❌ Failed to move $binary_name"; return 1; }
            ;;
        *.deb)
            sudo dpkg -i "$tmp_file" || { echo "❌ Failed to install $tmp_file"; return 1; }
            ;;
        *.rpm)
            sudo rpm -i "$tmp_file" || { echo "❌ Failed to install $tmp_file"; return 1; }
            ;;
        *)
            echo "❌ Unsupported file format: $tmp_file"
            return 1
            ;;
    esac

    [ -f "$tmp_file" ] && rm "$tmp_file"

    local extracted_file=$(find "$tmp_dir" -type f -executable -print -quit)
    if [ -z "$extracted_file" ]; then
        echo "❌ $binary_name not found in the extracted files."
        return 1
    fi

    if [[ "$extracted_file" != *"$binary_name"* ]]; then
        mv "$extracted_file" "$tmp_dir/$binary_name"
        extracted_file="$tmp_dir/$binary_name"
    fi

    sudo mv "$extracted_file" /usr/local/bin/"$binary_name" || { echo "❌ Failed to move $binary_name to /usr/local/bin/"; return 1; }
    sudo chmod +x /usr/local/bin/"$binary_name"
    rm -rf "$tmp_dir"
}

install_from_github() {
    local github_packages=("$@")

    for package in "${github_packages[@]}"; do
        package=$(echo "$package" | xargs)
        if [[ ! "$package" =~ ^[^:]+:[^:]+$ ]]; then
            echo "❌ Invalid package format: $package. Expected format: owner/repo:binary_name"
            continue
        fi

        IFS=':' read -r repo binary_name <<< "$package"
        repo=$(echo "$repo" | xargs)
        binary_name=$(echo "$binary_name" | xargs)

        echo "🌐 $repo 📦 '$binary_name' 🔍 Finding latest version..."

        local latest_release_json=$(fetch_latest_release "$repo")
        if [[ -z "$latest_release_json" ]]; then
            echo "❌ Failed to fetch latest release for $repo. Skipping."
            continue
        fi

        local version=$(echo -E "$latest_release_json" | jq -r '.tag_name')
        if [[ -z "$version" ]]; then
            echo "❌ Error: Unable to extract version from the release JSON for $repo. Skipping."
            continue
        fi

        local assets_json=$(echo -E "$latest_release_json" | jq '.assets')
        if [[ -z "$assets_json" ]]; then
            echo "❌ Error: Unable to extract assets from the release JSON for $repo. Skipping."
            continue
        fi

        local asset_url=$(find_best_asset "$assets_json")
        if [[ -z "$asset_url" ]]; then
            echo "❌ Failed to find appropriate asset for $binary_name from $repo. Skipping."
            continue
        fi

        echo "📦 '$binary_name' 🌐 $repo 🏷️ $version -> Downloading..."
        if download_and_extract_asset "$asset_url" "$binary_name"; then
            if command -v "$binary_name" &> /dev/null; then
                echo "📦 '$binary_name' 🌐 $repo 🏷️ $version was installed! ✅"
            else
                echo "❌ Installation failed for $repo."
            fi
        else
            echo "❌ Failed to download or extract asset for $binary_name from $repo."
        fi
    done
}

