import os
import socket

import pymysql
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

db_query_errors = metrics.counter(
    "db_query_errors_total",
    "Number of database query errors",
)

DB_HOST = os.environ.get("DB_HOST", "mysql")
DB_USER = os.environ.get("DB_USER", "root")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
DB_NAME = os.environ.get("DB_NAME", "appdb")
INSTANCE_ID = os.environ.get("INSTANCE_ID", socket.gethostname())


def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        connect_timeout=3,
        read_timeout=3,
        write_timeout=3,
    )


@app.route("/")
def index():
    return jsonify(
        {
            "service": "SRE Demo Web App",
            "instance": INSTANCE_ID,
            "hostname": socket.gethostname(),
            "status": "running",
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "healthy"})


@app.route("/ready")
def ready():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({"status": "ready"})
    except Exception as e:
        return jsonify({"status": "not_ready", "error": str(e)}), 503


@app.route("/users")
def get_users():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, email FROM users")
        rows = cursor.fetchall()
        users = [{"id": r[0], "name": r[1], "email": r[2]} for r in rows]
        conn.close()
        return jsonify({"users": users})
    except Exception as e:
        db_query_errors.inc()
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
