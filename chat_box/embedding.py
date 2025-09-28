from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L12-v2')

def get_embedding(text: str):
    embedding = model.encode(text, convert_to_numpy = True)
    return embedding

query = "Bữa ăn sáng nhẹ nhàng"
embedding = get_embedding(query)

print("vector:",embedding[:10])
print("shape:", embedding.shape)
