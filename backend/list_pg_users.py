from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import models
import os
from dotenv import load_dotenv

load_dotenv()

def list_pg_users():
    SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:b@localhost/bintar")
    try:
        engine = create_engine(SQLALCHEMY_DATABASE_URL)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        users = db.query(models.User).all()
        if not users:
            print("No users found in PostgreSQL database.")
            return
        
        print("--- Daftar Akun Terdaftar (PostgreSQL) ---")
        for user in users:
            print(f"- Email: {user.email} (Nama: {user.full_name})")
        print("------------------------------------------")
    except Exception as e:
        print(f"Error connecting to PostgreSQL: {e}")

if __name__ == "__main__":
    list_pg_users()
