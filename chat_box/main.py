import google.generativeai as genai
import os
from dotenv import load_dotenv

from fastapi.middleware.cors import CORSMiddleware
# from sentence_transformers import SentenceTransformer
from fastapi import FastAPI
from pydantic import BaseModel

from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

#---api_key---#
load_dotenv()
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
#---api_key---#

#---mode_database_config---#
# pc = Pinecone(api_key=PINECONE_API_KEY)
genai.configure(api_key='AIzaSyDic7CyKachNcLmKR3VhFINtQb5hK9L03A')
model_gemini = genai.GenerativeModel('gemini-2.5-flash-lite')
# model_llm = SentenceTransformer('all-MiniLM-L12-v2')
#---model_database_config---#

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
    # Cho phép thiếu một số trường từ client bằng giá trị mặc định an toàn
    age: int = 0
    height: float = 0.0
    weight: float = 0.0
    goal_weight: float = 0.0
    disease: str = ""
    allergy: str = ""
    goal: str = ""
    prompt: str
def build_system_prompt():
    return """
Bạn là **chuyên gia dinh dưỡng Việt Nam**, nói chuyện như **một đầu bếp chuyên nghiệp** với phong cách **đi thẳng vào vấn đề, thân thiện, dễ hiểu và thực tế**.

### Nhiệm vụ:
Trả lời mọi câu hỏi liên quan đến **ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống và món ăn Việt Nam** dựa trên **bối cảnh sống tại Sài Gòn**.
Câu trả lời phải **ngắn gọn, tự nhiên, mang tính tư vấn và hành động được**.

---

### **Luật bắt buộc:**

1. **Giới hạn phạm vi**
   - Chỉ trả lời các câu hỏi **liên quan đến dinh dưỡng, món ăn, calo, sức khỏe qua ăn uống, và mục tiêu (giảm cân, tăng cơ, giữ dáng)**.

2. **Giúp người dùng nhớ thông tin cá nhân**
   - Bắt buộc phải **nhắc lại** hoặc **lặp lại** thông tin như **tuổi, chiều cao, cân nặng, bệnh lý, dị ứng** của người dùng.

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

### 🧾 **Định dạng trả lời chuẩn:**

⭐
**Món ăn đề xuất:** (tên món ăn rõ ràng)
**Lý do chọn:** (1–2 câu nêu lý do chọn món, phù hợp sức khỏe hoặc mục tiêu)
**Thông tin dinh dưỡng (ước tính cho 1 khẩu phần):**
- Calo: … kcal
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

def build_user_prompt(age, height, weight, disease, allergy, goal, prompt, goal_weight):
    return f"""
### 🔍 **Thông tin đầu vào:**
- Tuổi: {age}
- Chiều cao: {height} cm
- Cân nặng: {weight} kg
- Bệnh lý: {disease}
- Dị ứng: {allergy}
- Mục tiêu: {goal}
- Cân nặng mục tiêu: {goal_weight}
- Truy vấn của người dùng: {prompt}

---

### ✅ **Nhiệm vụ của bạn:**
Dựa trên thông tin trên và quy tắc nêu rõ, hãy **trả lời tự nhiên, đúng chuyên môn, thân thiện và thực tế** cho câu hỏi của người dùng.
Nếu câu hỏi thuộc chủ đề ngoài dinh dưỡng → **từ chối nhẹ nhàng, không lạc đề.**
"""

@app.post("/chat")
async def chatbox(request: ChatRequest):
    print(f"Received request: {request.model_dump_json(indent=2)}")

    history=[]#<--------------------
    chat = model_gemini.start_chat(history = history)

    # Sử dụng đúng goal_weight do client gửi (không tính fallback)
    full_prompt = build_system_prompt() + "\n\n" + build_user_prompt(
        request.age, request.height, request.weight,
        request.disease, request.allergy, request.goal, request.prompt, request.goal_weight
    )

    # test_prompt = "mình hiện đang muốn" + request.goal

    response = chat.send_message(full_prompt)


    return {"reply": response.text}

if __name__ == "__main__":
    query_text = "gợi ý món ăn giảm cân nhiều protein"

    filters = extract_filter(query_text)

    query_embedding = get_embedding(query_text)

    results = index.query(
        vector = query_embedding,
        top_k = 3,
        include_metadata=True,
        filter = filters
    )

    retrieved_docs = []
    for match in results.matches:
        meta = match["metadata"]
        retrieved_docs.append(
    f"{meta['title']} - Nguyên liệu: {', '.join(meta['ingredients'])}\n"
    f"Cách nấu: {meta['how-to-cook']}\n"
    f"Tags: {', '.join(meta['tags'])}\n"
    f"Calories: {meta['calories']} - Protein: {meta['protein']}"
)

    context_text = "\n".join(retrieved_docs)
    full_prompt = build_system_prompt() + "\n\nNgữ cảnh từ CSDL món ăn\n" + context_text + "\n\nCó thể đề xuất thêm nhiều món ăn tương tự món ăn từ CSDL cho người dùng" + build_user_prompt(
        18, 171, 85, "béo phì", "sữa", "giảm cân", query_text)

    chat = model_gemini.start_chat(history=[])
    response = chat.send_message(full_prompt)
    print(response.text)