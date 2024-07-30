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
    
    local cue_file="install_config_rpi.cue"
    local steps

    # Parse and validate the configuration
    steps=$(parse_config "$cue_file") || {
        log "Failed to parse configuration." error
        exit 1
    }

    validate_config || {
        log "Configuration validation failed." error
        exit 1
    }

    # Execute each step
    while IFS= read -r step; do
        local step_type=$(get_step_details "$step" "type")
        case "$step_type" in
            apt)
                local packages=$(get_step_details "$step" "packages")
                install_apt_packages $packages
                ;;
            pipx)
                local packages=$(get_step_details "$step" "packages")
                install_pipx_packages $packages
                ;;
            github)
                local packages=$(get_step_details "$step" "packages")
                install_from_github $packages
                ;;
            command)
                local command=$(get_step_details "$step" "command")
                eval "$command"
                ;;
            function)
                local function=$(get_step_details "$step" "function")
                local args=$(get_step_details "$step" "args")
                $function $args
                ;;
            *)
                log "Unknown step type: $step_type" error
                ;;
        esac
    done <<< "$steps"

    log "Setup complete! Please reboot to apply all changes." info
    log --time rfc822 "Setup finished at $(date)" info
}

main
