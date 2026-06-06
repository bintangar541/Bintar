import requests

BASE_URL = "http://localhost:8000"

def test_goals():
    # Register a new user for testing
    register_data = {
        "email": "tester@bintar.ai",
        "full_name": "Tester",
        "password": "testerpassword"
    }
    response = requests.post(f"{BASE_URL}/auth/register", json=register_data)
    print(f"Register: {response.status_code}")
    
    # Login
    login_data = {"username": "tester@bintar.ai", "password": "testerpassword"}
    response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
    if response.status_code != 200:
        print(f"Login failed: {response.text}")
        return
    
    token = response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Create a goal
    goal_data = {
        "title": "Tabungan Menikah",
        "target_amount": 100000000,
        "current_amount": 5000000,
        "category": "Mimpi",
        "icon": "💍"
    }
    response = requests.post(f"{BASE_URL}/goals/", json=goal_data, headers=headers)
    print(f"Create Goal: {response.status_code}")
    print(response.json())

    # Get goals
    response = requests.get(f"{BASE_URL}/goals/", headers=headers)
    print(f"Get Goals: {response.status_code}")
    print(response.json())

if __name__ == "__main__":
    test_goals()
