from app.database.session import SessionLocal
from app.database import models

def get_latest_token():
    db = SessionLocal()
    try:
        # Fetch the latest token from the password_reset_tokens table
        token_record = db.query(models.PasswordResetToken).order_by(models.PasswordResetToken.created_at.desc()).first()
        if token_record:
            print(f"LATEST_TOKEN={token_record.token}")
        else:
            print("No token found.")
    finally:
        db.close()

if __name__ == "__main__":
    get_latest_token()
