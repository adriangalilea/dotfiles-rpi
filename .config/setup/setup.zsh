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
    
    local cue_file="${1:-rpi_aarch64.cue}"
    if [[ -z "$cue_file" ]]; then
        log "Error: No CUE file specified." error
        log "Usage: $0 <cue_file>" error
        return 1
    fi

    if ! generate_json_from_cue "$cue_file"; then
        log "Failed to generate JSON from CUE file" error
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        log "Error: 'jq' command not found. Please install jq." error
        return 1
    fi

    # Execute each step
    parse_config "$JSON_CONFIG_PATH" | while read -r step; do
        if ! validate_step "$step"; then
            log "Step validation failed, skipping execution" error
            continue
        fi
        if ! execute_step "$step"; then
            log "Step execution failed" error
        fi
    done

    log "Setup complete! Please reboot to apply all changes." info
}

main "$@"
