import os
import sys

# Add project root and backend to path
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)
sys.path.insert(0, os.path.join(root, "backend"))

# Import the full Bintar FastAPI app
from backend.main import app
