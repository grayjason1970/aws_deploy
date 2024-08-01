import os

class Config:
    # Database configuration
    MYSQL_HOST = os.getenv('DATABASE_HOST', 'host')
    MYSQL_USER = os.getenv('DATABASE_USER', 'user')
    MYSQL_PASSWORD = os.getenv('DATABASE_PASSWORD', 'your-db-password')
    MYSQL_DB = os.getenv('DATABASE_NAME', 'your-project-name')

    # AWS configuration
    AWS_REGION = os.getenv('AWS_REGION', 'your-region')
