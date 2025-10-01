import google.generativeai as genai
import os
from dotenv import load_dotenv
from pinecone import Pinecone, ServerlessSpec
from fastapi.middleware.cors import CORSMiddleware
from sentence_transformers import SentenceTransformer
from fastapi import FastAPI
from pydantic import BaseModel

#---api_key---#
load_dotenv()
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
#---api_key---#

#---mode_database_config---#
pc = Pinecone(api_key=PINECONE_API_KEY)
genai.configure(api_key=GEMINI_API_KEY)
model_gemini = genai.GenerativeModel('gemini-2.5-flash-lite')
model_llm = SentenceTransformer('all-MiniLM-L12-v2')
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
#--FastAPI--#

#--pinecone--#
index_name = "nutrition-db"
if index_name not in pc.list_indexes().names():
    pc.create_index(
        name=index_name,
        dimension=384,
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1")
    )

index = pc.Index(index_name)

def get_embedding(text: str):
    return model_llm.encode(text, convert_to_numpy=True).tolist()

recipes = [
    {"id": "1", "title": "cơm gà kho gừng", "ingredients": ["cơm", "đùi gà", "gừng"], "how-to-cook": "Ướp gà với gừng, tỏi, hành, nước mắm, đường, tiêu rồi kho lửa nhỏ với nước xăm xắp đến khi gà mềm, nước sánh lại, ăn kèm cơm trắng.","tags": ["giảm cân", "mặn", "khó làm"], "calories" : 300, "protein": 25},
    {"id": "2", "title": "cơm gà xối mỡ", "ingredients": ["cơm", "đùi gà", "tỏi", "dầu ăn"], "how-to-cook": "Luộc gà với gừng và hành cho thơm, vớt ra chiên giòn da, xối mỡ nóng lên gà cho bóng, nấu cơm bằng nước luộc gà với lá dứa, ăn kèm rau sống và nước mắm tỏi ớt.", "tags": ["tăng cân", "nhiều mỡ", "dễ làm"], "calories": 500, "protein": 25},
    {"id": "3", "title": "cơm trắng với ức gà", "ingredients": ["cơm", "ức gà", "muối tiêu"], "how-to-cook": "Áp chảo ức gà với tiêu và muối cho vàng mặt, nấu cơm trắng bằng nước lọc hoặc nước luộc gà, ăn kèm rau luộc hoặc salad để cân bằng dinh dưỡng.", "tags": ["nhiều protein", "rẻ"], "calories" : 350, "protein": 31},
    {"id": "4", "title": "nguyên con gà", "ingredients": ["nguyên con gà"], "how-to-cook": "Làm sạch gà, nhét gừng và hành vào bụng, luộc với nước vừa ngập đến khi chín mềm, vớt ra xé thịt, dùng nước luộc nấu cháo hoặc cơm, nêm vừa ăn và rắc hành tiêu khi dùng.", "tags": ["nhiều protein", "tăng cân"], "calories" : 2500, "protein": 300},
]
vectors = []
for recipe in recipes:
    vectors.append({
        "id": recipe["id"],
        "values": get_embedding(recipe["title"]),
        "metadata": {
            "title": recipe["title"],
            "ingredients": recipe["ingredients"],
            "how-to-cook": recipe["how-to-cook"],
            "tags": recipe["tags"],
            "calories": recipe["calories"],
            "protein": recipe["protein"]
        }
    })

index.upsert(vectors=vectors)

def extract_filter(user_query):
    filter = {}
    if "ít calo" in user_query.lower() or "giảm cân" in user_query.lower():
        filter["tags"] = {"$in": ["giảm cân"]}
        filter["calories"] = {"$lte": 350}
    if "tăng cân" in user_query.lower():
        filter["tags"] = {"$in": ["tăng cân"]}
        filter["calories"] = {"$gte": 300}
    if "nhiều protein" in user_query.lower():
        filter["tags"] = {"$in": ["nhiều protein"]}
        filter["protein"] = {"$gte": 25}
    return filter

#--pinecome--#

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
##rule-based##
            
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

    chat = model_gemini.start_chat(history=[])

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
    full_prompt = build_system_prompt() + "\n\nNgữ cảnh từ CSDL món ăn\n" + context_text + "\n\n" + build_user_prompt(
        18, 171, 85, "béo phì", "sữa", "giảm cân", query_text)
    
    chat = model_gemini.start_chat(history=[])
    response = chat.send_message(full_prompt)
    print(response.text)