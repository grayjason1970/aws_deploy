# EC2 Deployment Management Flask App

This project is a Flask-based web application designed to manage and deploy EC2 instances on AWS. The application allows users to configure and deploy instances, manage key pairs, and terminate instances through a user-friendly web interface. The Flask app interacts with a MariaDB database to store configuration details and instance information.

## Features

- **Deploy EC2 Instances**: Configure and deploy EC2 instances with various settings.
- **Manage Key Pairs**: Add and manage AWS key pairs used for instance access.
- **Instance Management**: View and terminate running EC2 instances.
- **Styled UI**: The application includes a styled user interface for ease of use.
- **IAM Policy Setup**: Steps on how to create a policy to allow the application to securly launch EC2 instances 

## Directory Structure

```plaintext
my_flask_app/
├── app.py
├── config.py
├── requirements.txt
├── variables.tf
├── insert_key.py
├── main.tf
├── docker-compose.yml
├── README.md
├── setup.sh
├── static/
│       └── styles.css
├── templates/
│   ├── index.html
│   ├── add_key_pair.html
│   ├── manage_instances.html
│   ├── home.html
│   └── deploy.html
└── instance/
    └── config.py
```

## Prerequisites

1. **AWS Account**: You need an AWS account to deploy and manage EC2 instances.
2. **MariaDB Database**: Ensure you have a MariaDB database set up to store configuration and instance details.
3. **Python 3**: The application requires Python 3.8 or higher.

Note: This project makes use of Github workflows and is setup to deploy a free tier AWS micro instance via terraform and then
      checkout the code automatically whenever the master branch is updated.

https://github.com/grayjason1970/project1

## Installation

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/grayjason1970/aws_deploy
    cd aws-deploy
    ```

2. **Create a Virtual Environment**:

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

3. **Install Dependencies**:

    ```bash
    pip install -r requirements.txt
    ```

4. **Configure the Application**:

    - Edit `config.py` with your AWS and database configuration details:

        ```python
        class Config:
        # Database configuration
        MYSQL_HOST = os.getenv('DATABASE_HOST', 'host')
        MYSQL_USER = os.getenv('DATABASE_USER', 'user')
        MYSQL_PASSWORD = os.getenv('DATABASE_PASSWORD', 'your-db-password')
        MYSQL_DB = os.getenv('DATABASE_NAME', 'your-project-name')

        # AWS configuration
        AWS_REGION = os.getenv('AWS_REGION', 'your-region')
        ```

5. **Initialize the Database**:

    Ensure your MariaDB database has the necessary tables. Use the provided SQL script to create the schema:

    ```sql
    CREATE TABLE images (
        id INT AUTO_INCREMENT PRIMARY KEY,
        image_id VARCHAR(255) NOT NULL,
        description TEXT
    );

    CREATE TABLE instance_types (
        id INT AUTO_INCREMENT PRIMARY KEY,
        instance_types VARCHAR(255) NOT NULL
    );

    CREATE TABLE memory_sizes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        memory_size VARCHAR(255) NOT NULL
    );

    CREATE TABLE disk_sizes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        disk_size VARCHAR(255) NOT NULL
    );

    CREATE TABLE subnet (
        id INT AUTO_INCREMENT PRIMARY KEY,
        subnet VARCHAR(255) NOT NULL,
        subnet_name VARCHAR(255) NOT NULL
    );

    CREATE TABLE key_pairs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        key_name VARCHAR(255) NOT NULL,
        private_key TEXT NOT NULL
    );

    CREATE TABLE instances (
        id INT AUTO_INCREMENT PRIMARY KEY,
        instance_id VARCHAR(255) NOT NULL
    );
    ```

6. **Run the Application**:

    ```bash
    python app.py
    ```

    The application will start and be accessible at `http://0.0.0.0:80`.

## Usage

- **Home Page**: Access the main page to deploy EC2 instances or manage key pairs.
- **Add Key Pair**: Use the `Key Pair Management` link to add new key pairs.
- **Configure Instances**: Use the deployment form to specify settings and deploy EC2 instances.
- **Manage Instances**: View and terminate instances using the `Manage Instances` page.

## Security Considerations

- Ensure that sensitive data such as AWS credentials and database passwords are stored securely.
- Use environment variables or a secrets management service to manage sensitive configurations.

## IAM Setup

### Step 1: Create a Custom IAM Policy
First, you need to create a custom policy that grants the necessary permissions to launch and manage EC2 instances.

Open the IAM Console: Go to the AWS Management Console and navigate to IAM.
Create a Policy:
Click on "Policies" in the left navigation pane.
Click the "Create policy" button.
Switch to the "JSON" tab and paste the following policy JSON:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:CreateTags",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        }
    ]
}
```
* Click "Next: Tags", then "Next: Review".
* Name the policy, e.g., EC2LaunchPolicy, and provide a description.
* Click "Create policy".

### Step 2: Create an IAM Role
Now, create an IAM role and attach the policy you just created.

1) Create a Role:

* In the IAM console, click on "Roles" in the left navigation pane.
* Click the "Create role" button.
* Select "AWS service" and choose "EC2" for the trusted entity.
* Click "Next: Permissions".

2) Attach the Policy:

* Search for the policy EC2LaunchPolicy you created.
* Select the policy and click "Next: Tags".
* Add any tags if necessary, then click "Next: Review".

3) Name the Role:

* Provide a name for the role, e.g., EC2LaunchRole, and a description.
* Click "Create role".

### Step 3: Add Trust Relationship

* Add the trust relationship to allow the EC2 instance to assume the role.

1) Edit Trust Relationship:

* In the IAM console, select the EC2LaunchRole role you created.
* Go to the "Trust relationships" tab.
* Click "Edit trust relationship".
* Update the policy to include the following JSON:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

2) Save the Changes:
* Click "Update Trust Policy" to save the changes.

### Step 4: Attach the IAM Role to Your EC2 Instance
* Attach the IAM role to the EC2 instance running your Flask application:

1) Navigate to EC2 Console:

* Go to the EC2 console.
* Select the EC2 instance running your Flask app.

2) Modify IAM Role:

* Click on the "Actions" button, select "Security", and then "Modify IAM role".
* Select the EC2LaunchRole you created from the dropdown.
* Click "Update IAM role".

You should be able to deploy instances without having to put any credentials into the application.

## Contributing

Feel free to open issues or submit pull requests if you have suggestions or improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
