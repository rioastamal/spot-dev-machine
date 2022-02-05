#!/bin/sh

echo "Installing Terraform..."
yum install -q -y yum-utils && \
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
yum install -q -y terraform
