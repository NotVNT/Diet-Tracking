import timm
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision.transforms as T
from torchvision.models import efficientnet_b0
from PIL import Image
from io import BytesIO
import numpy as np
import io
from fastapi import FastAPI, UploadFile, File
import os

app = FastAPI()

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

def load_feature_extractor():
    model = timm.create_model("efficientnet_lite0", pretrained=True)

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

vision_model = load_feature_extractor().to(device)
regressor = NutrientRegressor(input_dim=1280, output_dim=5).to(device)

regressor.load_state_dict(torch.load("model_weight/nutrient_regressor_weights (1).pth", map_location=device))
regressor.eval()

predictor = NutrientPredictor(vision_model, regressor).to(device)
predictor.eval()

transform = get_image_transform()

@app.post("/scan_food")
async def scan_food(file: UploadFile = File(...)):
    image_bytes = await file.read()

    preds = predict_image(image_bytes, predictor, transform, device)

    nutrient_columns = ['total_mass', 'total_calories', 'total_fat', 'total_carb', 'total_protein']
    result = {k: float(v) for k, v in zip(nutrient_columns, preds)}
    print(result)
    return {"predictions": result}

if __name__ == "__main__":
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    vision_model = load_feature_extractor().to(device)
    regressor = NutrientRegressor(input_dim=1280, output_dim=5).to(device)
    regressor.load_state_dict(torch.load("diet-tracking/chat_box/model_weight/nutrient_regressor_weights (1).pth", map_location=device))
    regressor.eval()

    predictor = NutrientPredictor(vision_model, regressor).to(device)
    predictor.eval()

    transform = get_image_transform()
    prediction = predict_image("diet-tracking/chat_box/testing_image/Screenshot 2025-11-21 161032.png", predictor, transform, device)

    nutrient_columns = ['total_mass', 'total_calories', 'total_fat', 'total_carb', 'total_protein']
    result = dict(zip(nutrient_columns, prediction))
    print(result)