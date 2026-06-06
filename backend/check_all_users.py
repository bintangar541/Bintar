import sqlite3
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

def check_all():
    print("--- SQLITE (bintar.db) ---")
    try:
        conn = sqlite3.connect("bintar.db")
        cur = conn.cursor()
        cur.execute("SELECT email, full_name FROM users")
        rows = cur.fetchall()
        for row in rows:
            print(f"Email: {row[0]}, Name: {row[1]}")
        conn.close()
    except Exception as e:
        print(f"Error SQLite: {e}")

    print("\n--- POSTGRESQL ---")
    try:
        url = os.getenv("DATABASE_URL", "postgresql://postgres:b@localhost/bintar")
        conn = psycopg2.connect(url)
        cur = conn.cursor()
        cur.execute("SELECT email, full_name FROM users")
        rows = cur.fetchall()
        for row in rows:
            print(f"Email: {row[0]}, Name: {row[1]}")
        conn.close()
    except Exception as e:
        print(f"Error PG: {e}")

if __name__ == "__main__":
    check_all()
