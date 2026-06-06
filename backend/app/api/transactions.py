from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from ..database.session import get_db
from ..database import models
from ..schemas import schemas
from ..services.gemini_service import GeminiService
from .auth import get_current_user

router = APIRouter(prefix="/transactions", tags=["transactions"])
gemini = GeminiService()

@router.post("/analyze-category")
async def analyze_category(description: str, current_user: models.User = Depends(get_current_user)):
    category = await gemini.analyze_category(description)
    return {"category": category}

@router.post("/smart-input")
async def smart_input(text: str, current_user: models.User = Depends(get_current_user)):
    """Parse natural language and returns structured transaction data."""
    result = await gemini.parse_smart_input(text)
    if not result:
        raise HTTPException(status_code=400, detail="AI gagal memahami input tersebut.")
    return result

from fastapi import UploadFile, File
@router.post("/import-bank")
async def import_bank(file: UploadFile = File(...), current_user: models.User = Depends(get_current_user)):
    """Membaca file bank (CSV/TXT/PDF) dan mengekstrak transaksi via AI."""
    content = await file.read()
    
    if file.filename.lower().endswith('.pdf'):
        # Ekstrak teks dari PDF
        text_content = gemini.extract_text_from_pdf(content)
    else:
        # Sederhananya kita asumsikan file teks/CSV untuk non-PDF
        text_content = content.decode("utf-8", errors="ignore")
    
    if text_content == "__ENCRYPTED__":
        return {"transactions": [], "error": "File PDF ini terkunci password. Mohon gunakan file PDF yang sudah dibuka kuncinya (de-crypted)."}
        
    if not text_content:
        return {"transactions": [], "error": "AI gagal membaca isi file tersebut."}
        
    transactions = await gemini.parse_bank_statement(text_content)
    return {"transactions": transactions}

class ChatRequest(BaseModel):
    message: str

@router.post("/chat")
async def ai_chat(req: ChatRequest, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Ambil semua transaksi milik USER yang sedang login dari database
    transactions = db.query(models.Transaction).filter(models.Transaction.user_id == current_user.id).order_by(models.Transaction.id.desc()).limit(50).all()
    
    # Hitung ringkasan keuangan
    total_income = sum(t.amount for t in transactions if t.amount > 0)
    total_expense = sum(abs(t.amount) for t in transactions if t.amount < 0)
    balance = total_income - total_expense
    
    # Susun data transaksi jadi teks
    tx_lines = []
    for t in transactions:
        tipe = "Pemasukan" if t.amount > 0 else "Pengeluaran"
        tx_lines.append(f"- {t.description}: Rp{abs(t.amount):,.0f} ({tipe}, Kategori: {t.category})")
    tx_summary = "\n".join(tx_lines) if tx_lines else "Belum ada transaksi."
    
    financial_context = f"""
DATA KEUANGAN PENGGUNA (dari database):
- Nama Pengguna: {current_user.full_name}
- Total Pemasukan: Rp{total_income:,.0f}
- Total Pengeluaran: Rp{total_expense:,.0f}
- Saldo: Rp{balance:,.0f}
- Jumlah Transaksi: {len(transactions)}

Riwayat Transaksi:
{tx_summary}
"""
    
    reply = await gemini.chat(req.message, financial_context)
    return {"reply": reply}

@router.post("/")
async def create_transaction(transaction: schemas.TransactionCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Pastikan user_id sesuai dengan user yang login
    db_transaction = models.Transaction(**transaction.dict())
    db_transaction.user_id = current_user.id
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    return db_transaction

@router.get("/", response_model=list[schemas.Transaction])
async def get_transactions(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    transactions = db.query(models.Transaction).filter(models.Transaction.user_id == current_user.id).order_by(models.Transaction.id.desc()).all()
    return transactions

@router.get("/analysis")
async def get_financial_analysis(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Ambil transaksi terbaru
    transactions = db.query(models.Transaction).filter(models.Transaction.user_id == current_user.id).order_by(models.Transaction.id.desc()).limit(100).all()
    
    if not transactions:
        return {
            "dna_title": "Investor Pemula",
            "dna_description": "Mulai catat transaksimu untuk mengetahui pola keuanganmu!",
            "timeline_insights": []
        }
    
    # Format data untuk AI
    tx_data = [f"{t.description} ({t.category}): {t.amount}" for t in transactions]
    tx_summary = "\n".join(tx_data[:30])
    
    # Panggil AI untuk analisa DNA
    dna_analysis = await gemini.analyze_financial_dna(tx_summary)
    
    # Parsing sederhana untuk format "Judul: ... Deskripsi: ..."
    dna_title = "AI Financial Intelligence"
    dna_desc = dna_analysis
    
    if "Judul:" in dna_analysis and "Deskripsi:" in dna_analysis:
        parts = dna_analysis.split("Deskripsi:")
        dna_title = parts[0].replace("Judul:", "").strip()
        dna_desc = parts[1].strip()
    
    # Dummy logic for timeline insights
    total_expense = sum(abs(t.amount) for t in transactions if t.amount < 0)
    
    return {
        "dna_title": dna_title,
        "dna_description": dna_desc,
        "timeline_insights": [
            {"title": "Pola Belanja", "desc": f"Total pengeluaranmu periode ini adalah Rp{total_expense:,.0f}", "type": "info"},
            {"title": "Insight DNA", "desc": f"Kamu terdeteksi sebagai {dna_title}", "type": "dna"}
        ]
    }

@router.post("/simulate")
async def simulate_scenario(req: ChatRequest, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    """Simulasikan skenario keuangan berdasarkan input user."""
    # Ambil data saldo dan tren 30 hari terakhir
    from datetime import datetime, timedelta
    thirty_days_ago = datetime.now() - timedelta(days=30)
    transactions = db.query(models.Transaction).filter(
        models.Transaction.user_id == current_user.id,
        models.Transaction.timestamp >= thirty_days_ago
    ).all()
    
    total_income = sum(t.amount for t in transactions if t.amount > 0)
    total_expense = sum(abs(t.amount) for t in transactions if t.amount < 0)
    balance = total_income - total_expense
    
    financial_context = f"""
    - Nama: {current_user.full_name}
    - Saldo 30 hari terakhir: Rp{balance:,.0f}
    - Total Pemasukan: Rp{total_income:,.0f}
    - Total Pengeluaran: Rp{total_expense:,.0f}
    - Rata-rata Pengeluaran: Rp{total_expense/30:,.0f}/hari
    """
    
    reply = await gemini.simulate_scenario(req.message, financial_context)
    return {"reply": reply}

@router.get("/wrapped")
async def get_monthly_wrapped(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    """Menghasilkan data Monthly Wrapped untuk user."""
    from datetime import datetime
    now = datetime.now()
    month_name = now.strftime("%B")
    
    # Ambil transaksi bulan ini
    start_of_month = datetime(now.year, now.month, 1)
    transactions = db.query(models.Transaction).filter(
        models.Transaction.user_id == current_user.id,
        models.Transaction.timestamp >= start_of_month
    ).all()
    
    if not transactions:
         return {
            "title": "Bulan Baru, Semangat Baru!",
            "hero_metric": "Lo baru aja mulai perjalanan di Bintar.",
            "lifestyle_insight": "Belum ada data belanja yang cukup.",
            "recommendation": "Yuk catat transaksi pertama lo!",
            "personality_badge": "Pendatang Baru"
        }

    # Grouping by category
    categories = {}
    for t in transactions:
        categories[t.category] = categories.get(t.category, 0) + abs(t.amount)
    
    sorted_cats = sorted(categories.items(), key=lambda x: x[1], reverse=True)
    top_cat = sorted_cats[0][0] if sorted_cats else "Lainnya"
    
    tx_summary = f"""
    - Total Transaksi: {len(transactions)}
    - Kategori Terbesar: {top_cat} (Rp{categories.get(top_cat, 0):,.0f})
    - Total Pengeluaran: Rp{sum(abs(t.amount) for t in transactions if t.amount < 0):,.0f}
    """
    
    wrapped_data = await gemini.generate_monthly_wrapped(current_user.full_name, month_name, tx_summary)
    return wrapped_data

@router.get("/notifications")
async def get_smart_notifications(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    """Menghasilkan list notifikasi pintar berbasis AI."""
    from datetime import datetime, timedelta
    thirty_days_ago = datetime.now() - timedelta(days=30)
    
    # 1. Ambil data transaksi (30 hari)
    transactions = db.query(models.Transaction).filter(
        models.Transaction.user_id == current_user.id,
        models.Transaction.timestamp >= thirty_days_ago
    ).all()
    
    tx_summary = ""
    if transactions:
        total_expense = sum(abs(t.amount) for t in transactions if t.amount < 0)
        categories = {}
        for t in transactions:
            categories[t.category] = categories.get(t.category, 0) + abs(t.amount)
        # Sort safe
        sorted_cats = sorted(categories.items(), key=lambda x: x[1], reverse=True)
        top_cat = sorted_cats[0][0] if sorted_cats else "Lainnya"
        tx_summary = f"Total belanja 30 hari: Rp{total_expense:,.0f}. Kategori terbanyak: {top_cat}."
    else:
        tx_summary = "Belum ada transaksi dalam 30 hari terakhir."

    # 2. Ambil data misi tabungan (goals)
    from app.models import Goal
    active_goals = db.query(Goal).filter(Goal.user_id == current_user.id, Goal.is_completed == False).all()
    goals_summary = ""
    if active_goals:
        goals_summary = ", ".join([f"{g.title} ({int((g.current_amount/g.target_amount)*100)}%)" for g in active_goals])
    else:
        goals_summary = "Belum ada misi aktif."

    # 3. Generate via Gemini
    notifications = await gemini.generate_smart_notifications(current_user.full_name, tx_summary, goals_summary)
    
    # Jika AI gagal, kasih fallback
    if not notifications:
        notifications = [
            {
                "icon": "auto_awesome_rounded",
                "color": "green",
                "title": "Welcome to Bintar! ✨",
                "desc": "Mulai catat transaksi pertama lo buat dapetin insight AI yang lebih personal.",
                "time": "Baru saja"
            }
        ]
        
    return notifications

