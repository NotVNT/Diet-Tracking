from fastapi import FastAPI, UploadFile, File
from pyzbar.pyzbar import decode
from PIL import Image
import requests
import io

app = FastAPI()

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