provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "flask_app" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "your-key-pair-name"

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y git docker
                service docker start
                usermod -a -G docker ec2-user
                chkconfig docker on
                # Install Docker Compose
                curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
                # Clone the GitHub repo and run the Flask app
                git clone https://github.com/your-username/your-repo.git /home/ec2-user/app
                cd /home/ec2-user/app
                docker-compose up -d
              EOF

  tags = {
    Name = "FlaskApp"
  }
}

resource "aws_security_group" "flask_sg" {
  name_prefix = "flask_sg_"

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
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  key_name               = "your-key-pair"
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  user_data              = file("setup.sh")

  tags = {
    Name = "FlaskAppInstance"
  }
}

output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}
