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

    messages = [ { "role": "system", "content": """ Bạn là bộ phân loại intent. - Nếu câu hỏi yêu cầu dữ liệu cụ thể từ dataset chứa thông tin thực phẩm và nguyên liệu (ví dụ: calories, protein, allergen, health_tags, thành phần dinh dưỡng, đề xuất món ăn, cho món ăn phù hợp, Gợi ý món ăn, Xin ý tưởng món ăn, cơm sườn có bao nhiêu calo) → Trả về đúng chữ: GraphRAG - Nếu câu hỏi chỉ mang tính hội thoại chung → Trả về đúng chữ: Chatbot - Không được trả lời thêm bất kỳ giải thích nào khác. """ }, 
     {"role": "user", "content": text} ]

    completion = client.chat.completions.create(
        model="openai/gpt-oss-20b:groq",
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

INPUT_DIR = "F:\Diet-Tracking\chat_box\graphrag\output"
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
    model="openai/gpt-oss-20b:groq",
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
        -Bạn là trợ lí dinh dưỡng ảo tiếng việt và trả lời nhẹ nhàng, có thể thêm emoji, trả lời mọi câu hỏi liên quan đến ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống, dị ứng. Nếu người dùng hỏi những câu hỏi không liên quan đến lĩnh vực của bạn thì nhớ nhắc người dùng là bạn chuyên về dinh dưỡng và sức khỏe là chính. Câu trả lời không được hơn 2000 kí tự
        Dưới đây là thông tin của người dùng để bạn hiểu rõ về người dùng hơn, và không được nhắc lại thông tin của người dùng trừ khi họ yêu cầu:[
        
        Tuổi: {age}
        Giới tính: {gender}
        Chiều cao: {height} cm
        Cân nặng: {weight} kg
        Dị ứng: {allergy}
        Mục tiêu: {goal}
        Cân nặng mục tiêu: {goal_weight}
        ].-Nếu người dùng hỏi ngoài chủ đề dinh dưỡng, hãy từ chối nhẹ nhàng, ví dụ:> “Xin lỗi, tôi chỉ hỗ trợ về dinh dưỡng và ăn uống. Bạn có muốn tôi gợi ý món ăn hôm nay không?”."""}

    messages = list(conversation_history)

    messages.append(system_message)
    messages.append({"role": "user", "content": prompt})

    completion = client.chat.completions.create(
        model="meta-llama/Llama-3.1-8B-Instruct",
        messages=messages,
    )

    bot_response = completion.choices[0].message.content

    messages.append({"role": "assistant", "content": bot_response})

    return bot_response, messages

def more_bot(prompt, conversation_history, age, height, weight, allergy, goal, goal_weight, gender, food):
    food = [
    {
        "dish_id": "dish_001",
        "dish_name": "cơm sườn",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "sườn lợn; gạo tẻ; dưa chuột; cà chua",
        "ingredient_ids": "food_023; food_024; food_025; food_026 ",
        "calories": "616",
        "protein": "14.5",
        "carbs": "93",
        "fat": "16.2",
        "allergen": "không có",
        "phân loại": "tăng_cân",
        "health_tags": "chứa_khoáng_chất:_canxi,contains_cholesterol,giàu_vitamin_c_và_beta-caroten,high_energy,hàm_lượng_carbohydrate_cao,hàm_lượng_chất_xơ_thấp,hàm_lượng_protein_vừa_phải,kali,kẽm,món_chính,sắt"
    },
    {
        "dish_id": "dish_002",
        "dish_name": "cơm rang thập cẩm",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "gạo tẻ; giò lụa; trứng vịt; cà rốt; dưa cải bẹ; bột canh; mỡ",
        "ingredient_ids": "food_024; food_027; food_028; food_029; food_030; food_031",
        "calories": "623",
        "protein": "19.9",
        "carbs": "86.6",
        "fat": "21.9",
        "allergen": "trứng",
        "phân loại": "tăng_cân",
        "health_tags": "high_cholesterol,high_energy,high_fat,không_phù_hợp_cho_người_tiểu_đường,không_tốt_cho_tim_mạch,low_fiber,món_chính,nhiều_natri"
    },
    {
        "dish_id": "dish_003",
        "dish_name": "bún bò nam bộ",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "bún tươi; rau xà lách; rau thơm; thịt bò xào; lạc rang; hành phi; nước chấm pha ớt; tỏi ta; giá đậu xanh; nước dùng",
        "ingredient_ids": "food_032; food_033; food_034; food_035; food_036; food_003; food_037; food_038; food_039; food_040; food_041",
        "calories": "457.7",
        "protein": "26.3",
        "carbs": "71.5",
        "fat": "7.4",
        "allergen": "đậu phộng; tỏi",
        "phân loại": "giữ_cân",
        "health_tags": "có_nguy_cơ_ảnh_hưởng_tim_mạch,giữ_cân,high_carbs,high_fiber,không_phù_hợp_cho_người_tiểu_đường,low_cholesterol,low_fat,moderate_energy,moderate_protein,món_chính,nhiều_natri"
    },
    {
        "dish_id": "dish_004",
        "dish_name": "mỳ vằn thắn",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "mỳ vằn thắn; há cảo hấp; cải ngọt luộc; trứng vịt luộc; thịt lợn xá xíu; nấm hương chần; tôm biển luộc; chanh; ớt đỏ; rau mùi; nước dùng",
        "ingredient_ids": "food_201; food_214;  food_107; food_215; food_028;  food_216;  food_055; food_070;  food_065; food_216; food_217;  food_218;  food_111;  food_219: food_140",
        "calories": "384.1",
        "protein": "20",
        "carbs": "30.5",
        "fat": "20.2",
        "allergen": "trứng; động vật có vỏ (tôm; cua...); gluten (chất gây dị ứng từ bột mì); thịt heo; nấm",
        "phân loại": "giữ_cân",
        "health_tags": "high_carbs,high_cholesterol,không_phù_hợp_cho_người_tiểu_đường,không_tốt_cho_tim_mạch,low_fat,low_fiber,moderate_energy,moderate_protein,món_chính,nhiều_natri"
    },
    {
        "dish_id": "dish_005",
        "dish_name": "miến lươn trộn",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "miến dong; lươn chiên giò; cà rốt; dưa chuột; giá đậu xanh; hành phi; rau kinh giới; lạc rang",
        "ingredient_ids": "food_144;  food_220;  food_029;  food_041; food_039; food_221; food_038",
        "calories": "308.8",
        "protein": "8.5",
        "carbs": "54.9",
        "fat": "6.1",
        "allergen": "đậu phộng; cá; nhóm hành tỏi",
        "phân loại": "giữ_cân",
        "health_tags": "high_carbs,high_vitamin_a,không_phù_hợp_cho_người_tiểu_đường,không_tốt_cho_tim_mạch,low_cholesterol,low_fat,low_fiber,low_protein,moderate_energy,món_chính,nhiều_natri"
    },
    {
        "dish_id": "dish_006",
        "dish_name": "nộm bò kho",
        "category": "salad",
        "ingredients": "bì bò khô; thịt bò khô; gan lợn rán; lạc rang; phồng tôm chiên; su hào; cà rốt; rau kinh giới; nước chấm pha",
        "ingredient_ids": "food_222; food_200; food_066; food_070; food_156;  food_038; food_265; food_111; food_131; food_200; food_054; food_066; food_205; food_159; food_029; food_221; ",
        "calories": "184.8",
        "protein": "18.5",
        "carbs": "11.7",
        "fat": "6.9",
        "allergen": "đậu phộng; động vật có vỏ (tôm; cua...); thịt heo; thịt đỏ; hành tỏi (nhóm allium)",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_dinh_dưỡng,high_iron,high_magnesium,high_protein,high_vitamin_a,low_carbs,low_cholesterol,low_energy,low_fat,natri_vừa_phải,phù_hợp_giảm_cân,salad"
    },
    {
        "dish_id": "dish_007",
        "dish_name": "bánh tráng trộn",
        "category": "salad",
        "ingredients": "bánh đa nem; thịt bò khô; lạc rang; hành khô; tép khô; xoài xanh; sốt bơ; sốt me",
        "ingredient_ids": "food_223; food_222; food_200; food_066; food_070; food_156; food_038; food_224; food_010; food_225; food_202",
        "calories": "436.7",
        "protein": "12.6",
        "carbs": "63.6",
        "fat": "14.4",
        "allergen": "đậu phộng; động vật có vỏ (tôm; cua...); thịt đỏ; hành tỏi (nhóm allium); sữa; trứng; gluten (chất gây dị ứng từ bột mì)",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_vừa_phải,giàu_beta-caroten,high_carbs,high_protein,không_phù_hợp_cho_người_tiểu_đường,không_tốt_cho_tim_mạch,low_cholesterol,moderate_energy,moderate_fat,nhiều_natri,phù_hợp_giữ_cân,salad,ít_vitamin_c"
    },
    {
        "dish_id": "dish_008",
        "dish_name": "cháo thịt",
        "category": "súp/cháo",
        "ingredients": "cháo trắng; thịt lợn nạc xay hầm; hành lá; ruốc thịt lợn; tía tô",
        "ingredient_ids": "food_024;  food_107; food_040; food_039; food_216; food_066; food_029; food_006; food_091; food_203; dish_091",
        "calories": "234",
        "protein": "12.7",
        "carbs": "37",
        "fat": "3.9",
        "allergen": "thịt heo; hành tỏi (nhóm allium)",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_vừa_phải,low_cholesterol,moderate_carbs,moderate_energy,moderate_fat,moderate_fiber,moderate_protein,món_ăn_dễ_tiêu,phù_hợp_giữ_cân,súp/cháo,ít_natri,ít_vitamin_c"
    },
    {
        "dish_id": "dish_009",
        "dish_name": "thịt bò xào ",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "thịt bò; hành tây; dứa; ớt chuông",
        "ingredient_ids": "food_035; food_036; food_003; food_037",
        "calories": "250",
        "protein": "25.9",
        "carbs": "0",
        "fat": "15.4",
        "allergen": "thịt heo; hành tỏi (nhóm allium)",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_dinh_dưỡng,giàu_niacin,giàu_vitamin_b12,high_fat,high_protein,món_chính,nguồn_gốc_động_vật,no_carbs,phù_hợp_chế_độ_keto,ít_đường"
    },
    {
        "dish_id": "dish_010",
        "dish_name": "chè thái",
        "category": "tráng miệng",
        "ingredients": "thạch xanh; thạch trắng ; nước đường; sữa bò tươi; đá",
        "ingredient_ids": "food_226; food_042;",
        "calories": "123",
        "protein": "4.5",
        "carbs": "20.6",
        "fat": "2.5",
        "allergen": "sữa",
        "phân loại": "giảm_cân",
        "health_tags": "calories_trung_bình,chứa_khoáng_chất_(sắt,contains_cholesterol,có_beta-carotene,có_vitamin_a,high_calcium,high_carbs,kẽm,low_fat,magie),nhiều_natri,tráng_miệng,ít_protein,ít_vitamin_c"
    },
    {
        "dish_id": "dish_011",
        "dish_name": "nước mía",
        "category": "đồ uống",
        "ingredients": "mía; quất",
        "ingredient_ids": "food_227",
        "calories": "269.4",
        "protein": "0.1",
        "carbs": "67.3",
        "fat": "0",
        "allergen": "không có",
        "phân loại": "giữ_cân",
        "health_tags": "có_beta-carotene,high_carbs,high_energy,low_protein,ít_canxi,ít_vitamin_a,ít_vitamin_c,đồ_uống"
    },
    {
        "dish_id": "dish_012",
        "dish_name": "nước ép dứa",
        "category": "đồ uống",
        "ingredients": "nước dứa ép; dứa ta nguyên miếng",
        "ingredient_ids": "food_003",
        "calories": "177.6",
        "protein": "4.4",
        "carbs": "40",
        "fat": "0",
        "allergen": "Enzyme bromelain",
        "phân loại": "giảm_cân",
        "health_tags": "canxi_vừa_phải,có_beta-carotene,có_kẽm,có_magie,có_natri,có_sắt,high_carbs,high_energy,high_vitamin_c,rất_giàu_vitamin_a,ít_protein,đồ_uống"
    },
    {
        "dish_id": "dish_013",
        "dish_name": "nước chanh leo",
        "category": "đồ uống",
        "ingredients": "chanh leo tươi; đường kính",
        "ingredient_ids": "food_012; food_054",
        "calories": "66",
        "protein": "0.5",
        "carbs": "15.6",
        "fat": "0.2",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "có_chất_béo_không_bão_hòa,có_kali,có_vitamin_a,high_carbs,low_energy,low_fat,low_protein,ít_canxi,ít_magie,ít_natri,ít_sắt,đồ_uống"
    },
    {
        "dish_id": "dish_014",
        "dish_name": "nước ép dưa hấu",
        "category": "đồ uống",
        "ingredients": "dưa hấu (ruột đỏ)",
        "ingredient_ids": "food_126",
        "calories": "85.1",
        "protein": "5.7",
        "carbs": "13.4",
        "fat": "1",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "canxi_vừa_phải,có_kẽm,high_iron,high_magnesium,high_vitamin_a,high_vitamin_c,low_energy,low_fat,moderate_carbs,protein_vừa_phải,rất_giàu_beta-carotene,ít_natri,đồ_uống"
    },
    {
        "dish_id": "dish_015",
        "dish_name": "nước ép cam",
        "category": "đồ uống",
        "ingredients": "cam(không vỏ)",
        "ingredient_ids": "food_007",
        "calories": "176.8",
        "protein": "3.4",
        "carbs": "40.8",
        "fat": "0",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "có_beta-carotene,có_kẽm,có_magie,có_sắt,có_vitamin_a,high_calcium,high_carbs,high_energy,protein_vừa_phải,rất_giàu_vitamin_c,ít_natri,đồ_uống"
    },
    {
        "dish_id": "dish_016",
        "dish_name": "sữa tươi chân trâu",
        "category": "đồ uống",
        "ingredients": "sữa tươi; đường; trân châu đen;",
        "ingredient_ids": "food_042; food_183; food_228",
        "calories": "424.5",
        "protein": "9.2",
        "carbs": "74.7",
        "fat": "9.9",
        "allergen": "sữa",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_rất_cao,carbohydrate_rất_cao,contains_cholesterol,có_chất_béo_không_bão_hòa,có_kẽm,có_magie,có_sắt,có_vitamin_a,giàu_protein,high_fat,high_potassium,natri_rất_cao,năng_lượng_rất_cao,đồ_uống"
    },
    {
        "dish_id": "dish_017",
        "dish_name": "sữa ngô",
        "category": "đồ uống",
        "ingredients": "ngô",
        "ingredient_ids": "food_063",
        "calories": "123.8",
        "protein": "4.3",
        "carbs": "21",
        "fat": "2.5",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "có_magie,có_sắt,high_calcium,low_fat,moderate_carbs,moderate_energy,protein_vừa_phải,đồ_uống"
    },
    {
        "dish_id": "dish_018",
        "dish_name": "nước trà hoa cúc",
        "category": "đồ uống",
        "ingredients": "trà hoa cúc; nước đường; quất; cam thảo;",
        "ingredient_ids": "food_227; food_229",
        "calories": "18.3",
        "protein": "0.1",
        "carbs": "4.5",
        "fat": "0",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "canxi_thấp,có_vitamin_a,kali_rất_thấp,không_có_chất_béo,low_carbs,protein_rất_thấp,very_low_energy,đồ_uống"
    },
    {
        "dish_id": "dish_019",
        "dish_name": "cà phê trứng",
        "category": "đồ uống",
        "ingredients": "lòng đỏ trứng; cà phê đen; sữa đặc;",
        "ingredient_ids": "food_230; food_087",
        "calories": "228.8",
        "protein": "8.7",
        "carbs": "8.7",
        "fat": "17.7",
        "allergen": "trứng; sữa",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_protein,high_energy,high_fat,high_potassium,moderate_carbs,rất_giàu_vitamin_a,đồ_uống"
    },
    {
        "dish_id": "dish_020",
        "dish_name": "chè vừng đen ",
        "category": "tráng miệng",
        "ingredients": "vừng đen; lạc rang; cùi dừa già; bánh quấy;",
        "ingredient_ids": "food_231; food_038; food_209; food_210; ",
        "calories": "457.1",
        "protein": "12.8",
        "carbs": "54.9",
        "fat": "20.7",
        "allergen": "vừng; lạc",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_rất_cao,có_beta-carotene,giàu_protein,high_carbs,high_cholesterol,high_fat,high_iron,high_zinc,magie_cao,năng_lượng_rất_cao,tráng_miệng,vitamin_a_rất_thấp,vitamin_c_rất_thấp,ít_natri"
    },
    {
        "dish_id": "dish_021",
        "dish_name": "chè kem dừa",
        "category": "tráng miệng",
        "ingredients": " nước cốt dừa; kem dừa; trân châu; thạch dừa; lạc rang; trân châu đường đen; thạch xanh; cùi dừa;",
        "ingredient_ids": "food_009; food_038; food_183; food_228; food_226; food_209; ",
        "calories": "385.5",
        "protein": "5.5",
        "carbs": "66.5",
        "fat": "10.8",
        "allergen": "lạc",
        "phân loại": "giữ_cân",
        "health_tags": "có_chất_béo_không_bão_hòa,có_kẽm,có_vitamin_a,high_calcium,high_carbs,high_energy,high_fat,high_iron,high_potassium,magie_cao,natri_vừa_phải,protein_vừa_phải,tráng_miệng"
    },
    {
        "dish_id": "dish_022",
        "dish_name": "nha đam trộn mít",
        "category": "tráng miệng",
        "ingredients": "trân châu đường đen; trân châu trắng; mít; caramel; nha đam; nước cốt dừa; sữa đặc; hạt chia;",
        "ingredient_ids": "food_183; food_228; food_014; food_239; food_211; food_212; food_087; food_213",
        "calories": "401.1",
        "protein": "8.3",
        "carbs": "79",
        "fat": "5.8",
        "allergen": "sữa",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_cao,carbohydrate_rất_cao,contains_cholesterol,có_chất_béo_không_bão_hòa,có_kẽm,có_sắt,có_vitamin_a,giàu_protein,high_energy,kali_rất_cao,magie_cao,moderate_fat,tráng_miệng,ít_natri"
    },
    {
        "dish_id": "dish_023",
        "dish_name": "chè thập cẩm",
        "category": "tráng miệng",
        "ingredients": "nếp cẩm; thạch dừa; mít; thạch matcha; trân châu; thạch nha đam; trân châu trắng; nước cốt dừa;",
        "ingredient_ids": "food_242; food_226; food_236; food_014; food_183; food_228;  food_212",
        "calories": "458.7",
        "protein": "4.6",
        "carbs": "103.9",
        "fat": "2.7",
        "allergen": "không có",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_cao,carbohydrate_rất_cao,có_kẽm,có_magie,có_sắt,kali_cao,low_fat,năng_lượng_rất_cao,tráng_miệng,vitamin_a_rất_thấp,ít_natri,ít_protein"
    },
    {
        "dish_id": "dish_024",
        "dish_name": "caramen hoa quả tươi",
        "category": "tráng miệng",
        "ingredients": "thanh long; mít; chuối; xoài chín; táo; dâu tây; bơ; nho; caramen; nước sốt; nước cốt dừa;",
        "ingredient_ids": "food_019; food_014; food_002; food_010; food_001; food_257; food_013; food_008; ",
        "calories": "251.5",
        "protein": "5.8",
        "carbs": "41.5",
        "fat": "6.9",
        "allergen": "sữa",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_cao,có_chất_béo_không_bão_hòa,có_kẽm,có_magie,có_sắt,có_vitamin_a,high_carbs,kali_rất_cao,moderate_energy,moderate_fat,protein_vừa_phải,tráng_miệng,ít_natri"
    },
    {
        "dish_id": "dish_025",
        "dish_name": "kem sữa chua trân châu",
        "category": "tráng miệng",
        "ingredients": "sữa chua đặc có đường; trân châu trắng; nước cốt dừa;",
        "ingredient_ids": "food_064; food_183; food_228; food_212",
        "calories": "284.2",
        "protein": "6.4",
        "carbs": "47.8",
        "fat": "7.5",
        "allergen": "sữa",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_rất_cao,contains_cholesterol,có_chất_béo_không_bão_hòa,có_kẽm,có_sắt,có_vitamin_a,high_carbs,kali_cao,magie_thấp,moderate_energy,moderate_fat,natri_vừa_phải,protein_vừa_phải,tráng_miệng"
    },
    {
        "dish_id": "dish_026",
        "dish_name": "háo cảo hấp",
        "category": "món phụ",
        "ingredients": "bột mì; thịt heo",
        "ingredient_ids": "food_214;  food_107",
        "calories": "224",
        "protein": "8.24",
        "carbs": "21.2",
        "fat": "11.8",
        "allergen": "không có",
        "phân loại": "giữ_cân",
        "health_tags": "canxi_thấp,carbohydrate_vừa,chất_béo_vừa,chất_xơ_thấp,contains_cholesterol,không_có_vitamin_a,không_có_vitamin_c,món_phụ,natri_cao,năng_lượng_vừa,protein_vừa,đường_thấp"
    },
    {
        "dish_id": "dish_027",
        "dish_name": "thịt lợn xá xíu",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "thịt lợn; mật ong; tỏi; hành củ; dầu thực vật; nước mắm; ngũ vị hương",
        "ingredient_ids": "food_216;  food_055; food_070;  food_065; food_216; food_217",
        "calories": "846",
        "protein": "50.3",
        "carbs": "7.3",
        "fat": "68.2",
        "allergen": "nước mắm",
        "phân loại": "tăng_cân",
        "health_tags": "chất_xơ_thấp,contains_cholesterol,có_canxi,có_sắt,có_vitamin_a,có_vitamin_c,high_energy,high_fat,high_protein,low_carbs,món_chính,natri_cao"
    },
    {
        "dish_id": "dish_028",
        "dish_name": "thịt bò khô",
        "category": "món phụ",
        "ingredients": "thịt bò; muối; tiêu; tỏi; ớt; ",
        "ingredient_ids": "food_222; food_200; food_066; food_070; food_156",
        "calories": "250",
        "protein": "30",
        "carbs": "10",
        "fat": "10",
        "allergen": "thịt bò",
        "phân loại": "giữ_cân",
        "health_tags": "có_thêm_đường,có_thể_gây_dị_ứng,giàu_protein,giàu_vi_chất_dinh_dưỡng,low_carbs,món_phụ,nhiều_natri,thực_phẩm_chế_biến_sẵn"
    },
    {
        "dish_id": "dish_029",
        "dish_name": "nước hầm xương bò",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "thịt bò; hành tây; cà rốt; cần tây; củ cải trắng; muối; tiêu; gừng; tỏi; ",
        "ingredient_ids": "food_222; food_036; food_029; food_075; food_157; food_200; food_066; food_113; food_040",
        "calories": "19",
        "protein": "4",
        "carbs": "0.3",
        "fat": "0.2",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "digestive_health,giàu_amino_acid,giàu_collagen,giàu_gelatin,món_chính,ít_calo"
    },
    {
        "dish_id": "dish_030",
        "dish_name": "cá thu chín",
        "category": "món chính; ăn trưa; ăn tối ",
        "ingredients": "phi lê cá thu; muối; tiêu; nước mắm; hành tây; tỏi",
        "ingredient_ids": "food_161; food_200; food_066; food_216; food_036; food_040",
        "calories": "189",
        "protein": "24.8",
        "carbs": "0",
        "fat": "9.2",
        "allergen": "cá",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_omega-3,giàu_vitamin_b12,high_vitamin_d,món_chính,protein_chất_lượng_cao"
    },
    {
        "dish_id": "dish_031",
        "dish_name": "cá trê chín",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "phi lê cá trê; rau thìa là; muối; tiêu; nước mắm; hành tây; tỏi",
        "ingredient_ids": "food_238; food_268; food_200; food_066; food_216; food_036; food_040",
        "calories": "144",
        "protein": "18.4",
        "carbs": "0",
        "fat": "7.2",
        "allergen": "cá",
        "phân loại": "giảm_cân",
        "health_tags": "chứa_omega-3,giàu_vitamin_b12,món_chính,protein_nạc,ít_calo"
    },
    {
        "dish_id": "dish_032",
        "dish_name": "da heo chiên giòn",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "da heo; muối; dầu ăn; tiêu; tỏi; ớt; bột ngọt",
        "ingredient_ids": "food_226; food_042; food_200; food_267; food_066; food_070; food_244; food_205",
        "calories": "576.7",
        "protein": "54.1",
        "carbs": "0",
        "fat": "40.3",
        "allergen": "không có",
        "phân loại": "tăng_cân",
        "health_tags": "chứa_collagen,giàu_protein,hàm_lượng_natri_rất_cao,keto_friendly,món_chính,no_carbs"
    },
    {
        "dish_id": "dish_033",
        "dish_name": "cá tuyết chín",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "cá tuyết; rau thìa là; dầu thực vật",
        "ingredient_ids": "food_162; food_268; food_065",
        "calories": "105",
        "protein": "22.8",
        "carbs": "0",
        "fat": "0.9",
        "allergen": "cá",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_selenium,hỗ_trợ_tim_mạch,món_chính,protein_chất_lượng_cao,ít_béo"
    },
    {
        "dish_id": "dish_034",
        "dish_name": "hạt hướng dương rang",
        "category": "món phụ",
        "ingredients": "hạt hướng dương; muối; dầu ăn",
        "ingredient_ids": "food_269; food_200; food_267",
        "calories": "582",
        "protein": "19.3",
        "carbs": "24.1",
        "fat": "49.8",
        "allergen": "không có",
        "phân loại": "tăng_cân",
        "health_tags": "giàu_chất_béo_lành_mạnh,giàu_vitamin_e,high_fiber,hàm_lượng_natri_cao,món_phụ"
    },
    {
        "dish_id": "dish_035",
        "dish_name": "cá rô phi chín",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "cá rô phi; rau thìa là; dầu thực vật",
        "ingredient_ids": "food_163; food_268; food_065",
        "calories": "128",
        "protein": "26.2",
        "carbs": "0",
        "fat": "2.7",
        "allergen": "cá",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_selenium,giàu_vitamin_b12,món_chính,protein_nạc,ít_béo"
    },
    {
        "dish_id": "dish_036",
        "dish_name": "cá hồi atlantis; nướng",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "cá hồi; rau thìa là; dầu thực vật",
        "ingredient_ids": "food_165; food_268; food_065",
        "calories": "208",
        "protein": "22.1",
        "carbs": "0",
        "fat": "12.4",
        "allergen": "cá",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_omega_3,gluten_free,high_vitamin_d,hỗ_trợ_tim_mạch,món_chính,tốt_cho_não_bộ"
    },
    {
        "dish_id": "dish_037",
        "dish_name": "ức gà; không da không xương; đã nấu chín",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "ước gà không da; muối; tiêu; nước mắm; hành tây; tỏi",
        "ingredient_ids": "food_168; food_200; food_066; food_216; food_036; food_040",
        "calories": "151",
        "protein": "30.54",
        "carbs": "0",
        "fat": "3.17",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_protein,gluten_free,hỗ_trợ_giảm_cân,hỗ_trợ_tăng_cơ,keto_friendly,low_fat,món_chính"
    },
    {
        "dish_id": "dish_038",
        "dish_name": "dưa cải hẹ",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "rau cải; hẹ; muối; ớt; tỏi",
        "ingredient_ids": "food_272; food_273; food_200; food_244; food_040",
        "calories": "25",
        "protein": "2",
        "carbs": "4",
        "fat": "0.5",
        "allergen": "Mù tạt; Họ hành tỏi",
        "phân loại": "giảm_cân",
        "health_tags": "có_nguồn_gốc_thực_vật,dairy_free,giàu_vitamin_k,gluten_free,heart_health,high_fiber,high_vitamin_c,món_chính,nguồn_chất_chống_oxy_hóa,probiotic_source,vegetarian_friendly,ít_calo"
    },
    {
        "dish_id": "dish_039",
        "dish_name": "hạt diêm mạch; nấu chín",
        "category": "món phụ",
        "ingredients": "hạt diêm mạch; muối ",
        "ingredient_ids": "food_271; food_200",
        "calories": "120",
        "protein": "4.4",
        "carbs": "21.3",
        "fat": "1.9",
        "allergen": "cá",
        "phân loại": "giảm_cân",
        "health_tags": "chỉ_số_đường_huyết_thấp,gluten_free,high_fiber,món_phụ,protein_hoàn_chỉnh,vegan_friendly"
    },
    {
        "dish_id": "dish_040",
        "dish_name": "cháo trắng",
        "category": "món chính; ăn trưa; ăn tối; ăn chay; ăn sáng",
        "ingredients": "gạo tẻ; giò lụa; trứng vịt; cà rốt; dưa cải bẹ; bột canh; mỡ",
        "ingredient_ids": "food_024; food_027; food_028; food_029; ",
        "calories": "71.18",
        "protein": "1.76",
        "carbs": "14.71",
        "fat": "0.59",
        "allergen": "Chất béo bão hòa; Chất béo chuyển hóa; Cholesterol; Đường bổ sung; Tổng lượng đường",
        "phân loại": "giảm_cân",
        "health_tags": "cholesterol_free,có_chất_xơ,có_khoáng_chất,có_vitamin_nhóm_b,low_fat,món_chính,ít_calo,ít_đường,ăn_chay,ăn_sáng"
    },
    {
        "dish_id": "dish_041",
        "dish_name": "thịt lợn nạc xay hầm",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "thịt lợn; tỏi; hành phi; nước mắm; muối; tiêu; cà rốt; khoai tây",
        "ingredient_ids": "food_107; food_040; food_039; food_216; food_066; food_029; food_006",
        "calories": "250",
        "protein": "20",
        "carbs": "2",
        "fat": "15",
        "allergen": "Cholesterol; Chất béo bão hòa; Chất béo chuyển hóa (nếu chiên/xào thêm dầu); Natri (muối)",
        "phân loại": "giữ_cân",
        "health_tags": "contains_cholesterol,có_khoáng_chất_thiết_yếu,có_vitamin_nhóm_b,giàu_protein,low_carbs,món_chính,nhiều_chất_béo_bão_hòa"
    },
    {
        "dish_id": "dish_042",
        "dish_name": "Rau khoai lang xào tỏi",
        "category": "Món phụ; Món chay; Low-carb",
        "ingredients": "rau khoai lang; tỏi; hạt nêm; mì chính; dầu thực vật",
        "ingredient_ids": "food_207; food_205; food_204; food_040; food_065",
        "calories": "114",
        "protein": "4",
        "carbs": "6.5",
        "fat": "8",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "low-carb,món_chay,món_phụ"
    },
    {
        "dish_id": "dish_043",
        "dish_name": "Rau cải xoong xào tỏi",
        "category": "Món phụ; Món chay; Low-carb",
        "ingredients": "Cải xoong; Tỏi; Dầu thực vật; Hạt nêm",
        "ingredient_ids": "food_208; food_207; food_065; food_040; food_207",
        "calories": "83",
        "protein": "5.4",
        "carbs": "3.6",
        "fat": "5.2",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "high_calcium,high_fiber,low-carb,món_chay,món_phụ,tốt_cho_xương,vitamin_c"
    },
    {
        "dish_id": "dish_044",
        "dish_name": "Rau cải ngồng xào tỏi",
        "category": "Món phụ; Món chay; Low-carb",
        "ingredients": "Rau cải ngồng; Tỏi; Dầu thực vật; Mì chính; Hạt nêm",
        "ingredient_ids": "food_205; food_040; food_065; food_207; food_215",
        "calories": "122",
        "protein": "5.8",
        "carbs": "13.3",
        "fat": "5",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_vitamin_a_(beta-caroten),high_potassium,high_vitamin_c,low-carb,món_chay,món_phụ"
    },
    {
        "dish_id": "dish_045",
        "dish_name": "Rau cải ngọt xào",
        "category": "Món phụ; Món chay; Low-carb",
        "ingredients": "Rau cải ngọt; Dầu thực vật; Bột canh; Mì chính",
        "ingredient_ids": "food_205; food_065; food_207; food_215",
        "calories": "62",
        "protein": "1.1",
        "carbs": "3.1",
        "fat": "5",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "high_vitamin_a,low-carb,low_energy,món_chay,món_phụ,nguồn_chất_xơ"
    },
    {
        "dish_id": "dish_046",
        "dish_name": "Rau cải chíp xào nấm",
        "category": "món chính; ăn trưa; ăn tối; Món chay; High-protein",
        "ingredients": "Cải chíp; Nấm; Dầu thực vật; Muối",
        "ingredient_ids": "food_065; food_218; food_200; food_127",
        "calories": "216",
        "protein": "14.3",
        "carbs": "13.6",
        "fat": "11.7",
        "allergen": "Nấm (có thể gây dị ứng với một số người)",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_đạm_thực_vật,heart_health,high-protein,high_fiber,high_iron,món_chay,món_chính"
    },
    {
        "dish_id": "dish_047",
        "dish_name": "Mực xào thập cẩm",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Mực; Ngô bao tử; Hành tây; Cần tây; Dầu thực vật; Hạt nêm",
        "ingredient_ids": "food_065; food_207; food_189; food_240; food_036; food_075",
        "calories": "154",
        "protein": "11.3",
        "carbs": "13.3",
        "fat": "6.2",
        "allergen": "Hải sản (Mực)",
        "phân loại": "giảm_cân",
        "health_tags": "high-protein,high_protein,high_vitamin_c,món_chính,nguồn_canxi,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_048",
        "dish_name": "Mướp đắng xào trứng",
        "category": "món chính; ăn trưa; ăn tối; Low-carb",
        "ingredients": "Mướp đắng; Trứng gà; Dầu thực vật; Bột canh; Hạt nêm; Mì chính",
        "ingredient_ids": "food_205; food_065; food_207; food_241; food_045;",
        "calories": "140",
        "protein": "7.5",
        "carbs": "5.4",
        "fat": "10",
        "allergen": "Trứng",
        "phân loại": "giảm_cân",
        "health_tags": "high_vitamin_a,hỗ_trợ_thanh_nhiệt,kiểm_soát_đường_huyết,low-carb,món_chính"
    },
    {
        "dish_id": "dish_049",
        "dish_name": "Lươn xào sả ớt",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Lươn; Ớt ngọt; Dầu thực vật; Muối; Sả; Ớt",
        "ingredient_ids": "food_065; food_220; food_037; food_243; food_244; food_200",
        "calories": "358",
        "protein": "27.7",
        "carbs": "0",
        "fat": "27.5",
        "allergen": "Cá (Lươn)",
        "phân loại": "giữ_cân",
        "health_tags": "bồi_bổ_sức_khỏe,high-protein,high_protein,high_vitamin_a,món_chính,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_050",
        "dish_name": "Mực xào dứa",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Mực; Dứa; Dầu thực vật; Muối",
        "ingredient_ids": "food_065; food_003; food_189; food_200",
        "calories": "203",
        "protein": "14.5",
        "carbs": "11.1",
        "fat": "11.1",
        "allergen": "Hải sản (Mực)",
        "phân loại": "giữ_cân",
        "health_tags": "digestive_health,high-protein,high_protein,món_chính,vitamin_c"
    },
    {
        "dish_id": "dish_051",
        "dish_name": "Lòng gà xào mướp; giá",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Mướp; Mề gà; Tim gà; Gan gà; Hành lá; Dầu thực vật; Bột canh",
        "ingredient_ids": "food_065; food_245; food_246; food_247; food_248; food_091; food_249",
        "calories": "196",
        "protein": "16.5",
        "carbs": "9.1",
        "fat": "10.5",
        "allergen": "Nội tạng động vật (Gà)",
        "phân loại": "giảm_cân",
        "health_tags": "high-protein,high_iron,high_vitamin_a,món_chính,tốt_cho_máu"
    },
    {
        "dish_id": "dish_052",
        "dish_name": "Lòng xào dưa",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Dưa chua; Lòng lợn; Cà chua; Dầu thực vật; Mì chính; Hạt nêm",
        "ingredient_ids": "food_205; food_065; food_207; food_235; food_026; food_250",
        "calories": "240",
        "protein": "6.6",
        "carbs": "3.7",
        "fat": "22.1",
        "allergen": "Nội tạng động vật",
        "phân loại": "giữ_cân",
        "health_tags": "cung_cấp_lợi_khuẩn_(từ_dưa_chua),giàu_chất_béo,món_chính"
    },
    {
        "dish_id": "dish_053",
        "dish_name": "Vịt rang",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Thịt vịt (cả xương); Riềng; Sả; Hạt tiêu; Muối",
        "ingredient_ids": "food_252; food_243; food_200; food_066; food_253",
        "calories": "2047",
        "protein": "59",
        "carbs": "1",
        "fat": "201",
        "allergen": "Không có",
        "phân loại": "tăng_cân",
        "health_tags": "high-protein,high_energy,high_iron,high_protein,high_vitamin_a,món_chính"
    },
    {
        "dish_id": "dish_054",
        "dish_name": "Gan xào giá",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Gan lợn; Giá đỗ; Hành lá; Dầu thực vật; Muối",
        "ingredient_ids": "food_065; food_233; food_041; food_091; food_200",
        "calories": "370",
        "protein": "48.9",
        "carbs": "18.1",
        "fat": "11.3",
        "allergen": "Nội tạng động vật (Gan lợn)",
        "phân loại": "giữ_cân",
        "health_tags": "high-protein,high_iron,món_chính,siêu_thực_phẩm_giàu_vitamin_a,tốt_cho_máu"
    },
    {
        "dish_id": "dish_055",
        "dish_name": "Thịt bò xào rau muống",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Rau muống; Thịt bò loại 1; Dầu thực vật; Bột canh; Mì chính",
        "ingredient_ids": "food_205; food_065; food_198; food_222;  food_031;",
        "calories": "175",
        "protein": "13.9",
        "carbs": "5.2",
        "fat": "11",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "high-protein,high_iron,high_protein,high_vitamin_a,món_chính,tốt_cho_máu"
    },
    {
        "dish_id": "dish_056",
        "dish_name": "Tôm đồng rang",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Tôm đồng; Đường kính; Dầu thực vật; Bột canh",
        "ingredient_ids": "food_065; food_111;  food_228; food_031",
        "calories": "103",
        "protein": "7.4",
        "carbs": "10",
        "fat": "3.7",
        "allergen": "Hải sản (Tôm)",
        "phân loại": "giảm_cân",
        "health_tags": "high-protein,high_protein,món_chính,nguồn_canxi,ít_béo"
    },
    {
        "dish_id": "dish_057",
        "dish_name": "Trứng đúc thịt rán",
        "category": "món chính; ăn trưa; ăn tối; Ăn sáng",
        "ingredients": "Trứng vịt; Thịt lợn nạc vai; Dầu thực vật",
        "ingredient_ids": "food_065; food_028; food_135",
        "calories": "282",
        "protein": "10.7",
        "carbs": "0.8",
        "fat": "26.2",
        "allergen": "Trứng",
        "phân loại": "giữ_cân",
        "health_tags": "high_energy,high_vitamin_a,món_chính,nguồn_kali,ăn_sáng"
    },
    {
        "dish_id": "dish_058",
        "dish_name": "Thịt lợn ba chỉ rang cháy cạnh",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Thịt ba chỉ; Đường; Muối",
        "ingredient_ids": "food_139; food_200; food_228",
        "calories": "798",
        "protein": "50",
        "carbs": "5",
        "fat": "65",
        "allergen": "Không có",
        "phân loại": "tăng_cân",
        "health_tags": "high-protein,high_energy,high_protein,món_chính,nguồn_kali"
    },
    {
        "dish_id": "dish_059",
        "dish_name": "Trạch tẩm bột chiên",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Trạch; Trứng gà; Bột mỳ; Bột chiên giòn; Dầu thực vật",
        "ingredient_ids": "food_065; food_254; food_045; food_214; ",
        "calories": "886",
        "protein": "62.7",
        "carbs": "73.1",
        "fat": "38.1",
        "allergen": "Cá; Trứng; Gluten (Bột mỳ)",
        "phân loại": "tăng_cân",
        "health_tags": "high-protein,high_energy,món_chính,nguồn_canxi_dồi_dào,siêu_giàu_đạm"
    },
    {
        "dish_id": "dish_060",
        "dish_name": "Tôm sốt cà chua",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Thịt tôm; Cà chua; Nước mắm; Dầu thực vật",
        "ingredient_ids": "food_065;food_111;food_026; food_216",
        "calories": "105",
        "protein": "16.5",
        "carbs": "3.1",
        "fat": "2.9",
        "allergen": "Hải sản (Tôm)",
        "phân loại": "giảm_cân",
        "health_tags": "heart_health,high-protein,high_protein,món_chính,nguồn_canxi,ít_béo"
    },
    {
        "dish_id": "dish_061",
        "dish_name": "Thịt bò bít tết khoai tây chiên",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Thịt bò thăn; Khoai tây; Đường; Dầu thực vật; Bột canh",
        "ingredient_ids": "food_125; food_006; food_054; food_031",
        "calories": "210",
        "protein": "20",
        "carbs": "13",
        "fat": "8",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "high-protein,high_protein,món_chính,nguồn_kali,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_062",
        "dish_name": "caramen",
        "category": "món phụ;",
        "ingredients": "trứng; sữa; đường",
        "ingredient_ids": "food_045; food_042; food_054",
        "calories": "77.4",
        "protein": "3.7",
        "carbs": "9.1",
        "fat": "2.9",
        "allergen": "sữa trứng",
        "phân loại": "giảm_cân",
        "health_tags": "có_chứa_sữa,có_chứa_trứng,có_nguồn_gốc_động_vật,không_phù_hợp_cho_người_ăn_chay,món_phụ,món_tráng_miệng_ngọt,nguồn_canxi,nguồn_đạm"
    },
    {
        "dish_id": "dish_063",
        "dish_name": "thạch xanh",
        "category": "Món phụ",
        "ingredients": "bột rau câu;",
        "ingredient_ids": "food_226",
        "calories": "25.42",
        "protein": "0.52",
        "carbs": "6.01",
        "fat": "0",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "cholesterol_free,có_khoáng_chất_vi_lượng,có_đường_bổ_sung,low_fat,món_phụ,ít_calo,ít_protein,ít_vitamin"
    },
    {
        "dish_id": "dish_064",
        "dish_name": "trân châu đường đen",
        "category": "tráng miệng",
        "ingredients": "bột năng; đường",
        "ingredient_ids": "food_183; food_228",
        "calories": "370",
        "protein": "0",
        "carbs": "0",
        "fat": "0",
        "allergen": "chứa gluten",
        "phân loại": "giữ_cân",
        "health_tags": "không_vitamin_đáng_kể,low_fiber,nguy_cơ_tăng_cân_nếu_dùng_nhiều.,nhiều_calo,nhiều_đường,no_fat,tráng_miệng,ít_protein"
    },
    {
        "dish_id": "dish_065",
        "dish_name": "trân châu trắng",
        "category": "tráng miệng",
        "ingredients": "bột năng; đường",
        "ingredient_ids": "food_183; food_228",
        "calories": "370",
        "protein": "0",
        "carbs": "0",
        "fat": "0",
        "allergen": "chứa gluten",
        "phân loại": "giữ_cân",
        "health_tags": "không_vitamin_đáng_kể,low_fiber,nguy_cơ_tăng_cân_nếu_dùng_nhiều.,nhiều_calo,nhiều_đường,no_fat,tráng_miệng,ít_protein"
    },
    {
        "dish_id": "dish_066",
        "dish_name": "Mực trứng chiên",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Mực trứng; Dầu thực vật",
        "ingredient_ids": "food_065; food_189",
        "calories": "462",
        "protein": "50.8",
        "carbs": "9.9",
        "fat": "24.4",
        "allergen": "Hải sản (Mực)",
        "phân loại": "giữ_cân",
        "health_tags": "high-protein,high_protein,high_vitamin_c,món_chính,nguồn_kali,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_067",
        "dish_name": "Nem rán / Chả giò chiên",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Thịt lợn nạc vai; Hành tây; Bánh đa; Dầu thực vật; Miến dong; Mộc nhĩ; Hành lá; Trứng vịt",
        "ingredient_ids": "food_065; food_089; food_036; food_158; food_144; food_028; food_091; food_255",
        "calories": "432.1",
        "protein": "7.8",
        "carbs": "83.1",
        "fat": "7.5",
        "allergen": "Trứng",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_glucid,high_energy,món_chính,nguồn_kali"
    },
    {
        "dish_id": "dish_068",
        "dish_name": "Khoai tây chiên",
        "category": "Món phụ",
        "ingredients": "Khoai tây; Dầu; Bột canh",
        "ingredient_ids": "food_065;food_006; food_031",
        "calories": "164.4",
        "protein": "1.6",
        "carbs": "17",
        "fat": "10",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "high_energy,món_phụ,nguồn_kali"
    },
    {
        "dish_id": "dish_069",
        "dish_name": "Chả cá rán",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Cá rô phi; Dầu thực vật; Muối",
        "ingredient_ids": "food_065;food_163;food_200",
        "calories": "235",
        "protein": "19.7",
        "carbs": "0",
        "fat": "17.3",
        "allergen": "Cá (Cá rô phi)",
        "phân loại": "giữ_cân",
        "health_tags": "high-protein,high_protein,món_chính,nguồn_canxi,ít_glucid"
    },
    {
        "dish_id": "dish_070",
        "dish_name": "Đùi gà rán",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Thịt đùi gà; Dầu thực vật; Ngũ vị hương",
        "ingredient_ids": "food_065;food_099;food_217",
        "calories": "251",
        "protein": "24.3",
        "carbs": "0.9",
        "fat": "17.4",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "high-protein,high_protein,món_chính,nguồn_kali,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_071",
        "dish_name": "Cá thu rán sốt cà chua",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Cá thu; Cà chua; Dầu thực vật; Thìa là; Muối",
        "ingredient_ids": "food_065;food_161; food_155;food_200",
        "calories": "511",
        "protein": "45.8",
        "carbs": "1.4",
        "fat": "35.8",
        "allergen": "Cá (Cá thu)",
        "phân loại": "tăng_cân",
        "health_tags": "high-protein,high_calcium,món_chính,nguồn_kali_dồi_dào,siêu_giàu_đạm,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_072",
        "dish_name": "Cá trôi rán sốt cà chua",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Cá trôi (cả xương); Cà chua; Hành lá; Mì chính; Bột canh; Dầu thực vật",
        "ingredient_ids": "food_205; food_193;food_026; food_091; food_205; food_031",
        "calories": "449",
        "protein": "36.5",
        "carbs": "6.5",
        "fat": "30.7",
        "allergen": "Cá (Cá trôi)",
        "phân loại": "giữ_cân",
        "health_tags": "high-protein,high_calcium,high_protein,món_chính,nguồn_kali,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_073",
        "dish_name": "Cá rô đồng rán",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Cá rô đồng (nguyên con); Gừng; Thì là; Hạt tiêu; Dầu thực vật; Bột canh",
        "ingredient_ids": "food_065; food_256; food_113; food_155; food_066; food_031",
        "calories": "333",
        "protein": "22.1",
        "carbs": "2.5",
        "fat": "26.2",
        "allergen": "Cá (Cá rô đồng)",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_beta-caroten,high-protein,high_protein,món_chính,nguồn_canxi,tốt_cho_xương_khớp"
    },
    {
        "dish_id": "dish_074",
        "dish_name": "Cá rô phi rán",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Cá rô phi (cả xương); Rau thìa là; Dầu thực vật",
        "ingredient_ids": "food_065;food_155; food_256",
        "calories": "622",
        "protein": "104.8",
        "carbs": "0.4",
        "fat": "22.3",
        "allergen": "Cá (Cá rô phi)",
        "phân loại": "tăng_cân",
        "health_tags": "giàu_beta-caroten,high-protein,high_calcium,món_chính,siêu_giàu_đạm,tốt_cho_cơ_bắp"
    },
    {
        "dish_id": "dish_075",
        "dish_name": "Nộm rau muống",
        "category": "Salad",
        "ingredients": "Rau muống; Lạc rang; Chanh; Đường; Tỏi; Ớt; Nước mắm",
        "ingredient_ids": "food_040; food_065;food_198;food_038;food_085;food_228; food_040; food_244; food_216",
        "calories": "230",
        "protein": "10.8",
        "carbs": "7.7",
        "fat": "15.9",
        "allergen": "Lạc (Đậu phộng)",
        "phân loại": "giữ_cân",
        "health_tags": "high_calcium,high_vitamin_c,nguồn_kali,salad,siêu_giàu_beta-caroten"
    },
    {
        "dish_id": "dish_076",
        "dish_name": "Nộm tai heo thập cẩm",
        "category": "Salad",
        "ingredients": "Tai heo; Đu đủ; Cà rốt; Dưa chuột; Rau thơm; Lạc rang; Gia vị nộm",
        "ingredient_ids": "food_004; food_029; food_071; food_038; food_258; food_131; food_259; food_260; food_261; food_262; food_263; food_264",
        "calories": "505",
        "protein": "44",
        "carbs": "27",
        "fat": "25",
        "allergen": "Lạc (Đậu phộng)",
        "phân loại": "tăng_cân",
        "health_tags": "giàu_beta-caroten,high_calcium,high_protein,nguồn_kali,salad"
    },
    {
        "dish_id": "dish_077",
        "dish_name": "Nộm bò khô",
        "category": "Salad",
        "ingredients": "Nộm rau củ thập cẩm; Nước chấm pha; Gan lợn rán; Bì lợn; Thịt bò khô; Bánh tôm; Lạc rang",
        "ingredient_ids": "food_233; food_038; food_216; food_237",
        "calories": "239.7",
        "protein": "14.6",
        "carbs": "23",
        "fat": "9.8",
        "allergen": "Lạc (Đậu phộng)",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_beta-caroten,high_magnesium,nguồn_vitamin_a,salad,tốt_cho_sức_khỏe"
    },
    {
        "dish_id": "dish_078",
        "dish_name": "Nộm hoa chuối thịt gà",
        "category": "Salad",
        "ingredients": "Hoa chuối; Thịt gà; Lạc rang; Cà rốt; Rau thơm; Gia vị nộm",
        "ingredient_ids": "food_259; food_260; food_261; food_262; food_263; food_264",
        "calories": "604",
        "protein": "34.1",
        "carbs": "50.1",
        "fat": "29.3",
        "allergen": "Lạc (Đậu phộng)",
        "phân loại": "tăng_cân",
        "health_tags": "giàu_beta-caroten,high_calcium,high_protein,nguồn_kali_dồi_dào,salad"
    },
    {
        "dish_id": "dish_079",
        "dish_name": "Gỏi ngó sen",
        "category": "Salad",
        "ingredients": "Ngó sen; Tôm; Thịt heo; Cà rốt; Lạc rang; Rau thơm; Gia vị trộn gỏi",
        "ingredient_ids": "food_259; food_260; food_261; food_262; food_263; food_264",
        "calories": "615",
        "protein": "35.8",
        "carbs": "42.4",
        "fat": "33.8",
        "allergen": "Lạc (Đậu phộng); Hải sản (Tôm)",
        "phân loại": "tăng_cân",
        "health_tags": "high_calcium,high_protein,high_vitamin_c,nguồn_kali_dồi_dào,salad"
    },
    {
        "dish_id": "dish_080",
        "dish_name": "Gỏi xoài",
        "category": "Salad",
        "ingredients": "Xoài xanh; Rau thơm; Ớt; Gia vị trộn gỏi",
        "ingredient_ids": "food_259; food_260; food_261; food_262; food_263; food_264",
        "calories": "105",
        "protein": "1",
        "carbs": "24",
        "fat": "1",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_beta-caroten,high_vitamin_c,nguồn_kali,salad,ít_béo"
    },
    {
        "dish_id": "dish_081",
        "dish_name": "Cháo tim",
        "category": "Súp / Cháo",
        "ingredients": "Cháo trắng; Hành phi; mùi tàu; Ruốc thịt lợn",
        "ingredient_ids": "food_024; food_027; food_028; food_029;  food_039; ",
        "calories": "350.6",
        "protein": "19.7",
        "carbs": "31.3",
        "fat": "16.3",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_glucid,high_protein,nguồn_sắt,súp_/_cháo,tốt_cho_sức_khỏe"
    },
    {
        "dish_id": "dish_082",
        "dish_name": "Cháo trai",
        "category": "Súp / Cháo; ăn sáng",
        "ingredients": "Cháo trắng; Hành phi; Ruốc thịt lợn; Rau mùi;rau răm",
        "ingredient_ids": "food_024; food_027; food_028; food_029; food_274; food_275; food_054; food_276; food_259",
        "calories": "196.8",
        "protein": "6.9",
        "carbs": "28",
        "fat": "6.4",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "giàu_glucid,low_cholesterol,nguồn_canxi,súp_/_cháo,ăn_sáng"
    },
    {
        "dish_id": "dish_083",
        "dish_name": "Cháo lòng",
        "category": "Súp / Cháo; ăn sáng",
        "ingredients": "Cháo huyết; Dồi lợn luộc; Gan lợn luộc; Dạ dày lợn luộc; Lòng non luộc; Hành mùi tàu; Nước chấm pha; Hành tây; Rau thơm ăn kèm",
        "ingredient_ids": "food_232; food_233; food_234; food_235; food_259; food_260; food_261; food_262; food_263; food_264",
        "calories": "464.7",
        "protein": "37.4",
        "carbs": "43",
        "fat": "15.9",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "high_iron,high_protein,nguồn_magie,siêu_giàu_vitamin_a,súp_/_cháo,ăn_sáng"
    },
    {
        "dish_id": "dish_084",
        "dish_name": "Cháo sườn",
        "category": "Súp / Cháo; ăn sáng",
        "ingredients": "Cháo trắng; sườn heo; Bánh quẩy; Ruốc thịt lợn; Rau răm; mùi",
        "ingredient_ids": "food_024; food_027; food_028; food_029; food_074; food_210; food_274; food_275; food_054; food_259",
        "calories": "199.7",
        "protein": "7.8",
        "carbs": "26.7",
        "fat": "6.9",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "dễ_tiêu_hóa,giàu_glucid,nguồn_protein,súp_/_cháo,ít_béo,ăn_sáng"
    },
    {
        "dish_id": "dish_085",
        "dish_name": "Cháo đậu đen đường",
        "category": "Súp / Cháo",
        "ingredients": "Cháo trắng; đỗ đen; Đường kính",
        "ingredient_ids": "food_024; food_027; food_028; food_029; food_277; food_054",
        "calories": "322",
        "protein": "4.9",
        "carbs": "74.4",
        "fat": "0.5",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "dễ_tiêu_hóa,giàu_glucid,nguồn_canxi,súp_/_cháo,ít_béo"
    },
    {
        "dish_id": "dish_086",
        "dish_name": "Cháo đỗ xanh",
        "category": "Súp / Cháo",
        "ingredients": "Cháo trắng;  đậu đỏ; Đường đỏ; Đường trắng",
        "ingredient_ids": "food_024; food_027; food_028; food_029; food_136; food_277",
        "calories": "274.3",
        "protein": "3.6",
        "carbs": "63.9",
        "fat": "0.5",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "dễ_tiêu_hóa,giàu_glucid,nguồn_natri,súp_/_cháo,ít_béo"
    },
    {
        "dish_id": "dish_087",
        "dish_name": "Cháo lươn cay",
        "category": "Súp / Cháo",
        "ingredients": "Cháo trắng; Bánh quẩy; Lươn xào; Mộc nhĩ xào thịt nạc; Rau mùi; Tía tô; Sa tế",
        "ingredient_ids": "food_024; food_027; food_028; food_029; food_210; food_065; food_220; food_037; food_243; food_244; food_200; food_274; food_278; food_029; food_091; food_040; food_216; food_207; food_066; food_200; food_276; ",
        "calories": "174.1",
        "protein": "7.1",
        "carbs": "29.5",
        "fat": "3.1",
        "allergen": "Không có",
        "phân loại": "giảm_cân",
        "health_tags": "dễ_tiêu_hóa,high_vitamin_a,siêu_giàu_beta-caroten,súp_/_cháo,ít_béo"
    },
    {
        "dish_id": "dish_088",
        "dish_name": "Cháo gà",
        "category": "Súp / Cháo; ăn sáng",
        "ingredients": "Cháo trắng; Thịt lườn gà luộc; Mộc nhĩ; nấm hương xào; Rau thơm",
        "ingredient_ids": "food_259; food_260; food_261; food_262; food_263; food_264",
        "calories": "375.9",
        "protein": "26.1",
        "carbs": "57.6",
        "fat": "4.6",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "giàu_glucid,high_magnesium,high_protein,nguồn_canxi,súp_/_cháo,ăn_sáng"
    },
    {
        "dish_id": "dish_089",
        "dish_name": "Cháo ruốc thịt lợn",
        "category": "Súp / Cháo; ăn sáng",
        "ingredients": "Cháo trắng; Bánh quẩy; Ruốc thịt lợn",
        "ingredient_ids": "food_024; food_027; food_028; food_029;  food_210; food_274; food_275; food_054; ",
        "calories": "223.6",
        "protein": "7.7",
        "carbs": "38.6",
        "fat": "4.3",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "dễ_tiêu_hóa,giàu_glucid,nguồn_kali,súp_/_cháo,ít_béo,ăn_sáng"
    },
    {
        "dish_id": "dish_090",
        "dish_name": "Ruốc thịt lợn",
        "category": "Món phụ",
        "ingredients": "Thịt lợn; Xì dầu; Đường; Gia vị",
        "ingredient_ids": "food_274; food_275; food_054; ",
        "calories": "400",
        "protein": "40",
        "carbs": "20",
        "fat": "20",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "high_protein,món_phụ,nguồn_kali,nguồn_sắt,tiện_lợi"
    },
    {
        "dish_id": "dish_091",
        "dish_name": "thạch dừa",
        "category": "món phụ",
        "ingredients": "cơm dừa; bột rau câu",
        "ingredient_ids": "food_226; food_236",
        "calories": "88",
        "protein": "0",
        "carbs": "17.5",
        "fat": "0",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "cholesterol_free,giàu_chất_xơ_hòa_tan,không_gluten,không_đường_thêm_(nếu_loại_không_đường),món_phụ,phù_hợp_cho_ăn_chay,thích_hợp_làm_món_tráng_miệng,thực_phẩm_có_nguồn_gốc_thực_vật,tốt_cho_tiêu_hóa,ít_calo"
    },
    {
        "dish_id": "dish_092",
        "dish_name": "phồng tôm",
        "category": "món phụ",
        "ingredients": "tôm; tinh bột khoai mì; muối; đường; tiêu; bột ngọt",
        "ingredient_ids": "food_111; food_131; food_200; food_054; food_066; food_205",
        "calories": "357",
        "protein": "3.57",
        "carbs": "82.1",
        "fat": "0",
        "allergen": "tôm; hải sản",
        "phân loại": "giữ_cân",
        "health_tags": "chiên_ngập_dầu,có_tinh_bột,có_tôm,high_protein,không_phù_hợp_cho_người_dị_ứng_hải_sản_có_vỏ,món_phụ,nguy_cơ_dị_ứng_hải_sản,nhiều_calo,nhiều_muối,thực_phẩm_chế_biến,đồ_ăn_vặt"
    },
    {
        "dish_id": "dish_093",
        "dish_name": "mộc nhĩ xào thịt nạc",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "thịt nạc heo; mộc nhĩ khô; cà rốt; hành lá; tỏi; nước mắm; hạt nêm; tiêu; muối",
        "ingredient_ids": "food_274; food_278; food_029; food_091; food_040; food_216; food_207; food_066; food_200",
        "calories": "98",
        "protein": "10.7",
        "carbs": "3.9",
        "fat": "4.4",
        "allergen": "Thịt lợn; Đậu nành; Nấm",
        "phân loại": "giảm_cân",
        "health_tags": "dairy_free,gluten_free,high_fiber,high_protein,kết_hợp_thực_vật_–_động_vật,món_chính,nguồn_chất_chống_oxy_hóa,nguồn_sắt,nguồn_vitamin_nhóm_b"
    },
    {
        "dish_id": "dish_094",
        "dish_name": "salad rau củ",
        "category": "salad",
        "ingredients": "cà chua; dưa chuột; rau xà lách; dầu thực vật",
        "ingredient_ids": "food_026; food_071; food_033; food_065;",
        "calories": "181",
        "protein": "2",
        "carbs": "0",
        "fat": "16",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "có_chứa_chất_béo_lành_mạnh,có_nguồn_gốc_thực_vật,dairy_free,digestive_health,giàu_vitamin,gluten_free,heart_health,high_antioxidants,high_fiber,salad,vegetarian_friendly,ít_calo"
    },
    {
        "dish_id": "dish_095",
        "dish_name": "nem tai",
        "category": "salad",
        "ingredients": "tai heo; hành tây; ",
        "ingredient_ids": "food_258; food_036;",
        "calories": "216.7",
        "protein": "28.3",
        "carbs": "9",
        "fat": "7.5",
        "allergen": "thịt heo",
        "phân loại": "giữ_cân",
        "health_tags": "có_chứa_collagen,có_chứa_gluten,có_thành_phần_lên_men,dairy_free,high_protein,không_phù_hợp_cho_người_ăn_chay,món_truyền_thống_việt_nam,salad,ít_tinh_bột"
    },
    {
        "dish_id": "dish_096",
        "dish_name": "Xôi xéo",
        "category": "ăn sáng",
        "ingredients": "xôi; đậu xanh; hành phi; ruốc thịt lợn",
        "ingredient_ids": "food_279; food_185; food_039; food_274; food_275; food_054; ",
        "calories": "420",
        "protein": "12.6",
        "carbs": "84.3",
        "fat": "3.6",
        "allergen": "thịt heo;",
        "phân loại": "giữ_cân",
        "health_tags": "ăn_sáng"
    },
    {
        "dish_id": "dish_097",
        "dish_name": "xôi",
        "category": "ăn sáng",
        "ingredients": "gạo nếp",
        "ingredient_ids": "food_279",
        "calories": "97",
        "protein": "2.5862",
        "carbs": "21.2644",
        "fat": "0.1724",
        "allergen": "không có",
        "phân loại": "giảm_cân",
        "health_tags": "có_nguồn_gốc_thực_vật,dairy_free,giàu_năng_lượng,giàu_tinh_bột,gluten_free,low_fat,thực_phẩm_truyền_thống_châu_á,tạo_cảm_giác_no_lâu,vegetarian_friendly,ăn_sáng"
    },
    {
        "dish_id": "dish_098",
        "dish_name": "bánh mì thập cẩm",
        "category": "ăn sáng",
        "ingredients": "Bánh mì; Pate; Thịt ba chỉ rán; Ruốc thịt lợn; Thịt nguội; Bơ; Dưa chuột",
        "ingredient_ids": "food_061; food_280; food_139; food_274; food_275; food_054; food_112; food_071",
        "calories": "678",
        "protein": "30.6",
        "carbs": "48.1",
        "fat": "40.5",
        "allergen": "Lúa mì; Thịt heo; Trứng; Sữa; Đậu nành",
        "phân loại": "tăng_cân",
        "health_tags": "có_chứa_gluten,có_chứa_sữa,có_chứa_trứng,có_chứa_đậu_nành,giàu_chất_béo,giàu_năng_lượng,high_protein,không_phù_hợp_cho_người_ăn_chay,món_ăn_truyền_thống_việt_nam,thịt_chế_biến,ăn_sáng"
    },
    {
        "dish_id": "dish_099",
        "dish_name": "Bánh cuốn thịt",
        "category": "ăn sáng",
        "ingredients": "bánh cuốn; chả lợn; ruốc thịt lợn; hành phi; nước mắm",
        "ingredient_ids": "food_027; food_274; food_275; food_054; food_039; food_216",
        "calories": "493.1",
        "protein": "13.8",
        "carbs": "65",
        "fat": "19.8",
        "allergen": "Thịt heo; Cá; Đậu nành; Lúa mì",
        "phân loại": "giữ_cân",
        "health_tags": "\",\"_xóa_đi_thông_số_và_độ_đo,cho_các_thành_phần_của_allergen_nằm_trên_1_dòng_cách_nhau_bởi_dấu_\",cho_các_thành_phần_của_minerals_nằm_trên_1_dòng_cách_nhau_bởi_dấu_\",cho_các_thành_phần_của_vitamins_nằm_trên_1_dòng_cách_nhau_bởi_dấu_\",health_tags_cho_nằm_trên_1_dòng_cách_nhau_bởi_dấu_\",health_tags_và_allergen_dịch_ra_tiếng_việt_và_allergen_chỉ_cho_các_chất_gây_dị_ứng_phổ_biến,kiếm_calories-protein-carbs-fat-vitamins-minerals-allergen-health_tags,ăn_sáng"
    },
    {
        "dish_id": "dish_100",
        "dish_name": "Tiết luộc (Boiled pig blood)",
        "category": "Món phụ; High-protein",
        "ingredients": "Tiết lợn luộc, Rau mùi tàu, Rau húng, Tía tô, Ớt đỏ to, Nước chấm pha",
        "ingredient_ids": "food_152; food_260; food_203; food_263; food_244; food_262; food_216; food_281",
        "calories": "65.9",
        "protein": "11.4",
        "carbs": "4.6",
        "fat": "0.2",
        "allergen": "thịt đỏ",
        "phân loại": "giảm_cân",
        "health_tags": "low_energy,high_protein,low_carbs,low_fat,high_vitamin_a,high_vitamin_c,high_iron,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_101",
        "dish_name": "Chả lợn mỡ (Fatty pork-paste)",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Chả lợn",
        "ingredient_ids": "food_282",
        "calories": "367.2",
        "protein": "7.7",
        "carbs": "3.6",
        "fat": "35.8",
        "allergen": "thịt đỏ",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,low_carbs,high_magnesium,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_102",
        "dish_name": "Bún ốc chấm (Rice vermicelli with snail and dipping sauce)",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Bún tươi,Ốc vặn luộc,Ốc nhồi luộc,Chanh,Ớt tươi,Rau sống,Hoa chuối,Cà chua,Nước dùng",
        "ingredient_ids": "food_032; food_012; food_096; food_244; food_026; food_283;food_284;food_285; food_079; food_262; food_263; food_264",
        "calories": "661.3",
        "protein": "58.2",
        "carbs": "89.3",
        "fat": "7.9",
        "allergen": "động vật có vỏ (tôm; cua...)",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,low_fat,high_vitamin_A,high_calcium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_103",
        "dish_name": "Bún cá chấm (Rice vermicelli with fried fish and dipping broth)",
        "category": "món chính; ăn trưa; ăn tối; High-protein",
        "ingredients": "Bún tươi, Cá rô phi rán, Giá đậu xanh, Cần ta, Dứa ta, Cà chua, Hành lá, Măng chua, Nước dùng, Nước chấm",
        "ingredient_ids": "food_032; food_163; food_041; food_075; food_003; food_026; food_091; food_172; food_023; food_216; food_012; food_070; food_244; food_054; ",
        "calories": "451.2",
        "protein": "37.6",
        "carbs": "64.4",
        "fat": "4.8",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,high_protein,moderate_carbs,low_fat,high_vitamin_a,high_calcium,high_potassium,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_104",
        "dish_name": "Bánh đa đỏ trộn (Red thick rice noodle mixed with meat and vegetables)",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Bánh đa đỏ, Giá đậu xanh, Cá rô phi rán, Mọc, Giò tai lợn, Rau muống luộc, Nước sốt, Hành phi, Lạc rang, Ớt đỏ",
        "ingredient_ids": "food_041; food_163; food_107; food_255; food_258; food_198; food_216; food_080; food_054; food_039; food_038; food_244;",
        "calories": "550.7",
        "protein": "24",
        "carbs": "70.1",
        "fat": "19.4",
        "allergen": "Không có",
        "phân loại": "tăng_cân",
        "health_tags": "moderate_energy,high_protein,high_carbs,moderate_fat,high_potassium,high_magnesium,dairy_free"
    },
    {
        "dish_id": "dish_105",
        "dish_name": "Trứng gà rán ngải cứu (Mugwort fried trứngs)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng",
        "ingredients": "Trứng gà công nghiệp,Ngải cứu,Dầu ăn",
        "ingredient_ids": "food_045; food_267; food_286",
        "calories": "114.6",
        "protein": "6.9",
        "carbs": "2",
        "fat": "8.8",
        "allergen": "trứng",
        "phân loại": "giảm_cân",
        "health_tags": "moderate_energy,low_carbs,high_vitamin_A,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_106",
        "dish_name": "Nước ép lựu (Pomegranate Juice)",
        "category": "Đồ uống",
        "ingredients": "Hạt lựu",
        "ingredient_ids": "food_017",
        "calories": "211.8",
        "protein": "0.6",
        "carbs": "49.9",
        "fat": "1.1",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,low_fat,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_107",
        "dish_name": "Bắp xào tép (Stir-fried maize seeds with small shrimp)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng",
        "ingredients": "Ngô ngọt chiên bơ,Hành phi,Tép khô rang",
        "ingredient_ids": "food_063; food_013; food_267; food_039; food_224",
        "calories": "758.7",
        "protein": "11",
        "carbs": "86.3",
        "fat": "41.1",
        "allergen": "động vật có vỏ (tôm; cua...)",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_108",
        "dish_name": "Nước ép lê (Pear juice)",
        "category": "Đồ uống",
        "ingredients": "Lê nguyên miếng",
        "ingredient_ids": "food_021",
        "calories": "229.2",
        "protein": "3.4",
        "carbs": "51.8",
        "fat": "1",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,low_fat,high_iron,high_carbs,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_109",
        "dish_name": "Bún ngan măng khô (Rice vermicelli with boiled muscovy and dried Bamboo shoots)",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Bún tươi,Thịt ngan luộc,Mọc mộc nhĩ,Tiết ngan luộc,Măng khô nấu,Hành lá,Rau mùi,Nước dùng",
        "ingredient_ids": "food_032; food_287; food_107; food_255; food_091; food_262; food_023",
        "calories": "630.1",
        "protein": "29.7",
        "carbs": "55.6",
        "fat": "32.1",
        "allergen": "Không có",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_iron,high_calcium,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_110",
        "dish_name": "Bún đậu mắm tôm, lòng lợn",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Bún tươi, Đậu phụ rán, Chả lợn, Nem rán, Lòng non luộc, Dạ dày rán, Tai lợn luộc, Thịt chân giò lợn luộc, Dồi lợn luộc, Quất, Mắm tôm + đường",
        "ingredient_ids": "food_032; food_108; food_258; food_232; food_227; food_235; food_234; food_274; food_054; food_288; food_289",
        "calories": "914.9",
        "protein": "42.2",
        "carbs": "105.7",
        "fat": "36",
        "allergen": "thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_calcium,high_magnesium,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_111",
        "dish_name": "Bún nem cua bể (Rice vermicelli with Crab spring rolls)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Bún tươi,Nem hải sản,Cà rốt,Đu đủ xanh,Rau húng,Rau kinh giới,Rau mùi,Chanh,Nước chấm pha",
        "ingredient_ids": "food_032; food_111; food_189; food_223; food_072; food_029; food_004; food_260; food_264; food_262; food_012; food_216; food_054; food_070; food_244",
        "calories": "596.3",
        "protein": "13.4",
        "carbs": "119.7",
        "fat": "7.1",
        "allergen": "động vật có vỏ (tôm; cua...)",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,low_fat,high_potassium,high_calcium,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_112",
        "dish_name": "Bún chả nem (Rice vermicelli with grilled pork and spring rolls)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Bún tươi,Nem hải sản,Chả viên nướng,Thịt lợn ba chỉ nướng,Đu đủ xanh,Cà rốt,Giá đậu xanh,Rau xà lách,Rau kinh giới,Tía tô,Nước chấm pha",
        "ingredient_ids": "food_032; food_111; food_189; food_223; food_072; food_107; food_139; food_029; food_041; food_033; food_221; food_203; food_216; food_054; food_070; food_244; food_012",
        "calories": "901.1",
        "protein": "40.8",
        "carbs": "110",
        "fat": "33.1",
        "allergen": "thịt đỏ,động vật có vỏ (tôm; cua...)",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_calcium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_113",
        "dish_name": "Miến ngan mọc",
        "category": "món chính; ăn trưa; ăn tối;Súp / Cháo;High-protein",
        "ingredients": "Miến dong,Thịt ngan luộc,Mọc mọc nhĩ,Tiết ngan luộc,Măng tươi,Hành lá,Nước dùng",
        "ingredient_ids": "food_144; food_287; food_107; food_255; food_281; food_172; food_091; food_023",
        "calories": "569.3",
        "protein": "27",
        "carbs": "51.2",
        "fat": "28.5",
        "allergen": "Không có",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_iron,high_calcium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_114",
        "dish_name": "Miến lươn trộn (Vermicelli mixed with eel)",
        "category": "món chính; ăn trưa; ăn tối",
        "ingredients": "Miến dong khô, Lươn chiên giòn, Cà rốt, Dưa chuột, Giá đậu xanh, Hành phi, Rau kinh giới, Lạc rang",
        "ingredient_ids": "food_144; food_220; food_029; food_071; food_041; food_039; food_221; food_038",
        "calories": "308.8",
        "protein": "8.5",
        "carbs": "54.9",
        "fat": "6.1",
        "allergen": "đậu phộng",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,low_fat,high_vitamin_A,high_carbs,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_115",
        "dish_name": "Miến lươn nước (Vermicelli soup with eel)",
        "category": "món chính; ăn trưa; ăn tối;Súp / Cháo",
        "ingredients": "Miến dong, Lươn chiên giòn, Giá đậu xanh, Hành phi, Hành tây, Rau răm, Nước dùng",
        "ingredient_ids": "food_144; food_220; food_041; food_039; food_036; food_259; food_023",
        "calories": "338.2",
        "protein": "8.9",
        "carbs": "59.9",
        "fat": "7",
        "allergen": "Không có",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,low_fat,high_carbs,high_vitamin_A,high_calcium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_116",
        "dish_name": "Hủ tiếu thịt bằm (Rice noodle soup with minced pork)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Hủ tiếu,Thịt lợn vai xay,Trứng cút luộc,Hành lá,Hẹ lá,Hành phi,Giá đậu xanh,Rau xà lách,Chanh,Ớt,Nước dùng",
        "ingredient_ids": "food_107; food_091; food_118; food_039; food_041; food_033; food_012; food_244; food_023; food_290; food_291",
        "calories": "530.9",
        "protein": "31.7",
        "carbs": "59.5",
        "fat": "18.5",
        "allergen": "thịt đỏ,trứng",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_calcium,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_117",
        "dish_name": "Hủ tiếu đại dương (Rice noodle soup with mixed seafood)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Hủ tiếu,Chả cá,Thanh cua,Bề bề,Tôm sú,Mực tươi,Thịt lợn vai xay,Trứng cút luộc,Giá đậu xanh,Rau xà lách,Chanh,Ớt,Hành phi,Nước dùng",
        "ingredient_ids": "food_111; food_189; food_107; food_041; food_033; food_012; food_244; food_039; food_023; food_290",
        "calories": "572.1",
        "protein": "47.4",
        "carbs": "53.1",
        "fat": "18.9",
        "allergen": "động vật có vỏ (tôm; cua...),trứng",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_calcium,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_118",
        "dish_name": "Hủ tiếu Nam Vang",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Hủ tiếu,Gan lợn luộc,Trứng cút luộc,Tôm biển luộc,Rau xà lách,Rau cần,Giá đậu xanh,Dạ dày lợn luộc,Thịt bò luộc,Thịt lợn sẵn băm,Chanh,Ớt,Tỏi,Nước dùng",
        "ingredient_ids": "food_290; food_265; food_291; food_111; food_033; food_075; food_041; food_234; food_222; food_107; food_012; food_244; food_070; food_023",
        "calories": "537.1",
        "protein": "30.1",
        "carbs": "82.8",
        "fat": "9.5",
        "allergen": "thịt đỏ,động vật có vỏ (tôm; cua...),trứng",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,low_fat,high_vitamin_A,high_potassium,high_iron,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_119",
        "dish_name": "Phở bò tái gầu (Pho with rare beef brisket)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh phở,Thịt bò gầu luộc,Thịt bò loại I,Bánh quẩy,Hành lá,Hành tây,Chanh,Ớt đỏ,Nước dùng",
        "ingredient_ids": "food_222; food_210; food_091; food_036; food_012; food_244; food_023; food_295",
        "calories": "581.5",
        "protein": "28.1",
        "carbs": "77.9",
        "fat": "17.5",
        "allergen": "thịt đỏ,gluten",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,dairy_free"
    },
    {
        "dish_id": "dish_120",
        "dish_name": "Bánh canh sườn heo",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh canh,Sườn lợn,Tiết lợn luộc,Thịt chân giò lợn luộc,Gan lợn luộc,Hành lá,Mùi,Hẹ,Hành phi,Củ cải khô,Cà rốt,Chanh,Ớt,Giá đậu xanh,Rau xà lách,Cần tây,Nước dùng",
        "ingredient_ids": "food_023; food_281; food_274; food_265; food_091; food_262; food_118; food_039; food_029; food_012; food_244; food_041; food_033; food_075; food_296; food_297",
        "calories": "487.6",
        "protein": "20.6",
        "carbs": "72.8",
        "fat": "12.7",
        "allergen": "thịt đỏ",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,high_protein,high_carbs,high_vitamin_A,high_potassium,high_calcium,high_iron,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_121",
        "dish_name": "Phở lõi bò (Pho with Beef heel muscle)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh phở,Thịt bò loại I,Hành lá,Hành tây,Chanh,Bánh quẩy,Nước dùng",
        "ingredient_ids": "food_295; food_222; food_091; food_036; food_012; food_210; food_023",
        "calories": "461.8",
        "protein": "19.9",
        "carbs": "69.9",
        "fat": "11.4",
        "allergen": "thịt đỏ,gluten",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,high_protein,high_carbs,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_122",
        "dish_name": "Bánh canh ghẹ (Thick rice noodle soup with flower crab)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Bánh canh, Trứng cút luộc, Thịt chân giò lợn luộc, Ghẹ, Chả lợn, Bỏng cua, Tiết lợn luộc, Hành phi, Nước dùng, Chanh, Ớt, Giá đậu xanh, Rau cần, Rau xà lách, Hành lá, Rau mùi",
        "ingredient_ids": "food_296; food_291; food_274; food_175; food_282; food_281; food_039; food_023; food_012; food_244; food_041; food_075; food_033; food_091; food_262",
        "calories": "590",
        "protein": "21.6",
        "carbs": "85.2",
        "fat": "18.1",
        "allergen": "động vật có vỏ (tôm; cua...),trứng,thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_calcium,high_iron,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_123",
        "dish_name": "Phở bò tái chín (Pho with rare beef)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh phở, Nạm bò luộc, Nạm bò sống, Rau mùi, Chanh, Hành tây, Nước dùng",
        "ingredient_ids": "food_295; food_222; food_262; food_012; food_036; food_023",
        "calories": "503.6",
        "protein": "36.4",
        "carbs": "62.6",
        "fat": "11.9",
        "allergen": "thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_iron,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_124",
        "dish_name": "Phở gà trộn (Pho mixed with chicken)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh phở,Thịt gà ta luộc,Giá đậu xanh,Rau mùi,Hành lá,Xì dầu,Hành tây,Nước dùng,Chanh,Ớt tươi",
        "ingredient_ids": "food_295; food_084; food_041; food_262; food_091; food_275; food_036; food_023; food_012; food_244",
        "calories": "524.6",
        "protein": "30.4",
        "carbs": "68",
        "fat": "14.6",
        "allergen": "soy",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_vitamin_A,dairy_free"
    },
    {
        "dish_id": "dish_125",
        "dish_name": "Miến riêu cua (nước)",
        "category": "món chính; ăn trưa; ăn tối;Súp / Cháo;High-protein",
        "ingredients": "Miến dong,Rau muống,Cần ta,Giá đậu xanh,Giò tai,Chả cá,Thịt bò loại I,Đậu phụ rán,Gạch cua,Hành lá,Nước dùng",
        "ingredient_ids": "food_144; food_198; food_075; food_041; food_292; food_222; food_108; food_175; food_091; food_023",
        "calories": "461.2",
        "protein": "22.5",
        "carbs": "53.2",
        "fat": "17.6",
        "allergen": "thịt đỏ",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,high_protein,high_carbs,high_calcium,high_potassium,high_vitamin_A,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_126",
        "dish_name": "Bún riêu bò (Rice vermicelli with beef and fresh water crab paste soup)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bún tươi, Thịt bò loại I, Giò tai, Đậu phụ rán, Nước riêu cua, Hành lá",
        "ingredient_ids": "food_032; food_222; food_027; food_258; food_108; food_175; food_091",
        "calories": "527",
        "protein": "31",
        "carbs": "49",
        "fat": "23",
        "allergen": "thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_calcium,high_potassium,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_127",
        "dish_name": "Bánh mỳ bít tết (Banh my with steak)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh mỳ, Thịt bò loại I sống, Pate, Trứng gà công nghiệp, Khoai tây rán, Dưa chuột muối, Nước sốt, Tương ớt, Xì dầu",
        "ingredient_ids": "food_061; food_222; food_280; food_045; food_006; food_275; food_298; food_299",
        "calories": "920",
        "protein": "44.5",
        "carbs": "109",
        "fat": "34",
        "allergen": "thịt đỏ,trứng,soy",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_iron,high_magnesium,high_vitamin_A,dairy_free"
    },
    {
        "dish_id": "dish_128",
        "dish_name": "Bánh mỳ chảo lợn",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh mỳ,Xúc xích,Trứng rán,Dăm bông lợn,Pate,Nước dùng,Dưa chuột",
        "ingredient_ids": "food_061; food_083; food_045; food_280; food_023; food_071;  food_300",
        "calories": "726.2",
        "protein": "35.7",
        "carbs": "56.5",
        "fat": "39.7",
        "allergen": "trứng,thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_vitamin_A,high_potassium,high_iron,dairy_free"
    },
    {
        "dish_id": "dish_129",
        "dish_name": "Xôi xéo thịt (Sticky rice with braised pork belly and mung bean)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Xôi đỗ,Đậu xanh đồ,Hành phi,Dưa chuột,Thịt lợn ba chỉ kho,Nước thịt kho",
        "ingredient_ids": "food_279; food_185; food_039; food_071; food_139; food_216; food_054",
        "calories": "676.1",
        "protein": "23.2",
        "carbs": "112.6",
        "fat": "14.8",
        "allergen": "thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_130",
        "dish_name": "Bánh mì chảo (Banh my with bacon and sausage served in frying pan)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh mì, Pate gan, Xúc xích, Trứng gà rán, Khoai tây, Thịt chân giò lợn muối, Nước sốt, Nộm su hào",
        "ingredient_ids": "food_061; food_280; food_083; food_045; food_006; food_143; food_010",
        "calories": "708.4",
        "protein": "38.3",
        "carbs": "78.4",
        "fat": "26.9",
        "allergen": "trứng,thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_vitamin_A,high_potassium,dairy_free"
    },
    {
        "dish_id": "dish_131",
        "dish_name": "Xôi xíu (Sticky rice with Char siu)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Xôi trắng, Lạp xưởng, Ruốc thịt lợn, Trứng gà rán, Chả lợn, Hành phi, Pate",
        "ingredient_ids": "food_279; food_024; food_170; food_045; food_282; food_039; food_280",
        "calories": "1022",
        "protein": "36.7",
        "carbs": "114.4",
        "fat": "46.4",
        "allergen": "thịt đỏ,trứng",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_potassium,high_magnesium,high_vitamin_A,high_iron,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_132",
        "dish_name": "Xôi thập cẩm (Sticky rice with mixed meat and vegetables)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Xôi trắng (đồ),Pate,Thịt xá xíu,Trứng gà rán,Thịt gà xào,Mộc nhĩ,Hành phi,Đu đủ,Cà rốt",
        "ingredient_ids": "food_279; food_280; food_053; food_045; food_255; food_039; food_004; food_029",
        "calories": "1227.1",
        "protein": "56.9",
        "carbs": "135.5",
        "fat": "50.8",
        "allergen": "thịt đỏ,trứng",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_vitamin_A,high_potassium,high_iron,high_calcium,high_magnesium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_133",
        "dish_name": "Mỳ vằn thắn (Wheat noodle with Wonton soup)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Mỳ sợi,Thịt lợn xá xíu,Trứng vịt luộc,Nấm hương,Hẹ lá,Cải ngọt luộc,Gan lợn luộc,Bóng bì lợn,Sủi cảo luộc,Sủi cảo chiên,Nước dùng",
        "ingredient_ids": "food_102; food_274; food_028; food_090; food_118; food_193; food_265; food_107; food_223; food_023; food_266",
        "calories": "579.6",
        "protein": "35.6",
        "carbs": "58",
        "fat": "22.8",
        "allergen": "thịt đỏ,trứng,gluten",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_vitamin_A,high_iron,dairy_free"
    },
    {
        "dish_id": "dish_134",
        "dish_name": "Cơm rang thập cẩm (Fried rice with meat and vegetables)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Cơm rang,Dưa chuột muối,Cà rốt,Ngô ngọt,Đậu cô ve,Lạp xưởng,Chả lợn,Nước dùng,Hành lá",
        "ingredient_ids": "food_026; food_029; food_059; food_051; food_024; food_282; food_023; food_091; food_299",
        "calories": "1088.2",
        "protein": "33.6",
        "carbs": "113.5",
        "fat": "55.6",
        "allergen": "thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_iron,high_calcium,high_potassium,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_135",
        "dish_name": "Cơm rang dưa bò",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Cơm rang,Thịt bò loại I sống,Dưa cải sen,Dưa chuột muối,Nước dùng,Hành lá",
        "ingredient_ids": "food_299; food_026; food_222; food_250; food_023; food_091",
        "calories": "1022.3",
        "protein": "48.1",
        "carbs": "107",
        "fat": "44.7",
        "allergen": "thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_calcium,high_potassium,high_iron,gluten_free,dairy_free"
    },
    {
        "dish_id": "dish_136",
        "dish_name": "Miến riêu cua (nước) (Vermicelli soup with fresh water crab paste)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Miến dong, Rau muống luộc, Cần ta, Giá đậu xanh, Giò tai, Chả cá, Thịt bò loại I, Đậu phụ rán, Gạch cua, Hành lá, Nước dùng",
        "ingredient_ids": "food_144; food_198; food_075; food_041; food_027; food_258; food_292; food_222; food_108; food_175; food_091; food_023",
        "calories": "461.2",
        "protein": "22.5",
        "carbs": "53.2",
        "fat": "17.6",
        "allergen": "thịt đỏ",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_protein, high_carbs, high_calcium, high_potassium, gluten_free, dairy_free"
    },
    {
        "dish_id": "dish_137",
        "dish_name": "Miến riêu cua (trộn)",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Miến dong, Giá đậu xanh, Cần ta, Đậu phụ rán, Giò tai, Chả cá, Thịt bò loại I, Lạc rang, Riêu cua, Hành lá, Rau muống luộc, Xì dầu",
        "ingredient_ids": "food_144; food_041; food_075; food_108; food_027; food_258; food_292; food_222; food_134; food_175; food_091; food_198; food_275",
        "calories": "493",
        "protein": "24",
        "carbs": "59.4",
        "fat": "17.7",
        "allergen": "thịt đỏ, đậu phộng, soy",
        "phân loại": "giữ_cân",
        "health_tags": "high_energy, high_protein, high_carbs, high_calcium, high_potassium, dairy_free"
    },
    {
        "dish_id": "dish_138",
        "dish_name": "Pizza gà nướng nấm (cỡ L) (BBQ chicken mushroom pizza (L size))",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Đế bánh,Phô mai,Thịt gà,Nấm,Dứa ta,Cà rốt,Rau mùi,Nước sốt cà chua,Tương ớt",
        "ingredient_ids": "food_214; food_301; food_084; food_073; food_003; food_029; food_262; food_026; food_298",
        "calories": "1728.6",
        "protein": "85.8",
        "carbs": "219.9",
        "fat": "56.2",
        "allergen": "sữa,gluten",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_calcium,high_potassium,high_magnesium"
    },
    {
        "dish_id": "dish_139",
        "dish_name": "Hamburger lợn (Pork hamburger)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng",
        "ingredients": "Bánh mỳ, Thịt lợn xay rán, Phô mai, Nước sốt",
        "ingredient_ids": "food_061; food_107; food_301; food_072",
        "calories": "282.5",
        "protein": "18.4",
        "carbs": "30.1",
        "fat": "9.9",
        "allergen": "sữa, gluten, thịt đỏ",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_protein, high_calcium"
    },
    {
        "dish_id": "dish_140",
        "dish_name": "Pizza bò (cỡ M) (Premium beef pizza (M size))",
        "category": "món chính; ăn trưa; ăn tối;High-protein",
        "ingredients": "Đế bánh,Nước sốt cà chua,Sốt mayonnaise,Thịt bò viên,Thịt bò loại I,Hành tây,Cà chua,Phô mai",
        "ingredient_ids": "food_214; food_026; food_072; food_035; food_222; food_036; food_026; food_301",
        "calories": "1111.9",
        "protein": "51",
        "carbs": "125.5",
        "fat": "45.1",
        "allergen": "sữa,gluten,thịt đỏ",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy,high_protein,high_carbs,high_calcium,high_potassium,high_magnesium"
    },
    {
        "dish_id": "dish_141",
        "dish_name": "Hamburger Bò (Beef Hamburger)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh mỳ, Thịt bò băm rán, Rau xà lách, Cà chua, Phô mai, Nước sốt",
        "ingredient_ids": "food_061; food_035; food_033; food_026; food_301; food_072",
        "calories": "308.9",
        "protein": "18",
        "carbs": "33.2",
        "fat": "11.5",
        "allergen": "sữa,gluten,thịt đỏ",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,high_protein,high_calcium"
    },
    {
        "dish_id": "dish_142",
        "dish_name": "Hamburger Gà (Chicken Hamburger)",
        "category": "món chính; ăn trưa; ăn tối; Ăn sáng; High-protein",
        "ingredients": "Bánh mỳ, Ức gà chiên, Rau xà lách, Cà chua, Phô mai, Nước sốt",
        "ingredient_ids": "food_061; food_168; food_033; food_026; food_301; food_072",
        "calories": "451.7",
        "protein": "29.3",
        "carbs": "39.4",
        "fat": "19.6",
        "allergen": "sữa, gluten",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_protein, high_calcium"
    },
    {
        "dish_id": "dish_143",
        "dish_name": "Burger cá (Fish Burger)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng",
        "ingredients": "Bánh mỳ,Cá tẩm bột chiên,Sốt mayonnaise,Rau xà lách,Tương ớt,Tương cà chua",
        "ingredient_ids": "food_061; food_292; food_072; food_033; food_298; food_026",
        "calories": "305.7",
        "protein": "22.1",
        "carbs": "38.4",
        "fat": "7.1",
        "allergen": "seafood,gluten",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy,high_protein,high_calcium,dairy_free"
    },
    {
        "dish_id": "dish_144",
        "dish_name": "Burger Tôm (Shrimp burger)",
        "category": "món chính; ăn trưa; ăn tối; Ăn sáng",
        "ingredients": "Bánh mỳ, Tôm tẩm bột chiên, Rau xà lách, Sốt mayonnaise",
        "ingredient_ids": "food_061; food_111; food_033; food_072",
        "calories": "537.4",
        "protein": "20.8",
        "carbs": "50.2",
        "fat": "28.1",
        "allergen": "seafood, gluten",
        "phân loại": "tăng_cân",
        "health_tags": "moderate_energy, high_protein, high_carbs, dairy_free"
    },
    {
        "dish_id": "dish_145",
        "dish_name": "Bánh mỳ pa tê trứng (Banh my with Pate and fried trứng)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh mỳ, Pate, Ruốc thịt lợn, Trứng gà rán",
        "ingredient_ids": "food_061; food_280; food_302; food_045",
        "calories": "426.5",
        "protein": "23.5",
        "carbs": "41.7",
        "fat": "18.4",
        "allergen": "thịt đỏ, trứng, gluten",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_protein, high_vitamin_A, dairy_free"
    },
    {
        "dish_id": "dish_146",
        "dish_name": "Bánh mỳ Pate thập cẩm (Banh my with Pate and mixed)",
        "category": "món chính; ăn trưa; ăn tối;Ăn sáng;High-protein",
        "ingredients": "Bánh mỳ, Pate gan, Bơ thực vật, Dăm bông lợn, Chả lợn, Thịt ba chỉ rán, Dưa chuột, Su hào, Hành phi, Ruốc thịt lợn, Nước sốt",
        "ingredient_ids": "food_061; food_280; food_112; food_300; food_282; food_139; food_071; food_159; food_039; food_302; food_072",
        "calories": "662.1",
        "protein": "26.2",
        "carbs": "43.6",
        "fat": "42.5",
        "allergen": "thịt đỏ, gluten",
        "phân loại": "tăng_cân",
        "health_tags": "high_energy, high_protein, high_vitamin_A, dairy_free"
    },
    {
        "dish_id": "dish_147",
        "dish_name": "Chè khúc bạch (Almond panna cotta dessert soup)",
        "category": "Tráng miệng;Ăn nhẹ",
        "ingredients": "Thạch trắng,Thạch lá dứa,Nước đường,Hạt hạnh nhân",
        "ingredient_ids": "food_054; food_056; food_305",
        "calories": "145.5",
        "protein": "3.4",
        "carbs": "28.2",
        "fat": "2.1",
        "allergen": "nut",
        "phân loại": "giảm_cân",
        "health_tags": "low_fat,high_magnesium,high_calcium,high_potassium"
    },
    {
        "dish_id": "dish_148",
        "dish_name": "Hoa quả dầm (Mixed fresh fruit)",
        "category": "Tráng miệng; Ăn nhẹ",
        "ingredients": "Quả bơ, Dâu tây, Mít dai, Thạch dừa, Xoài chín, Dưa gang, Dưa hấu, Đu đủ chín, Quả thanh long, Trân châu, Nước cốt dừa, Sữa đặc",
        "ingredient_ids": "food_120;  food_013; food_257; food_014; food_010; food_126; food_004; food_019; food_212; food_087; ",
        "calories": "233.2",
        "protein": "3.6",
        "carbs": "47.1",
        "fat": "3.4",
        "allergen": "sữa",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, low_fat, high_carbs, high_potassium, high_calcium"
    },
    {
        "dish_id": "dish_149",
        "dish_name": "Bánh flan caramel",
        "category": "Tráng miệng; Ăn nhẹ",
        "ingredients": "trứng gà, sữa tươi, đường, sữa đặc",
        "ingredient_ids": "food_045; food_042; food_054; food_087",
        "calories": "111.9",
        "protein": "5.2",
        "carbs": "13.5",
        "fat": "4.1",
        "allergen": "trứng, sữa",
        "phân loại": "giảm_cân",
        "health_tags": "low_fat, moderate_energy"
    },
    {
        "dish_id": "dish_150",
        "dish_name": "Chè kem dừa (Coconut ice cream dessert soup)",
        "category": "Tráng miệng; Ăn nhẹ",
        "ingredients": "Nước cốt dừa, Kem dừa, Trân châu, Thạch dừa, Lạc rang, Trân châu trắng, Thạch nha đam, Cùi dừa nạo",
        "ingredient_ids": "food_212; food_304; food_303; food_038; food_211; food_009; food_306; food_307",
        "calories": "385.5",
        "protein": "5.5",
        "carbs": "66.5",
        "fat": "10.8",
        "allergen": "nut",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_carbs, high_calcium, high_potassium"
    },
    {
        "dish_id": "dish_151",
        "dish_name": "Cà phê trứng (trứng coffee)",
        "category": "Đồ uống; Ăn nhẹ",
        "ingredients": "Lòng đỏ trứng gà, Cà phê đen, Sữa đặc",
        "ingredient_ids": "food_115; food_087; food_308",
        "calories": "228.8",
        "protein": "8.7",
        "carbs": "8.7",
        "fat": "17.7",
        "allergen": "trứng, sữa",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_vitamin_A, high_iron"
    },
    {
        "dish_id": "dish_152",
        "dish_name": "Sữa chua nếp cẩm (Black sticky rice yogurt)",
        "category": "Tráng miệng; Ăn nhẹ",
        "ingredients": "Sữa chua, Xôi nếp cẩm, Trân châu, Sữa đặc có đường, Nước cốt dừa, Cùi dừa nạo",
        "ingredient_ids": "food_064; food_242; food_307; food_087; food_212; food_009",
        "calories": "437.4",
        "protein": "11.2",
        "carbs": "78.3",
        "fat": "8.8",
        "allergen": "sữa",
        "phân loại": "giữ_cân",
        "health_tags": "moderate_energy, high_carbs, high_calcium, high_potassium"
    }
]
    system_message = {"role": "system", "content":f"""
        -Bạn là trợ lí dinh dưỡng ảo tiếng việt và trả lời nhẹ nhàng, có thể thêm emoji, trả lời mọi câu hỏi liên quan đến ăn uống, dinh dưỡng, sức khỏe, thói quen ăn uống, dị ứng. Nếu người dùng hỏi những câu hỏi không liên quan đến lĩnh vực của bạn thì nhớ nhắc người dùng là bạn chuyên về dinh dưỡng và sức khỏe là chính. Câu trả lời không được hơn 2000 kí tự
        Dưới đây là thông tin của người dùng để bạn hiểu rõ về người dùng hơn, và không được nhắc lại thông tin của người dùng trừ khi họ yêu cầu:[
        
        Tuổi: {age}
        Giới tính: {gender}
        Chiều cao: {height} cm
        Cân nặng: {weight} kg
        Dị ứng: {allergy}
        Mục tiêu: {goal}
        Cân nặng mục tiêu: {goal_weight}
        ].        
        -Dưới đây là thông tin đồ ăn lấy từ database + {food}, hãy trả lời thông tin dinh dưỡng cho người dùng.
        -Nếu người dùng yêu cầu món ăn thì hãy trả lời dưới dạng sau.
        ### 🧾 Định dạng trả lời chuẩn bắt buộc phải đưa ra cho từng món ăn:

        ⭐
        Món ăn đề xuất: (tên món ăn rõ ràng)
        Lý do chọn: (1–2 câu nêu lý do chọn món, phù hợp sức khỏe hoặc mục tiêu)
        Thông tin dinh dưỡng (ước tính cho 1 khẩu phần):
        
        Calo: Khoảng (…) - (…) kcal
        Protein: … g
        Carb: … g
        Fat: … g⭐,

        -Hãy trả lời người dùng 1 cách thân thiện.
        -Tránh lặp lại cùng một bộ món ăn trong nhiều lần gợi ý.
        """}
    messages = list(conversation_history) # Create a mutable copy

    messages.append(system_message)
    messages.append({"role": "user", "content": prompt})
    completion = client.chat.completions.create(
        model="openai/gpt-oss-20b:groq",
        messages=messages,
    )

    bot_response = completion.choices[0].message.content

    # Add the bot's response to the history
    messages.append({"role": "assistant", "content": bot_response})
    messages.remove(system_message)

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