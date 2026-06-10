import os
import sys
import traceback
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

# Add project root and backend to path
root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, root)
sys.path.insert(0, os.path.join(root, "backend"))

try:
    from backend.main import app as bintar_app
except Exception:
    # If it fails early, we create a dummy app to show the error
    bintar_app = FastAPI()

app = FastAPI()

@app.middleware("http")
async def catch_exceptions_middleware(request: Request, call_next):
    try:
        return await call_next(request)
    except Exception as e:
        err_msg = traceback.format_exc()
        return JSONResponse(
            status_code=500,
            content={
                "error": str(e),
                "traceback": err_msg,
                "path": request.url.path,
                "method": request.method
            }
        )

# Mount the real app
app.mount("/", bintar_app)

@app.get("/debug-internal")
async def debug_internal():
    results = {"status": "running"}
    try:
        from backend.app.database.session import engine
        from sqlalchemy import text
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        results["db"] = "ok"
    except Exception as e:
        results["db"] = str(e)
    return results
