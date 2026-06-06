import sys
import os

# Add the root directory and backend directory to sys.path
# Vercel's root directory is where vercel.json is located
root_dir = os.path.dirname(os.path.dirname(__file__))
sys.path.append(root_dir)
sys.path.append(os.path.join(root_dir, "backend"))

from backend.main import app
