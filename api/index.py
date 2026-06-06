import os
import sys
import traceback
from fastapi import FastAPI
from fastapi.responses import JSONResponse

# Add paths
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)
sys.path.insert(0, os.path.join(root, "backend"))

app = FastAPI()

try:
    from main import app as bintar_app
    app.mount("/", bintar_app)
except Exception as e:
    @app.get("/{full_path:path}")
    @app.post("/{full_path:path}")
    @app.options("/{full_path:path}")
    async def catch_all(full_path: str):
        return JSONResponse(
            status_code=500,
            content={
                "error": "Initialization Failed",
                "detail": str(e),
                "traceback": traceback.format_exc()
            }
        )
