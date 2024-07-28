variable "vpc_id" {
  description = "The VPC ID"
  default     = "vpc-056766a49ea873983"
}

variable "subnet_id" {
  description = "The Subnet ID"
  default     = "subnet-03d934629af7d951e"
}

variable "security_group_id" {
  description = "The Security Group ID"
  default     = "sg-025f828e00022b542"
}

variable "key_name" {
  description = "The key pair name"
  default     = "projectone"
}

variable "instance_type" {
  description = "The instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID"
  default     = "ami-0648742c7600c103f"
}
