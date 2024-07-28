variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the EC2 Key Pair"
  type        = string
  default     = "projectone"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0648742c7600c103f"
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
  default     = "data.aws_vpc.project1.id"
}
