#!/bin/bash

# Install Docker Community edition for the latest functions.
echo "Installing Docker Community Edition."

sudo apt -yqq install curl
cd || exit
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

sudo usermod -aG docker "$USER" || true
