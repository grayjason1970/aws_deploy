provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "flask_sg" {
  name_prefix = "flask_sg_"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask_sg"
  }
}

resource "aws_instance" "flask_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  security_group_id      = var.security_group_id
  user_data              = file("setup.sh")

  tags = {
    Name = "FlaskAppInstance"
  }
}

output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}
