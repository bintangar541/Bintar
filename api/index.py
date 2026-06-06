import os
import sys

# Get the absolute path to the project root
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)
sys.path.insert(0, os.path.join(root, "backend"))

# Import the refactored FastAPI app
from backend.main import app
