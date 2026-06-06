import os
import sys

# Add project root to sys.path
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)

# Now we can import from the backend package
from backend.main import app
