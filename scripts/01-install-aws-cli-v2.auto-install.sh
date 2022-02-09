#!/bin/sh

echo "Installing AWS CLI v2..." && \
cd /tmp && \
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip -q awscliv2.zip && \
sudo ./aws/install
