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
        local step_type=$(get_step_details "$step" "type")
        local step_name=$(get_step_details "$step" "name")
        log "Executing step: $step_name" info
        
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
                local repo binaries
                while IFS= read -r package; do
                    repo=$(echo "$package" | yq e '.repo' -)
                    binaries=($(echo "$package" | yq e '.binaries[]' -))
                    install_from_github "$repo" "${binaries[@]}"
                done <<< "$packages"
                ;;
            command)
                local command=$(get_step_details "$step" "command")
                log "Executing command: $command" debug
                if ! eval "$command"; then
                    log "Command execution failed: $command" error
                fi
                ;;
            function)
                local function=$(get_step_details "$step" "function")
                local args=$(get_step_details "$step" "args")
                log "Calling function: $function" debug
                if ! $function $args; then
                    log "Function call failed: $function" error
                fi
                ;;
            *)
                log "Unknown step type: $step_type" error
                ;;
        esac
        
        log "Step completed: $step_name" info
        echo
    done <<< "$steps"

    log "Setup complete! Please reboot to apply all changes." info
}

main "$@"
