provider "aws" {
  region = "us-west-2"
}

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

output "ec2_instance_public_ip" {
  value = aws_instance.flask_app.public_ip
}
