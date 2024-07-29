#!/bin/bash
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
echo "Cloning App"
git clone git@github.com:grayjason1970/aws_deploy.git /home/ec2-user/app
echo "Finished cloning App"
cd /home/ec2-user/app
docker-compose up -d