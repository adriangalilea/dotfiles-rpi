#!/bin/zsh

echo

# Go to setup.sh if you want to edit anything.
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
    if [ -f "./setup.sh" ]; then
        ./setup.sh
    else
        gum log --structured --level error "setup.sh not found in the current directory."
        exit 1
    fi
}

# Main execution
if command -v gum &> /dev/null; then
    echo "😎 gum was already installed. Running system setup..."
    echo
    run_system_setup
else
    install_gum
    if command -v gum &> /dev/null; then
        echo "😎 gum installed successfully. Running system setup..."
        echo
        run_system_setup
    else
        echo "Failed to install gum. Please check your internet connection and try again."
        exit 1
    fi
fi

