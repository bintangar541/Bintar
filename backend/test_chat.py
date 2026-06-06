from groq import Groq
import os
from dotenv import load_dotenv

load_dotenv(override=True)
client = Groq(api_key=os.getenv("GROQ_API_KEY"))

try:
    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": "Halo, jawab singkat: 1+1 berapa?"}],
        temperature=0.7,
        max_tokens=100,
    )
    print("SUCCESS:", response.choices[0].message.content)
except Exception as e:
    print("ERROR:", str(e))
