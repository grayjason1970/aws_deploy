provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "flask_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  user_data = file("setup.sh")

  tags = {
    Name = "FlaskApp"
  }
  network_interface {
    network_interface_id = aws_network_interface.flask_app.id
    device_index         = 0
  }
}

resource "aws_network_interface" "flask_app" {
  subnet_id       = var.subnet_id
  private_ips     = ["10.10.8.50"]

  security_groups = [
    var.security_group_id,
  ]
}

output "ec2_instance_public_ip" {
  value = aws_instance.flask_app.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.flask_app.id
}