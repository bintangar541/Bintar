from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from .session import Base
import datetime

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    full_name = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    transactions = relationship("Transaction", back_populates="owner")
    goals = relationship("Goal", back_populates="owner")

class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    amount = Column(Float)
    description = Column(String)
    category = Column(String)
    wallet_type = Column(String) # Cash, Bank, etc.
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    
    owner = relationship("User", back_populates="transactions")

class FinancialDNA(Base):
    __tablename__ = "financial_dna"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    dna_type = Column(String) # The Saver, The Planner, etc.
    last_update = Column(DateTime, default=datetime.datetime.utcnow)

class Goal(Base):
    __tablename__ = "goals"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String)
    target_amount = Column(Float)
    current_amount = Column(Float, default=0.0)
    category = Column(String) # Mimpi, Kebutuhan, Investasi
    icon = Column(String) # Icon code or emoji
    target_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    owner = relationship("User", back_populates="goals")

class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    token = Column(String, unique=True, index=True)
    expires_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
