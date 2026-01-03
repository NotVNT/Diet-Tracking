from fastapi import FastAPI, UploadFile, File, Form, Body
from pyzbar.pyzbar import decode
from PIL import Image
from openai import OpenAI
from huggingface_hub import InferenceClient
from dotenv import load_dotenv
import requests
import io
import os

app = FastAPI()

load_dotenv()

HF_TOKEN = os.getenv("HF_TOKEN")

client = OpenAI(
    api_key = HF_TOKEN,
    base_url="https://router.huggingface.co/v1"
)

def is_this_stuff_good(weight, goal, disease, allergy, product_name, nutriments, calories, protein, carbs, fat):
    system_prompt = {"role": "system",
                     "content": f"""
    -Duới đây là thông tin của người dùng:
    Cân nặng: {weight},
    Mục tiêu: {goal},
    Bệnh tật: {disease},
    Dị ứng: {allergy}.

    Và dưới đây là thông tin của sản phẩm:
    Tên: {product_name},
    Dinh dưỡng: {nutriments},
    Calo: {calories},
    Protein: {protein},
    Carbs: {carbs},
    Fat: {fat},

    Hãy cho người dùng biết sản phẩm này có hợp với người dùng hay không, nói ngắn gọn, không dài dòng và không cần hỏi thêm người dùng. Giới hạn 100 kí tự.
"""}
    
    messages = []
    messages.append(system_prompt)

    completion = client.chat.completions.create(
        model="openai/gpt-oss-20b:groq",
        messages=messages,
    )

    bot_response = completion.choices[0].message.content
    return bot_response

@app.post("/get_product_info")
async def get_product_info(
    barcode: str = Form(...),
    age: int | None = Form(None),
    height: float | None = Form(None),
    weight: float | None = Form(None),
    goal_weight: float | None = Form(None),
    disease: str | None = Form(None),
    allergy: str | None = Form(None),
    goal: str | None = Form(None),
    gender: str | None = Form(None),
):
    """
    Endpoint chính: Nhận mã barcode từ Flutter (đã quét bằng ML Kit)
    và trả về thông tin sản phẩm từ OpenFoodFacts.

    Đồng thời nhận kèm userData dạng form fields (Flutter hiện đang gửi kiểu này).
    """
    print(f"\n{'='*60}")
    print(f"🔵 [INFO] Nhận barcode từ Flutter: {barcode}")

    # Log thông tin người dùng (nếu được gửi kèm)
    if any(v is not None and str(v) != "" for v in [age, height, weight, goal_weight, disease, allergy, goal, gender]):
        print("🟣 [USER] Thông tin người dùng gửi kèm:")
        print(f"   - Tuổi: {age}")
        print(f"   - Giới tính: {gender}")
        print(f"   - Chiều cao: {height} cm")
        print(f"   - Cân nặng: {weight} kg")
        print(f"   - Cân nặng mục tiêu: {goal_weight}")
        print(f"   - Bệnh lý: {disease}")
        print(f"   - Dị ứng: {allergy}")
        print(f"   - Mục tiêu: {goal}")
    
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

        response = is_this_stuff_good(weight, goal, disease, allergy, product_name, nutriments, calories, protein, carbs, fat)
        
        return {
            "barcode": barcode,
            "response": response,
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

    results = decode(image)
    if not results:
        return {"error": "Không tìm thấy barcode"}

    barcode = results[0].data.decode("utf-8")

    url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
    resp = requests.get(url).json()

    product = resp.get("product", None)
    if not product:
        print("Không tìm thấy thông tin sản phẩm tron OpenFoodFact")

    print("\n Tên sản phẩm:", product.get("product_name"))
    print("Thương hiệu:", product.get("brands"))
    print("Calo:", product.get("nutriments", {}).get("energy-kcal"))
    print("Nutriments:", product.get("nutriments"))

    return {
        "barcode": barcode,
        "product": resp.get("product", {})
    }

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

    except FileNotFoundError:
        print(f"⚠️ File test không tồn tại: {test_file}")
    except Exception as e:
        print(f"🔴 Lỗi khi xử lý ảnh test: {e}")