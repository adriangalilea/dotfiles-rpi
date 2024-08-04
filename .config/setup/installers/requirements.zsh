#!/bin/zsh
source "${0:A:h}/../lib/ui.zsh"
source "${0:A:h}/apt.zsh"
source "${0:A:h}/github/utils.zsh"
source "${0:A:h}/github/main.zsh"

REQUIRED_BINS=("jq" "gum" "cue")

# Determine OS and set up package manager
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    PACKAGE_MANAGER="brew"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    PACKAGE_MANAGER="apt"
else
    echo "Unsupported operating system"
    exit 1
fi

install_homebrew() {
    if command -v brew &>/dev/null; then
        echo "Homebrew is already installed."
        return 0
    fi

    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$OS" == "macos" ]]; then
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    echo "Homebrew installed and added to PATH."
}

install_package() {
    local package=$1
    echo "Installing $package..."
    if [[ "$OS" == "macos" ]]; then
        brew install "$package"
    elif [[ "$OS" == "linux" ]]; then
        sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$package"
    fi
}

install_gum() {
    if [[ "$OS" == "linux" ]]; then
        add_repository "charm" "https://repo.charm.sh/apt/gpg.key" "deb [signed-by=/usr/share/keyrings/charm-archive-keyring.gpg] https://repo.charm.sh/apt/ *" "/etc/apt/sources.list.d/charm.list"
    fi
    install_package "gum"
}

install_syncthing() {
    if [[ "$OS" == "linux" ]]; then
        add_repository "syncthing" \
                       "https://syncthing.net/release-key.gpg" \
                       "https://apt.syncthing.net/" \
                       "syncthing" \
                       "stable"
    fi
    install_package "syncthing"
}

install_cue() {
    log "Installing cue..." debug
    if ! install_from_github "cue-lang" "cue" "cue"; then
        log "Failed to install cue" error
        return 1
    fi
    log "cue installed successfully." info
}

install_jq() {
    log "Installing jq..." debug
    if [[ "$OS" == "macos" ]]; then
        sudo cp bin/jq-macos-arm64 /usr/local/bin/jq
    elif [[ "$OS" == "linux" ]]; then
        sudo cp bin/jq-linux-arm64 /usr/local/bin/jq
    fi
    sudo chmod +x /usr/local/bin/jq
    log "jq installed successfully." info
}

install_requirements() {
    echo "Installing requirements..."
    if [[ "$OS" == "macos" ]]; then
        install_homebrew
    fi
    for bin in "${REQUIRED_BINS[@]}"; do
        if ! command -v "$bin" &> /dev/null; then
            echo "Installing $bin..."
            if type "install_$bin" &>/dev/null; then
                "install_$bin" || { echo "Failed to install $bin"; return 1; }
            else
                install_package "$bin"
            fi
        else
            echo "$bin is already installed."
        fi
    done
    echo "All requirements installed successfully."
}

check_requirements_installed() {
    local missing_bins=()
    for bin in "${REQUIRED_BINS[@]}"; do
        if ! command -v "$bin" &> /dev/null; then
            missing_bins+=("$bin")
        fi
    done
    
    if [ ${#missing_bins[@]} -eq 0 ]; then
        echo "All required binaries are installed."
        return 0
    else
        echo "Missing binaries: ${missing_bins[*]}"
        return 1
    fi
}
