import os
import sys

# Add project root and backend folder to sys.path
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)
sys.path.insert(0, os.path.join(root, "backend"))

# Now we can import the app directly from backend.main
from backend.main import app
