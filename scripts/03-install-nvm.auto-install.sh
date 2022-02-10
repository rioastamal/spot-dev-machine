#!/bin/sh

NORMAL_USER=$USER
[ "$NORMAL_USER" != "ec2-user" ] && NORMAL_USER=ec2-user

sudo mkdir -p /opt/nvm && sudo chown $NORMAL_USER:$NORMAL_USER /opt/nvm

echo "Installing nvm..."
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | sudo -u $NORMAL_USER NVM_DIR=/opt/nvm bash