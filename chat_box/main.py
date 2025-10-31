import google.generativeai as genai
from googleapiclient.discovery import build
from googlesearch import search
import requests
import json
import re
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel

#---api_key---#
load_dotenv()
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
GEMINI_API_KEY = ('AIzaSyDic7CyKachNcLmKR3VhFINtQb5hK9L03A')
GOOGLE_API_KEY = ('AIzaSyDyWyqsCP864gGSxyunCqfKAiPtcRg85_s')
GOOGLE_CX = ('326a236a3e77a4180')
#---api_key---# 

#---model_database_config---#
genai.configure(api_key=GEMINI_API_KEY)
model_gemini = genai.GenerativeModel('gemini-2.5-flash-lite')
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
    age: int
    height: float
    weight: float
    goal_weight: float
    disease: str
    allergy: str
    goal: str
    prompt: str

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

def db_lookup(tool_query:str): 
    #you intergate your shit into this function
    #hàm này là trả danh sách đồ ăn từ database về
    if "giảm cân" in tool_query.lower():
        return """
    Món ăn: Mì xào giòn chay.
    Lí do chọn: Là món ăn chay cung cấp nhiều vitamin, chất xơ màu sắc đẹp, hấp dẫn, phù hợp với những bữa ăn chay kể cả tiệc chay.
    Calo: 220kcal
    Protein: 20g
    Carb: 8g
    Fat: 5g
    """

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

def build_google_search_prompt():
    return """
    Bạn là **chuyên gia dinh dưỡng Việt Nam**, nói chuyện như **một đầu bếp chuyên nghiệp** với phong cách **đi thẳng vào vấn đề, thân thiện, dễ hiểu và thực tế**.

    ### Nhiệm vụ:
    Trả lời mọi câu hỏi liên quan đến **ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống và món ăn Việt Nam** dựa trên **bối cảnh sống tại Sài Gòn**.
    Câu trả lời phải **ngắn gọn, tự nhiên, mang tính tư vấn và hành động được**.
    Nếu người dùng hỏi **ngoài chủ đề dinh dưỡng**, hãy **từ chối nhẹ nhàng**, ví dụ:
    > “Xin lỗi, tôi chỉ hỗ trợ về dinh dưỡng và ăn uống. Bạn có muốn tôi gợi ý món ăn hôm nay không?”
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

def decide_action(user_query:str):
    full_prompt = reasoning_intruction() + user_query
    response = model_gemini.generate_content(full_prompt)
    raw = response.text.strip()
    match = re.findall(r'\{.*?\}', raw, re.DOTALL)
    parsed = json.loads(match[0])
    action = parsed.get("action", "").upper()
    try:
        if action not in ("GOOGLE", "DATABASE", "DIRECT"):
            raise ValueError("Không có hành động hợp lệ")
        return {
            "action": action,
            "direct_answer": parsed.get("direct_answer", ""),
        }
    except Exception:
        follow_up = (
                "PHẢI CHỈ TRẢ VỀ JSON. Trích xuất lại một JSON với các trường "
                "\"action\" (DIRECT/DATABASE/GOOGLE), và \"direct_answer\". "
                "Dưới đây là output cũ:\n" + raw
            )
        try:
            response_2 = model_gemini.generate_content(follow_up)
            raw2= response_2.text.strip()
            match2 = re.findall(r'\{.*?\}', raw2, re.DOTALL)
            parsed2 = json.loads(match2[0])
            action2 = parsed2.get("action", "").upper()
            if action2 not in ("GOOGLE", "DATABASE", "DIRECT"):
                raise ValueError("Không có hành động hợp lệ")
            return {
            "action": action2,
            "direct_answer": parsed2.get("direct_answer", ""),
        }
        except Exception:
            return {"action": "DIRECT", "direct_answer": "Xin lỗi, tôi không thể phân tích câu hỏi chính xác. Vui lòng hỏi lại hoặc cung cấp thêm."}

@app.post("/chat")
async def chatbox(request: ChatRequest):
    print("Received request:", request.model_dump())
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
        results = db_lookup(request.prompt)
        final_prompt = build_system_prompt() + build_user_prompt(request.age, request.height, request.weight, request.disease, request.allergy, request.goal, request.prompt, request.goal_weight)
        # final_prompt = build_system_prompt() + build_user_prompt(request.age, request.height, request.weight, request.disease, request.allergy, request.goal, request.prompt, request.goal_weight) + "Dưới đây là danh sách món ăn lấy được từ database:" + results + "Chỉ được chọn và trả lời dựa trên các món có trong danh sách trên. Không được thêm món khác hoặc tự nghĩ ra món mới"
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
            response = chat.send_message(final_prompt)
            return {"reply": response.text}
        else:
            context.append("Tôi đã tìm thấy trên google và tóm tắt link/snippet chính sau:")
            for r in web_results:
                print(f"-{r['title']} - {r['snippet']} - {r['link']}")
            context.append(f"-{r['title']} - {r['snippet']} - {r['link']}")
            context_string = str(context)
            final_prompt = build_google_search_prompt() + request.prompt +"Ngữ cảnh thu thập được(dùng để tham khảo)" + context_string
            response = chat.send_message(final_prompt)
            return {"reply": response.text}

    # full_prompt = build_system_prompt() + "\n\n" + build_user_prompt(
    #     request.age, request.height, request.weight,
    #     request.disease, request.allergy, request.goal, request.prompt, request.goal_weight
    # )

    # # test_prompt = "mình hiện đang muốn" + request.goal

    # response = chat.send_message(full_prompt)


    # return {"reply": response.text}

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