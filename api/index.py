import os
import sys
import traceback
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"status": "ok", "message": "Bintar Minimal API is Running"}

@app.get("/debug")
async def debug_imports():
    root_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    sys.path.insert(0, root_path)
    sys.path.insert(0, os.path.join(root_path, "backend"))
    
    results = {}
    try:
        import sqlalchemy
        results["sqlalchemy"] = "ok"
    except Exception as e:
        results["sqlalchemy"] = str(e)
        
    try:
        import groq
        results["groq"] = "ok"
    except Exception as e:
        results["groq"] = str(e)

    try:
        from backend.main import app as bintar_app
        results["bintar_app"] = "ok"
    except Exception as e:
        results["bintar_app"] = {
            "error": str(e),
            "traceback": traceback.format_exc()
        }
        
    return results

@app.get("/auth/register")
@app.post("/auth/register")
@app.options("/auth/register")
async def proxy_register():
    # If we are here, at least this file works.
    # Let's try to load the real app on the fly
    root_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    if root_path not in sys.path:
        sys.path.insert(0, root_path)
    if os.path.join(root_path, "backend") not in sys.path:
        sys.path.insert(0, os.path.join(root_path, "backend"))
        
    try:
        from backend.main import app as bintar_app
        return {"status": "import_ok"}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e), "traceback": traceback.format_exc()})
