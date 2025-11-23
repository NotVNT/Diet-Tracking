from fastapi import FastAPI, Form, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
from fastapi import FastAPI, UploadFile, File, Form
from pyzbar.pyzbar import decode
from PIL import Image
import requests
import io
import os
from dotenv import load_dotenv

load_dotenv()
app = FastAPI()

@app.post("/get_product_info")
async def get_product_info(barcode: str = Form(...)):
    """
    Endpoint chính: Nhận mã barcode từ Flutter (đã quét bằng ML Kit)
    và trả về thông tin sản phẩm từ OpenFoodFacts
    """
    print(f"\n{'='*60}")
    print(f"🔵 [INFO] Nhận barcode từ Flutter: {barcode}")
    
    url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
    print(f"🔵 [INFO] Đang gọi OpenFoodFacts API...")
    
    try:
        resp = requests.get(url, timeout=10).json()
        
        status = resp.get('status')
        print(f"🔵 [INFO] API status: {status}")
        
        if status != 1:
            print(f"🔴 [WARNING] Sản phẩm không tồn tại trong OpenFoodFacts")
            return {
                "barcode": barcode,
                "product": None,
                "message": "Sản phẩm không có trong database OpenFoodFacts"
            }

        product = resp.get("product", {})
        
        # Log thông tin sản phẩm
        product_name = product.get('product_name', 'N/A')
        brands = product.get('brands', 'N/A')
        nutriments = product.get('nutriments', {})
        calories = nutriments.get('energy-kcal', 0)
        protein = nutriments.get('proteins', 0)
        carbs = nutriments.get('carbohydrates', 0)
        fat = nutriments.get('fat', 0)
        
        print(f"🟢 [SUCCESS] Tìm thấy sản phẩm!")
        print(f"   📦 Tên: {product_name}")
        print(f"   🏷️  Thương hiệu: {brands}")
        print(f"   🔥 Calories: {calories} kcal")
        print(f"   🥩 Protein: {protein}g")
        print(f"   🍚 Carbs: {carbs}g")
        print(f"   🧈 Fat: {fat}g")
        print(f"{'='*60}\n")
        
        return {
            "barcode": barcode,
            "product": product
        }
        
    except requests.Timeout:
        print(f"🔴 [ERROR] Timeout khi gọi OpenFoodFacts API")
        return {
            "error": "Timeout khi tra cứu sản phẩm"
        }
    except Exception as e:
        print(f"🔴 [ERROR] Lỗi: {str(e)}")
        return {
            "error": f"Lỗi khi tra cứu sản phẩm: {str(e)}"
        }

@app.post("/scan_barcode")
async def scan_barcode(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes))

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)
model_gemini = genai.GenerativeModel('gemini-2.5-flash-lite')

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    disease: str
    allergy: str
    goal: str

def analyze_product(disease, allergy, goal, product_name, calories, protein, Carbs, fat):
    guidance_prompt = f"Hãy kiểm tra xem món ăn {product_name} có lượng dinh dưỡng bao gồm calories: {calories}, protein: {protein}, Carbs: {Carbs}, fat: {fat} có phù hợp với bệnh lí: {disease}, dị ứng: {allergy} và goal: {goal} và hãy đưa ra nhận xét của bạn của món ăn trên để nó phù hợp với thông tin của người dùng. Nhớ nói ngắn gọn nhưng súc tích và hãy nhớ nói một cách nhẹ nhàng"

    response = model_gemini.generate_content(guidance_prompt)
    raw = response.text.strip()
    return raw

app = FastAPI()

@app.post("/get_product_info")
async def get_product_info(barcode: str = Form(...)):
    """
    Endpoint chính: Nhận mã barcode từ Flutter (đã quét bằng ML Kit)
    và trả về thông tin sản phẩm từ OpenFoodFacts
    """
    print(f"\n{'='*60}")
    print(f"🔵 [INFO] Nhận barcode từ Flutter: {barcode}")
    
    url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
    print(f"🔵 [INFO] Đang gọi OpenFoodFacts API...")
    
    try:
        resp = requests.get(url, timeout=10).json()
        
        status = resp.get('status')
        print(f"🔵 [INFO] API status: {status}")
        
        if status != 1:
            print(f"🔴 [WARNING] Sản phẩm không tồn tại trong OpenFoodFacts")
            return {
                "barcode": barcode,
                "product": None,
                "message": "Sản phẩm không có trong database OpenFoodFacts"
            }

        product = resp.get("product", {})
        
        # Log thông tin sản phẩm
        product_name = product.get('product_name', 'N/A')
        brands = product.get('brands', 'N/A')
        nutriments = product.get('nutriments', {})
        calories = nutriments.get('energy-kcal', 0)
        protein = nutriments.get('proteins', 0)
        carbs = nutriments.get('carbohydrates', 0)
        fat = nutriments.get('fat', 0)
        
        print(f"🟢 [SUCCESS] Tìm thấy sản phẩm!")
        print(f"   📦 Tên: {product_name}")
        print(f"   🏷️  Thương hiệu: {brands}")
        print(f"   🔥 Calories: {calories} kcal")
        print(f"   🥩 Protein: {protein}g")
        print(f"   🍚 Carbs: {carbs}g")
        print(f"   🧈 Fat: {fat}g")
        print(f"{'='*60}\n")
        

        reply = (analyze_product("không có", "không có", "giữ cân", product.get("product_name"), product.get("nutriments", {}).get("energy-kcal"), product.get("nutriments", {}).get("protein"), product.get("nutriments", {}).get("carbohydrates_serving"), product.get("nutriments", {}).get("fat")))

        print(reply)

        return {
            "barcode": barcode,
            "reply": reply
        }
        
    except requests.Timeout:
        print(f"🔴 [ERROR] Timeout khi gọi OpenFoodFacts API")
        return {
            "error": "Timeout khi tra cứu sản phẩm"
        }
    except Exception as e:
        print(f"🔴 [ERROR] Lỗi: {str(e)}")
        return {
            "error": f"Lỗi khi tra cứu sản phẩm: {str(e)}"
        }

# @app.post("/scan_barcode")
# async def scan_barcode(file: UploadFile = File(...)):
#     image_bytes = await file.read()
#     image = Image.open(io.BytesIO(image_bytes))

#     results = decode(image)
#     if not results:
#         return {"error": "Không tìm thấy barcode"}

#     barcode = results[0].data.decode("utf-8")

#     url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
#     resp = requests.get(url).json()

#     product = resp.get("product", None)
#     if not product:
#         print("Không tìm thấy thông tin sản phẩm tron OpenFoodFact")

#     print("\n Tên sản phẩm:", product.get("product_name"))
#     print("Thương hiệu:", product.get("brands"))
#     print("Calo:", product.get("nutriments", {}).get("energy-kcal"))
#     print("Nutriments:", product.get("nutriments"))

#     return {
#         "barcode": barcode,
#         "product": resp.get("product", {})
#     }

if __name__ == "__main__":
    base_dir = os.path.dirname(__file__)
    test_file = os.path.join(base_dir, "barcode_for_testing", "Screenshot 2025-11-15 190539.png")

    try:
        with open(test_file, "rb") as f:
            image_bytes = f.read()
        # `image_bytes` already contains the file bytes from the open() above.
        # The previous code attempted to call `.read()` on a string literal
        # which raised: 'str' object has no attribute 'read'. Removed that call.

        # Option A: open directly from bytes
        image = Image.open(io.BytesIO(image_bytes))

        # Option B (simpler): PIL can open from path directly
        # image = Image.open(test_file)

        results = decode(image)
        if not results:
            print("⚠️ Không tìm thấy barcode trong ảnh test.")
        else:
            barcode = results[0].data.decode("utf-8")
            print("📌 Barcode nhận được:", barcode)

            url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
            resp = requests.get(url).json()

            product = resp.get("product", None)
            if not product:
                print("⚠️ Không tìm thấy thông tin sản phẩm trong OpenFoodFacts.")
            else:
                print("\n📦 Tên sản phẩm:", product.get("product_name"))
                print("🏷️ Thương hiệu:", product.get("brands"))
                print("🔥 Calo:", product.get("nutriments", {}).get("energy-kcal"))
                print("🥣 Nutriments:", product.get("nutriments"))
                print("\n")

                print(analyze_product("không có", "không có", "giữ cân", product.get("product_name"), product.get("nutriments", {}).get("energy-kcal"), product.get("nutriments", {}).get("protein"), product.get("nutriments", {}).get("carbohydrates_serving"), product.get("nutriments", {}).get("fat")))

    except FileNotFoundError:
        print(f"⚠️ File test không tồn tại: {test_file}")
    except Exception as e:
        print(f"🔴 Lỗi khi xử lý ảnh test: {e}")