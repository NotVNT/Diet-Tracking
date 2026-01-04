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
from fastapi import FastAPI, UploadFile, File, Form, Body
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
    "sauce": {"unit": "30g", "calories": (50, 80)},
    "rice": {"unit": "100g", "calories": (130, 150)},
    "soy_sauce": {"unit": "10ml", "calories": (8, 12)},
    "pepper": {"unit": "5g", "calories": (10, 15)},
    "mushroom": {"unit": "100g", "calories": (25, 35)},
    "tofu_skin": {"unit": "100g", "calories": (50, 70)},
    "garlic": {"unit": "10g", "calories": (15, 20)}  # mới thêm
}



DISH_DB = {
    "beef_bo": {  # phở bò
        "alias": ["phở bò", "pho bo", "beef noodle soup"],
        "ingredients": {
            "rice_noodles": (150, 250),
            "beef": (80, 150),
            "broth": (300, 500),
            "vegetables": (30, 60)
        },
        "optional": ["oil"]
    },

    "hue_beef_noodle_soup": {  # bún bò huế
        "alias": ["bún bò huế", "bun bo hue"],
        "ingredients": {
            "rice_noodles": (150, 230),
            "beef": (90, 160),
            "broth": (250, 400),
            "vegetables": (40, 80)
        },
        "optional": ["oil", "sauce"]
    },

    "broken_rice": {  # cơm tấm
        "alias": ["cơm tấm", "com tam", "broken rice"],
        "ingredients": {
            "rice": (200, 300),
            "pork": (100, 180),
            "vegetables": (50, 100)
        },
        "optional": ["oil", "sauce"]
    },

    "vietnamese_baguette_sandwich": {  # bánh mì
        "alias": ["bánh mì", "banh mi", "vietnamese sandwich"],
        "ingredients": {
            "pork": (80, 120),
            "vegetables": (40, 60),
            "sauce": (20, 40)
        },
        "optional": ["oil"]
    },

    "grilled_pork_with_vermicelli": {  # bún thịt nướng
        "alias": ["bún thịt nướng", "bun thit nuong"],
        "ingredients": {
"rice_noodles": (150, 250),
            "pork": (120, 200),
            "vegetables": (50, 100),
            "broth": (200, 300)
        },
        "optional": ["oil"]
    },

    "crab_noodle_soup": {  # bún riêu
        "alias": ["bún riêu", "bun rieu"],
        "ingredients": {
            "rice_noodles": (150, 250),
            "shrimp": (50, 100),
            "pork": (50, 100),
            "broth": (300, 500),
            "vegetables": (40, 80)
        },
        "optional": ["oil", "sauce"]
    },

    "southern_noodle_soup": {  # hủ tiếu
        "alias": ["hủ tiếu", "hu tieu", "southern noodle soup"],
        "ingredients": {
            "rice_noodles": (150, 250),
            "pork": (80, 150),
            "shrimp": (50, 100),
            "broth": (300, 500),
            "vegetables": (30, 60)
        },
        "optional": ["oil"]
    },

    "chicken_glass_noodle_soup": {  # miến gà
        "alias": ["miến gà", "mien ga"],
        "ingredients": {
            "egg_noodles": (150, 200),
            "chicken": (80, 150),
            "broth": (300, 500),
            "vegetables": (30, 60)
        },
        "optional": ["oil"]
    },

    "vietnamese_pancake": {  # bánh xèo
        "alias": ["bánh xèo", "banh xeo"],
        "ingredients": {
            "shrimp": (50, 100),
            "pork": (50, 100),
            "vegetables": (50, 100)
        },
        "optional": ["oil", "sauce"]
    },

    "spring_rolls": {  # gỏi cuốn
        "alias": ["gỏi cuốn", "goi cuon", "spring rolls"],
        "ingredients": {
            "shrimp": (40, 80),
            "pork": (40, 80),
            "vegetables": (60, 100),
            "rice_noodles": (50, 100)
        },
        "optional": ["sauce"]
    },

    "chicken_soup": {  # cháo gà
        "alias": ["cháo gà", "chao ga", "chicken porridge"],
        "ingredients": {
            "rice": (100, 200),
            "chicken": (80, 150),
            "broth": (300, 500),
            "vegetables": (30, 60)
        },
        "optional": ["oil"]
    },

    "steamed_rice_rolls": {  # bánh cuốn
        "alias": ["bánh cuốn", "banh cuon", "steamed rice rolls"],
        "ingredients": {
            "rice_noodles": (100, 150),
            "pork": (50, 100),
            "vegetables": (40, 80)
        },
        "optional": ["sauce", "oil"]
    },

    "braised_fish": {  # cá kho
        "alias": ["cá kho", "ca kho", "braised fish"],
        "ingredients": {
            "fish": (150, 250),
            "soy_sauce": (10, 20),
            "pepper": (2, 5),
            "oil": (10, 20),
            "vegetables": (30, 60)
        },
        "optional": ["sauce"]
    },

    "vegetarian_soup": {  # súp chay
        "alias": ["súp chay", "sup chay", "vegetarian soup"],
        "ingredients": {
            "mushroom": (80, 150),
            "tofu": (50, 100),
            "tofu_skin": (50, 100),
            "vegetables": (100, 200),
            "broth": (300, 500)
},
        "optional": ["oil", "sauce"]
    },
    "fried_fish_with_garlic" : {  # Cá chiên tỏi
        "alias": ["cá chiên tỏi", "ca chien toi", "fried fish with garlic"],
        "ingredients": {
            "fish": (150, 250),
            "garlic": (5, 15),
            "oil": (10, 20),
            "vegetables": (30, 60)
        },
        "optional": ["sauce"]
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

def good_or_bad(allergy, food_name):
    response = client.chat.completions.create(
        model="Qwen/Qwen3-4B-Instruct-2507:nscale",
        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": f"""người dùng có dị ứng {allergy}.
                        Hãy xem tên tiếng anh món ăn được gửi: {food_name}
                        - Nếu món ăn không phù hợp với người dùng → trả lời **không**. 
                        - Nếu món ăn phù hợp với người dùng → trả lời **có**. 
                        Chỉ trả lời đúng một trong hai: **có**, **không**.
                        """
                    }
                ]
            }
        ]
    )

    return response.choices[0].message.content

def food_classification(img_64):
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
                            "In those cases, return JSON with ***dish='uncertain'*** and message='Please retake the photo with only one clear dish.'\n\n"
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
                            "url": f"data:image/jpeg;base64,{img_64}"
                        }
}
                ]
            }
        ],
        max_tokens=300,
    )

    import json
    result = json.loads(response.choices[0].message.content.strip("```json").strip("```"))
    return result

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
async def scan_food(file: UploadFile = File(...),
                    allergy: str | None = Form(None),):
    image_bytes = await file.read()
    img_base64 = base64.b64encode(image_bytes).decode('utf-8')

    vlm_output = food_classification(img_base64)
    flag = good_or_bad(allergy, vlm_output["dish"])

    if(vlm_output["dish"].lower() == "uncertain"):
        return {"reply": "Bức ảnh đồ ăn chưa nằm chính giữa khung hình."}
    else:
        normalize_text(vlm_output["dish"])
        query = normalize_text(vlm_output["dish"])
        query_emb = embedder.encode([query], normalize_embeddings=True)
        sims = dish_embeddings @ query_emb[0]

        best_idx = int(np.argmax(sims))
        best_score = float(sims[best_idx])

        if best_score < 0.2:
            matched_dish = None
        else:
            matched_dish = dish_keys[best_idx]

        dish = matched_dish
        cal_range = synthesize_dish(dish, DISH_DB, INGREDIENT_DB)
        print(cal_range)
        if(flag.lower() == "có"):
            print(vlm_output["dish"])
            return {
                    # "dish_name": vlm_output["dish"],
                    "calories_range": cal_range,
                    "warning": "none"
                    }
        else:
            print(vlm_output["dish"])
            return {
                    # "dish_name": vlm_output["dish"],
                    "calories_range": cal_range,
                    "warning": "món ăn có chứa chất gây dị ứng đối với bạn, hãy cẩn thận."
                    }