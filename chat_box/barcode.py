from fastapi import FastAPI, UploadFile, File, Form
from pyzbar.pyzbar import decode
from PIL import Image
import requests
import io

app = FastAPI()

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
    và trả về thông tin sản phẩm từ OpenFoodFacts. Đồng thời nhận kèm
    thông tin người dùng (nếu có) để phục vụ cá nhân hóa phía server.
    """
    print(f"\n{'='*60}")
    print(f"🔵 [INFO] Nhận barcode từ Flutter: {barcode}")

    # Log thông tin người dùng (nếu được gửi kèm)
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