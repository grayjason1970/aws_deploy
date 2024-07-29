import MySQLdb

# Database connection
def get_db_connection():
    return MySQLdb.connect(host="your-db-host", user="your-db-user", passwd="your-db-password", db="project1")

def insert_key_pair(key_name, private_key):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO key_pairs (key_name, private_key) VALUES (%s, %s)", (key_name, private_key))
    conn.commit()
    cursor.close()
    conn.close()

# Example usage
key_name = 'my-key-pair'
private_key = """-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAr5...
-----END RSA PRIVATE KEY-----"""

insert_key_pair(key_name, private_key)
