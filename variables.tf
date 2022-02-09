
variable "dev_machine_region" {
  type = string
  default = "ap-southeast-1"
}

variable "dev_efs_az" {
  type = string
  default = "ap-southeast-1a"
}

variable "dev_spot_price" {
  type = string
  default = "0.004"
}

variable "dev_instance_type" {
  type = string
  default = "t3.micro"
}

variable "dev_bucket_name" {
  type = string
  default = "rioastamal-dev-bucket"
}

variable "dev_user_data_url" {
  type = string
  default = "https://raw.githubusercontent.com/rioastamal/spot-dev-machine/master/scripts/user-data.sh"
}

# Used in Security Group for accessing EC2
# You can set define it as environment variable `export TF_VAR_dev_my_ip=YOUR_IP/32`
variable "dev_my_ip" {
  type = string
  default = "127.0.0.1/32"
}

# This ips should be list of AWS Cloud9 IPs according to your selected region
# See https://docs.aws.amazon.com/cloud9/latest/user-guide/ip-ranges.html
# This default uses ap-southeast-1 Cloud9 IP address range
variable "dev_cloud9_ips" {
  type = list
  default = ["13.250.186.128/27", "13.250.186.160/27"]
}