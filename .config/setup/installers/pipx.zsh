#!/bin/zsh

install_pipx_packages() {
    local pipx_packages=("$@")
    log "Installing pipx packages: ${pipx_packages[*]}" debug
    local pipx_output=""
    local install_failed=false
    
    # Ensure pipx is installed
    if ! command -v pipx &> /dev/null; then
        log "pipx not found, installing pipx..." debug
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
        log "pipx installed. ✅" info
        # Refresh the shell's environment
        export PATH="$PATH:~/.local/bin"
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

