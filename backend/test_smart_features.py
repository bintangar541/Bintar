import requests

BASE_URL = "http://localhost:8000"
TOKEN = "" # Fill this after login

def login():
    global TOKEN
    login_data = {"username": "user@bintar.ai", "password": "password123"}
    response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
    if response.status_code == 200:
        TOKEN = response.json()["access_token"]
        print("Login Successful")
    else:
        print(f"Login Failed: {response.text}")

def test_smart_input():
    headers = {"Authorization": f"Bearer {TOKEN}"}
    params = {"text": "Tadi makan sate 25 ribu pakai cash"}
    response = requests.post(f"{BASE_URL}/transactions/smart-input", params=params, headers=headers)
    print(f"Smart Input Response: {response.status_code}")
    print(response.json())

def test_import_bank():
    headers = {"Authorization": f"Bearer {TOKEN}"}
    content = """
    01/06/2026 TRANSFER DARI BUDI Rp 1.000.000
    02/06/2026 PEMBAYARAN TOKOPEDIA Rp 150.000
    03/06/2026 TARIK TUNAI ATM Rp 200.000
    """
    files = {'file': ('mutasi.txt', content)}
    response = requests.post(f"{BASE_URL}/transactions/import-bank", files=files, headers=headers)
    print(f"Import Bank Response: {response.status_code}")
    print(response.json())

if __name__ == "__main__":
    login()
    if TOKEN:
        test_smart_input()
        test_import_bank()
