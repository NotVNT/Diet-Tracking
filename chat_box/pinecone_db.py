from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer
import os
from dotenv import load_dotenv

load_dotenv()

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
pc = Pinecone(api_key=PINECONE_API_KEY)

index_name = "nutrition-db"
if index_name not in pc.list_indexes().names():
    pc.create_index(
        name=index_name,
        dimension=384,
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1")
    )

index = pc.Index(index_name)

model = SentenceTransformer('all-MiniLM-L12-v2')

def get_embedding(text: str):
    return model.encode(text, convert_to_numpy=True).tolist()


##dummy data##
recipes = [
    {"id": "1", "title": "cơm gà kho gừng", "ingredients": ["cơm", "đùi gà", "gừng"], "how-to-cook": "Ướp gà với gừng, tỏi, hành, nước mắm, đường, tiêu rồi kho lửa nhỏ với nước xăm xắp đến khi gà mềm, nước sánh lại, ăn kèm cơm trắng.","tags": ["giảm cân", "mặn", "khó làm"], "calories" : 5, "protein": 25},
    {"id": "2", "title": "cơm gà xối mỡ", "ingredients": ["cơm", "đùi gà", "tỏi", "dầu ăn"], "how-to-cook": "Luộc gà với gừng và hành cho thơm, vớt ra chiên giòn da, xối mỡ nóng lên gà cho bóng, nấu cơm bằng nước luộc gà với lá dứa, ăn kèm rau sống và nước mắm tỏi ớt.", "tags": ["tăng cân", "nhiều mỡ", "dễ làm"], "calories": 99999, "protein": 25},
    {"id": "3", "title": "cơm trắng với ức gà", "ingredients": ["cơm", "ức gà", "muối tiêu"], "how-to-cook": "Áp chảo ức gà với tiêu và muối cho vàng mặt, nấu cơm trắng bằng nước lọc hoặc nước luộc gà, ăn kèm rau luộc hoặc salad để cân bằng dinh dưỡng.", "tags": ["nhiều protein", "rẻ"], "calories" : 10, "protein": 99999},
    {"id": "4", "title": "nguyên con gà", "ingredients": ["nguyên con gà"], "how-to-cook": "Làm sạch gà, nhét gừng và hành vào bụng, luộc với nước vừa ngập đến khi chín mềm, vớt ra xé thịt, dùng nước luộc nấu cháo hoặc cơm, nêm vừa ăn và rắc hành tiêu khi dùng.", "tags": ["nhiều protein", "tăng cân"], "calories" : 99999, "protein": 99999},
]
##dummy data##

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
    if "tăng cân" in user_query.lower():
        filter["calories"] = {"$gt": 999}
    if "nhiều protein" in user_query.lower():
        filter["protein"] = {"$gt": 999}
    return filter


##"đề xuất món ăn tăng cân" "đề xuất món ăn giảm cân" "đề xuất món ăn nhiều protein" "đề xuất món ăn tăng cân và nhiều protein"

query_embedding = get_embedding("đề xuất món ăn tăng cân và nhiều protein")
filters = extract_filter("đề xuất món ăn tăng cân và nhiều protein")

results = index.query(
    vector=query_embedding,
    top_k=5,
    include_metadata=True,
    filter=filters
)

for match in results.matches:
    print(f" Gợi ý: {match['metadata']['title']} (score: {match['score']:.3f}) - tags: {match['metadata']['tags']} - recipe: {match['metadata']['how-to-cook']}")
