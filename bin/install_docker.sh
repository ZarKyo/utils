#!/bin/bash

# Script to install Docker (root or rootless mode)
# Usage: ./install_docker.sh            # classic install (needs sudo internally)
#        ./install_docker.sh --rootless # rootless install (run as regular user)

set -euo pipefail
IFS=$'\n\t'

sudo -v

ROOTLESS_MODE=false
if [[ "${1:-}" == "--rootless" ]]; then
    ROOTLESS_MODE=true
fi

# --- ROOT MODE ---
if [[ "$ROOTLESS_MODE" == false ]]; then
    echo "Installing Docker (root mode)..."
    sudo apt-get update -q
    sudo apt-get install -y curl
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm -f get-docker.sh

    echo "Adding $USER to the docker group..."
    sudo usermod -aG docker "$USER"

    if id -nG "$USER" | grep -qw "docker"; then
        echo "Done. Log out and back in (or run: newgrp docker) to apply group membership."
    else
        echo "Failed to add $USER to the docker group."
        exit 1
    fi
    exit 0
fi

# --- ROOTLESS MODE ---
echo "Installing Docker (rootless mode)..."
sudo apt-get update -q
sudo apt-get install -y curl uidmap dbus-user-session

curl -fsSL https://get.docker.com/rootless | sh

# Configure environment in shell rc files
SHELL_CONFIGS=("$HOME/.zshrc" "$HOME/.bashrc")
for config in "${SHELL_CONFIGS[@]}"; do
    if [[ -f "$config" ]]; then
        if ! grep -q "export PATH=/home/$USER/bin:\$PATH" "$config"; then
            echo "export PATH=/home/$USER/bin:\$PATH" >> "$config"
        fi
        if ! grep -q "DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" "$config"; then
            echo "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" >> "$config"
        fi
    fi
done

systemctl --user start docker
systemctl --user enable docker

docker run hello-world
echo "Docker rootless installation complete."
