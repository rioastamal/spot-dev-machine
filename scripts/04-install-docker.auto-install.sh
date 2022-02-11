#!/bin/sh

DOCKER_VAR_LIB=/dockerlib
mkdir -p $DOCKER_VAR_LIB

amazon-linux-extras install -q -y docker && \
usermod -a -G docker ec2-user

echo "Changing Docker data root location to ${DOCKER_VAR_LIB}..."
cp /etc/sysconfig/docker /etc/sysconfig/docker.$( date +%s ).backup
sed -i "s@OPTIONS=\"--default-ulimit@OPTIONS=\"--data-root $DOCKER_VAR_LIB --default-ulimit@g" /etc/sysconfig/docker

echo "Docker installed, but not started. To start docker use following command:
  -> sudo systemctl start docker"
