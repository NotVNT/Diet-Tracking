import os
import torch
import timm
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision.transforms as T
from sklearn.metrics.pairwise import cosine_similarity
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
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY_FOR_VISION")
HF_TOKEN = os.getenv("HF_TOKEN")

##pinecone##
pc = Pinecone(api_key=PINECONE_API_KEY)

index_name = "testing-db"

# if index_name not in [idx["name"] for idx in pc.list_indexes()]:
#     pc.create_index(name=index_name, dimension=384, metric="cosine", spec=ServerlessSpec(cloud="aws", region="us-east-1"))
#     print(f"Tạo bảng {index_name}")

index = pc.Index(index_name)

food_content = [
    {
        "id": "1",
        "food_name": "apple",
        "tag": ["Apple", "fresh apple", "raw apple", "whole apple"],
        "calories": "52kcal",
        "fat": "0.17g",
        "protein": "0.26g",
        "carb": "13.8g"
    },
    {
        "id": "2",
        "food_name": "pomelo",
        "tag": ["Pomelo", "fresh pomelo", "raw pomelo", "whole pomelo"],
        "calories": "32kcal",
        "fat": "0.1g",
        "protein": "0.63g",
        "carb": "8.08g"
    },
    {
        "id": "3",
        "food_name": "raspberry",
        "tag": ["Raspberry", "fresh raspberry", "raw raspberry", "whole raspberry cluster"],
        "calories": "43kcal",
        "fat": "0.49g",
        "protein": "1.39g",
        "carb": "9.61g"
    },
    {
        "id": "4",
        "food_name": "watermelon",
        "tag": ["Watermelon", "fresh watermelon", "raw watermelon", "whole watermelon"],
        "calories": "31.3kcal",
        "fat": "0.1g",
        "protein": "0.66g",
        "carb": "7.73g"
    },
    {
        "id": "5",
        "food_name": "mango",
        "tag": ["Mango", "fresh mango", "ripe mango", "raw mango", "whole mango"],
        "calories": "60kcal",
        "fat": "0.38g",
        "protein": "0.82g",
        "carb": "15g"
    },
    {
        "id": "6",
        "food_name": "durian",
        "tag": ["Durian", "fresh durian", "ripe durian", "raw durian", "whole durian"],
        "calories": "137kcal",
        "fat": "1.4g",
        "protein": "2.4g",
        "carb": "28.4g"
    },
    {
        "id": "7",
        "food_name": "dragon fruit",
        "tag": ["Dragon fruit", "fresh dragon fruit", "raw dragon fruit", "whole dragon fruit"],
        "calories": "60kcal",
        "fat": "0.1g",
        "protein": "1g",
        "carb": "14g"
    },
    {
        "id": "8",
        "food_name": "mangosteen",
        "tag": ["Mangosteen", "fresh mangosteen", "raw mangosteen", "whole mangosteen"],
        "calories": "73kcal",
        "fat": "0.58g",
        "protein": "0.41g",
"carb": "18g"
    },
    {
        "id": "9",
        "food_name": "banana",
        "tag": ["Banana", "fresh banana", "raw banana", "whole banana", "ripe banana"],
        "calories": "89kcal",
        "fat": "0.33g",
        "protein": "1.09g",
        "carb": "22.8g"
    },
    {
        "id": "10",
        "food_name": "pear",
        "tag": ["Pear", "fresh pear", "raw pear", "whole pear"],
        "calories": "57kcal",
        "fat": "0.14g",
        "protein": "0.36g",
        "carb": "15.2g"
    },
    {
        "id": "11",
        "food_name": "avocado",
        "tag": ["Avocado", "fresh avocado", "raw avocado", "whole avocado"],
        "calories": "153kcal",
        "fat": "14.4g",
        "protein": "1.9g",
        "carb": "8.5g",
    }
]

extractor = InferenceClient(model="sentence-transformers/all-MiniLM-L6-v2")
def get_embedding(text: str):
  return extractor.feature_extraction(text).tolist()
##--------##

##main_logic##
def is_in_domain(new_emb, db_emb, threshold=0.65):
    sims = cosine_similarity(new_emb.reshape(1, -1), db_emb)
    max_sim = sims.max()
    return max_sim >= threshold, max_sim
##----------##

##qwen##
client = OpenAI(
    base_url="https://router.huggingface.co/v1",
    api_key=HF_TOKEN,
)

def food_or_not(img_base64):
    messages = [
    {"role": "system", "content": """Hãy xem qua bức ảnh người dùng gửi, bức ảnh có phải là đồ mà con người ăn hay uống được hay không.
    Nếu được thì trả về **FOOD**, không được thì trả về **NOT_FOOD**. Không cần giải thích thêm."""},
    {"role": "user", "content":
        [
            {"type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{img_base64}"}},
        ]
    }]

    completion = client.chat.completions.create(
    model="Qwen/Qwen2.5-VL-7B-Instruct",
    messages=messages,)

    return(completion.choices[0].message.content)

def predict_correction(img_base64):

    messages = [
    {"role": "system", "content": """Cho mình biết tên về thực phẩm hoặc nước uống hoặc cả hai nếu có trong bức ảnh này. Và cho mình từ khóa đơn giản dựa trên hình ảnh để search vectorbase. Từ khóa nên được trả về như sau: Từ khóa: {từ khóa}"""},
    {"role": "user", "content":
    [
        {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_base64}"}},
    ]}]

    completion = client.chat.completions.create(
        model="Qwen/Qwen2.5-VL-7B-Instruct",
        messages=messages,)

    return(completion.choices[0].message.content)

##----##

##efficientnet##
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def get_image_transform():
    mean = [0.5, 0.5, 0.5]
    std  = [0.5, 0.5, 0.5]

    transform = T.Compose([
        T.Resize(256),
        T.CenterCrop(224),
        T.ToTensor(),
        T.Normalize(mean=mean, std=std),
    ])
    return transform

def load_feature_extractor(model):
    model.classifier = nn.Identity()

    model.eval()
    return model
def extract_embedding(rgb_bytes, transform, vision_model, device):
    image = Image.open(BytesIO(rgb_bytes)).convert("RGB")

    img_tensor = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        embedding = vision_model(img_tensor)

    return embedding.squeeze(0).cpu().numpy()

class NutrientRegressor(nn.Module):
    def __init__(self, input_dim=1280, output_dim=5):
        super(NutrientRegressor, self).__init__()
        self.regressor = nn.Sequential(
            nn.Linear(input_dim, 512),
            nn.SiLU(),
            nn.BatchNorm1d(512),
            nn.Dropout(0.3),

            nn.Linear(512, 256),
            nn.SiLU(),
            nn.BatchNorm1d(256),
            nn.Dropout(0.2),

            nn.Linear(256, 128),
            nn.SiLU(),
            nn.Dropout(0.1),

            nn.Linear(128, output_dim)
        )

    def forward(self, x):
        return self.regressor(x)

class NutrientPredictor(nn.Module):
    def __init__(self, backbone, regressor):
        super(NutrientPredictor, self).__init__()
        self.backbone = backbone
        self.regressor = regressor

    def forward(self, x): # Changed input argument from pixel_values to x
        with torch.no_grad():
            features = self.backbone(x) # Pass the tensor directly; removed .pooler_output
        return self.regressor(features)

def predict_image(img_bytes, predictor, transform, device):
    image = Image.open(BytesIO(img_bytes)).convert("RGB")
    tensor = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        preds = predictor(tensor)
    return preds.squeeze(0).cpu().numpy()

model = timm.create_model("efficientnet_lite0", pretrained=True)
vision_model = load_feature_extractor(model).to(device)
regressor = NutrientRegressor(input_dim=1280, output_dim=5).to(device)

regressor.load_state_dict(torch.load("model_weight/nutrient_regressor_weights (3).pth", map_location=device))
regressor.eval()

predictor = NutrientPredictor(vision_model, regressor).to(device)
predictor.eval()

transform = get_image_transform()
db_emb = np.load("embedding_of_database/embeddings.npy")

##efficientnet##


@app.post("/scan_food")
async def scan_food(file: UploadFile = File(...)):
    ##Logic mới là nếu người dùng gửi bức ảnh là không phải là thực phẩm thì endpoint sẽ trả về là NOT_FOOD, còn lại vẫn như cũ
    image_bytes = await file.read()
    img_base64 = base64.b64encode(image_bytes).decode('utf-8')
    if food_or_not(img_base64) == "FOOD":
        print("FOOD")
        new_emb = extract_embedding(image_bytes, transform, vision_model, device)
        in_domain, score = is_in_domain(new_emb, db_emb)
        if(in_domain == True):
            prediction = predict_image(image_bytes, predictor, transform, device)
            new_emb = extract_embedding(image_bytes, transform, vision_model, device)
            nutrient_columns = ['total_mass', 'total_calories', 'total_fat', 'total_carb', 'total_protein']
            result = dict(zip(nutrient_columns, prediction))
            print(in_domain)
            print(result)
            return {
                "total_calories": str(float(result["total_calories"])),
                "total_fat": str(float(result["total_fat"])),
                "total_carb": str(float(result["total_carb"])),
                "total_protein": str(float(result["total_protein"])),
            }
        else:
            print(in_domain)
            query = predict_correction(img_base64)
            print(query)
            query_embedding = get_embedding(query)
            results = index.query(
            vector=query_embedding,
            top_k=1,
            include_metadata=True
            )
            # print(results)

            if results["matches"] and len(results["matches"]) > 0:
                return {
                    "total_calories": results["matches"][0]["metadata"]["calories"],
                    "total_fat": results["matches"][0]["metadata"]["fat"],
                    "total_carb": results["matches"][0]["metadata"]["carb"],
                    "total_protein": results["matches"][0]["metadata"]["protein"],
                }
            else:
                return {"error": "No matching food found"}
    else:
        return {"NOT_FOOD"}


if __name__ == "__main__":
    # img_path = "diet-tracking/chat_box/testing_image/OIP.png"

    # image = Image.open(img_path).convert("RGB")

    # with open(img_path, "rb") as f:
    #     image_bytes = f.read()

    # img_base64 = base64.b64encode(image_bytes).decode('utf-8')
    # db_emb = np.load("diet-tracking/chat_box/embedding_of_database/embeddings.npy")
    # if food_or_not(img_base64) == "FOOD":
    #     new_emb = extract_embedding(image_bytes, transform, vision_model, device)
    #     in_domain, score = is_in_domain(new_emb, db_emb)
    #     if(in_domain == True):
    #         prediction = predict_image(image_bytes, predictor, transform, device)
    #         new_emb = extract_embedding(image_bytes, transform, vision_model, device)
    #         nutrient_columns = ['total_mass', 'total_calories', 'total_fat', 'total_carb', 'total_protein']
    #         result = dict(zip(nutrient_columns, prediction))
    #         print(in_domain)
    #         print(result)
    #     else:
    #         query = predict_correction(img_base64)
    #         print(query)
    #         query_embedding = get_embedding(query)
    #         results = index.query(
    #         vector=query_embedding,
    #         top_k=1,
    #         include_metadata=True
    #         )
    #         nutritional_values = []

    #         for match in results["matches"]:
    #             nutritional_values.append(
    #             {'total_calories':match["metadata"]["calories"],
    #             'total_fat':match["metadata"]["fat"],
    #             'total_protein':match["metadata"]["protein"],
    #             'total_carb':match["metadata"]["carb"]}
    #             )
#         print(match["metadata"]["food_name"], "-", match["score"])
    #         print(nutritional_values)
    # else:
        print("NOT_FOOD")

    #     query = "apple 2"
    #     query_embedding = get_embedding(query)
    #     results = index.query(
    #     vector=query_embedding,
    #     top_k=1,
    #     include_metadata=True
    # )

    # for match in results["matches"]:
    #     print(match["metadata"]["food_name"], "-", match["score"])
