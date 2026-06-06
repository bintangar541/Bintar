from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class TransactionBase(BaseModel):
    amount: float
    description: str
    category: str
    wallet_type: Optional[str] = "Cash"

class TransactionCreate(TransactionBase):
    user_id: Optional[int] = None

class Transaction(TransactionBase):
    id: int
    user_id: int
    timestamp: datetime

    class Config:
        from_attributes = True

class UserBase(BaseModel):
    email: str
    full_name: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class GoalBase(BaseModel):
    title: str
    target_amount: float
    current_amount: float = 0.0
    category: str
    icon: str
    target_date: Optional[datetime] = None

class GoalCreate(GoalBase):
    pass

class Goal(GoalBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class ForgotPassword(BaseModel):
    email: str

class ResetPassword(BaseModel):
    token: str
    new_password: str
