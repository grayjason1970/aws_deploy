import os
import boto3
import botocore
import logging
from flask import Flask, render_template, request, redirect, url_for, flash
import MySQLdb
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
app.secret_key = os.urandom(24)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Database connection
def get_db_connection():
    try:
        conn = MySQLdb.connect(
            host=app.config['MYSQL_HOST'],
            user=app.config['MYSQL_USER'],
            passwd=app.config['MYSQL_PASSWORD'],
            db=app.config['MYSQL_DB']
        )
        return conn
    except MySQLdb.Error as e:
        flash(f"Database connection error: {e}", "danger")
        return None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/deploy')
def deploy():
    conn = get_db_connection()
    if not conn:
        return render_template('deploy.html', error="Database connection failed")

    try:
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM images")
        images = cursor.fetchall()
        
        cursor.execute("SELECT * FROM instance_types")
        instance_types = cursor.fetchall()
        
        cursor.execute("SELECT * FROM memory_sizes")
        memory_sizes = cursor.fetchall()
        
        cursor.execute("SELECT * FROM disk_sizes")
        disk_sizes = cursor.fetchall()
        
        cursor.execute("SELECT * FROM subnet")
        subnets = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()

    return render_template('deploy.html', images=images, instance_types=instance_types, 
                           memory_sizes=memory_sizes, disk_sizes=disk_sizes, subnets=subnets)

@app.route('/configure', methods=['POST'])
def configure():
    image_id = request.form['image_id']
    instance_type = request.form['instance_type']
    memory_size = request.form['memory_size']
    disk_size = request.form['disk_size']
    subnet_id = request.form['subnet_id']
    instance_count = int(request.form['instance_count'])

    # Log received form data
    app.logger.debug(f"Received form data: image_id={image_id}, instance_type={instance_type}, memory_size={memory_size}, disk_size={disk_size}, subnet_id={subnet_id}, instance_count={instance_count}")

    # Check if instance_type is valid
    valid_instance_types = [
        "t2.nano", "t2.micro", "t2.small", "t2.medium", "t2.large", 
        "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge", "m5.12xlarge", "m5.24xlarge"
        # Add more valid instance types as necessary
    ]

    if instance_type not in valid_instance_types:
        flash(f"Invalid instance type: {instance_type}", "danger")
        return redirect(url_for('deploy'))

    ec2 = boto3.resource('ec2', region_name=app.config['AWS_REGION'])
    deployment_success = True

    for _ in range(instance_count):
        try:
            instance = ec2.create_instances(
                ImageId=image_id,
                MinCount=1,
                MaxCount=1,
                InstanceType=instance_type,
                SubnetId=subnet_id,
            )[0]

            # Save the instance ID to the database
            conn = get_db_connection()
            if not conn:
                flash("Database connection failed", "danger")
                deployment_success = False
                continue

            try:
                cursor = conn.cursor()
                cursor.execute("INSERT INTO instances (instance_id) VALUES (%s)", (instance.id,))
                conn.commit()
            finally:
                cursor.close()
                conn.close()
        except botocore.exceptions.ClientError as e:
            flash(f"Failed to launch instance: {e}", "danger")
            app.logger.error(f"Failed to launch instance: {e}")
            deployment_success = False

    if deployment_success:
        flash("Instances successfully launched.", "success")
    else:
        flash("Some instances could not be launched. Please check the logs.", "warning")

    return redirect(url_for('deploy'))

@app.route('/manage_instances')
def manage_instances():
    conn = get_db_connection()
    if not conn:
        return render_template('manage_instances.html', error="Database connection failed")
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM instances")
        instances = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()
    
    return render_template('manage_instances.html', instances=instances)

@app.route('/terminate_instance/<instance_id>', methods=['POST'])
def terminate_instance(instance_id):
    ec2 = boto3.client('ec2', region_name=app.config['AWS_REGION'])
    
    try:
        # Request to terminate the instance
        response = ec2.terminate_instances(InstanceIds=[instance_id])
        # Check response for termination status
        instance_status = response['TerminatingInstances'][0]['CurrentState']['Name']
        
        if instance_status == 'shutting-down' or instance_status == 'terminated':
            flash(f"Instance {instance_id} is being terminated.", "success")
        else:
            flash(f"Instance {instance_id} could not be terminated.", "danger")
            app.logger.error(f"Unexpected termination status: {instance_status}")
    except botocore.exceptions.ClientError as e:
        flash(f"Failed to terminate instance: {e}", "danger")
        app.logger.error(f"Failed to terminate instance: {e}")

    # Remove the instance ID from the database
    conn = get_db_connection()
    if not conn:
        flash("Database connection failed", "danger")
        return redirect(url_for('manage_instances'))
    
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM instances WHERE instance_id = %s", (instance_id,))
        conn.commit()
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('manage_instances'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

