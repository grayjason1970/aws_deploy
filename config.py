import os

class Config:
    # Database configuration
    MYSQL_HOST = os.getenv('DATABASE_HOST', '10.10.14.182')
    MYSQL_USER = os.getenv('DATABASE_USER', 'root')
    MYSQL_PASSWORD = os.getenv('DATABASE_PASSWORD', '8+RyYJJedYbdj4WQ!')
    MYSQL_DB = os.getenv('DATABASE_NAME', 'project1')

    # AWS configuration
    AWS_REGION = os.getenv('AWS_REGION', 'us-west-2')
