terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.73.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.dev_machine_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  availability_zone = var.dev_machine_az
}

resource "aws_security_group" "dev_machine_firewall" {
  name = "dev_machine_sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ var.dev_my_ip ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "dev_efs_firewall" {
  name = "dev_efs_sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description      = "NFSv4"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    security_groups = [ aws_security_group.dev_machine_firewall.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
}

resource "aws_efs_file_system" "dev_efs" {
  availability_zone_name = var.dev_machine_az
  creation_token = "dev_machine_files"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
  
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_access_point" "dev_efs_main_ap" {
  file_system_id = aws_efs_file_system.dev_efs.id
  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    creation_info {
      owner_uid = 1000
      owner_gid = 1000
      permissions = 0755
    }
    path = "/data"
  }
}

resource "aws_efs_access_point" "dev_efs_docker_ap" {
  file_system_id = aws_efs_file_system.dev_efs.id
  posix_user {
    uid = 0
    gid = 0
  }

  root_directory {
    creation_info {
      owner_uid = 0
      owner_gid = 0
      permissions = 0755
    }
    path = "/docker"
  }
}

resource "aws_efs_mount_target" "dev_efs_mount" {
  file_system_id = aws_efs_file_system.dev_efs.id
  subnet_id = data.aws_subnet.default.id
  security_groups = [ aws_security_group.dev_efs_firewall.id ]
}

resource "aws_eip" "dev_machine_ip" {
  vpc = true
}

resource "aws_ssm_parameter" "dev_machine_ip" {
  name  = "dev_ip_allocation_id"
  type  = "String"
  value = aws_eip.dev_machine_ip.allocation_id
}

resource "aws_ssm_parameter" "dev_machine_az" {
  name  = "dev_machine_az"
  type  = "String"
  value = var.dev_machine_az
}

resource "aws_ssm_parameter" "dev_efs" {
  name  = "dev_efs_id"
  type  = "String"
  value = aws_efs_file_system.dev_efs.id
}

resource "aws_ssm_parameter" "dev_efs_main_ap" {
  name  = "dev_efs_data_ap"
  type  = "String"
  value = aws_efs_access_point.dev_efs_main_ap.id
}

resource "aws_ssm_parameter" "dev_efs_docker_ap" {
  name  = "dev_efs_docker_ap"
  type  = "String"
  value = aws_efs_access_point.dev_efs_docker_ap.id
}

data "aws_ami" "amzn_linux2" {
  owners = ["amazon"]
  most_recent = "true"

  filter {
    name = "name"
    values = [ "amzn2-ami-kernel-*" ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "dev_ec2_profile" {
  name = "dev_instance_profile"
  role = aws_iam_role.dev_machine_role.name
}
  
resource "aws_spot_instance_request" "dev_ec2_spot" {
  ami = data.aws_ami.amzn_linux2.id
  instance_type = var.dev_instance_type
  vpc_security_group_ids = [aws_security_group.dev_machine_firewall.id]
  spot_price = var.dev_spot_price
  wait_for_fulfillment = true
  spot_type = "persistent"
  instance_interruption_behavior = "terminate"
  iam_instance_profile = aws_iam_instance_profile.dev_ec2_profile.name
  
  credit_specification {
    cpu_credits = "standard" 
  }

  user_data = <<EOF
#!/bin/sh

curl -L -s ${var.dev_user_data_url} | bash
EOF
}

resource "aws_s3_bucket" "dev_main_bucket" {
  bucket = var.dev_bucket_name
  acl = "private"
}
