import os
import unicodedata
import re
import base64
from sentence_transformers import SentenceTransformer
from PIL import Image
from io import BytesIO
import numpy as np
import base64
from pinecone import Pinecone
from fastapi import FastAPI, UploadFile, File
from dotenv import load_dotenv
import os
from huggingface_hub import InferenceClient
from openai import OpenAI

import logging
from logging.handlers import RotatingFileHandler
import json
from datetime import datetime

load_dotenv()
app = FastAPI()

##api-key##
HF_TOKEN = os.getenv("HF_TOKEN")

##data#
INGREDIENT_DB = {
    "rice_noodles": {"unit": "100g", "calories": (105, 130)},
    "egg_noodles": {"unit": "100g", "calories": (130, 160)},
    "beef": {"unit": "100g", "calories": (220, 280)},
    "chicken": {"unit": "100g", "calories": (165, 210)},
    "pork": {"unit": "100g", "calories": (240, 300)},
    "fish": {"unit": "100g", "calories": (120, 160)},
    "shrimp": {"unit": "100g", "calories": (90, 120)},
    "tofu": {"unit": "100g", "calories": (70, 90)},
    "broth": {"unit": "100ml", "calories": (10, 30)},
    "vegetables": {"unit": "100g", "calories": (20, 40)},
    "oil": {"unit": "10ml", "calories": (80, 90)},
    "sauce": {"unit": "30g", "calories": (50, 80)}
}

DISH_DB = {
    "pho_bo": {
        "ingredients": {
            "rice_noodles": (150, 250),
            "beef": (80, 150),
            "broth": (300, 500),
            "vegetables": (30, 60)
        },
        "optional": ["oil"]
    },

    "bun_bo": {
        "ingredients": {
            "rice_noodles": (150, 230),
            "beef": (90, 160),
            "broth": (250, 400),
            "vegetables": (40, 80)
        },
        "optional": ["oil", "sauce"]
    },

    "com_tam": {
        "ingredients": {
            "rice_noodles": (200, 300),   # dùng như rice portion
            "pork": (100, 180),
            "vegetables": (50, 100)
        },
        "optional": ["oil", "sauce"]
    },

    "banh_mi": {
        "ingredients": {
            "pork": (80, 120),
            "vegetables": (40, 60),
            "sauce": (20, 40)
        },
        "optional": ["oil"]
    },

    "bun_cha": {
        "ingredients": {
            "rice_noodles": (150, 250),
            "pork": (120, 200),
            "vegetables": (50, 100),
            "broth": (200, 300)
        },
        "optional": ["oil"]
    }
}



embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

dish_keys = list(DISH_DB.keys())
dish_texts = [k.replace("_", " ") for k in dish_keys]

dish_embeddings = embedder.encode(dish_texts, normalize_embeddings=True)

client = OpenAI(
    base_url="https://router.huggingface.co/v1",
    api_key=HF_TOKEN,
)

def food_classification(img_64):
    img = img_64
    response = client.chat.completions.create(
    model="Qwen/Qwen2.5-VL-7B-Instruct:hyperbolic",
    messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": (
                            "Look at the picture and identify the dish.\n"
                            "⚠️ If the picture contains multiple dishes, a plate with mixed food, "
                            "or if the picture is not food, DO NOT guess.\n"
                            "In those cases, return JSON with dish='uncertain' and message='Please retake the photo with only one clear dish.'\n\n"
                            "JSON format:\n"
                            "```json\n"
                            "{\n"
                            '  "dish": "...",\n'
                            '  "ingredients": ["...", "..."],\n'
                            '  "confidence": "high | medium | low",\n'
                            '  "message": "..." \n'
                            "}\n"
                                "```"
                            )

                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{img}"
                        }
                    }
                ]
            }
        ],
        max_tokens=300,
    )

    return(response.choices[0].message.content)

def normalize_text(text):
    text = unicodedata.normalize("NFKD", text)
    text = "".join(c for c in text if not unicodedata.combining(c))
    text = text.lower()
    text = re.sub(r"[^a-z0-9\s]", " ", text)
    return text.strip()


def synthesize_dish(dish_name, dish_db, ingredient_db, ratio=0.25):
    if dish_name not in dish_db:
        return None

    dish = dish_db[dish_name]

    min_total = 0.0
    max_total = 0.0

    for ing, (min_amt, max_amt) in dish["ingredients"].items():
        if ing not in ingredient_db:
            continue

        cal_min, cal_max = ingredient_db[ing]["calories"]

        min_total += (min_amt / 100) * cal_min
        max_total += (max_amt / 100) * cal_max
    span = max_total - min_total
    new_min = min_total + span * ratio
    new_max = max_total - span * ratio
    return int(new_min), int(new_max)


@app.post("/scan_food")
async def scan_food(file: UploadFile = File(...)):
    image_bytes = await file.read()
    img_base64 = base64.b64encode(image_bytes).decode('utf-8')
    vlm_json_string = food_classification(img_base64)
    

    vlm_output = json.loads(vlm_json_string.strip('```json\n').strip('\n```'))
    if(vlm_output["dish"].lower() == "uncertain"):
        return {"reply": vlm_output["message"]}
    else:
        normalize_text(vlm_output["dish"])
        query = normalize_text(vlm_output["dish"])
        query_emb = embedder.encode([query], normalize_embeddings=True)
        sims = dish_embeddings @ query_emb[0]

        best_idx = int(np.argmax(sims))
        best_score = float(sims[best_idx])

        if best_score < 0.6:
            matched_dish = None
        else:
            matched_dish = dish_keys[best_idx]

        dish = matched_dish
        cal_range = synthesize_dish(dish, DISH_DB, INGREDIENT_DB)
        print(cal_range)
        return {
                "dish_name": vlm_output["dish"],
                "calories_range": cal_range,
                }
