#!/bin/bash

# Script to install Docker (root or rootless mode)
# Usage: ./install_docker.sh [--rootless]

# Check if running as root (except for rootless mode)
if [[ $EUID -eq 0 && "$1" != "--rootless" ]]; then
    echo "⚠️  Do not run this script as root unless using --rootless mode."
    exit 1
fi

# Default: Install Docker in root mode
ROOTLESS_MODE=false

# Parse arguments
if [[ "$1" == "--rootless" ]]; then
    ROOTLESS_MODE=true
    echo "🔧 Installing Docker in ROOTLESS mode..."
else
    echo "🔧 Installing Docker in ROOT mode..."
fi

# Install Docker
echo "📦 Installing Docker..."
sudo apt-get update
sudo apt-get install -y curl

# --- ROOT MODE ---
if [[ "$ROOTLESS_MODE" == false ]]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm -f get-docker.sh

    # Add user to docker group to avoid sudo
    echo "👤 Adding $USER to the docker group to avoid sudo..."
    sudo usermod -aG docker "$USER"

    # Check if the user is already in the docker group
    if id -nG "$USER" | grep -qw "docker"; then
        echo "✅ User $USER is now in the docker group."
        echo "🔄 Please log out and log back in for the changes to take effect."
        echo "   Or run: newgrp docker"
    else
        echo "❌ Failed to add $USER to the docker group."
        exit 1
    fi

    exit 0
fi

# --- ROOTLESS MODE ---
echo "🛡️  Installing dependencies for rootless mode..."
sudo apt-get install -y uidmap dbus-user-session

echo "📥 Downloading and running Docker rootless install script..."
curl -fsSL https://get.docker.com/rootless | sh

# Configure environment
echo "🔧 Configuring environment for rootless Docker..."
export PATH="/home/$USER/bin:$PATH"
export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"

# Add to shell config files (check if they exist)
SHELL_CONFIGS=("$HOME/.zshrc" "$HOME/.bashrc")
for config in "${SHELL_CONFIGS[@]}"; do
    if [[ -f "$config" ]]; then
        echo "📝 Adding Docker environment variables to $config"
        if ! grep -q "export PATH=/home/$USER/bin:\$PATH" "$config"; then
            echo "export PATH=/home/$USER/bin:$PATH" >> "$config"
        fi
        if ! grep -q "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" "$config"; then
            echo "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" >> "$config"
        fi
    fi
done

# Start Docker in rootless mode
echo "🚀 Starting Docker in rootless mode..."
systemctl --user start docker
systemctl --user enable docker

# Verify installation
echo "✅ Verifying Docker installation..."
if docker run hello-world; then
    echo "🎉 Docker installation successful!"
else
    echo "❌ Docker installation failed. Check logs with: journalctl --user -u docker"
    exit 1
fi

# Cleanup
rm -f get-docker.sh