import numpy as np
from googleapiclient.discovery import build
from googlesearch import search
from openai import OpenAI
from pinecone import Pinecone, ServerlessSpec
from huggingface_hub import InferenceClient
import json
import re
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel

#---api_key---#
load_dotenv()
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY_FOR_CHATBOX")
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
GOOGLE_API_KEY = os.getenv('GOOGLE_SEARCH_API_KEY')
GOOGLE_CX = os.getenv('GOOGLE_SEARCH_CX')
HF_TOKEN = os.getenv("HF_TOKEN")
#---api_key---#

#---model_database_config---#
client = OpenAI(
    api_key = HF_TOKEN,
    base_url="https://router.huggingface.co/v1"
)
extractor = InferenceClient(model="sentence-transformers/all-MiniLM-L6-v2")
#---model_database_config---#

#--pinecone--#
pc = Pinecone(api_key=PINECONE_API_KEY)
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


def extract_tags(query_text):
    guideline_prompt = build_guideline_prompt()

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

    response = client.chat.completions.create(
        model="Qwen/Qwen3-4B-Instruct-2507:nscale",
        messages= [
            {"role": "system",
            "content": prompt},
        ]
    )

    response = response.choices[0].message.content
    json_str = re.sub(r"```json\n?|```", "", response.strip())
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
    food_scan: dict | None = None

def google_search(query: str, num_results: int = 3):
    print("đang sử dụng google")
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

def db_lookup(tool_query: str, gender: str = "male", top_k=10):
    """
    Thực hiện Hybrid Search (v3)
    Hàm này là hàm chính để ứng dụng của bạn gọi.
    Args:
        tool_query: Câu truy vấn (ví dụ: "món gà")
        gender: "male" hoặc "female" (mặc định là "male")
    """

    print(f"--- Đang tìm kiếm cho: '{tool_query}' | Giới tính: {gender} ---")

    target_namespace = "male_diet"
    if gender.lower() == "female":
        target_namespace = "female_diet"

    extracted_tags = extract_tags(tool_query)
    print(f"Tags trích xuất từ database: {extracted_tags}")

    pinecone_filter = {}
    filter_parts = []

    if extracted_tags:
        if extracted_tags.get("true_ingredients"):
            filter_parts.append({"true_ingredients": {"$in": extracted_tags["true_ingredients"]}})
        if extracted_tags.get("main_methods"):
            filter_parts.append({"main_methods": {"$in": extracted_tags["main_methods"]}})
        if extracted_tags.get("dish_tags"):
            filter_parts.append({"dish_tags": {"$in": extracted_tags["dish_tags"]}})

        if extracted_tags.get("dish_type"):
            filter_parts.append({"dish_type": {"$eq": extracted_tags["dish_type"][0]}})
        if extracted_tags.get("mức độ"):
            filter_parts.append({"mức độ": {"$eq": extracted_tags["mức độ"][0]}})

    if filter_parts:
        pinecone_filter = {"$and": filter_parts}
    print(f"Bộ lọc (filter) Pinecone sẽ dùng: {pinecone_filter}")

    query_vector = extractor.feature_extraction(tool_query).tolist()

    if pinecone_filter:
        results = index.query(
            vector=query_vector,
            filter=pinecone_filter,
            top_k=top_k,
            include_metadata=True,
            namespace=target_namespace
        )
    else:
        print("Không có filter, thực hiện tìm kiếm ngữ nghĩa đơn thuần.")
        results = index.query(
            vector=query_vector,
            top_k=top_k,
            include_metadata=True,
            namespace=target_namespace
        )

    if not results['matches']:
        print("Không tìm thấy kết quả nào.")
        return []


    matches = results['matches']

    if matches:
        scores = np.array([m['score'] for m in matches], dtype=np.float64)

        probs = scores / scores.sum()

        k = min(3, len(matches))
        chosen_indices = np.random.choice(len(matches), size=k, replace=False, p=probs)

        food_list = [matches[i]['metadata'] for i in chosen_indices]
    else:
        food_list = []
    print(food_list)
    return food_list





def build_system_prompt():
    return f"""
### Nhiệm vụ:
Trả lời mọi câu hỏi liên quan đến **ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống và món ăn**.
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

### 🔧 Quy tắc sử dụng công cụ (tool‑calling):
- Khi người dùng hỏi về món ăn, calo, thành phần, dinh dưỡng, cách nấu, hoặc cần tra cứu dữ liệu, bạn phải ưu tiên sử dụng function được cung cấp.
- Nếu câu hỏi liên quan đến món ăn cụ thể → gọi function `db_lookup`.
- Nếu câu hỏi liên quan đến thông tin chung → gọi function `google_search`.
- Không trả lời trực tiếp nếu có function phù hợp để xử lý truy vấn.
- Không tự tạo dữ liệu món ăn hoặc calo nếu chưa gọi tool.
---
"""

def build_user_prompt(age, height, weight, allergy, goal, prompt, goal_weight, gender):
    return f"""
### 🔍 **Thông tin đầu vào:**
- Tuổi: {age}
- Giới tính: {gender}
- Chiều cao: {height} cm
- Cân nặng: {weight} kg
- Dị ứng: {allergy}
- Mục tiêu: {goal}
- Cân nặng mục tiêu: {goal_weight}
- Truy vấn của người dùng: {prompt}

---

###**Nhiệm vụ của bạn:**
Dựa trên thông tin trên, hãy **phản hồi tự nhiên, thân thiện**.
- Nếu người dùng hỏi món ăn, gợi ý món phù hợp với mục tiêu.
"""

tools = [
  {
      "type": "function",
      "function": {
          "name": "google_search",
          "description": "Tìm kiếm thông tin trên mạng",
          "parameters": {
              "type": "object",
              "properties": {
                  "query":{
                      "type": "string",
                      "description": "Tìm kiếm query để tìm thông tin"
                  }
              },
              "required": ["query"]
          }
      }
  },
  {
      "type": "function",
      "function": {
          "name": "db_lookup",
          "description": "Tìm kiếm thông tin của món ăn trong database",
          "parameters":{
              "type": "object",
              "properties": {
                  "tool_query": {
                      "type": "string",
                      "description": "Tìm kiếm query để tìm thông tin của món ăn"
                  }
              },
              "required": ["tool_query"]
          }

      }
  }
]
TOOL_MAPPING = {
    "google_search": google_search,
    "db_lookup": db_lookup
}

def call_llm(msgs):
    resp = client.chat.completions.create(
        model="Qwen/Qwen3-4B-Instruct-2507:nscale",
        tools=tools,
        messages=msgs
    )
    msgs.append(resp.choices[0].message.dict())
    return resp

def get_tool_response(response):
    tool_call = response.choices[0].message.tool_calls[0]
    tool_name = tool_call.function.name
    tool_args = json.loads(tool_call.function.arguments)
    tool_result = TOOL_MAPPING[tool_name](**tool_args)
    return {
        "role": "tool",
        "tool_call_id": tool_call.id,
        "content": tool_result,
    }

@app.post("/chat")
async def chatbox(request: ChatRequest):
    print(f"Received request with gender: {request.gender}")
    chat_history = [
        {"role": "system",
        "content": build_system_prompt()}
    ]

    content = build_user_prompt(request.age, request.height, request.weight, request.allergy, request.goal, request.prompt, request.goal_weight, request.gender)

    chat_history.append(
        {"role": "user",
         "content": content}
    )

    max_iterations = 2
    iteration_count = 0
    while iteration_count < max_iterations:
        iteration_count += 1
        resp = call_llm(chat_history)
        if resp.choices[0].message.tool_calls:
            chat_history.append(get_tool_response(resp))
        else:
            break
    if iteration_count >= max_iterations:
        print("Warning: Maximum iterations reached")
    return{"reply": chat_history[-1]['content']}
        
if __name__ == "__main__":
    print(extract_tags("món ăn giảm cân giành con người bị dị ứng cá"))