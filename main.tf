provider "aws" {
  region = "us-west-2"
}

variable "vpc_id" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "instance_type" { default = "t2.micro" }
variable "ami_id" { default = "ami-0c55b159cbfafe1f0" }  # Amazon Linux 2 AMI

resource "aws_instance" "flask_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = file("setup.sh")

  tags = {
    Name = "FlaskApp"
  }
}

output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}
