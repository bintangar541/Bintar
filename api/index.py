import sys
import os

# Add the root directory and backend directory to sys.path
# Vercel's root directory is where vercel.json is located
pwd = os.path.dirname(os.path.dirname(__file__))
sys.path.insert(0, pwd)
sys.path.insert(0, os.path.join(pwd, "backend"))

from backend.main import app
