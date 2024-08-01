#!/bin/zsh

install_pipx_packages() {
    local pipx_packages=("$@")
    log "Installing pipx packages: ${pipx_packages[*]}" debug
    local pipx_output=""
    local install_failed=false
    
    # Ensure pipx is installed
    if ! command -v pipx &> /dev/null; then
        log "pipx not found, attempting to install pipx..." debug
        
        # Attempt to install pipx
        if python3 -m pip install --user pipx &> /dev/null && python3 -m pipx ensurepath &> /dev/null; then
            log "pipx installed successfully. ✅" info
            # Refresh the shell's environment
            export PATH="$PATH:$HOME/.local/bin"
        else
            log "Failed to install pipx. ❌" error
            log "Please install pipx manually and ensure it's in your PATH." error
            return 1
        fi
    fi

    # Verify pipx is now available
    if ! command -v pipx &> /dev/null; then
        log "pipx installation failed or it's not in the PATH. ❌" error
        log "Please install pipx manually and ensure it's in your PATH." error
        return 1
    fi

    # Install packages with pipx
    for package in "${pipx_packages[@]}"; do
        pipx_output=$(pipx install "$package" 2>&1)
        if [ $? -eq 0 ]; then
            log "Successfully installed pipx package: $package" info
        else
            log "Error installing pipx package: $package" error
            log "Error details: $pipx_output" error
            install_failed=true
        fi
    done

    if [ "$install_failed" = false ]; then
        log "All pipx packages installed successfully. ✅" info
    else
        log "Some pipx packages failed to install. Continuing with setup..." warn
    fi
    echo
}
