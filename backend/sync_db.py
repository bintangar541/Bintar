from app.database.session import engine, Base
from app.database import models

def sync_db():
    print("Mengecek dan mensinkronisasikan database...")
    # Ini akan membuat tabel yang belum ada, 
    # tapi tidak akan menambah kolom jika tabel sudah ada.
    # Untuk amannya di fase dev, kita bisa drop dan create ulang 
    # ATAU gunakan migrasi. Karena ini masih dev, kita drop & create.
    
    try:
        # Hapus tabel lama agar skema baru (hashed_password, user_id) terpasang
        print("Menghapus tabel lama untuk pembaharuan skema...")
        Base.metadata.drop_all(bind=engine)
        print("Memสร้าง tabel baru...")
        Base.metadata.create_all(bind=engine)
        print("Database berhasil disinkronisasi!")
    except Exception as e:
        print(f"Error saat sinkronisasi: {e}")

if __name__ == "__main__":
    sync_db()
