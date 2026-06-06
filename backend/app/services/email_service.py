
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv(override=True)

class EmailService:
    @staticmethod
    async def send_reset_password_email(email_to: str, token: str):
        mail_username = os.getenv("MAIL_USERNAME")
        mail_password = os.getenv("MAIL_PASSWORD")
        mail_from = os.getenv("MAIL_FROM")
        mail_server = os.getenv("MAIL_SERVER", "smtp.gmail.com")
        mail_port = int(os.getenv("MAIL_PORT", 587))
        app_url = os.getenv("APP_URL", "http://localhost:52039")
        
        # Reset Link
        reset_link = f"{app_url}/#/reset-password?token={token}"

        # Create message
        message = MIMEMultipart("alternative")
        message["Subject"] = "Atur Ulang Kata Sandi Bintar"
        message["From"] = f"Bintar Support <{mail_from}>"
        message["To"] = email_to

        html = f"""
        <html>
          <body style="font-family: sans-serif; padding: 20px;">
            <h2 style="color: #10b981;">Atur Ulang Kata Sandi Bintar</h2>
            <p>Halo,</p>
            <p>Anda menerima email ini karena kami menerima permintaan reset kata sandi untuk akun Bintar Anda.</p>
            <p style="margin: 30px 0;">
              <a href="{reset_link}" 
                 style="background-color: #10b981; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold;">
                Atur Ulang Kata Sandi Sekarang
              </a>
            </p>
            <p>Penting: Link ini hanya berlaku selama 1 jam.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="font-size: 12px; color: #666;">Jika Anda tidak merasa melakukan permintaan ini, abaikan email ini.</p>
          </body>
        </html>
        """
        
        message.attach(MIMEText(html, "html"))

        try:
            # Using SMTP_SSL on 465 is often more reliable
            print(f"SMTP: Sending email to {email_to} via port 465 SSL...")
            with smtplib.SMTP_SSL(mail_server, 465, timeout=15) as server:
                server.login(mail_username, mail_password)
                server.sendmail(mail_from, email_to, message.as_string())
            
            log_msg = f"SUCCESS: Email sent to {email_to} via Gmail SMTP"
            print(log_msg)
            with open("email_debug.log", "a") as f:
                f.write(f"{datetime.now()}: {log_msg}\n")
            return True
        except Exception as e:
            # Fallback to TLS on 587
            print(f"SSL Failed ({e}). Trying TLS on port 587...")
            try:
                with smtplib.SMTP(mail_server, mail_port, timeout=15) as server:
                    server.starttls()
                    server.login(mail_username, mail_password)
                    server.sendmail(mail_from, email_to, message.as_string())
                return True
            except Exception as e2:
                log_msg = f"ERROR sending email: {str(e2)}"
                print(log_msg)
                with open("email_debug.log", "a") as f:
                    f.write(f"{datetime.now()}: {log_msg}\n")
                return False

email_service = EmailService()
