from flask import Flask, render_template, request, redirect, url_for
import MySQLdb
import boto3
from config import Config

app = Flask(__name__)

app.config.from_object(Config)

def get_db_connection():
    conn = MySQLdb.connect(
        host=app.config['MYSQL_HOST'],
        user=app.config['MYSQL_USER'],
        passwd=app.config['MYSQL_PASSWORD'],
        db=app.config['MYSQL_DB']
    )
    return conn

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/config', methods=['GET', 'POST'])
def config_form():
    if request.method == 'POST':
        image_id = request.form['image_id']
        instance_type = request.form['instance_type']
        memory_size = request.form['memory_size']
        disk_size = request.form['disk_size']
        subnet_id = request.form['subnet_id']
        instance_count = int(request.form['instance_count'])

        ec2 = boto3.resource('ec2', region_name=app.config['AWS_REGION'])

        for _ in range(instance_count):
            ec2.create_instances(
                ImageId=image_id,
                InstanceType=instance_type,
                MinCount=1,
                MaxCount=1,
                SubnetId=subnet_id,
                KeyName=app.config['KEYNAME']
            )
        
        return redirect(url_for('deploy_results', count=instance_count))

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT key_name FROM key_pairs WHERE id = %s", (key_pair_id,))
    key_pair = cursor.fetchone()
    key_name = key_pair[0]
    
    cursor.execute("SELECT * FROM images")
    images = cursor.fetchall()

    cursor.execute("SELECT * FROM instance_types")
    instance_types = cursor.fetchall()

    cursor.execute("SELECT * FROM memory_sizes")
    memory_sizes = cursor.fetchall()

    cursor.execute("SELECT * FROM disk_sizes")
    disk_sizes = cursor.fetchall()

    cursor.execute("SELECT * FROM subnet_id")
    subnets = cursor.fetchall()

    cursor.execute("SELECT * FROM key_pairs")
    key_pairs = cursor.fetchall()
    
    conn.close()

    return render_template('config_form.html',
                           images=images,
                           instance_types=instance_types,
                           memory_sizes=memory_sizes,
                           disk_sizes=disk_sizes,
                           subnets=subnets,
                           key_pairs=key_pairs)

@app.route('/deploy_results')
def deploy_results():
    count = request.args.get('count', 0)
    return render_template('deploy_results.html', count=count)

if __name__ == '__main__':
    #app.run(debug=True)
    app.run(host='0.0.0.0', port=80, debug=True)
