#!/bin/zsh

install_pipx_packages() {
    local pipx_packages=("$@")
    gum log --structured --level info "Installing pipx packages..."
    local pipx_output=""
    
    # Ensure pipx is installed
    if ! command -v pipx &> /dev/null; then
        gum log --structured --level info "pipx not found, installing pipx..."
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
    fi
    
    # Install packages with pipx
    for package in "${pipx_packages[@]}"; do
        pipx_output+=$(pipx install "$package" 2>&1)
        pipx_output+=$'\n'
    done

    if [ $? -eq 0 ]; then
        gum log --structured --level info "pipx packages installed successfully."
    else
        gum log --structured --level error "Error installing pipx packages. Details:"
        echo "$pipx_output"
        gum log --structured --level warn "pipx package installation failed. Continuing with setup..."
    fi
}

