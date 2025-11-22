import google.generativeai as genai
import numpy as np
from googleapiclient.discovery import build
from googlesearch import search
from datetime import datetime
from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer
import json
import re
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel

#---api_key---#
load_dotenv()
PINECONE_API_KEY = os.getenv("pcsk_5vFAvq_QCVDvAYQ7kxvD4xaN9t2s2Grm2NGVXMWHi12hJvtPyFmryNbcCMfM5kEzUUjZW6")
GEMINI_API_KEY = ('AIzaSyDic7CyKachNcLmKR3VhFINtQb5hK9L03A')
GOOGLE_API_KEY = ('AIzaSyDyWyqsCP864gGSxyunCqfKAiPtcRg85_s')
GOOGLE_CX = ('326a236a3e77a4180')
#---api_key---# 

#---model_database_config---#
genai.configure(api_key="AIzaSyDic7CyKachNcLmKR3VhFINtQb5hK9L03A")
model_gemini = genai.GenerativeModel('gemini-2.5-flash-lite')
model = SentenceTransformer('all-MiniLM-L6-v2')
#---model_database_config---#

#--pinecone--#
pc = Pinecone(api_key="pcsk_5vFAvq_QCVDvAYQ7kxvD4xaN9t2s2Grm2NGVXMWHi12hJvtPyFmryNbcCMfM5kEzUUjZW6")
index_name = 'food-db'
index = pc.Index(index_name)
#--pinecone--#

with open('tag_guidelines.json', 'r', encoding='utf-8') as f:
    TAG_GUIDELINES = json.load(f)

#----#
def build_guideline_prompt():
    prompt_lines = []
    for key, tags_list in TAG_GUIDELINES.items():
        tag_string = ", ".join(tags_list)
        prompt_lines.append(f"Danh mục '{key}' (Các tag hợp lệ: [{tag_string}])")

    return "\n".join(prompt_lines)


def extract_tags_with_gemini(query_text):
    """Sử dụng Gemini để trích xuất các tag từ query, dựa trên guideline."""
    guideline_prompt = build_guideline_prompt()
    if not guideline_prompt:
        return {}

    prompt = (
        f"Bạn là một trợ lý trích xuất thông tin món ăn.\n"
        f"Nhiệm vụ của bạn là đọc câu truy vấn của người dùng và trích xuất các từ khóa (tags)\n"
        f"dựa trên các DANH MỤC VÀ TỪ VỰNG HỢP LỆ (guideline) sau đây:\n\n"
        f"--- BỘ TỪ VỰNG HỢP LỆ ---\n"
        f"{guideline_prompt}\n"
        f"--- KẾT THÚC BỘ TỪ VỰNG ---\n\n"
        f"QUY TẮC QUAN TRỌNG:\n"
        f"1. CHỈ TRẢ VỀ các tag có trong \"Bộ từ vựng hợp lệ\".\n"
        f"2. Chuẩn hóa từ đồng nghĩa về tag đúng (ví dụ: \"gà\" -> \"Thịt gà\", \"ăn chay\" -> \"Món chay\", \"ăn tối\" -> \"bữa tối\").\n"
        f"3. BỎ QUA các từ không có trong bộ từ vựng (ví dụ: \"ngon\", \"healthy\" (nếu healthy ko có trong dish_tags)).\n"
        f"4. TRẢ VỀ ĐỊNH DẠNG JSON. Nếu không tìm thấy tag nào, trả về JSON rỗng {{}}.\n\n"
        f"VÍ DỤ:\n"
        f"Query: \"món gà cho bữa tối nhanh\"\n"
        f"Output:\n"
        f"{{\n"
        f"  \"true_ingredients\": [\"Thịt gà\"],\n"
        f"  \"dish_tags\": [\"bữa tối\"],\n"
        f"  \"mức độ\": [\"nhanh\"]\n"
        f"}}\n\n"
        f"Query: \"cách làm món chay xào có đậu hũ\"\n"
        f"Output:\n"
        f"{{\n"
        f"  \"dish_type\": [\"Món chay\"],\n"
        f"  \"true_ingredients\": [\"Đậu hũ\"],\n"
        f"  \"main_methods\": [\"Xào\"]\n"
        f"}}\n\n"
        f"BÂY GIỜ, HÃY XỬ LÝ QUERY SAU:\n"
        f"Query: \"{query_text}\"\n"
        f"Output:\n"
    )

    response = model_gemini.generate_content(prompt)
    json_str = re.sub(r"```json\n?|```", "", response.text.strip())
    extracted_tags = json.loads(json_str)

    for key, value in extracted_tags.items():
        if not isinstance(value, list):
            extracted_tags[key] = [value]

    return extracted_tags



#----#

#--FastAPI--#
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    age: int
    height: float
    weight: float
    goal_weight: float | None = None
    disease: str
    allergy: str
    goal: str
    prompt: str
    gender: str | None = None
    nutrition_plan: dict | None = None
    food_records: list[dict] | None = None

def google_search(query: str, num_results: int = 3):
    service = build("customsearch", "v1", developerKey=GOOGLE_API_KEY)
    resp = service.cse().list(q=query, cx=GOOGLE_CX).execute()
    items = resp['items'][:num_results]
    results = []
    for it in items:
        results.append({
            "title": it.get("title"),
            "snippet": it.get("snippet"),
            "link": it.get("link")
        })
    return results
    
def weighted_random_choice(matches, k=5):
    scores = np.array([m['score'] for m in matches])
    probs = scores / scores.sum()
    chosen = np.random.choice(matches, size=min(k, len(matches)), replace=False, p=probs)
    food_list = [matches[i]['metadata'] for i in chosen]
    return food_list.tolist()

def db_lookup(tool_query: str, top_k=10):
    """
    Thực hiện Hybrid Search (v3)
    Hàm này là hàm chính để ứng dụng của bạn gọi.
    """

    print(f"--- Đang thực hiện Hybrid Search v3 cho: '{tool_query}' ---")

    # Bước 1: Trích xuất Tag bằng Gemini
    extracted_tags = extract_tags_with_gemini(tool_query)
    print(f"Tags trích xuất từ Gemini: {extracted_tags}")

    pinecone_filter = {}
    filter_parts = [] # Dùng $and để kết hợp các điều kiện

    if extracted_tags:
        # $in: Dùng cho các cột là LIST
        if extracted_tags.get("true_ingredients"):
            filter_parts.append({"true_ingredients": {"$in": extracted_tags["true_ingredients"]}})
        if extracted_tags.get("main_methods"):
            filter_parts.append({"main_methods": {"$in": extracted_tags["main_methods"]}})
        if extracted_tags.get("dish_tags"):
            filter_parts.append({"dish_tags": {"$in": extracted_tags["dish_tags"]}})

        # $eq: Dùng cho các cột là STRING (chính xác)
        if extracted_tags.get("dish_type"):
            filter_parts.append({"dish_type": {"$eq": extracted_tags["dish_type"][0]}})
        if extracted_tags.get("mức độ"):
            filter_parts.append({"mức độ": {"$eq": extracted_tags["mức độ"][0]}})

    if filter_parts:
        pinecone_filter = {"$and": filter_parts}
    print(f"Bộ lọc (filter) Pinecone sẽ dùng: {pinecone_filter}")

    # Bước 2: Encode Query gốc để tạo Vector
    query_vector = model.encode(tool_query).tolist()

    # Bước 3: Truy vấn Pinecone
    if pinecone_filter:
        results = index.query(
            vector=query_vector,
            filter=pinecone_filter,
            top_k=top_k,
            include_metadata=True
        )
    else:
        print("Không có filter, thực hiện tìm kiếm ngữ nghĩa đơn thuần.")
        results = index.query(
            vector=query_vector,
            top_k=top_k,
            include_metadata=True
        )

        # Bước 4: Trả về kết quả (thay vì chỉ in)
    if not results['matches']:
        print("Không tìm thấy kết quả nào.")
        return [] # Trả về list rỗng


    matches = results['matches']

# === Weighted Random Sampling ===
    if matches:
        # Lấy điểm similarity
        scores = np.array([m['score'] for m in matches], dtype=np.float64)

        # Chuẩn hóa điểm để thành xác suất (cộng = 1)
        probs = scores / scores.sum()

        # Chọn ngẫu nhiên 3 kết quả (tùy bạn)
        k = min(3, len(matches))
        chosen_indices = np.random.choice(len(matches), size=k, replace=False, p=probs)

        # Lấy metadata tương ứng
        food_list = [matches[i]['metadata'] for i in chosen_indices]
    else:
        food_list = []

    return food_list

def total_calories_for_today(nutrition_plan, food_records):
    max_calories = 0
    if nutrition_plan:
         max_calories = nutrition_plan.get('caloriesMax')
    
    today = datetime.now().strftime("%Y-%m-%d")
    total_calories = sum(
    record.get("calories", 0)
    for record in food_records
    if record.get("date", "").startswith(today)
    )
    print(total_calories)
    if total_calories >= max_calories:
        return 1;




def build_system_prompt(nutrition_plan, food_records):

    if total_calories_for_today(nutrition_plan, food_records):
        return f"""
### ⚠️ **Thông báo dinh dưỡng**
Database đã tính toán và thấy rằng người dùng đã tiêu thụ đủ lượng calories cho hôm nay. Hãy từ chối cung cấp thêm món ăn cho người dùng và từ chối thẳng thắn là bạn sẽ không đề xuất món ăn nữa nhưng vẫn sẽ trả lời câu hỏi liên quan về **ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống và món ăn Việt Nam**.
"""

    else:
        return """
Cư xử như **chuyên gia dinh dưỡng Việt Nam**, nói chuyện như **một đầu bếp chuyên nghiệp** với phong cách **đi thẳng vào vấn đề, thân thiện, dễ hiểu và thực tế**.

### Nhiệm vụ:
Trả lời mọi câu hỏi liên quan đến **ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống và món ăn Việt Nam**.
Câu trả lời phải **ngắn gọn, tự nhiên, mang tính tư vấn** tối đa 250 câu.

---

### **Luật bắt buộc:**

1. **Giới hạn phạm vi**
   - Chỉ trả lời các câu hỏi **liên quan đến dinh dưỡng, món ăn, calo, sức khỏe qua ăn uống, và mục tiêu (giảm cân, tăng cơ, giữ dáng)**.
   - Nếu người dùng hỏi những câu hỏi liên quan về kiến thức chung hay vấn đề chung của dinh dưỡng thì hãy trả lời và đừng đề xuất món ăn.
   - Nếu người dùng hỏi **ngoài chủ đề dinh dưỡng**, hãy **từ chối nhẹ nhàng**, ví dụ:
     > “Xin lỗi, tôi chỉ hỗ trợ về dinh dưỡng và ăn uống. Bạn có muốn tôi gợi ý món ăn hôm nay không?”

2. **Bảo mật thông tin cá nhân**
   - Không được **nhắc lại** hoặc **lặp lại** thông tin như **tuổi, chiều cao, cân nặng, bệnh lý, dị ứng** của người dùng trừ khi người dùng yêu cầu.
   - Chỉ **sử dụng thông tin đó để cá nhân hóa gợi ý**, không được in lại.

3. **An toàn và phù hợp sức khỏe**
   - Nếu món ăn **liên quan đến bệnh lý hoặc dị ứng**, **ngăn lại** và **giải thích lý do** rõ ràng.
   - Luôn chọn món **phù hợp với mục tiêu** và **trạng thái sức khỏe**.

4. **Tính thực tế và địa phương**
   - Món ăn phải **thực tế, phổ biến ở Việt Nam (đặc biệt là Sài Gòn)**, có thể mua ở tiệm hoặc tự nấu tại nhà.
   - Có thể gợi ý **biến tấu món Việt** theo hướng lành mạnh.

5. **Nếu người dùng yêu cầu công thức**, hãy đưa:
   - **Nguyên liệu**
   - **Cách làm chi tiết**
   - **Mẹo nấu nhanh hoặc thay thế nguyên liệu nếu cần**

---

### 🧾 **Định dạng trả lời chuẩn bắt buộc phải đưa ra cho từng món ăn:**

⭐
**Món ăn đề xuất:** (tên món ăn rõ ràng)
**Lý do chọn:** (1–2 câu nêu lý do chọn món, phù hợp sức khỏe hoặc mục tiêu)
**Thông tin dinh dưỡng (ước tính cho 1 khẩu phần):**
- Calo: Khoảng (…) - (…) kcal
- Protein: … g
- Carb: … g
- Fat: … g
⭐

Nếu người dùng hỏi về:
- **So sánh món ăn:** So sánh rõ ràng theo calo, đường, chất béo, lợi ích.
- **Kiến thức dinh dưỡng:** Giải thích ngắn, dễ hiểu, kèm ví dụ món Việt.
- **Lượng ăn mỗi ngày:** Tính toán hợp lý dựa vào cân nặng và mục tiêu, nhưng không nhắc lại thông tin đó trong câu trả lời.

---
"""

def build_google_search_prompt():
    return """
    ### Nhiệm vụ:
    Trả lời mọi câu hỏi liên quan đến **ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống và món ăn Việt Nam**.
    Câu trả lời phải **ngắn gọn, tự nhiên, mang tính tư vấn và hành động được**.
    Nếu người dùng hỏi **ngoài chủ đề dinh dưỡng**, hãy **từ chối nhẹ nhàng**, ví dụ:
    > “Xin lỗi, tôi chỉ hỗ trợ về dinh dưỡng và ăn uống. Bạn có muốn tôi gợi ý món ăn hôm nay không?”
    """


def build_user_prompt(age, height, weight, disease, allergy, goal, prompt, goal_weight, gender, nutrition_plan, food_records):
    # plan_details = ""
    # if nutrition_plan:
    #     plan_details = f"""\n- Kế hoạch dinh dưỡng hiện tại:
    #      - BMR: {nutrition_plan.get('bmr', 'N/A')} kcal
    #      - TDEE: {nutrition_plan.get('tdee', 'N/A')} kcal
    #      - Lượng calo mục tiêu: {nutrition_plan.get('targetCalories', 'N/A')} kcal/ngày
    #      - Thời gian: {nutrition_plan.get('targetDays', 'N/A')} ngày
    #      - Trạng thái: {'Lành mạnh' if nutrition_plan.get('isHealthy') else 'Cần cân nhắc'}"""

    # food_history = ""
    # if food_records:
    #     food_history += "\n- Lịch sử ăn uống gần đây:"
    #     for record in food_records:
    #         food_history += f"\n  - {record.get('foodName', 'N/A')}: {record.get('calories', 'N/A')} kcal"

    return f"""
### 🔍 **Thông tin đầu vào:**
- Tuổi: {age}
- Giới tính: {gender or 'Không xác định'}
- Chiều cao: {height} cm
- Cân nặng: {weight} kg
- Bệnh lý: {disease}
- Dị ứng: {allergy}
- Mục tiêu: {goal}
- Cân nặng mục tiêu: {goal_weight}
- Truy vấn của người dùng: {prompt}

---

### ✅ **Nhiệm vụ của bạn:**
Dựa trên thông tin trên, hãy **phản hồi tự nhiên, thân thiện và chuyên nghiệp như một chuyên gia dinh dưỡng**.
- Nếu người dùng hỏi món ăn, gợi ý món phù hợp với mục tiêu và còn trong giới hạn calo.
- Nếu người dùng hỏi ngoài chủ đề dinh dưỡng, hãy từ chối nhẹ nhàng và hướng lại đúng chủ đề.
"""

def reasoning_intruction():
    return"""
    Bạn là một trợ lý chuyên về dinh dưỡng. Khi nhận một câu hỏi, hãy phân tích nhanh và quyết định một trong ba hành động:
    - "DIRECT": bạn có thể trả lời ngay dựa trên kiến thức chung.
    - "DATABASE": cần truy vấn cơ sở dữ liệu nội bộ để trả lời chính xác (ví dụ danh sách món ăn, yêu cầu đề xuất món ăn, yêu cầu về chế độ ăn, yêu cầu về bữa ăn).
    - "GOOGLE": cần tìm thông tin cập nhật/chi tiết từ web nếu bạn không chắc chắn (ví dụ thông tin dinh dưỡng có cấu trúc, câu hỏi chung chung về dinh dưỡng).

    Trả về văn bản dạng như sau (không giải thích thêm) với các trường:
    '''
    "action": "DIRECT" | "DATABASE" | "GOOGLE",
    "direct_answer": "nếu action là DIRECT thì điền câu trả lời ngắn ở đây, ngược lại để trống"
    '''
    Luôn đảm bảo JSON hợp lệ.
    """

# def check_calories(food_records):


def decide_action(user_query:str):
    full_prompt = reasoning_intruction() + user_query
    try:
        response = model_gemini.generate_content(full_prompt)
        raw = response.text.strip()
        # Find JSON block, even with markdown wrappers
        match = re.search(r'```json\n(\{.*?\})\n```|(\{.*?\})', raw, re.DOTALL)
        if not match:
            print(f"Warning: Could not find JSON in decision response. Defaulting to DIRECT. Response was: {raw}")
            return {"action": "DIRECT", "direct_answer": ""} # Let the main prompt handle it

        # Extract the actual JSON string from one of the capture groups
        json_str = match.group(1) or match.group(2)
        parsed = json.loads(json_str)
        action = parsed.get("action", "").upper()

        if action not in ("GOOGLE", "DATABASE", "DIRECT"):
            print(f"Warning: Invalid action '{action}' in decision response. Defaulting to DIRECT.")
            return {"action": "DIRECT", "direct_answer": ""}

        return {
            "action": action,
            "direct_answer": parsed.get("direct_answer", ""),
        }
    except Exception as e:
        print(f"Error in decide_action: {e}. Defaulting to DIRECT action.")
        return {"action": "DIRECT", "direct_answer": "Xin lỗi, tôi gặp chút sự cố khi phân tích câu hỏi của bạn. Bạn có thể hỏi lại được không?"}
@app.post("/chat")
async def chatbox(request: ChatRequest):
    print(f"Received request with gender: {request.gender}")
    # print("Received request:", request.model_dump())
    history=[]
    chat = model_gemini.start_chat(history = history)

    decision = decide_action(request.prompt)
    action = decision["action"]
    if(action == "DIRECT"):
        print("DIRECT")
        response = chat.send_message(request.prompt)
        return {"reply": response.text}
    
    if(action == "DATABASE"):#<---------------------------
        #biến results sẽ là biến mà lưu danh sách database vào
        print("ĐANG SỬ DỤNG DATABASE")
        results = db_lookup(request.prompt +  request.goal, 10)
        # final_prompt = build_system_prompt(request.nutrition_plan, request.food_records) + build_user_prompt(request.age, request.height, request.weight, request.disease, request.allergy, request.goal, request.prompt, request.goal_weight, request.nutrition_plan, request.food_records)
        # print("FINAL_PROMPT",final_prompt)
        final_prompt = build_system_prompt(request.nutrition_plan, request.food_records) + build_user_prompt(request.age, request.height, request.weight, request.disease, request.allergy, request.goal, request.prompt, request.goal_weight, request.gender, request.nutrition_plan, request.food_records) + "Dưới đây là danh sách món ăn lấy được từ database:" + str(results) + "Chỉ được chọn và trả lời dựa trên các món có trong danh sách trên. Không được thêm món khác hoặc tự nghĩ ra món mới"
        print(results)
        response = chat.send_message(final_prompt)
        return {"reply": response.text}
    
    elif action == "GOOGLE":
        context = []
        print("ĐANG SỬ DỤNG GOOGLE")
        try:
            web_results = google_search(request.prompt, num_results = 3)
        except Exception as e:
            print(f"Lỗi tìm kiếm trên google", e)

        web_results = []
        if not web_results:
            context.append("Không có context công cụ, hãy trả lời bằng kiến thức nội bộ nếu có.")
            context_string = str(context)
            final_prompt = build_google_search_prompt() + request.prompt + "Ngữ cảnh thu thập được(dùng để tham khảo)" + context_string
            # print("\n--- FINAL PROMPT FOR AI (GOOGLE) ---\n", final_prompt)
            response = chat.send_message(final_prompt)
            return {"reply": response.text}
        else:
            context.append("Tôi đã tìm thấy trên google và tóm tắt link/snippet chính sau:")
            for r in web_results:
                print(f"-{r['title']} - {r['snippet']} - {r['link']}")
            context.append(f"-{r['title']} - {r['snippet']} - {r['link']}")
            context_string = str(context)
            final_prompt = build_google_search_prompt() + request.prompt +"Ngữ cảnh thu thập được(dùng để tham khảo)" + context_string
            print("\n--- FINAL PROMPT FOR AI (GOOGLE) ---\n", final_prompt)
            response = chat.send_message(final_prompt)
            return {"reply": response.text}