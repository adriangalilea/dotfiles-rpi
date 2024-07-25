#!/bin/zsh

install_pipx_packages() {
    local pipx_packages=("$@")
    log "Installing pipx packages..." debug 
    local pipx_output=""
    
    # Ensure pipx is installed
    if ! command -v pipx &> /dev/null; then
        log "pipx not found, installing pipx..." debug 
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
        log "pipx installed. ✅" info
    fi
    
    # Install packages with pipx
    for package in "${pipx_packages[@]}"; do
        pipx_output+=$(pipx install "$package" 2>&1)
        pipx_output+=$'\n'
    done

    if [ $? -eq 0 ]; then
        log "pipx packages installed successfully. ✅" info 
    else
        log "Error installing pipx packages. Details:" error 
        echo "$pipx_output"
        log "pipx package installation failed. Continuing with setup..." warn 
    fi
    echo
}

