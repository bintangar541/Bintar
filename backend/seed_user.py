from app.database.session import SessionLocal
from app.database import models
from app.api.auth import get_password_hash

def seed_test_user():
    db = SessionLocal()
    # Check if user exists
    user = db.query(models.User).filter(models.User.email == "user@bintar.ai").first()
    if not user:
        new_user = models.User(
            email="user@bintar.ai",
            full_name="User Bintar",
            hashed_password=get_password_hash("password123")
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        print(f"User created: {new_user.email} / password123")
    else:
        # Update password just in case
        user.hashed_password = get_password_hash("password123")
        db.commit()
        print(f"User updated: {user.email} / password123")

if __name__ == "__main__":
    seed_test_user()
