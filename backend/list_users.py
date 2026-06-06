from app.database.session import SessionLocal
from app.database import models

def list_users():
    db = SessionLocal()
    users = db.query(models.User).all()
    if not users:
        print("No users found in database.")
        return
    
    print("--- Daftar Akun Terdaftar ---")
    for user in users:
        print(f"- Email: {user.email} (Nama: {user.full_name})")
    print("-----------------------------")

if __name__ == "__main__":
    list_users()
