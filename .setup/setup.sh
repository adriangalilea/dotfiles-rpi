#!/bin/zsh

source ./utils.sh
source ./github.sh
source ./apt.sh
source ./pipx.sh

main() {
    gum log --structured --level info "Starting setup..."
    increase_swap_size 1024

    # APT packages
    local apt_packages=(
        zsh git wget curl jq tar xz-utils htop neofetch bat
        build-essential dh-make devscripts golang python3-pip fd-find tree tmux shellcheck
        glow
    )
    install_apt_packages "${apt_packages[@]}" || {
        gum log --structured --level error "Failed to install APT packages. Exiting."
        exit 1
    }

    install_pipx_packages dtj tldr yt-dlp periodic-table-cli || {
        gum log --structured --level error "Failed to install pipx packages. Exiting."
        exit 1
    }

    # GitHub packages
    local github_packages=(
        "helix-editor/helix:helix"
        "eza-community/eza:eza"
        "jesseduffield/lazygit:lazygit"
        "dundee/gdu:gdu"
        "junegunn/fzf:fzf"
        "dandavison/delta:delta"
        "errata-ai/vale:vale"
        "errata-ai/vale-ls:vale-ls"
        # "devmatteini/dra:dra"
        "sxyazi/yazi:yazi"
        "achannarasappa/ticker:ticker"
        "humanlogio/humanlog:humanlog"
        "zaghaghi/openapi-tui:openapi-tui"
        "tbillington/kondo:kondo"
        "ynqa/jnv:jnv"
        "jwt-rs/jwt-ui:jwtui"
    )
    install_from_github "${github_packages[@]}" || {
        gum log --structured --level error "Failed to install GitHub packages. Exiting."
        exit 1
    }

    # install clipboard `cb`
    curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh

    # install direnv
    curl -sfL https://direnv.net/install.sh | bash

    setup_ssh_clipboard_forwarding || {
        gum log --structured --level error "Failed to set up SSH clipboard forwarding. Exiting."
        exit 1
    }

    gum log --structured --level info "Setup complete! Please reboot to apply all changes."
    gum log --structured --level info --time rfc822 "Setup finished at $(date)"
}

main
