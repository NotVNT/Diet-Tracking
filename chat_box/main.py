import google.generativeai as genai
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from pydantic import BaseModel

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

genai.configure(api_key=GEMINI_API_KEY)

model = genai.GenerativeModel('gemini-1.5-flash-latest')
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
    height: int
    weight: int
    disease: str
    allergy: str
    goal: str
    prompt: str

def build_system_prompt():
    return """
Bạn là chuyên gia dinh dưỡng Việt Nam với giọng điệu như 1 đầu bếp chuyên nghiệp và cách nói chuyện đi thẳng vào vấn đề nhưng nhẹ nhàng.

Luật bắt buộc:
- Tuyệt đối không nhắc lại thông tin **tuổi, chiều cao, cân nặng, bệnh lí, dị ứng** trong bất kỳ trường hợp nào.
- Chỉ trả lời câu hỏi liên quan đến dinh dưỡng. Nếu người dùng hỏi ngoài chủ đề thì từ chối.
- Nếu người dùng đề xuất món ăn liên quan đến bệnh lí hoặc dị ứng của họ thì phải ngăn lại và giải thích lý do.
- Món ăn phải thực tế (tìm được ở tiệm hoặc tự làm) và phù hợp với bối cảnh Sài Gòn.
- Nếu người dùng yêu cầu công thức thì đưa công thức chi tiết.
- Giải thích ngắn lý do lựa chọn từng món ăn kèm theo thông tin dinh dưỡng của món ăn đó như calo, protein, carb và fat.
"""

##rule-based##
FORBIDDEN_BY_DISEASE = {
    "tiểu đường": ["coca", "nước ngọt", "bánh kẹo", "đường"],
    "cao huyết áp": ["muối", "mắm", "thịt mỡ"],
    "thừa cân": ["mỡ heo"]
}

FORBIDDEN_BY_ALLERGY = {
    "sữa": ["sữa", "phô mai", "bơ"],
    "hải sản": ["tôm", "cua", "cá biển"],
}
##rule-based##
def violates_rules(disease, allergy, user_prompt):
    if disease in FORBIDDEN_BY_DISEASE:
        for item in FORBIDDEN_BY_DISEASE[disease]:
            if item.lower() in user_prompt.lower():
                return f"Không thể đề xuất món ăn có '{item}' vì bạn có bệnh {disease}"
    
    if allergy in FORBIDDEN_BY_ALLERGY:
        for item in FORBIDDEN_BY_ALLERGY[allergy]:
            if item.lower() in user_prompt.lower():
                return f"Không thể đề xuất món ăn có '{item}' vì bạn dị ứng với {allergy}"
            
def filter_output(disease, allergy, model_reply):
    forbidden_words = []
    if disease in FORBIDDEN_BY_DISEASE:
        forbidden_words += FORBIDDEN_BY_DISEASE[disease]
    if allergy in FORBIDDEN_BY_ALLERGY:
        forbidden_words += FORBIDDEN_BY_ALLERGY[allergy]

    for item in forbidden_words:
        if item.lower() in model_reply.lower():
            return 0
        
    return 1;

def build_user_prompt(age, height, weight, disease, allergy, goal, user_prompt):
    return f"""
Dựa trên thông tin sau:
- Tuổi: {age}
- Chiều cao: {height} cm
- Cân nặng: {weight} kg
- Bệnh lý: {disease}
- Dị ứng: {allergy}
- Mục tiêu: {goal}

Người dùng hỏi: {user_prompt}
"""

@app.post("/chat")
async def chatbox(request: ChatRequest):
    violation = violates_rules(request.disease, request.allergy, request.prompt)
    if violation:
        return {"reply": violation}
    full_prompt = build_system_prompt() + "\n\n" + build_user_prompt(
        request.age, request.height, request.weight,
        request.disease, request.allergy, request.goal, request.prompt
    )

    chat = model.start_chat(history=[])

    response = chat.send_message(full_prompt)

    flag = filter_output(request.disease, request.allergy, response.text)

    while(flag == 0):
        full_prompt = build_system_prompt() + "\n\n" + build_user_prompt(
        request.age, request.height, request.weight,
        request.disease, request.allergy, request.goal, request.prompt
    ) + f"Không được đề xuất món ăn mà người dùng bị dị ứng với {request.allergy} hoặc ảnh hưởng xấu đến sức khỏe tại vì họ bị {request.disease}"
        response = chat.send_message(full_prompt)
        flag = filter_output(request.disease, request.allergy, response.text)

    return {"reply": response.text}
