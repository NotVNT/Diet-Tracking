import torch
import timm
import torch.nn as nn
import torchvision.transforms as T
from PIL import Image
from io import BytesIO
from fastapi import FastAPI, UploadFile, File
import os

app = FastAPI()

# --- Module-level model initialization (safe, graceful) ---
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# placeholders; will be set in try/except
vision_model = None
regressor = None
predictor = None
transform = None

def _load_models():
    global vision_model, regressor, predictor, transform
    try:
        # build transform now that function exists
        transform = get_image_transform()

        vision_model = load_feature_extractor().to(device)

        regressor = NutrientRegressor(input_dim=1280, output_dim=5).to(device)
        weights_path = os.path.join("diet-tracking", "chat_box", "model_weight", "nutrient_regressor_weights (1).pth")
        if os.path.exists(weights_path):
            regressor.load_state_dict(torch.load(weights_path, map_location=device))
        else:
            print(f"⚠️ Regressor weights not found at {weights_path}. Using randomly initialized regressor.")
        regressor.eval()

        predictor = NutrientPredictor(vision_model, regressor).to(device)
        predictor.eval()
        print("✅ Models loaded (or initialized). Ready for /scan_food")
    except Exception as e:
        vision_model = None
        regressor = None
        predictor = None
        print(f"🔴 Lỗi khi load models: {e}")


# Load on import (non-blocking-ish — may still be heavy depending on environment)
_load_models()

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

    def forward(self, x):
        with torch.no_grad():
            features = self.backbone(x)
        return self.regressor(features)
    
def predict_image(img_path, predictor, transform, device):
    image = Image.open(img_path).convert("RGB")
    tensor = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        preds = predictor(tensor)
    return preds.squeeze(0).cpu().numpy()


def predict_from_bytes(image_bytes: bytes, predictor, transform, device):
    """Preprocess image bytes and return numpy predictions from predictor."""
    try:
        image = Image.open(BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        raise ValueError(f"Invalid image bytes: {e}")

    tensor = transform(image).unsqueeze(0).to(device)
    with torch.no_grad():
        preds = predictor(tensor)
    return preds.squeeze(0).cpu().numpy()

@app.post("/scan_food")
async def scan_food(file: UploadFile = File(...)):
    image_bytes = await file.read()

    if predictor is None:
        return {"error": "Model not loaded on server. Check logs."}

    try:
        preds = predict_from_bytes(image_bytes, predictor, transform, device)
    except ValueError as e:
        return {"error": str(e)}
    except Exception as e:
        return {"error": f"Inference failed: {e}"}

    nutrient_columns = ['total_mass', 'total_calories', 'total_fat', 'total_carb', 'total_protein']
    result = {k: float(v) for k, v in zip(nutrient_columns, preds)}
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