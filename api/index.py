import os
import sys

# Get the absolute path to the project root
# __file__ is /var/task/api/index.py or similar
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)
sys.path.insert(0, os.path.join(root, "backend"))

# Now we can import main and it can import app.api
from main import app
