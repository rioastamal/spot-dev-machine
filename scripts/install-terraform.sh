#!/bin/sh

echo "Installing Terraform..."
TERRAFORM_VERSION="1.1.5"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
curl -L -s -o /tmp/terraform-${TERRAFORM_VERSION}.zip "$TERRAFORM_URL"
sudo unzip /tmp/terraform-${TERRAFORM_VERSION}.zip -d /usr/local/bin/