provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "flask_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # key_name      = var.key_name
  key_name      = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Add keys to gain access to github
               echo "${ssh_key}" > /home/ec2-user/.ssh/id_rsa
               chmod 600 /home/ec2-user/.ssh/id_rsa
               chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
               echo "Host github.com" >> /home/ec2-user/.ssh/config
               echo "  StrictHostKeyChecking no" >> /home/ec2-user/.ssh/config
               echo "  IdentityFile /home/ec2-user/.ssh/id_rsa" >> /home/ec2-user/.ssh/config
               chown ec2-user:ec2-user /home/ec2-user/.ssh/config
               chmod 600 /home/ec2-user/.ssh/config

              # Continue with the rest of installation
                sudo yum update -y
                sudo yum install -y gcc
                sudo yum install -y python3
                sudo yum install -y python3-devel
                sudo yum install -y mariadb
                sudo yum install -y mariadb-devel
                sudo yum install -y pip3
                sudo pip3 install flask sqlalchemy flask_sqlalchemy boto3 pymysql mysqlclient
                sudo yum install -y git docker
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                sudo systemctl enable docker
                # Install Docker Compose
                sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose
                # Clone the GitHub repo and run the Flask app
                ssh-keyscan github.com >> /home/ec2-user/.ssh/known_hosts
                git clone git@github.com:grayjason1970/aws_deploy.git /home/ec2-user/app
                cd /home/ec2-user/app
                docker-compose up -d  
              EOF

  tags = {
    Name = "FlaskApp"
  }
  network_interface {
    network_interface_id = aws_network_interface.flask_app.id
    device_index         = 0
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  private_key = var.private_key
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