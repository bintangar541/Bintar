
import smtplib
import os
from dotenv import load_dotenv

def test_smtp():
    load_dotenv(override=True)
    
    server_addr = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
    user = os.getenv('MAIL_USERNAME')
    password = os.getenv('MAIL_PASSWORD')
    port_tls = 587
    port_ssl = 465
    
    print(f"Testing with User: {user}")
    print(f"Password starts with: {password[:4]}...")

    # Try TLS (587)
    try:
        print("\nAttempting TLS (587)...")
        server = smtplib.SMTP(server_addr, port_tls, timeout=10)
        server.starttls()
        server.login(user, password)
        print("✅ TLS Login SUCCESS!")
        server.quit()
        return
    except Exception as e:
        print(f"❌ TLS Login FAILED: {e}")

    # Try SSL (465)
    try:
        print("\nAttempting SSL (465)...")
        server = smtplib.SMTP_SSL(server_addr, port_ssl, timeout=10)
        server.login(user, password)
        print("✅ SSL Login SUCCESS!")
        server.quit()
        return
    except Exception as e:
        print(f"❌ SSL Login FAILED: {e}")

if __name__ == "__main__":
    test_smtp()
