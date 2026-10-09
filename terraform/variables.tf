variable "aws_region" {
  type        = string
  description = "ap-south-1"
}

variable "ami_id" {
  type        = string
  description = "ami-08e3b3155fc937a94"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "devops_key"
}

variable "vpc_cidr" {
  description = "Private VPC CIDR"
  type        = string
  default     = "11.0.0.0/16"
}

variable "allowed_ssh_cidr" {
  description = "49.47.216.28"
  type        = string
}