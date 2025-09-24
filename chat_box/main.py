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

def build_nutrition_prompt(age, height, weight, disease, allergy, goal, user_prompt):
    return f"""
Bạn là chuyên gia dinh dưỡng Việt Nam với giọng điệu như 1 đầu bếp chuyên nghiệp và cách nói chuyện đi thẳng vào vấn đề nhưng nhẹ nhàng.
Dựa trên thông tin sau:
- Tuổi: {age}
- Chiều cao: {height} cm
- Cân nặng: {weight} kg
- Bệnh lý: {disease} 
- Dị ứng: {allergy}
- Mục Tiêu: {goal}

Lưu ý: Tuyệt đối không nhắc lại thông tin **tuổi, chiều cao, cân nặng, bệnh lí, dị ứng** trong bất kỳ trường hợp nào và đi thẳng vào vấn đề luôn.

Hãy đề xuất thực đơn trong 1 ngày hoặc 1 bữa ăn phù hợp với mục tiêu của người dùng, các món ăn được đề xuất phải phù hợp ở ngoài tiệm hoặc tự làm phù hợp với người ở Sài Gòn, nếu người dùng yêu cầu công thức thì đưa ra công thức nấu ăn chi tiết cho từng món.
Không được đề xuất món ăn mà người dùng bị {allergy} hoặc gây ảnh hưởng đến {disease}, nếu người dùng đề xuất món ăn liên quan đến **bệnh lí** và **dị ứng của họ** thì phải ngăn lại và nói rõ tại sao không nên ăn món ăn đó.
Giải thích ngắn lý do lựa chọn từng món ăn.
Nếu người dùng hỏi những câu hỏi không liên quan đến chủ đề dinh dưỡng thì không trả lời và yêu cầu người dùng hỏi câu hỏi liên quan đến dinh dưỡng.

Người dùng hỏi: {user_prompt}
"""


@app.post("/chat")
async def chatbox(request: ChatRequest):
    chat = model.start_chat(history=[])
    full_prompt = build_nutrition_prompt(
        request.age, request.height, request.weight, request.disease, request.allergy, request.goal, request.prompt
    )
    response = chat.send_message(full_prompt)
    return {"reply": response.text}

if __name__ == "__main__":
    chat = model.start_chat(history=[])

    response = chat.send_message(build_nutrition_prompt(
        age=30,
        height=170,
        weight=65,
        disease="thừa cân",
        allergy="sữa",
        goal = "giảm cân",
        user_prompt = "Hãy gợi ý bữa ăn trưa ít calo"
    ))
    print(response.text)