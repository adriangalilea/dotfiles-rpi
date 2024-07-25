#!/bin/zsh

source ./lib/sys.sh
source ./lib/ui.sh
source ./installers/github/main.zsh
source ./installers/apt.sh
source ./installers/pipx.sh

main() {
    log "Starting setup..." debug
    echo
    
    increase_swap_size 1024

    setup_custom_motd

    # APT packages
    local apt_packages=(
        zsh git wget curl jq tar xz-utils htop neofetch bat
        build-essential dh-make devscripts golang python3-pip fd-find tree tmux shellcheck
        glow freeze
    )
    install_apt_packages "${apt_packages[@]}" || {
        log "Failed to install APT packages. Exiting." error 
        exit 1
    }

    install_pipx_packages dtj tldr yt-dlp periodic-table-cli || {
        log "Failed to install pipx packages. Exiting." error 
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
        "csvlens/releases:csvlens"
        "yassinebridi/serpl:serpl"
        "zellij-org/zellij:zellij"
        "Feel-ix-343/markdown-oxide:markdown-oxide"
    )
    install_from_github "${github_packages[@]}" || {
        log "Failed to install GitHub packages. Exiting." error 
        exit 1
    }

    # install clipboard `cb`
    curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh
    echo

    # install direnv
    curl -sfL https://direnv.net/install.sh | bash > /dev/null
    echo

    setup_ssh_clipboard_forwarding || {
        log "Failed to set up SSH clipboard forwarding. Exiting." error 
        exit 1
    }

    log "Setup complete! Please reboot to apply all changes." info 
    log --time rfc822 "Setup finished at $(date)" info 
}

main
