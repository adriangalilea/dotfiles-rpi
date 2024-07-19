#!/bin/zsh

# TODO check [jpillora/instaler](https://github.com/jpillora/installer)
# TODO check [@codelinkx gist](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4699831#gistcomment-4699831)
# TODO [implement dra](https://github.com/devmatteini/dra?tab=readme-ov-file#non-interactive-download)

# Function to update the static line
update_static_line() {
    local message=$1
    echo -e "\033[1A\033[K$message"
}
    
process_package() {
    local repo=$1
    local binary=$2
    local latest_release_json version assets asset_url

    echo "📦 $binary 🌐 $repo"
    if ! latest_release_json=$(run_with_spinner "🔍 looking for the right version..." "fetch_latest_release $repo"); then
        echo "❌ Failed to fetch the latest release for $repo"
        return 1
    fi

    if ! { read -r version; read -r assets; } < <(extract_release_info "$latest_release_json"); then
        echo "❌ Failed to extract release information"
        return 1
    fi
    update_static_line "📦 $binary 🌐 $repo 🏷️ $version"
    run_with_spinner "🧠 Extracting release info..." "sleep 1"  # Simulating work

    if ! asset_url=$(run_with_spinner "🧠 Selecting the right binary..." "find_best_asset '$assets'"); then
        echo "❌ Failed to find best asset"
        return 1
    fi

    local asset_name=$(echo "$asset_url" | awk -F/ '{print $NF}')
    if ! run_with_spinner "⚙️ Installing..." "download_and_extract_asset '$asset_url' '$binary'"; then
        echo "❌ Failed to download or extract asset"
        return 1
    fi

    if ! command -v "$binary" &> /dev/null; then
        echo "❌ Installation failed: $binary not found in PATH"
        return 1
    fi

    return 0
}

install_from_github() {
    local github_packages=("$@")

    for package in "${github_packages[@]}"; do
        if [[ ! "$package" =~ ^[^:]+:[^:]+$ ]]; then
            echo "❌ Invalid package format: $package. Expected format: owner/repo:binary"
            continue
        fi
    
        IFS=':' read -r repo binary <<< "$package"

        repo=$(echo "$repo" | xargs)
        binary=$(echo "$binary" | xargs)

        if ! process_package "$repo" "$binary"; then
            update_static_line "❌ Skipping $package: Failed to process package"
            
        else
            update_static_line "📦 $binary 🌐 $repo 🏷️ $version was installed! ✅"
        fi
    done
}
