from fastapi import FastAPI
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

@app.get("/auth/register")
@app.options("/auth/register")
async def dummy_register():
    return {"message": "Endpoint exists"}
