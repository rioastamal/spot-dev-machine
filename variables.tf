# Region where you want to run the dev machine
variable "dev_machine_region" {
  type = string
  default = null
}

# We choose EFS One Zone Storage for cheaper option
variable "dev_efs_az" {
  type = string
  default = null
}

# Max EC2 spot price
variable "dev_spot_price" {
  type = string
  default = "0.004"
}

# Type of the EC2 instance you want to launch
variable "dev_instance_type" {
  type = string
  default = "t3.micro"
}

# You can use this S3 bucket to store your development files
variable "dev_bucket_name" {
  type = string
  default = ""
}

# EC2 will fetch and run script on this url after boot
variable "dev_user_data_url" {
  type = string
  default = "https://raw.githubusercontent.com/rioastamal/spot-dev-machine/master/scripts/user-data.sh"
}

# Used in Security Group for accessing EC2
# You can set the value as environment variable `export TF_VAR_dev_my_ip=YOUR_IP/32`
variable "dev_my_ip" {
  type = string
  default = null
}

# This ips should be list of AWS Cloud9 IPs according to your selected region
# See https://docs.aws.amazon.com/cloud9/latest/user-guide/ip-ranges.html
# This default uses ap-southeast-1 Cloud9 IP address range
variable "dev_cloud9_ips" {
  type = list
  default = ["13.250.186.128/27", "13.250.186.160/27"]
}

# Your SSH public key
variable "dev_ssh_public_key" {
  type = string
  default = null
}