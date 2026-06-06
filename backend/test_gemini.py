import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()
try:
    genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
    models = genai.list_models()
    supported = [m.name for m in models if "generateContent" in m.supported_generation_methods]
    with open("models.txt", "w") as f:
        f.write("\n".join(supported))
except Exception as e:
    with open("models.txt", "w") as f:
        f.write("ERROR: " + str(e))
