import numpy as np
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
import pandas as pd
from PIL import Image
from io import BytesIO
import numpy as np
import io
import requests


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

def intent_classification(text):

    messages = [ {"role": "system", "content": """ Bạn là bộ phân loại intent. - Nếu câu hỏi yêu cầu dữ liệu cụ thể từ dataset (ví dụ: calories, protein, allergen, health_tags, thành phần dinh dưỡng, số liệu, "đề xuất món ăn", "cho món ăn phù hơp", "Gợi ý món ăn", "Xin ý tưởng món ăn", "cơm sườn có bao nhiêu calo") → GraphRAG. - Nếu câu hỏi chỉ mang tính hội thoại chung về thực phẩm, món ăn, sức khỏe (ví dụ: "táo có tốt cho sức khỏe không", "ăn nhiều cơm có béo không", "tại sao dị ứng cá không được ăn hải sản", "Ăn chuối mỗi ngày có lợi gì?", "Bỏ bữa sáng có hại sức khỏe không?") → Chatbot. Không cần giải thích thêm"""}, {"role": "user", "content": text} ]

    completion = client.chat.completions.create(
        model="Qwen/Qwen3-4B-Instruct-2507",
        messages=messages,
    )

    return(completion.choices[0].message.content)

import os
from dotenv import load_dotenv
import pandas as pd

from graphrag.config.models.vector_store_schema_config import VectorStoreSchemaConfig
from graphrag.query.context_builder.entity_extraction import EntityVectorStoreKey
from graphrag.query.indexer_adapters import (
    read_indexer_covariates,
    read_indexer_entities,
    read_indexer_relationships,
    read_indexer_reports,
    read_indexer_text_units,
)
from graphrag.query.question_gen.local_gen import LocalQuestionGen
from graphrag.query.structured_search.local_search.mixed_context import (
    LocalSearchMixedContext,
)
from graphrag.query.structured_search.local_search.search import LocalSearch
from graphrag.vector_stores.lancedb import LanceDBVectorStore

load_dotenv()

INPUT_DIR = "E:\MyProjectLibrary\Diet Tracking\diet_tracking_project\chat_box\graphrag\output"
LANCEDB_URI = f"{INPUT_DIR}/lancedb"

COMMUNITY_REPORT_TABLE = "community_reports"
ENTITY_TABLE = "entities"
COMMUNITY_TABLE = "communities"
RELATIONSHIP_TABLE = "relationships"
# COVARIATE_TABLE = "covariates"
TEXT_UNIT_TABLE = "text_units"
COMMUNITY_LEVEL = 2

# read nodes table to get community and degree data
entity_df = pd.read_parquet(f"{INPUT_DIR}/{ENTITY_TABLE}.parquet")
community_df = pd.read_parquet(f"{INPUT_DIR}/{COMMUNITY_TABLE}.parquet")

entities = read_indexer_entities(entity_df, community_df, COMMUNITY_LEVEL)

# load description embeddings to an in-memory lancedb vectorstore
# to connect to a remote db, specify url and port values.
description_embedding_store = LanceDBVectorStore(
    vector_store_schema_config=VectorStoreSchemaConfig(
        index_name="default-entity-description"
    )
)
description_embedding_store.connect(db_uri=LANCEDB_URI)

print(f"Entity count: {len(entity_df)}")
entity_df.head()

relationship_df = pd.read_parquet(f"{INPUT_DIR}/{RELATIONSHIP_TABLE}.parquet")
relationships = read_indexer_relationships(relationship_df)

print(f"Relationship count: {len(relationship_df)}")
relationship_df.head()

# NOTE: covariates are turned off by default, because they generally need prompt tuning to be valuable
# Please see the GRAPHRAG_CLAIM_* settings
# covariate_df = pd.read_parquet(f"{INPUT_DIR}/{COVARIATE_TABLE}.parquet")

# claims = read_indexer_covariates(covariate_df)

# print(f"Claim records: {len(claims)}")
# covariates = {"claims": claims}

report_df = pd.read_parquet(f"{INPUT_DIR}/{COMMUNITY_REPORT_TABLE}.parquet")
reports = read_indexer_reports(report_df, community_df, COMMUNITY_LEVEL)

print(f"Report records: {len(report_df)}")
report_df.head()

text_unit_df = pd.read_parquet(f"{INPUT_DIR}/{TEXT_UNIT_TABLE}.parquet")
text_units = read_indexer_text_units(text_unit_df)

print(f"Text unit records: {len(text_unit_df)}")
text_unit_df.head()

from graphrag.config.enums import ModelType
from graphrag.config.models.language_model_config import LanguageModelConfig
from graphrag.language_model.manager import ModelManager
from graphrag.tokenizer.get_tokenizer import get_tokenizer

api_key = os.environ["HF_TOKEN"]

chat_config = LanguageModelConfig(
    api_key=api_key,
    type=ModelType.Chat,
    model_provider="openai",
    model="Qwen/Qwen3-4B-Instruct-2507",
    api_base = "https://router.huggingface.co/v1",
    model_supports_json = "true",
    concurrent_requests = 1, # Rất quan trọng: HF API miễn phí sẽ khóa bạn nếu gọi nhanh
    async_mode = "threaded",
    retry_strategy = "exponential_backoff",
    max_retries = 10
    )
chat_model = ModelManager().get_or_create_chat_model(
    name="local_search",
    model_type=ModelType.Chat,
    config=chat_config,
)

embedding_config = LanguageModelConfig(
    api_key=api_key,
    type=ModelType.Embedding,
    model_provider="openai",
    model="Qwen/Qwen3-Embedding-8B",
    api_base = "https://router.huggingface.co/nebius/v1",
    concurrent_requests = 1, # Giữ ở mức thấp để tránh lỗi 429 (Too many requests)
    async_mode = "threaded",
    retry_strategy = "exponential_backoff",
    max_retries = 10)

text_embedder = ModelManager().get_or_create_embedding_model(
    name="local_search_embedding",
    model_type=ModelType.Embedding,
    config=embedding_config,
)

tokenizer = get_tokenizer(chat_config)

context_builder = LocalSearchMixedContext(
    community_reports=reports,
    text_units=text_units,
    entities=entities,
    relationships=relationships,
    # if you did not run covariates during indexing, set this to None
    covariates=None,
    entity_text_embeddings=description_embedding_store,
    embedding_vectorstore_key=EntityVectorStoreKey.ID,  # if the vectorstore uses entity title as ids, set this to EntityVectorStoreKey.TITLE
    text_embedder=text_embedder,
    tokenizer=tokenizer,
)

# text_unit_prop: proportion of context window dedicated to related text units
# community_prop: proportion of context window dedicated to community reports.
# The remaining proportion is dedicated to entities and relationships. Sum of text_unit_prop and community_prop should be <= 1
# conversation_history_max_turns: maximum number of turns to include in the conversation history.
# conversation_history_user_turns_only: if True, only include user queries in the conversation history.
# top_k_mapped_entities: number of related entities to retrieve from the entity description embedding store.
# top_k_relationships: control the number of out-of-network relationships to pull into the context window.
# include_entity_rank: if True, include the entity rank in the entity table in the context window. Default entity rank = node degree.
# include_relationship_weight: if True, include the relationship weight in the context window.
# include_community_rank: if True, include the community rank in the context window.
# return_candidate_context: if True, return a set of dataframes containing all candidate entity/relationship/covariate records that
# could be relevant. Note that not all of these records will be included in the context window. The "in_context" column in these
# dataframes indicates whether the record is included in the context window.
# max_tokens: maximum number of tokens to use for the context window.


local_context_params = {
    "text_unit_prop": 0.5,
    "community_prop": 0.1,
    "conversation_history_max_turns": 5,
    "conversation_history_user_turns_only": True,
    "top_k_mapped_entities": 20,
    "top_k_relationships": 20,
    "include_entity_rank": True,
    "include_relationship_weight": True,
    "include_community_rank": False,
    "return_candidate_context": False,
    "embedding_vectorstore_key": EntityVectorStoreKey.ID,  # set this to EntityVectorStoreKey.TITLE if the vectorstore uses entity title as ids
    "max_tokens": 15_000,  # change this based on the token limit you have on your model (if you are using a model with 8k limit, a good setting could be 5000)
}

model_params = {
    "max_tokens": 15_000,  # change this based on the token limit you have on your model (if you are using a model with 8k limit, a good setting could be 1000=1500)
    "temperature": 0.3,
}

search_engine = LocalSearch(
    model=chat_model,
    context_builder=context_builder,
    tokenizer=tokenizer,
    model_params=model_params,
    context_builder_params=local_context_params,
    response_type="multiple paragraphs",  # free form text describing the response type and format, can be anything, e.g. prioritized list, single paragraph, multiple paragraphs, multiple-page report
)

# print("Entities:", len(entities))
# print("Reports:", len(reports))
# print("Relationships:", len(relationships))
# print("Text units:", len(text_units))
# print(report_df["level"].unique())
# print(community_df["level"].unique())

def build_user_profile(age, height, weight, allergy, goal, goal_weight, gender):
    user_profile = f"""Dưới đây là thông tin của người dùng để bạn hiểu rõ về người dùng hơn, và không được nhắc lại thông tin của người dùng trừ khi họ yêu cầu:[
        - Tuổi: {age}
        - Giới tính: {gender}
        - Chiều cao: {height} cm
        - Cân nặng: {weight} kg
        - Dị ứng: {allergy}
        - Mục tiêu: {goal}
        - Cân nặng mục tiêu: {goal_weight}
        ].
"""
    return user_profile

import asyncio

async def local_search(prompt, age, height, weight, allergy, goal, goal_weight, gender):
    user_profile = f"""Dưới đây là thông tin của người dùng để bạn hiểu rõ về người dùng hơn, và không được nhắc lại thông tin của người dùng trừ khi họ yêu cầu:[
            - Tuổi: {age}
            - Giới tính: {gender}
            - Chiều cao: {height} cm
            - Cân nặng: {weight} kg
            - Dị ứng: {allergy}
            - Mục tiêu: {goal}
            - Cân nặng mục tiêu: {goal_weight}
            ].
    """

    json_type = """
        Trả về dữ liệu theo mẫu sau:
        {
            "name": string,
            "calories": float,
            "carbs": float,
            "fat": float,
            "protein": float
        }
"""

    result = await search_engine.search(user_profile + prompt + f"cho 10 món ăn phù hợp với query của người dùng và cho thông tin dinh dưỡng về calories, carb, fat và protein đầy đủ + {json_type}, giải thích ngắn gọn về cách suy luận của bạn")
    # result = await search_engine.search("cho biết thông tin về các chế độ ăn phổ biến trong bảng dữ liệu")
    json_blocks = re.findall(r'\{.*?\}', result.response, re.DOTALL)
    foods = [json.loads(block) for block in json_blocks] 
    return(foods)

# asyncio.run(local_search())


def chat_bot(prompt, conversation_history, age, height, weight, allergy, goal, goal_weight, gender):
    # Define the system message
    system_message = {"role": "system", "content":f"""
        -Bạn là trợ lí dinh dưỡng ảo tiếng việt và trả lời nhẹ nhàng, có thể thêm emoji, trả lời mọi câu hỏi liên quan đến ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống, dị ứng. Nếu người dùng hỏi những câu hỏi không liên quan đến lĩnh vực của bạn thì nhớ nhắc người dùng là bạn chuyên về dinh dưỡng và sức khỏe là chính. Câu trả lời không được hơn 1000 kí tự
        Dưới đây là thông tin của người dùng để bạn hiểu rõ về người dùng hơn, và không được nhắc lại thông tin của người dùng trừ khi họ yêu cầu:[
        - Tuổi: {age}
        - Giới tính: {gender}
        - Chiều cao: {height} cm
        - Cân nặng: {weight} kg
        - Dị ứng: {allergy}
        - Mục tiêu: {goal}
        - Cân nặng mục tiêu: {goal_weight}
        ].
        -Nếu người dùng hỏi **ngoài chủ đề dinh dưỡng**, hãy **từ chối nhẹ nhàng**, ví dụ:> “Xin lỗi, tôi chỉ hỗ trợ về dinh dưỡng và ăn uống. Bạn có muốn tôi gợi ý món ăn hôm nay không?”.
        """}

    messages = list(conversation_history)

    messages.append(system_message)
    messages.append({"role": "user", "content": prompt})

    completion = client.chat.completions.create(
        model="Qwen/Qwen3-4B-Instruct-2507",
        messages=messages,
    )

    bot_response = completion.choices[0].message.content

    messages.append({"role": "assistant", "content": bot_response})

    return bot_response, messages

def more_bot(prompt, conversation_history, age, height, weight, allergy, goal, goal_weight, gender, food):
    system_message = {"role": "system", "content":f"""
        -Bạn là trợ lí dinh dưỡng ảo tiếng việt và trả lời nhẹ nhàng, có thể thêm emoji, trả lời mọi câu hỏi liên quan đến ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống, dị ứng. Nếu người dùng hỏi những câu hỏi không liên quan đến lĩnh vực của bạn thì nhớ nhắc người dùng là bạn chuyên về dinh dưỡng và sức khỏe là chính.
        Dưới đây là thông tin của người dùng để bạn hiểu rõ về người dùng hơn, và không được nhắc lại thông tin của người dùng trừ khi họ yêu cầu:[
        - Tuổi: {age}
        - Giới tính: {gender}
        - Chiều cao: {height} cm
        - Cân nặng: {weight} kg
        - Dị ứng: {allergy}
        - Mục tiêu: {goal}
        - Cân nặng mục tiêu: {goal_weight}
        ].
        -Dưới đây là thông tin đồ ăn lấy từ database, Hãy chọn ngẫu nhiên 3 món khác nhau mỗi lần trả lời và giải thích ngắn gọn, tránh lặp lại cùng một bộ món ăn trong nhiều lần gợi ý.+ {food}
        -Sau đây là yêu cầu đề xuất món ăn của người dùng, hãy trả lời dưới dạng sau.
        ### 🧾 **Định dạng trả lời chuẩn bắt buộc phải đưa ra cho từng món ăn:**

        ⭐
        **Món ăn đề xuất:** (tên món ăn rõ ràng)
        **Lý do chọn:** (1–2 câu nêu lý do chọn món, phù hợp sức khỏe hoặc mục tiêu)
        **Thông tin dinh dưỡng (ước tính cho 1 khẩu phần):**
        - Calo: Khoảng (…) - (…) kcal
        - Protein: … g
        - Carb: … g
        - Fat: … g
        ⭐,

        -Hãy trả lời người dùng 1 cách thân thiện.
        """}
    messages = list(conversation_history) # Create a mutable copy

    messages.append(system_message)
    messages.append({"role": "user", "content": prompt})
    completion = client.chat.completions.create(
        model="Qwen/Qwen3-4B-Instruct-2507",
        messages=messages,
    )

    bot_response = completion.choices[0].message.content

    # Add the bot's response to the history
    messages.append({"role": "assistant", "content": bot_response})

    # Return the bot's response and the updated conversation history
    return bot_response, messages


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

# def google_search(query: str, num_results: int = 3):
#     print("đang sử dụng google")
#     service = build("customsearch", "v1", developerKey=GOOGLE_API_KEY)
#     resp = service.cse().list(q=query, cx=GOOGLE_CX).execute()
#     items = resp['items'][:num_results]
#     results = []
#     for it in items:
#         results.append({
#             "title": it.get("title"),
#             "snippet": it.get("snippet"),
#             "link": it.get("link")
#         })
#     return results

chat_history = []
@app.post("/chat")
async def chatbox(request: ChatRequest):
    print(f"Received request with gender: {request.gender}")
    global chat_history
    
    intent = intent_classification(request.prompt)
    if(intent.lower() == "chatbot"):
        response, chat_history = chat_bot(request.prompt, chat_history, request.age, request.height, request.weight, request.allergy, request.goal, request.goal_weight, request.gender)
        return{"reply": response}
    else:
        print(intent)
        food = await local_search(request.prompt, request.age, request.height, request.weight, request.allergy, request.goal, request.goal_weight, request.gender)
        response, chat_history = more_bot(request.prompt, chat_history, request.age, request.height, request.weight, request.allergy, request.goal, request.goal_weight, request.gender, food)

        return{"reply": response}
        # return{"reply": response}





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