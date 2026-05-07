from flask import Flask, jsonify
import pymysql
import os
import socket
from prometheus_flask_exporter import PrometheusMetrics  # 新增

app = Flask(__name__)
metrics = PrometheusMetrics(app)  # 新增，自动注册 /metrics 端点

# 自定义业务指标（新增）
db_query_errors = metrics.counter(
    'db_query_errors_total',
    'Number of database query errors'
)

DB_HOST = os.environ.get('DB_HOST', 'mysql')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASSWORD = os.environ.get('DB_PASSWORD', '')
DB_NAME = os.environ.get('DB_NAME', 'sre_demo')

@app.route('/')
def index():
    return jsonify({
        'service': 'SRE Demo Web App',
        'hostname': socket.gethostname(),
        'status': 'running'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/users')
def get_users():
    try:
        conn = pymysql.connect(
            host=DB_HOST, user=DB_USER,
            password=DB_PASSWORD, database=DB_NAME
        )
        cursor = conn.cursor()
        cursor.execute('SELECT id, name, email FROM users')
        rows = cursor.fetchall()
        users = [{'id': r[0], 'name': r[1], 'email': r[2]} for r in rows]
        conn.close()
        return jsonify({'users': users})
    except Exception as e:
        db_query_errors.inc()   # 新增，数据库报错时计数
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
