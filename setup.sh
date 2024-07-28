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
git clone git@github.com:grayjason1970/aws_deploy.git /home/ec2-user/app
cd /home/ec2-user/app
docker-compose up -d