#!/bin/sh

echo "Installing Go..."
GO_VERSION="1.18"
GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
[ ! -f /tmp/go-${GO_VERSION}.tar.gz ] && {
    curl -L -s -o /tmp/go-${GO_VERSION}.tar.gz "$GO_URL"
}
sudo tar xf /tmp/go-${GO_VERSION}.tar.gz -C /opt/
sudo ln -fs /opt/go/bin/go /usr/local/bin/go
sudo ln -fs /opt/go/bin/gofmt /usr/local/bin/gofmt