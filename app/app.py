from flask import Flask, jsonify
import os
import time
import pymysql

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "mysql")
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "root123")
DB_NAME = os.getenv("DB_NAME", "app_db")


def get_connection():
    for i in range(10):  # 🔥 解决启动顺序问题
        try:
            conn = pymysql.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASSWORD,
                database=DB_NAME,
                port=3306
            )
            return conn
        except Exception as e:
            print(f"MySQL连接失败，重试中... {e}")
            time.sleep(3)
    return None


@app.route("/")
def hello():
    return f"Hello from {os.getenv('HOSTNAME')}"


@app.route("/db")
def db_test():
    conn = get_connection()
    if not conn:
        return "数据库连接失败", 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM users;")
            result = cursor.fetchall()
        return jsonify(result)
    except Exception as e:
        return str(e), 500
    finally:
        conn.close()


@app.route('/health')
def health():
    return "ok"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, threaded=False)
