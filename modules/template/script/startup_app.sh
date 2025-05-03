#!/bin/bash
sudo dnf install -y python3 python3-pip
sudo pip3 install flask pymysql

cat <<EOF > /opt/app.py
from flask import Flask, request
import pymysql

app = Flask(__name__)

@app.route('/')
def grades():
    conn = pymysql.connect(
        host='${db_host}',
        user='${db_user}',
        password='${db_password}',
        database='${db_name}'
    )
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM grade")
    result = cursor.fetchall()
    return str(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF

sudo bash -c 'nohup python3 /opt/app.py > /var/log/app.log 2>&1 &'

