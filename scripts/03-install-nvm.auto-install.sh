#!/bin/sh

sudo mkdir -p /opt/nvm && sudo chown $USER:$USER /opt/nvm
export NVM_DIR=/opt/nvm

echo "Installing nvm..."
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
