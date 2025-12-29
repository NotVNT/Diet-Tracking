import os
from pathlib import Path
from dotenv import load_dotenv
import pandas as pd

from graphrag.config.enums import ModelType
from graphrag.config.models.drift_search_config import DRIFTSearchConfig
from graphrag.config.models.language_model_config import LanguageModelConfig
from graphrag.config.models.vector_store_schema_config import VectorStoreSchemaConfig
from graphrag.language_model.manager import ModelManager
from graphrag.query.indexer_adapters import (
    read_indexer_entities,
    read_indexer_relationships,
    read_indexer_report_embeddings,
    read_indexer_reports,
    read_indexer_text_units,
)
from graphrag.query.structured_search.drift_search.drift_context import (
    DRIFTSearchContextBuilder,
)
from graphrag.query.structured_search.drift_search.search import DRIFTSearch
from graphrag.tokenizer.get_tokenizer import get_tokenizer
from graphrag.vector_stores.lancedb import LanceDBVectorStore

from neo4j import GraphDatabase

uri = "neo4j://localhost:7687"
driver = GraphDatabase.driver(uri, auth=("neo4j", "foodrecommendation123"))  # thay mật khẩu nếu đã đổi

def get_recipes(tx):
    return list(tx.run("""
    MATCH (r:Recipe)
    RETURN r.recipe_id AS id, r.title AS title, r.recipe_cuisine AS cuisine,
           r.rating_value AS rating_value
    """))

def get_ingredients(tx):
    return list(tx.run("""
    MATCH (i:Ingredient)
    RETURN i.ingredient_id AS id, i.canonical_name AS name, i.category AS category
    """))

def get_relationships(tx):
    return list(tx.run("""
    MATCH (r:Recipe)-[rel:CONTAINS]->(i:Ingredient)
    RETURN r.recipe_id AS source, i.ingredient_id AS target, type(rel) AS rel_type
    """))

with driver.session() as session:
    recipe_df = pd.DataFrame([dict(r) for r in session.read_transaction(get_recipes)])
    ingredient_df = pd.DataFrame([dict(r) for r in session.read_transaction(get_ingredients)])
    relationship_df = pd.DataFrame([dict(r) for r in session.read_transaction(get_relationships)])





load_dotenv()

INPUT_DIR = "C:/Users/LENOVO/myfilebro/testing/graphrag_project/output"
LANCEDB_URI = f"{INPUT_DIR}/lancedb"

COMMUNITY_REPORT_TABLE = "community_reports"
COMMUNITY_TABLE = "communities"
ENTITY_TABLE = "entities"
RELATIONSHIP_TABLE = "relationships"
# COVARIATE_TABLE = "covariates"
TEXT_UNIT_TABLE = "text_units"
COMMUNITY_LEVEL = 2


# read nodes table to get community and degree data
entity_df = pd.concat([recipe_df, ingredient_df], ignore_index=True)
community_df = pd.read_parquet(f"{INPUT_DIR}/{COMMUNITY_TABLE}.parquet")

print(f"Entity df columns: {entity_df.columns}")

entities = read_indexer_entities(entity_df, community_df, COMMUNITY_LEVEL)


# load description embeddings to an in-memory lancedb vectorstore
# to connect to a remote db, specify url and port values.
description_embedding_store = LanceDBVectorStore(
    vector_store_schema_config=VectorStoreSchemaConfig(
        index_name="default-entity-description"
    ),
)
description_embedding_store.connect(db_uri=LANCEDB_URI)

full_content_embedding_store = LanceDBVectorStore(
    vector_store_schema_config=VectorStoreSchemaConfig(
        index_name="default-community-full_content"
    )
)
full_content_embedding_store.connect(db_uri=LANCEDB_URI)

print(f"Entity count: {len(entity_df)}")
entity_df.head()

relationships = read_indexer_relationships(relationship_df)

print(f"Relationship count: {len(relationship_df)}")
relationship_df.head()

text_unit_df = pd.read_parquet(f"{INPUT_DIR}/{TEXT_UNIT_TABLE}.parquet")
text_units = read_indexer_text_units(text_unit_df)

print(f"Text unit records: {len(text_unit_df)}")
text_unit_df.head()

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

def read_community_reports(
    input_dir: str,
    community_report_table: str = COMMUNITY_REPORT_TABLE,
):
    """Embeds the full content of the community reports and saves the DataFrame with embeddings to the output path."""
    input_path = Path(input_dir) / f"{community_report_table}.parquet"
    return pd.read_parquet(input_path)


report_df = read_community_reports(INPUT_DIR)
reports = read_indexer_reports(
    report_df,
    community_df,
    COMMUNITY_LEVEL,
    content_embedding_col="full_content_embeddings",
)
read_indexer_report_embeddings(reports, full_content_embedding_store)

drift_params = DRIFTSearchConfig(
    temperature=0,
    max_tokens=12_000,
    primer_folds=1,
    drift_k_followups=3,
    n_depth=3,
    n=1,
)

context_builder = DRIFTSearchContextBuilder(
    model=chat_model,
    text_embedder=text_embedder,
    entities=entities,
    relationships=relationships,
    reports=reports,
    entity_text_embeddings=description_embedding_store,
    text_units=text_units,
    tokenizer=tokenizer,
    config=drift_params,
)

search = DRIFTSearch(
    model=chat_model, context_builder=context_builder, tokenizer=tokenizer
)

import asyncio

async def main():
    resp = await search.search("đề xuất món ăn sáng. Nếu không tìm thấy câu trả lời khi mở rộng, hãy quay lại node ban đầu và trả lời ngắn gọn.")
    return (resp.response)

asyncio.run(main())