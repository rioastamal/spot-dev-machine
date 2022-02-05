#!/bin/sh

export AWS_DEFAULT_REGION=$( curl -s http://169.254.169.254/latest/meta-data/placement/region )
EFS_ID=$( aws ssm get-parameter --name dev_efs_id --output text --query 'Parameter.Value' )
ACCESS_POINT_DATA=$( aws ssm get-parameter --name dev_efs_data_ap --output text --query 'Parameter.Value' )
ACCESS_POINT_DOCKER=$( aws ssm get-parameter --name dev_efs_docker_ap --output text --query 'Parameter.Value' )
EFS_MOUNT_AZ=$( aws ssm get-parameter --name dev_machine_az --output text --query 'Parameter.Value' )
IP_ALLOC_ID=$( aws ssm get-parameter --name dev_ip_allocation_id --output text --query 'Parameter.Value' )
INSTANCE_ID=$( curl -s http://169.254.169.254/latest/meta-data/instance-id )
HOME_DIR=/home/ec2-user

echo "Associating Elastic IP..."
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $IP_ALLOC_ID

echo "Installing Amazon EFS file system utilities..."
yum install -y amazon-efs-utils
pip3 -q install botocore

echo "Mount EFS file system into home directory"
mkdir -p $HOME_DIR/dockerlib
mount -t efs -o az=$EFS_MOUNT_AZ,tls,accesspoint=$ACCESS_POINT_DATA $EFS_ID:/ $HOME_DIR
mount -t efs -o az=$EFS_MOUNT_AZ,tls,accesspoint=$ACCESS_POINT_DOCKER $EFS_ID:/ $HOME_DIR/dockerlib

GIT_REPO=rioastamal/rioastamal/spot-dev-machine
RAW_GIT_URL=https://raw.githubusercontent.com/${GIT_REPO}/master/scripts
AUTO_INSTALL_SCRIPTS="01-install-aws-cli-v2.auto-install.sh 02-install-tmux.auto-install.sh 03-install-nvm.auto-install.sh 04-install-docker.auto-install.sh"

for script in $AUTO_INSTALL_SCRIPTS
do
  echo "Downloading ${RAW_GIT_URL}/$script..."
  curl -L -s ${RAW_GIT_URL}/$script | bash
  echo "$script done at $( date )" >> /tmp/dev-machine-installer.log
done
