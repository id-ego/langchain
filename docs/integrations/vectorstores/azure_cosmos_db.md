---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/azure_cosmos_db.ipynb
description: Azure Cosmos DB Mongo vCore를 활용하여 벡터 검색 쿼리를 수행하고 문서를 저장하는 방법을 소개합니다.
---

# Azure Cosmos DB Mongo vCore

이 노트북은 통합된 [벡터 데이터베이스](https://learn.microsoft.com/en-us/azure/cosmos-db/vector-database)를 활용하여 컬렉션에 문서를 저장하고, 인덱스를 생성하며, COS(코사인 거리), L2(유클리드 거리), IP(내적)과 같은 근사 최근접 이웃 알고리즘을 사용하여 쿼리 벡터에 가까운 문서를 찾기 위한 벡터 검색 쿼리를 수행하는 방법을 보여줍니다.

Azure Cosmos DB는 OpenAI의 ChatGPT 서비스를 지원하는 데이터베이스입니다. 단일 밀리초 응답 시간, 자동 및 즉각적인 확장성, 모든 규모에서 보장된 속도를 제공합니다.

Azure Cosmos DB for MongoDB vCore(https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/vcore/)는 개발자에게 친숙한 아키텍처로 현대 애플리케이션을 구축하기 위한 완전 관리형 MongoDB 호환 데이터베이스 서비스를 제공합니다. MongoDB 경험을 적용하고 애플리케이션을 MongoDB vCore 계정의 연결 문자열에 맞춰 API에 지정하여 좋아하는 MongoDB 드라이버, SDK 및 도구를 계속 사용할 수 있습니다.

[가입하기](https://azure.microsoft.com/en-us/free/)를 통해 평생 무료 액세스를 시작하세요.

```python
%pip install --upgrade --quiet  pymongo langchain-openai langchain-community
```

```output

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m23.2.1[0m[39;49m -> [0m[32;49m23.3.2[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
Note: you may need to restart the kernel to use updated packages.
```


```python
import os

CONNECTION_STRING = "YOUR_CONNECTION_STRING"
INDEX_NAME = "izzy-test-index"
NAMESPACE = "izzy_test_db.izzy_test_collection"
DB_NAME, COLLECTION_NAME = NAMESPACE.split(".")
```


`OpenAIEmbeddings`를 사용하려고 하므로 Azure OpenAI API 키와 기타 환경 변수를 설정해야 합니다.

```python
# Set up the OpenAI Environment Variables
os.environ["OPENAI_API_TYPE"] = "azure"
os.environ["OPENAI_API_VERSION"] = "2023-05-15"
os.environ["OPENAI_API_BASE"] = (
    "YOUR_OPEN_AI_ENDPOINT"  # https://example.openai.azure.com/
)
os.environ["OPENAI_API_KEY"] = "YOUR_OPENAI_API_KEY"
os.environ["OPENAI_EMBEDDINGS_DEPLOYMENT"] = (
    "smart-agent-embedding-ada"  # the deployment name for the embedding model
)
os.environ["OPENAI_EMBEDDINGS_MODEL_NAME"] = "text-embedding-ada-002"  # the model name
```


이제 문서를 컬렉션에 로드하고 인덱스를 생성한 다음 인덱스를 기준으로 쿼리를 실행하여 일치를 검색해야 합니다.

특정 매개변수에 대한 질문이 있는 경우 [문서](https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/vcore/vector-search)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Azure Cosmos DB Mongo vCore"}, {"imported": "AzureCosmosDBVectorSearch", "source": "langchain_community.vectorstores.azure_cosmos_db", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.azure_cosmos_db.AzureCosmosDBVectorSearch.html", "title": "Azure Cosmos DB Mongo vCore"}, {"imported": "CosmosDBSimilarityType", "source": "langchain_community.vectorstores.azure_cosmos_db", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.azure_cosmos_db.CosmosDBSimilarityType.html", "title": "Azure Cosmos DB Mongo vCore"}, {"imported": "CosmosDBVectorSearchType", "source": "langchain_community.vectorstores.azure_cosmos_db", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.azure_cosmos_db.CosmosDBVectorSearchType.html", "title": "Azure Cosmos DB Mongo vCore"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Azure Cosmos DB Mongo vCore"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Azure Cosmos DB Mongo vCore"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.azure_cosmos_db import (
    AzureCosmosDBVectorSearch,
    CosmosDBSimilarityType,
    CosmosDBVectorSearchType,
)
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

SOURCE_FILE_NAME = "../../how_to/state_of_the_union.txt"

loader = TextLoader(SOURCE_FILE_NAME)
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

# OpenAI Settings
model_deployment = os.getenv(
    "OPENAI_EMBEDDINGS_DEPLOYMENT", "smart-agent-embedding-ada"
)
model_name = os.getenv("OPENAI_EMBEDDINGS_MODEL_NAME", "text-embedding-ada-002")


openai_embeddings: OpenAIEmbeddings = OpenAIEmbeddings(
    deployment=model_deployment, model=model_name, chunk_size=1
)
```


```python
from pymongo import MongoClient

# INDEX_NAME = "izzy-test-index-2"
# NAMESPACE = "izzy_test_db.izzy_test_collection"
# DB_NAME, COLLECTION_NAME = NAMESPACE.split(".")

client: MongoClient = MongoClient(CONNECTION_STRING)
collection = client[DB_NAME][COLLECTION_NAME]

model_deployment = os.getenv(
    "OPENAI_EMBEDDINGS_DEPLOYMENT", "smart-agent-embedding-ada"
)
model_name = os.getenv("OPENAI_EMBEDDINGS_MODEL_NAME", "text-embedding-ada-002")

vectorstore = AzureCosmosDBVectorSearch.from_documents(
    docs,
    openai_embeddings,
    collection=collection,
    index_name=INDEX_NAME,
)

# Read more about these variables in detail here. https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/vcore/vector-search
num_lists = 100
dimensions = 1536
similarity_algorithm = CosmosDBSimilarityType.COS
kind = CosmosDBVectorSearchType.VECTOR_IVF
m = 16
ef_construction = 64
ef_search = 40
score_threshold = 0.1

vectorstore.create_index(
    num_lists, dimensions, similarity_algorithm, kind, m, ef_construction
)
```


```output
{'raw': {'defaultShard': {'numIndexesBefore': 1,
   'numIndexesAfter': 2,
   'createdCollectionAutomatically': False,
   'ok': 1}},
 'ok': 1}
```


```python
# perform a similarity search between the embedding of the query and the embeddings of the documents
query = "What did the president say about Ketanji Brown Jackson"
docs = vectorstore.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

문서가 로드되고 인덱스가 생성되면 이제 벡터 저장소를 직접 인스턴스화하고 인덱스를 기준으로 쿼리를 실행할 수 있습니다.

```python
vectorstore = AzureCosmosDBVectorSearch.from_connection_string(
    CONNECTION_STRING, NAMESPACE, openai_embeddings, index_name=INDEX_NAME
)

# perform a similarity search between a query and the ingested documents
query = "What did the president say about Ketanji Brown Jackson"
docs = vectorstore.similarity_search(query)

print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```


```python
vectorstore = AzureCosmosDBVectorSearch(
    collection, openai_embeddings, index_name=INDEX_NAME
)

# perform a similarity search between a query and the ingested documents
query = "What did the president say about Ketanji Brown Jackson"
docs = vectorstore.similarity_search(query)

print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

## 필터링된 벡터 검색 (미리 보기)
Azure Cosmos DB for MongoDB는 $lt, $lte, $eq, $neq, $gte, $gt, $in, $nin 및 $regex로 사전 필터링을 지원합니다. 이 기능을 사용하려면 Azure 구독의 "미리 보기 기능" 탭에서 "벡터 검색 필터링"을 활성화하세요. 미리 보기 기능에 대한 자세한 내용은 [여기](https://learn.microsoft.com/azure/cosmos-db/mongodb/vcore/vector-search#filtered-vector-search-preview)에서 확인하세요.

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)