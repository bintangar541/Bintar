import asyncio
from app.database.session import SessionLocal, engine
from app.database import models

async def seed():
    models.Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    # Create Dummy User
    user = models.User(
        email="test@bintar.ai",
        full_name="John Doe",
        hashed_password="hashed_password_here"
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Create Initial Transactions
    transactions = [
        models.Transaction(user_id=user.id, amount=25000, description="Kopi Pagi", category="Makanan & Minuman"),
        models.Transaction(user_id=user.id, amount=150000, description="Bensin Mobil", category="Transportasi"),
        models.Transaction(user_id=user.id, amount=300000, description="Investasi Reksa Dana", category="Investasi")
    ]
    db.add_all(transactions)
    
    # Create Financial DNA
    dna = models.FinancialDNA(user_id=user.id, dna_type="The Strategic Planner")
    db.add(dna)
    
    db.commit()
    print("Database Seeded Successfully!")

if __name__ == "__main__":
    asyncio.run(seed())
