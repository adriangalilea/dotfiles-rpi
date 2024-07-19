#!/bin/zsh

source ./utils.sh
source ./github.sh
source ./apt.sh

main() {
    gum log --structured --level info "Starting setup..."
    increase_swap_size 1024
    add_charm_repository

    # APT packages
    local apt_packages=(
        zsh git wget curl jq tar xz-utils htop neofetch bat
        build-essential dh-make devscripts golang python3-pip fd-find tree tmux shellcheck
        gum glow
    )
    install_apt_packages "${apt_packages[@]}"
    install_pip_packages
    
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
    )
    install_from_github "${github_packages[@]}"
    
    setup_ssh_clipboard_forwarding
    gum log --structured --level info "Setup complete! Please reboot to apply all changes."
    gum log --structured --level info --time rfc822 "Setup finished at $(date)"
}

main
