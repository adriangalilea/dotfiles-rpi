install_pipx_packages() {
    local pipx_packages=("$@")
    log "Installing pipx packages: ${pipx_packages[*]}" debug
    local pipx_output=""
    local install_failed=false
    
    # Ensure pipx is installed
    if ! command -v pipx &> /dev/null; then
        log "pipx not found, attempting to install pipx..." debug
        
        # Determine the OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install pipx
            else
                log "Homebrew not found. Please install Homebrew first." error
                return 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux (assuming Debian-based)
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y pipx
            else
                log "apt not found. Please install pipx manually." error
                return 1
            fi
        else
            log "Unsupported operating system" error
            return 1
        fi
        
        # Ensure pipx is in PATH
        pipx ensurepath
        sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
        
        # Refresh the current shell's PATH
        export PATH="$PATH:$HOME/.local/bin"
        
        if command -v pipx &> /dev/null; then
            log "pipx installed successfully. ✅" info
        else
            log "Failed to install pipx. ❌" error
            log "Please install pipx manually and ensure it's in your PATH." error
            return 1
        fi
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
