#!/bin/zsh

source ./lib/sys.zsh
source ./lib/ui.zsh
source ./lib/parsing.zsh
source ./installers/github/main.zsh
source ./installers/apt.zsh
source ./installers/pipx.zsh

main() {
    log "Starting setup..." debug
    echo
    
    local cue_file="${1:-install_config_rpi.cue}"
    local steps

    # Parse and validate the configuration
    steps=$(parse_config "$cue_file") || {
        log "Failed to parse or validate configuration." error
        exit 1
    }

    # Execute each step
    while IFS= read -r step; do
        execute_step "$step"
    done <<< "$steps"

    log "Setup complete! Please reboot to apply all changes." info
}

main "$@"
