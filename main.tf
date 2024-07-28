provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "flask_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install SSM Agent if not already installed
              if ! rpm -q amazon-ssm-agent; then
                yum install -y amazon-ssm-agent
              fi
              systemctl start amazon-ssm-agent
              systemctl enable amazon-ssm-agent

              # Wait for SSM Agent to be ready
              sleep 30

               # Execute setup.sh last
               ${file("$setup.sh")} 
              EOF

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