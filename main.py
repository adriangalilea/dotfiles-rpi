#!/bin/bash

# Define log file
LOGFILE="$HOME/setup.log"

log() {
    echo "$1" | tee -a "$LOGFILE"
}

# Redirect stdout and stderr to the log file for the entire script
exec > >(tee -a "$LOGFILE") 2>&1

increase_swap_size() {
    local new_size=$1
    
    if [[ -z "$new_size" ]]; then
        log "Please provide the new swap size in MB."
        return 1
    fi

    sudo sed -i "s/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=${new_size}/" /etc/dphys-swapfile
    sudo systemctl restart dphys-swapfile.service
    
    log "Swap size increased to ${new_size}MB."
}
    
rpi_setup() {
    log "Increasing swap to 1GB"
    increase_swap_size 1024
    
    # DO NOT use 'rpi-update' as part of a regular update process.
    # log "Updating rpi..."
    # sudo rpi-update
    
    log "Installing required packages..."
    sudo apt install -y zsh git wget curl jq tar xz-utils htop neofetch bat build-essential dh-make devscripts golang python3-pip fd-find tree tmux shellcheck
    
    # Install dtj :)
    sudo pip3 install dtj --break-system-packages

    # Install tldr
    sudo pip3 install --break-system-packages tldr

}

determine_architecture() {
    ARCH=$(uname -m)
    log "Detected architecture: $ARCH"

    case $ARCH in
        x86_64)
            ARCH="x86_64"
            HELIX_FILE_EXT="AppImage"
            EZA_FILE_EXT="tar.gz"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            HELIX_FILE_EXT="tar.xz"
            EZA_FILE_EXT="tar.gz"
            ;;
        *)
            log "Unsupported architecture: $ARCH"
            log "Please report this to the script maintainer."
            exit 1
            ;;
    esac
    log "Normalized architecture: $ARCH"
}

fetch_latest_release() {
    local repo=$1
    local latest_release=$(curl -s https://api.github.com/repos/$repo/releases/latest)
    
    if ! log "$latest_release" | jq -e . >/dev/null 2>&1; then
        log "Failed to fetch the latest release for $repo. Response was:"
        log "$latest_release"
        exit 1
    fi

    log "$latest_release"
}


install_helix() {
    log "Installing Helix..."
    local latest_release=$(fetch_latest_release "helix-editor/helix")
    local version=$(log "$latest_release" | jq -r .tag_name)

    log "Searching for asset matching: ${ARCH}-linux.${HELIX_FILE_EXT}"
    local asset_url=$(log "$latest_release" | jq -r ".assets[] | select(.name | test(\"${ARCH}-linux.${HELIX_FILE_EXT}$\")) | .browser_download_url")

    if [ -z "$asset_url" ]; then
        log "Error: Could not find appropriate file for your architecture ($ARCH)."
        log "Available assets:"
        log "$(log "$latest_release" | jq -r '.assets[].name')"
        log "You may need to build Helix from source for your architecture."
        exit 1
    fi

    log "Found asset URL: $asset_url"

    log "Downloading Helix $version for $ARCH..."
    curl -L $asset_url -o helix.$HELIX_FILE_EXT &>> $LOGFILE

    log "Installing Helix..."
    if [ "$HELIX_FILE_EXT" = "AppImage" ]; then
        chmod +x helix.AppImage
        sudo mv helix.AppImage /usr/local/bin/hx
        log "Helix $version has been installed to /usr/local/bin/hx"
        rm helix.AppImage
    elif [ "$HELIX_FILE_EXT" = "tar.xz" ]; then
        tar -xf helix.$HELIX_FILE_EXT &>> $LOGFILE
        sudo mv helix-* /opt/helix
        sudo ln -sf /opt/helix/hx /usr/local/bin/hx
        log "Helix $version has been installed to /opt/helix and linked to /usr/local/bin/hx"
        rm -rf helix-$version-aarch64-linux helix.$HELIX_FILE_EXT
    fi
}


install_eza() {
    log "Installing eza..."
    local latest_release=$(fetch_latest_release "eza-community/eza")
    local version=$(log "$latest_release" | jq -r .tag_name)

    log "Searching for asset matching: eza_${ARCH}-unknown-linux-gnu.${EZA_FILE_EXT}"
    local asset_url=$(log "$latest_release" | jq -r ".assets[] | select(.name | test(\"eza_${ARCH}-unknown-linux-gnu.${EZA_FILE_EXT}$\")) | .browser_download_url")

    if [ -z "$asset_url" ]; then
        log "Error: Could not find appropriate file for your architecture ($ARCH)."
        log "Available assets:"
        log "$(log "$latest_release" | jq -r '.assets[].name')"
        log "You may need to build eza from source for your architecture."
        exit 1
    fi

    log "Found asset URL: $asset_url"

    log "Downloading eza $version for $ARCH..."
    wget -c $asset_url -O - | tar xz &>> $LOGFILE

    sudo chmod +x eza
    sudo chown root:root eza
    sudo mv eza /usr/local/bin/eza
    log "eza $version has been installed to /usr/local/bin/eza"
}

setup_local_eza() {
    log "Setting up local eza binary..."
    if [ "$ARCH" = "aarch64" ]; then
        if [[ -f "$HOME/.shell/bin/eza" ]]; then
            chmod +x "$HOME/.shell/bin/eza"
            log "Made local eza binary executable at $HOME/.shell/bin/eza"
        else
            log "Error: Local eza binary not found at $HOME/.shell/bin/eza"
            log "Please ensure the aarch64 eza binary is placed in $HOME/.shell/bin/"
            exit 1
        fi
    else
        log "Architecture is not aarch64. Skipping local eza setup."
        log "Current architecture: $ARCH"
        log "For non-aarch64 architectures, please use the install_eza function or provide appropriate binaries."
    fi
}

setup_zsh() {
    log "Setting up Zsh..."
    sudo usermod --shell $(which zsh) $USER

    # Download and set up .zshrc
    curl -sL https://gist.githubusercontent.com/adriangalilea/172754e3bfc75f729db7c9d7780fa0d7/raw/4fb7592433529c4d291cd833bfa387831a17c073/.zshrc -o $HOME/.zshrc

    log "Installing zplug..."
    if ! curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh; then
        log "Failed to install zplug. Proceeding with the rest of the setup."
    fi

    # log "Downloading eza completions..."
    # sudo mkdir -p /usr/local/share/zsh/site-functions
    # sudo wget -O /usr/local/share/zsh/site-functions/_eza https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza
}

install_lazygit() {
    local arch="arm64"
    if [ "$(uname -m)" = "armv7l" ]; then
        arch="arm"
    fi

    log "Downloading and installing Lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${arch}.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin

    # Clean up downloaded files
    rm lazygit.tar.gz lazygit

    # Verify installation
    if command -v lazygit &> /dev/null; then
        log "Lazygit has been successfully installed."
        lazygit --version
    else
        log "Installation failed. Please check for errors and try again."
    fi
}

install_gdu() {
    log "Installing gdu..."
    local latest_release=$(fetch_latest_release "dundee/gdu")
    local version=$(log "$latest_release" | jq -r .tag_name)

    log "Searching for asset matching: gdu_linux_arm64.tgz"
    local asset_url=$(log "$latest_release" | jq -r '.assets[] | select(.name == "gdu_linux_arm64.tgz") | .browser_download_url')

    if [ -z "$asset_url" ]; then
        log "Error: Could not find appropriate file for your architecture (aarch64)."
        log "Available assets:"
        log "$(log "$latest_release" | jq -r '.assets[].name')"
        log "You may need to build gdu from source for your architecture."
        exit 1
    fi

    log "Found asset URL: $asset_url"

    log "Downloading gdu $version for aarch64..."
    curl -L $asset_url -o gdu.tgz

    log "Installing gdu..."
    tar -xzf gdu.tgz
    sudo mv gdu_linux_arm64 /usr/local/bin/gdu
    sudo chmod +x /usr/local/bin/gdu
    rm gdu.tgz

    log "gdu $version has been installed to /usr/local/bin/gdu"
}

install_fzf() {
    log "Installing fzf..."
    local version="0.54.0"
    local filename="fzf-${version}-linux_arm64.tar.gz"
    local download_url="https://github.com/junegunn/fzf/releases/download/v${version}/${filename}"

    wget "$download_url"
    tar -xzf "$filename"
    sudo mv fzf /usr/local/bin/
    sudo chmod +x /usr/local/bin/fzf

    # Clean up
    rm "$filename"

    # Verify installation
    if command -v fzf &> /dev/null; then
        log "fzf $version has been successfully installed."
        fzf --version
    else
        log "fzf installation failed. Please check for errors."
    fi
}

setup_ssh_clipboard_forwarding() {
    local SSHD_CONFIG="/etc/ssh/sshd_config"

    # Enable X11 forwarding in sshd_config
    sudo sed -i.bak -e 's/^#X11Forwarding no/X11Forwarding yes/' \
                    -e 's/^X11Forwarding no/X11Forwarding yes/' \
                    -e 's/^#X11Forwarding yes/X11Forwarding yes/' \
                    -e 's/^#X11DisplayOffset 10/X11DisplayOffset 10/' \
                    -e 's/^#X11UseLocalhost yes/X11UseLocalhost yes/' \
                    -e '/^#X11Forwarding no/a X11Forwarding yes' \
                    -e '/^#X11Forwarding yes/a X11Forwarding yes' \
                    -e '/^#X11DisplayOffset 10/a X11DisplayOffset 10' \
                    -e '/^#X11UseLocalhost yes/a X11UseLocalhost yes' \
                    "$SSHD_CONFIG"

    # Restart SSH service
    sudo systemctl restart sshd || sudo service ssh restart

    log "Clipboard forwarding set up and SSH service restarted."
}

install_git_delta() {
    log "Installing git-delta..."

    # Fetch the latest release information
    local latest_release=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest)
    
    # Check if the response is valid JSON
    if ! echo "$latest_release" | jq -e . >/dev/null 2>&1; then
        log "Failed to fetch the latest release for git-delta. Response was:"
        log "$latest_release"
        return 1
    fi

    # Extract the version tag
    local version=$(log "$latest_release" | jq -r .tag_name)
    log "Latest git-delta version: $version"

    # Search for the asset matching the architecture
    local asset_url=$(log "$latest_release" | jq -r ".assets[] | select(.name | test(\"delta-${version}-aarch64-unknown-linux-gnu.tar.gz$\")) | .browser_download_url")

    if [ -z "$asset_url" ]; then
        log "Error: Could not find appropriate file for your architecture (aarch64)."
        log "Available assets:"
        log "$(log "$latest_release" | jq -r '.assets[].name')"
        return 1
    fi

    log "Found asset URL: $asset_url"

    # Download the asset
    log "Downloading git-delta $version for aarch64..."
    wget "$asset_url" -O delta.tar.gz

    # Install git-delta
    log "Installing git-delta..."
    tar -xzf delta.tar.gz
    sudo mv delta*/delta /usr/local/bin/
    sudo chmod +x /usr/local/bin/delta
    rm -rf delta.tar.gz delta*

    # Verify installation
    if command -v delta &> /dev/null; then
        log "git-delta $version has been successfully installed."
        delta --version
    else
        log "Installation failed. Please check for errors and try again."
        return 1
    fi
}

install_vale() {
    log "Installing Vale..."

    # Fetch the latest release information for Vale
    local vale_latest_release=$(fetch_latest_release "errata-ai/vale")
    local vale_version=$(echo "$vale_latest_release" | jq -r .tag_name)
    vale_version="${vale_version#v}"  # Remove the 'v' from the version string if present

    log "Searching for asset matching: vale_${vale_version}_Linux_arm64.tar.gz"
    local vale_asset_url=$(echo "$vale_latest_release" | jq -r ".assets[] | select(.name == \"vale_${vale_version}_Linux_arm64.tar.gz\") | .browser_download_url")

    if [ -z "$vale_asset_url" ]; then
        log "Error: Could not find appropriate file for your architecture (arm64) for Vale."
        log "Available assets:"
        echo "$vale_latest_release" | jq -r '.assets[].name'
        log "You may need to build Vale from source for your architecture."
        exit 1
    fi

    log "Found Vale asset URL: $vale_asset_url"

    log "Downloading Vale $vale_version for arm64 Linux..."
    curl -L $vale_asset_url -o vale.tar.gz

    log "Installing Vale..."
    tar -xzf vale.tar.gz
    sudo mv vale /usr/local/bin/vale
    sudo chmod +x /usr/local/bin/vale
    rm vale.tar.gz

    # Verify Vale installation
    if command -v vale &> /dev/null; then
        log "Vale $vale_version has been successfully installed."
        vale --version
        mkdir -p ~/.config/vale/styles # this is needed so it can save styles for whatever reason
        vale sync # this is needed so it generates the corresponding styles from the vale.ini
    else
        log "Installation failed for Vale. Please check for errors and try again."
        exit 1
    fi

    log "Vale installation complete."

    log "Installing Vale Language Server..."

    # Fetch the latest release information for Vale Language Server
    local vale_ls_latest_release=$(fetch_latest_release "errata-ai/vale-ls")
    local vale_ls_version=$(echo "$vale_ls_latest_release" | jq -r .tag_name)
    vale_ls_version="${vale_ls_version#v}"  # Remove the 'v' from the version string if present

    log "Searching for asset matching: vale-ls-${vale_ls_version}-aarch64-unknown-linux-gnu.zip"
    local vale_ls_asset_url=$(echo "$vale_ls_latest_release" | jq -r ".assets[] | select(.name == \"vale-ls-aarch64-unknown-linux-gnu.zip\") | .browser_download_url")

    if [ -z "$vale_ls_asset_url" ]; then
        log "Error: Could not find appropriate file for your architecture (arm64) for Vale Language Server."
        log "Available assets:"
        echo "$vale_ls_latest_release" | jq -r '.assets[].name'
        log "You may need to build Vale Language Server from source for your architecture."
        exit 1
    fi

    log "Found Vale Language Server asset URL: $vale_ls_asset_url"

    log "Downloading Vale Language Server $vale_ls_version for arm64 Linux..."
    curl -L $vale_ls_asset_url -o vale-ls.zip

    log "Installing Vale Language Server..."
    unzip vale-ls.zip
    sudo mv vale-ls /usr/local/bin/vale-ls
    sudo chmod +x /usr/local/bin/vale-ls
    rm vale-ls.zip

    # Verify Vale Language Server installation
    if command -v vale-ls &> /dev/null; then
        log "Vale Language Server $vale_ls_version has been successfully installed."
        vale-ls --version
    else
        log "Installation failed for Vale Language Server. Please check for errors and try again."
        exit 1
    fi

    log "Vale Language Server installation complete."
}


install_charmbracelet {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install glow mods
}


main() {
    # rpi_setup
    # setup_ssh_clipboard_forwarding
            
    # determine_architecture
    
    # install_helix
    ## install_eza # this is removed because the compiled bineries currently come without --git
    # setup_local_eza
    # install_lazygit
    # install_gdu

    ## install zoxide
    # curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    ## install gls
    # go install go.sazak.io/gls/cmd/gls@latest

    # install_gdu

    # install_fzf
    # install_git_delta

    ## install bun
    # curl -fsSL https://bun.sh/install | bash # it adds completion to .zshrc regardless of what I try

    # install bash-language-server
    # bun add -g bash-language-server

    install_vale
    install_charmbracelet

    ## setup_zsh # should be removed as this is in git dir

    log "Setup complete! Please reboot to apply all changes."
    log "Setup finished at $(date)"
}

main
