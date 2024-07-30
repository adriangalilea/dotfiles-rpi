#!/bin/zsh

echo

# Go to setup.zsh if you want to edit anything.
# This file just serves as an entry point to install gum if it's not installed since it's used throughout the program

install_gum() {
    echo "Installing gum..."
    echo "Adding Charm repository..."
    if [ ! -f /etc/apt/keyrings/charm.gpg ]; then
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg; then
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ *"* | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
            echo "Charm GPG key added."
            sudo apt update
        else
            echo "Failed to add Charm GPG key. Skipping Charm repository addition."
            return 1
        fi
    else
        echo "Charm GPG key already exists. Skipping addition."
    fi
    echo "Charm repository process completed."

    sudo apt update && sudo apt install gum -y
}

run_system_setup() {
    local install_config="$1"
    if [ -f "./setup.zsh" ]; then
        ./setup.zsh "$install_config"
    else
        gum log --structured --level error "setup.zsh not found in the current directory."
        exit 1
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Error: No configuration file specified."
    echo "Usage: $0 <config_file.cue>"
    exit 1
fi

install_config="$1"

if [ ! -f "$install_config" ]; then
    echo "Error: Configuration file '$install_config' not found."
    exit 1
fi

if command -v gum &> /dev/null; then
    echo "😎 gum was already installed. Running system setup..."
    echo
    run_system_setup "$install_config"
else
    install_gum
    if command -v gum &> /dev/null; then
        echo "😎 gum installed successfully. Running system setup..."
        echo
        run_system_setup "$install_config"
    else
        echo "Failed to install gum. Please check your internet connection and try again."
        exit 1
    fi
fi

