import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

# Load env from the backend directory
load_dotenv('backend/.env')

def test_email():
    mail_username = os.getenv("MAIL_USERNAME")
    mail_password = os.getenv("MAIL_PASSWORD")
    mail_from = os.getenv("MAIL_FROM")
    mail_server = os.getenv("MAIL_SERVER")
    mail_port = int(os.getenv("MAIL_PORT", 587))

    print(f"Testing with: {mail_username}")
    
    recipient = mail_username # Send to self for testing
    
    message = MIMEMultipart()
    message["Subject"] = "Test Email Bintar"
    message["From"] = mail_from
    message["To"] = recipient
    
    body = "Ini adalah email percobaan untuk memverifikasi konfigurasi SMTP pada aplikasi Bintar."
    message.attach(MIMEText(body, "plain"))
    
    try:
        print(f"Connecting to {mail_server}:{mail_port}...")
        with smtplib.SMTP(mail_server, mail_port) as server:
            server.starttls()
            print("Logging in...")
            server.login(mail_username, mail_password)
            print("Sending email...")
            server.sendmail(mail_from, recipient, message.as_string())
        print("SUCCESS: Email berhasil dikirim!")
    except Exception as e:
        print(f"ERROR: {str(e)}")
        print("\nCatatan: Jika menggunakan Gmail, pastikan Anda menggunakan 'App Password', bukan password email biasa.")

if __name__ == "__main__":
    test_email()
