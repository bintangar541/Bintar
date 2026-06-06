from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

load_dotenv()

SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:b@localhost/bintar")

try:
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    # Check connection
    engine.connect()
except Exception as e:
    print(f"Error: Gagal menyambung ke PostgreSQL. Pastikan database 'bintar' sudah dibuat.")
    print(f"Detail: {e}")
    # Fallback to sqlite for demo if postgres fails
    SQLALCHEMY_DATABASE_URL = "sqlite:///./bintar.db"
    engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
