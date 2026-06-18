import os
import psycopg2
from flask import Flask

app = Flask(__name__)

def get_db():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
    )

@app.route("/")
def hello():
    count = 0
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY)")
        cur.execute("INSERT INTO visits DEFAULT VALUES")
        cur.execute("SELECT COUNT(*) FROM visits")
        count = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        return f"DB error: {e}", 500
    return f"Hello from UAT! You are visitor #{count}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
