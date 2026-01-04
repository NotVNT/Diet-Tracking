from pinecone import Pinecone, ServerlessSpec
from sentence_transformers import SentenceTransformer
import os
from dotenv import load_dotenv

load_dotenv()

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY_FOR_CHATBOX")
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
    {"id": "1", "title": "cơm gà kho gừng", "ingredients": ["cơm", "đùi gà", "gừng"], "how-to-cook": "Ướp gà với gừng, tỏi, hành, nước mắm, đường, tiêu rồi kho lửa nhỏ với nước xăm xắp đến khi gà mềm, nước sánh lại, ăn kèm cơm trắng.","tags": ["giảm cân", "mặn", "khó làm"], "calories" : 300, "protein": 25},
    {"id": "2", "title": "cơm gà xối mỡ", "ingredients": ["cơm", "đùi gà", "tỏi", "dầu ăn"], "how-to-cook": "Luộc gà với gừng và hành cho thơm, vớt ra chiên giòn da, xối mỡ nóng lên gà cho bóng, nấu cơm bằng nước luộc gà với lá dứa, ăn kèm rau sống và nước mắm tỏi ớt.", "tags": ["tăng cân", "nhiều mỡ", "dễ làm"], "calories": 500, "protein": 25},
    {"id": "3", "title": "cơm trắng với ức gà", "ingredients": ["cơm", "ức gà", "muối tiêu"], "how-to-cook": "Áp chảo ức gà với tiêu và muối cho vàng mặt, nấu cơm trắng bằng nước lọc hoặc nước luộc gà, ăn kèm rau luộc hoặc salad để cân bằng dinh dưỡng.", "tags": ["nhiều protein", "rẻ"], "calories" : 350, "protein": 31},
    {"id": "5", "title": "gà nướng tiêu", "ingredients": ["đùi gà góc tư", "tương ớt", "tương cà", "tương ớt Hàn Quốc", "tương xí muội", "dầu ăn", "hạt nêm", "đường", "nước mắm", "tiêu xanh", "tỏi"], "how-to-cook": "Ngâm sạch gà trong nước muối, ướp với sốt 30p-1h hoặc qua đêm. Bọc giấy bạc, nướng 180°C trong 30p.","tags": ["nướng", "đạm", "calo vừa"], "calories": 400, "protein": 30},
    {"id": "6", "title": "popcorn chicken", "ingredients": ["ức gà", "nước tương", "muối", "bột hành","tỏi băm", "lòng trắng trứng", "bột mì", "giấm", "bột bắp/bột năng"], "how-to-cook": "Rửa sạch ức gà, cắt nhỏ và ướp với gia vị. Áo gà với bột bắp, chiên trong dầu nóng cho đến khi vàng.", "tags": ["chiên", "nhiều calo", "dễ làm"], "calories": 500, "protein": 40},
    {"id": "7", "title": "popcorn chicken", "ingredients": ["ức gà", "nước tương", "muối", "bột hành", "tỏi băm", "lòng trắng trứng", "bột mì", "giấm", "bột bắp/bột năng"], "how-to-cook": "Rửa sạch ức gà, cắt nhỏ và ướp với gia vị. Áo gà với bột bắp, chiên trong dầu nóng cho đến khi vàng.", "tags": ["chiên", "nhiều calo", "dễ làm"], "calories": 500, "protein": 40},
    {"id": "8", "title": "Louisiana Chicken Pasta", "ingredients": ["ức gà", "bột đa dụng", "vụn bánh mì", "parmesan", "muối", "tiêu", "trứng gà", "bơ", "bột cajun", "tỏi", "hành tây", "nấm mỡ", "ớt chuông", "nước dùng gà", "pasta", "whipping cream"], "how-to-cook": "Ngâm muối ức gà, đập mỏng và áo bột. Chiên gà cho đến khi vàng. Xào hành tây với bơ, thêm nấm, ớt, bột cajun, nước dùng và whipping cream. Thêm pasta đã luộc, đảo nhẹ.", "tags": ["chiên", "nhiều calo"], "calories": 700, "protein": 50},
    {"id": "9", "title": "cơm nắm nhân gà cay phô mai", "ingredients": ["ức gà", "tỏi băm", "tương ớt Hàn Quốc", "tương cà", "bột ớt", "đường", "mật ong", "muối", "tiêu", "mè rang", "cơm chín", "phô mai"],"how-to-cook": "Cắt ức gà nhỏ, ướp với gia vị và xào trên chảo nóng. Thêm mè rang. Nắm cơm với phô mai và gà cay, sau đó áp chảo.", "tags": ["có thể đóng hộp", "calo vừa"], "calories": 600, "protein": 3},
    {"id": "10", "title": "Steak nước mắm", "ingredients": ["steak bò dày 1,5 cm", "dầu hào", "nước mắm", "ngò gai", "ngò rí", "hành tím cắt mỏng", "thính gạo rang", "ớt xanh", "ớt đỏ"], "how-to-cook": "Làm nước chấm bằng cách giã ngò gai, ngò rí, tỏi, ớt, thêm đường, chanh, nước mắm và thính gạo. Áp chảo steak ở lửa nhỏ trong 5 phút mỗi mặt cho vừa tới. Cắt nhỏ steak và bày ra đĩa, rưới nước chấm lên trên.", "tags": ["đạm", "áp chảo", "nhiều calo"], "calories": 500, "protein": 40},
    {"id": "11", "title": "thịt xào lá quế", "ingredients": ["thịt heo xay", "dầu hào", "nước tương", "mắm", "đường", "lá quế", "hành", "tỏi"], "how-to-cook": "Băm hành tỏi, phi thơm. Xào thịt heo với hành tỏi, thêm hỗn hợp nước sốt và lá quế, xào đều.", "tags": ["xào", "đạm", "nhanh", "tăng cơ"], "calories": 500,"protein": 40},#<-----------
    {"id": "12", "title": "Canh chay bắp cải", "ingredients": ["1 bắp cải", "cà rốt", "nấm hương", "đậu hũ","hạt nêm", "nước tương", "hạt tiêu", "hẹ hoặc hành lá"], "how-to-cook": "Cà rốt và nấm hương cắt nhỏ, trộn với đậu hũ, hạt nêm, nước tương, hạt tiêu. Bắp cải luộc sơ 5 phút, tách lá và cuộn nhân, cột bằng hẹ hoặc hành lá. Cuốn các cuốn bắp cải vào nồi nước sôi, thêm hạt nêm, nấu lửa vừa 10 phút.", "tags": ["chay", "canh", "ít calo"], "calories": 150, "protein": 8},
    {"id": "13", "title": "Tom Hakai", "ingredients": ["riềng", "sả", "hành", "thịt gà", "nước", "hạt nêm", "nước cốt dừa", "mắm", "thốt nốt", "nước chanh", "cà chua", "nấm"], "how-to-cook": "Xào thịt gà với riềng, sả, hành. Thêm nước và gia vị, đậy nắp nấu chín. Cuối cùng thêm nước cốt dừa, cà chua và nấm.", "tags": ["canh", "đậm đà", "thái", "nhiều calo"], "calories": 500, "protein": 35},
    {"id": "14", "title": "Nâng cấp phở bò ăn liền", "ingredients": ["gói phở", "thịt thăn bò", "tỏi băm", "đầu hành", "dầu ăn"], "how-to-cook": "Ướp thịt bò với tỏi và gói sốt phở. Làm nóng chảo với dầu, xào bò trong 2 phút. Cho bò vào tô phở cùng với hành lá.", "tags": ["nhanh", "tiện lợi", "ngon", "calo vừa"], "calories": 400, "protein": 30},
    {"id": "15", "title": "Nâng cấp phở gà ăn liền", "ingredients": ["thịt gà", "gói phở gà ăn liền", "muối","tiêu", "lá quế"], "how-to-cook": "Ướp thịt gà với muối và tiêu, xào trên chảo nóng đến xém vàng. Thêm gói gia vị phở và đảo đều. Tắt bếp, rắc lá quế, cho gà vào phở.", "tags": ["nhanh", "tiện lợi", "ngon", "calo vừa"], "calories": 350, "protein": 25},
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
    tags = []
    # if "ít calo" in user_query.lower() or "giảm cân" in user_query.lower():
    #     filter["tags"] = {"$in": ["giảm cân"]}
    #     filter["calories"] = {"$lte": 300}#lte = less than equal
    if "tăng cân" in user_query.lower() or "tăng cân" in user_query.lower():
        filter["tags"] = {"$in": ["tăng cân"]}
        filter["calories"] = {"$gte": 350}#gte = greater than equal
    if "nhiều protein" in user_query.lower() or "tăng cơ" in user_query.lower():
        filter["protein"] = {"$gte": 25}
    # if "dễ làm" in user_query.lower():
    #     tags.append("dễ làm")
    # if "khó làm" in user_query.lower():
    #     tags.append("khó làm")
    # if "rẻ" in user_query.lower():
    #     tags.append("rẻ")
    # if "mắc" in user_query.lower():
    #     tags.append("mắc")
    # if "vừa" in user_query.lower():
    #     tags.append("vừa")
    # if "nướng" in user_query.lower():
    #     tags.append("nướng")
    # if "chiên" in user_query.lower():
    #     tags.append("chiên")
    # if "hấp" in user_query.lower():
    #     tags.append("hấp")
    # if "xào" in user_query.lower():
    #     tags.append("xào")
    # if "áp chảo" in user_query.lower():
    #     tags.append("áp chảo")
    return filter


##"đề xuất món ăn tăng cân" "đề xuất món ăn giảm cân" "đề xuất món ăn nhiều protein" "đề xuất món ăn tăng cân và nhiều protein"

query_embedding = get_embedding("đề xuất món ăn tăng cân và tăng cơ")
filters = extract_filter("đề xuất món ăn tăng cân và tăng cơ")

results = index.query(
    vector=query_embedding,
    top_k=3,
    include_metadata=True,
    filter=filters
)

# count = 0
for match in results.matches:
    # count+=1
    print(f" Gợi ý: {match['metadata']['title']} (score: {match['score']:.3f}) - tags: {match['metadata']['tags']} - recipe: {match['metadata']['how-to-cook']} - calo và pro: {match['metadata']['calories']}-{match['metadata']['protein']}")
# print(count)