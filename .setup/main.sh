#!/bin/zsh

# Go to setup.sh if you want to edit anything.
# This file just serves as an entry point to install gum if it's not installed since it's used throughout the program


install_gum() {
    echo "Installing gum..."
    if ! command -v gum &> /dev/null; then
        echo "Adding Charm repository..."
        if [ ! -f /etc/apt/keyrings/charm.gpg ]; then
            sudo mkdir -p /etc/apt/keyrings
            if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg; then
                echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ *"* | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
                gum log --structured --level info "Charm GPG key added."
                update_package_lists
            else
                echo "Failed to add Charm GPG key. Skipping Charm repository addition."
                return 1
            fi
        else
            echo "Charm GPG key already exists. Skipping addition."
        fi
        echo "Charm repository process completed."
        
        sudo apt update && sudo apt install gum -y
    fi
}

run_system_setup() {
    if [ -f "./setup.sh" ]; then
        ./setup.sh
    else
        gum log --structured --level error "setup.sh not found in the current directory."
        exit 1
    fi
}

# Main execution
install_gum
if command -v gum &> /dev/null; then
    gum log --structured --level info "😎 gum installed successfully. Running system setup..."
    run_system_setup
else
    echo "Failed to install gum. Please check your internet connection and try again."
    exit 1
fi
