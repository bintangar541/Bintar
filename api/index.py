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
    return {"status": "ok", "message": "Bintar Baseline is Running"}

@app.get("/debug")
async def debug_all():
    root_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    sys.path.insert(0, root_path)
    sys.path.insert(0, os.path.join(root_path, "backend"))
    
    results = {}
    
    # 1. Check Env
    db_url = os.getenv("DATABASE_URL", "NOT_FOUND")
    results["db_url_exists"] = db_url != "NOT_FOUND"
    results["db_url_type"] = "postgres" if db_url.startswith("postgres") else "other/sqlite"
    
    # 2. Check Import
    try:
        from backend.main import app as bintar_app
        results["bintar_app_import"] = "ok"
    except Exception as e:
        results["bintar_app_import"] = traceback.format_exc()

    # 3. Check DB Connection
    try:
        from backend.app.database.session import engine
        with engine.connect() as connection:
            from sqlalchemy import text
            connection.execute(text("SELECT 1"))
        results["db_connection"] = "ok"
    except Exception as e:
        results["db_connection"] = {
            "error": str(e),
            "traceback": traceback.format_exc()
        }
        
    return results

@app.get("/auth/register")
@app.post("/auth/register")
@app.options("/auth/register")
async def proxy_register():
    root_path = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    sys.path.insert(0, root_path)
    sys.path.insert(0, os.path.join(root_path, "backend"))
        
    try:
        from backend.main import app as bintar_app
        return {"info": "App started, check /debug for DB status"}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e), "traceback": traceback.format_exc()})
