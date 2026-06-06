from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.app.api import transactions, auth, goals

app = FastAPI(title="Bintar AI API", version="1.0.0")
print("UVICORN: Bintar API Reloaded - Resend Service Active")

# Include Routers
app.include_router(auth.router)
app.include_router(transactions.router)
app.include_router(goals.router)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to Bintar AI Financial Companion API"}

if __name__ == "__main__":
    import uvicorn
    # Triggering reload
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
