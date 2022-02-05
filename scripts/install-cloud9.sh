#!/bin/sh
node --version | grep ^v12 || {
  echo "Please install Node.js v12.x first. You can use scripts/install-nvm.sh to install Node.js." >&2
  exit 1
}

command -v python3 || {
  echo "Please install Python 3 first." >&2
  exit 1
}

echo "Installing development tools..."
sudo yum -q groupinstall -y 'Development Tools'

echo "Installing AWS Cloud9 installer..." 
curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash

echo ""
echo "------------------------------------------------------------------"
echo "Installation is done, you may remove development tools by running:"
echo "-> yum groupremove -y 'Development Tools'"
