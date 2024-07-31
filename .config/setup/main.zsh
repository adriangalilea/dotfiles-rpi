#!/bin/zsh

source "${0:A:h}/installers/requirements.zsh"
source "${0:A:h}/lib/ui.zsh"

run_system_setup() {
    local install_config="$1"
    if [ -f "./setup.zsh" ]; then
        ./setup.zsh "$install_config"
    else
        log "setup.zsh not found in the current directory." error
        exit 1
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    log "Error: No configuration file specified." error
    log "Usage: $0 <config_file.cue>" error
    exit 1
fi

install_config="$1"

if [ ! -f "$install_config" ]; then
    log "Error: Configuration file '$install_config' not found." error
    exit 1
fi

echo "Installing requirements..."
install_requirements

if check_requirements_installed; then
    log "😎 Requirements are installed. Running system setup..." info
    echo
    run_system_setup "$install_config"
else
    echo "Failed to install requirements. Please check your internet connection and try again."
    exit 1
fi

