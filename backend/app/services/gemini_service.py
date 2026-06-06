from groq import Groq
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv(override=True)

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

import io
from pypdf import PdfReader

class GeminiService:
    """AI Service - sekarang menggunakan Groq (Llama 3) sebagai engine."""

    def extract_text_from_pdf(self, pdf_content: bytes) -> str:
        """Ekstrak teks dari binary PDF menggunakan pypdf."""
        try:
            reader = PdfReader(io.BytesIO(pdf_content))
            
            if reader.is_encrypted:
                return "__ENCRYPTED__"
                
            text = ""
            for page in reader.pages:
                text += page.extract_text() + "\n"
            
            return text.strip()
        except Exception as e:
            print(f"Error extracting PDF: {e}")
            return ""

    def _chunk_text(self, text: str, chunk_size: int = 4000) -> list:
        """Bagi teks menjadi potongan-potongan kecil berdasarkan baris."""
        lines = text.split('\n')
        chunks = []
        current_chunk = ""
        for line in lines:
            if len(current_chunk) + len(line) + 1 > chunk_size:
                if current_chunk:
                    chunks.append(current_chunk.strip())
                current_chunk = line + "\n"
            else:
                current_chunk += line + "\n"
        if current_chunk.strip():
            chunks.append(current_chunk.strip())
        return chunks

    def _chat_completion(self, prompt: str) -> str:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.1,
            max_tokens=4096,
        )
        return response.choices[0].message.content.strip()

    async def generate_financial_insight(self, transaction_history: str):
        prompt = f"Berdasarkan data transaksi berikut: {transaction_history}. Berikan satu insight keuangan singkat dalam Bahasa Indonesia untuk dashboard pengguna."
        return self._chat_completion(prompt)

    async def analyze_financial_dna(self, transactions: str):
        prompt = f"""Analisis pola pengeluaran ini:
{transactions}

Tentukan kategori 'Financial DNA' pengguna (Pilih satu: The Saver, The Planner, The Explorer, atau The Impulsive Buyer).
Berikan jawaban dalam format persis seperti ini (HANYA FORMAT INI):
Judul: [Kategori]
Deskripsi: [Satu paragraf singkat (maks 2 kalimat) yang menarik dan memotivasi pengguna, tanpa menyebutkan angka teknis atau detail perhitungan]"""
        return self._chat_completion(prompt)

    async def analyze_category(self, description: str):
        try:
            prompt = f"Kategorikan transaksi ini ke dalam SATU dari kategori berikut (HANYA tulis nama kategorinya saja, tanpa penjelasan): Transportasi, Makanan, Hiburan, Belanja, Tagihan, Transfer, Penghasilan, Tabungan, Lainnya. Deskripsi: '{description}'"
            return self._chat_completion(prompt)
        except Exception:
            desc_lower = description.lower()
            if any(word in desc_lower for word in ["bensin", "parkir", "gojek", "grab", "tol", "krl", "mrt"]):
                return "Transportasi"
            elif any(word in desc_lower for word in ["makan", "minum", "kopi", "cafe", "roti", "kue", "susu"]):
                return "Makanan"
            elif any(word in desc_lower for word in ["nonton", "bioskop", "game", "spotify", "netflix"]):
                return "Hiburan"
            elif any(word in desc_lower for word in ["baju", "sepatu", "skincare", "shopee", "tokopedia"]):
                return "Belanja"
            elif any(word in desc_lower for word in ["listrik", "air", "wifi", "internet"]):
                return "Tagihan"
            return "Lainnya"

    async def chat(self, message: str, financial_context: str = ""):
        try:
            prompt = f"""Anda adalah AI Money Coach Bintar, asisten keuangan cerdas yang ramah bergaya fintech modern.

{financial_context}

Berdasarkan DATA KEUANGAN di atas, jawab pertanyaan pengguna dengan RINGKAS (maks 3 paragraf pendek dengan emoji). Berikan analisis dan saran yang SPESIFIK berdasarkan angka nyata di atas, bukan saran generik.

Pertanyaan pengguna: {message}"""
            return self._chat_completion(prompt)
        except Exception as e:
            error_str = str(e).lower()
            if "429" in error_str or "rate" in error_str:
                return "Maaf, kuota API sedang habis. Coba lagi dalam beberapa menit ya! 🙇‍♂️"
            return "Maaf, koneksi ke pusat kecerdasan AI sedang terganggu. Coba lagi ya! 🤖"

    async def parse_smart_input(self, text: str):
        """Menerjemahkan input natural language (suara/teks) jadi objek transaksi."""
        prompt = f"""Tolong ekstrak data transaksi dari kalimat berikut: "{text}"
        
        Berikan jawaban dalam format JSON murni (HANYA JSON, tanpa markdown):
        {{
            "description": "nama barang/kegiatan",
            "amount": integer (negatif untuk pengeluaran, positif untuk pemasukan),
            "category": "salah satu dari: Transportasi, Makanan, Hiburan, Belanja, Tagihan, Transfer, Penghasilan, Tabungan, Lainnya"
        }}
        """
        try:
            result = self._chat_completion(prompt)
            # Remove any markdown code blocks if present
            clean_result = result.replace("```json", "").replace("```", "").strip()
            import json
            return json.loads(clean_result)
        except Exception:
            return None

    async def parse_bank_statement(self, text_content: str):
        """Mengekstrak list transaksi dari teks mentah file mutasi bank, diproses per bagian."""
        import json

        def parse_chunk(chunk_text: str) -> list:
            prompt = f"""Ekstrak data transaksi individu dari teks mutasi bank berikut secara AKURAT.
        
        DATA MENTAH:
        ---
        {chunk_text}
        ---
        
        HANYA berikan output JSON array (tanpa penjelasan, tanpa markdown):
        [
            {{ "date": "YYYY-MM-DD", "description": "...", "amount": float, "category": "Makanan/Belanja/Transfer/Hiburan/Lainnya" }},
            ...
        ]
        
        Jika tidak ada transaksi dalam teks ini, kembalikan array kosong: []
        Abaikan Saldo Awal/Akhir. Pastikan JSON valid dan lengkap.
        """
            try:
                result = self._chat_completion(prompt).strip()
                start = result.find('[')
                end = result.rfind(']')
                if start == -1:
                    return []
                if end != -1 and end > start:
                    json_str = result[start:end+1]
                else:
                    json_str = result[start:]
                try:
                    return json.loads(json_str)
                except json.JSONDecodeError:
                    try:
                        return json.loads(json_str + "]")
                    except:
                        last_obj_end = json_str.rfind('}')
                        if last_obj_end != -1:
                            try:
                                return json.loads(json_str[:last_obj_end+1] + "]")
                            except:
                                pass
                return []
            except Exception as e:
                print(f"Chunk parse error: {e}")
                return []

        try:
            chunks = self._chunk_text(text_content, chunk_size=4000)
            all_transactions = []

            with open("ai_debug_raw.log", "a") as f:
                f.write(f"\n--- NEW CHUNKED IMPORT ---\n")
                f.write(f"TOTAL TEXT LENGTH: {len(text_content)}\n")
                f.write(f"TOTAL CHUNKS: {len(chunks)}\n")

            for i, chunk in enumerate(chunks):
                chunk_results = parse_chunk(chunk)
                all_transactions.extend(chunk_results)
                with open("ai_debug_raw.log", "a") as f:
                    f.write(f"CHUNK {i+1}/{len(chunks)}: found {len(chunk_results)} transactions\n")

            # Deduplicate by (date, description, amount)
            seen = set()
            unique_transactions = []
            for tx in all_transactions:
                key = (tx.get('date'), tx.get('description'), tx.get('amount'))
                if key not in seen:
                    seen.add(key)
                    unique_transactions.append(tx)

            with open("ai_debug_raw.log", "a") as f:
                f.write(f"TOTAL UNIQUE TRANSACTIONS: {len(unique_transactions)}\n")

            return unique_transactions
        except Exception as e:
            print(f"Error parsing bank statement: {e}")
            return []
    async def simulate_scenario(self, user_query: str, financial_context: str):
        """Simulasikan skenario keuangan 'What-If'."""
        prompt = f"""Anda adalah AI Financial Simulator Bintar.
        
KONTEKS KEUANGAN USER:
{financial_context}

PERTANYAAN SIMULASI:
"{user_query}"

Tugas Anda:
1. Analisis apakah rencana user masuk akal berdasarkan saldo dan pengeluaran mereka.
2. Berikan estimasi waktu atau sisa dana yang dibutuhkan.
3. Berikan saran konkret (misal: "Kurangi jajan kopi sebesar 200rb/bulan").

Berikan balasan dalam Bahasa Indonesia yang ramah, ringkas, dan penuh angka nyata (maks 3 paragraf). Gunakan emoji.
"""
        return self._chat_completion(prompt)

    async def generate_monthly_wrapped(self, user_name: str, month_name: str, tx_summary: str):
        """Buat narasi untuk Bintar Monthly Wrapped."""
        prompt = f"""Buatlah narasi 'Monthly Wrapped' yang seru dan estetik untuk {user_name} di bulan {month_name}.
        
RINGKASAN TRANSAKSI:
{tx_summary}

Berikan output dalam format JSON murni (HANYA JSON) dengan struktur berikut:
{{
    "title": "Judul Besar (misal: 'Bulan Penuh Jajan! 🍕')",
    "hero_metric": "Satu fakta paling gila (misal: 'Lo ngabisin 2 juta cuma buat Kopi!')",
    "lifestyle_insight": "Satu kalimat tentang gaya hidup (misal: 'Lo lebih sering jajan di weekend daripada hari kerja.')",
    "recommendation": "Satu tantangan buat bulan depan (misal: 'Coba puasa belanja baju dulu ya!')",
    "personality_badge": "Satu badge unik (misal: 'Si Paling Royal' atau 'Suhu Hemat')"
}}

Jawab dalam Bahasa Indonesia yang gaul, suportif, dan penuh semangat!
"""
        try:
            result = self._chat_completion(prompt)
            clean_result = result.replace("```json", "").replace("```", "").strip()
            import json
            return json.loads(clean_result)
        except Exception:
            return {
                "title": f"Bulan {month_name} yang Luar Biasa!",
                "hero_metric": "Lo hebat udah mulai catat keuangan!",
                "lifestyle_insight": "Pola belanjamu mulai terlihat rapi.",
                "recommendation": "Teruskan kebiasaan baik ini bulan depan!",
                "personality_badge": "Pejuang Bintar"
            }

    async def generate_smart_notifications(self, user_name: str, tx_summary: str, goals_summary: str):
        """Buat daftar notifikasi pintar berbasis AI."""
        prompt = f"""Halo, saya adalah AI Engine Bintar. Tolong buatkan 3 notifikasi cerdas untuk {user_name} berdasarkan data berikut:
        
DATA TRANSAKSI (30 HARI):
{tx_summary}

DATA MISI TABUNGAN:
{goals_summary}

Tugas Anda:
Buatlah 3 notifikasi yang personal, inspiratif, dan sangat berguna. 
Misal: Peringatan jika belanja makanan terlalu tinggi, pengingat tagihan (jika ada data tagihan), atau progress misi tabungan.

Berikan output dalam format JSON array murni (HANYA JSON) dengan struktur berikut:
[
    {{
        "icon": "warning_amber_rounded",
        "color": "orange",
        "title": "Judul Notifikasi (singkat + emoji)",
        "desc": "Pesan detail (Bahasa Indonesia gaul/ramah)",
        "time": "Kapan (misal: 'Baru saja', '2 jam yang lalu')"
    }},
    ...
]

Pilihan icon: warning_amber_rounded, event_repeat_rounded, auto_awesome_rounded, local_attraction_rounded, payments_rounded.
Pilihan color: orange, blue, green, red, purple.
"""
        try:
            result = self._chat_completion(prompt)
            clean_result = result.replace("```json", "").replace("```", "").strip()
            import json
            return json.loads(clean_result)
        except Exception:
            return []
