
variable "dev_machine_az" {
  type = string
  default = "ap-southeast-1a"
}

variable "dev_machine_region" {
  type = string
  default = "ap-southeast-1"
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
