---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_vertex_ai_vector_search.ipynb
description: 이 문서는 Google Cloud Vertex AI Vector Search를 활용한 벡터 데이터베이스 기능 사용법을 설명합니다.
---

# 구글 버텍스 AI 벡터 검색

이 노트북은 `Google Cloud Vertex AI Vector Search` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

> [Google Vertex AI Vector Search](https://cloud.google.com/vertex-ai/docs/vector-search/overview), 이전에 Vertex AI Matching Engine으로 알려졌던, 업계 최고의 고규모 저지연 벡터 데이터베이스를 제공합니다. 이러한 벡터 데이터베이스는 일반적으로 벡터 유사성 매칭 또는 근사 최근접 이웃(ANN) 서비스라고 불립니다.

**참고**: Langchain API는 이미 생성된 엔드포인트와 배포된 인덱스를 기대합니다. 인덱스 생성 시간은 최대 1시간이 소요될 수 있습니다.

> 인덱스를 생성하는 방법은 [Create Index and deploy it to an Endpoint](#create-index-and-deploy-it-to-an-endpoint) 섹션을 참조하세요.\
이미 배포된 인덱스가 있는 경우 [Create VectorStore from texts](#create-vector-store-from-texts)로 건너뛰세요.

## 인덱스 생성 및 엔드포인트에 배포
- 이 섹션에서는 새로운 인덱스를 생성하고 이를 엔드포인트에 배포하는 방법을 보여줍니다.

```python
# TODO : Set values as per your requirements
# Project and Storage Constants
PROJECT_ID = "<my_project_id>"
REGION = "<my_region>"
BUCKET = "<my_gcs_bucket>"
BUCKET_URI = f"gs://{BUCKET}"

# The number of dimensions for the textembedding-gecko@003 is 768
# If other embedder is used, the dimensions would probably need to change.
DIMENSIONS = 768

# Index Constants
DISPLAY_NAME = "<my_matching_engine_index_id>"
DEPLOYED_INDEX_ID = "<my_matching_engine_endpoint_id>"
```


```python
# Create a bucket.
! gsutil mb -l $REGION -p $PROJECT_ID $BUCKET_URI
```


### [VertexAIEmbeddings](https://python.langchain.com/docs/integrations/text_embedding/google_vertex_ai_palm/)를 임베딩 모델로 사용

```python
from google.cloud import aiplatform
from langchain_google_vertexai import VertexAIEmbeddings
```


```python
aiplatform.init(project=PROJECT_ID, location=REGION, staging_bucket=BUCKET_URI)
```


```python
embedding_model = VertexAIEmbeddings(model_name="textembedding-gecko@003")
```


### 빈 인덱스 생성

**참고:** 인덱스를 생성할 때 "BATCH_UPDATE" 또는 "STREAM_UPDATE" 중 하나에서 "index_update_method"를 지정해야 합니다.
> 배치 인덱스는 정해진 시간 동안 저장된 데이터로 인덱스를 일괄 업데이트하려는 경우에 사용됩니다. 예를 들어, 주간 또는 월간으로 처리되는 시스템입니다. 스트리밍 인덱스는 새로운 데이터가 데이터 저장소에 추가될 때 인덱스 데이터를 업데이트하려는 경우에 사용됩니다. 예를 들어, 서점이 있고 가능한 한 빨리 새로운 재고를 온라인에 표시하려는 경우입니다. 어떤 유형을 선택하느냐가 중요하며, 설정 및 요구 사항이 다릅니다.

인덱스 구성에 대한 자세한 내용은 [공식 문서](https://cloud.google.com/vertex-ai/docs/vector-search/create-manage-index#create-index-batch)를 참조하세요.

```python
# NOTE : This operation can take upto 30 seconds
my_index = aiplatform.MatchingEngineIndex.create_tree_ah_index(
    display_name=DISPLAY_NAME,
    dimensions=DIMENSIONS,
    approximate_neighbors_count=150,
    distance_measure_type="DOT_PRODUCT_DISTANCE",
    index_update_method="STREAM_UPDATE",  # allowed values BATCH_UPDATE , STREAM_UPDATE
)
```


### 엔드포인트 생성

```python
# Create an endpoint
my_index_endpoint = aiplatform.MatchingEngineIndexEndpoint.create(
    display_name=f"{DISPLAY_NAME}-endpoint", public_endpoint_enabled=True
)
```


### 인덱스를 엔드포인트에 배포

```python
# NOTE : This operation can take upto 20 minutes
my_index_endpoint = my_index_endpoint.deploy_index(
    index=my_index, deployed_index_id=DEPLOYED_INDEX_ID
)

my_index_endpoint.deployed_indexes
```


## 텍스트에서 벡터 저장소 생성

참고: 기존 인덱스와 엔드포인트가 있는 경우 아래 코드를 사용하여 로드할 수 있습니다.

```python
# TODO : replace 1234567890123456789 with your acutial index ID
my_index = aiplatform.MatchingEngineIndex("1234567890123456789")

# TODO : replace 1234567890123456789 with your acutial endpoint ID
my_index_endpoint = aiplatform.MatchingEngineIndexEndpoint("1234567890123456789")
```


```python
from langchain_google_vertexai import (
    VectorSearchVectorStore,
    VectorSearchVectorStoreDatastore,
)
```


![Langchainassets.png](/img/31e8d56b9f1cb1311c147e4d56ac21d2.png)

### 필터 없이 간단한 벡터 저장소 생성

```python
# Input texts
texts = [
    "The cat sat on",
    "the mat.",
    "I like to",
    "eat pizza for",
    "dinner.",
    "The sun sets",
    "in the west.",
]

# Create a Vector Store
vector_store = VectorSearchVectorStore.from_components(
    project_id=PROJECT_ID,
    region=REGION,
    gcs_bucket_name=BUCKET,
    index_id=my_index.name,
    endpoint_id=my_index_endpoint.name,
    embedding=embedding_model,
    stream_update=True,
)

# Add vectors and mapped text chunks to your vectore store
vector_store.add_texts(texts=texts)
```


### 선택 사항: 벡터를 생성하고 데이터 저장소에 청크 저장

```python
# NOTE : This operation can take upto 20 mins
vector_store = VectorSearchVectorStoreDatastore.from_components(
    project_id=PROJECT_ID,
    region=REGION,
    index_id=my_index.name,
    endpoint_id=my_index_endpoint.name,
    embedding=embedding_model,
    stream_update=True,
)

vector_store.add_texts(texts=texts, is_complete_overwrite=True)
```


```python
# Try running a simialarity search
vector_store.similarity_search("pizza")
```


### 메타데이터 필터로 벡터 저장소 생성

```python
# Input text with metadata
record_data = [
    {
        "description": "A versatile pair of dark-wash denim jeans."
        "Made from durable cotton with a classic straight-leg cut, these jeans"
        " transition easily from casual days to dressier occasions.",
        "price": 65.00,
        "color": "blue",
        "season": ["fall", "winter", "spring"],
    },
    {
        "description": "A lightweight linen button-down shirt in a crisp white."
        " Perfect for keeping cool with breathable fabric and a relaxed fit.",
        "price": 34.99,
        "color": "white",
        "season": ["summer", "spring"],
    },
    {
        "description": "A soft, chunky knit sweater in a vibrant forest green. "
        "The oversized fit and cozy wool blend make this ideal for staying warm "
        "when the temperature drops.",
        "price": 89.99,
        "color": "green",
        "season": ["fall", "winter"],
    },
    {
        "description": "A classic crewneck t-shirt in a soft, heathered blue. "
        "Made from comfortable cotton jersey, this t-shirt is a wardrobe essential "
        "that works for every season.",
        "price": 19.99,
        "color": "blue",
        "season": ["fall", "winter", "summer", "spring"],
    },
    {
        "description": "A flowing midi-skirt in a delicate floral print. "
        "Lightweight and airy, this skirt adds a touch of feminine style "
        "to warmer days.",
        "price": 45.00,
        "color": "white",
        "season": ["spring", "summer"],
    },
]
```


```python
# Parse and prepare input data

texts = []
metadatas = []
for record in record_data:
    record = record.copy()
    page_content = record.pop("description")
    texts.append(page_content)
    if isinstance(page_content, str):
        metadata = {**record}
        metadatas.append(metadata)
```


```python
# Inspect metadatas
metadatas
```


```python
# NOTE : This operation can take more than 20 mins
vector_store = VectorSearchVectorStore.from_components(
    project_id=PROJECT_ID,
    region=REGION,
    gcs_bucket_name=BUCKET,
    index_id=my_index.name,
    endpoint_id=my_index_endpoint.name,
    embedding=embedding_model,
)

vector_store.add_texts(texts=texts, metadatas=metadatas, is_complete_overwrite=True)
```


```python
from google.cloud.aiplatform.matching_engine.matching_engine_index_endpoint import (
    Namespace,
    NumericNamespace,
)
```


```python
# Try running a simple similarity search

# Below code should return 5 results
vector_store.similarity_search("shirt", k=5)
```


```python
# Try running a similarity search with text filter
filters = [Namespace(name="season", allow_tokens=["spring"])]

# Below code should return 4 results now
vector_store.similarity_search("shirt", k=5, filter=filters)
```


```python
# Try running a similarity search with combination of text and numeric filter
filters = [Namespace(name="season", allow_tokens=["spring"])]
numeric_filters = [NumericNamespace(name="price", value_float=40.0, op="LESS")]

# Below code should return 2 results now
vector_store.similarity_search(
    "shirt", k=5, filter=filters, numeric_filter=numeric_filters
)
```


### 검색기로서 벡터 저장소 사용

```python
# Initialize the vectore_store as retriever
retriever = vector_store.as_retriever()
```


```python
# perform simple similarity search on retriever
retriever.invoke("What are my options in breathable fabric?")
```


```python
# Try running a similarity search with text filter
filters = [Namespace(name="season", allow_tokens=["spring"])]

retriever.search_kwargs = {"filter": filters}

# perform similarity search with filters on retriever
retriever.invoke("What are my options in breathable fabric?")
```


```python
# Try running a similarity search with combination of text and numeric filter
filters = [Namespace(name="season", allow_tokens=["spring"])]
numeric_filters = [NumericNamespace(name="price", value_float=40.0, op="LESS")]


retriever.search_kwargs = {"filter": filters, "numeric_filter": numeric_filters}

retriever.invoke("What are my options in breathable fabric?")
```


### 질문 응답 체인에서 검색기와 함께 필터 사용

```python
from langchain_google_vertexai import VertexAI

llm = VertexAI(model_name="gemini-pro")
```


```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Google Vertex AI Vector Search"}]-->
from langchain.chains import RetrievalQA

filters = [Namespace(name="season", allow_tokens=["spring"])]
numeric_filters = [NumericNamespace(name="price", value_float=40.0, op="LESS")]

retriever.search_kwargs = {"k": 2, "filter": filters, "numeric_filter": numeric_filters}

retrieval_qa = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    return_source_documents=True,
)

question = "What are my options in breathable fabric?"
response = retrieval_qa({"query": question})
print(f"{response['result']}")
print("REFERENCES")
print(f"{response['source_documents']}")
```


## PDF 읽기, 청크화, 벡터화 및 인덱스화

```python
!pip install pypdf
```


```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "Google Vertex AI Vector Search"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Google Vertex AI Vector Search"}]-->
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
```


```python
loader = PyPDFLoader("https://arxiv.org/pdf/1706.03762.pdf")
pages = loader.load()
```


```python
text_splitter = RecursiveCharacterTextSplitter(
    # Set a really small chunk size, just to show.
    chunk_size=1000,
    chunk_overlap=20,
    length_function=len,
    is_separator_regex=False,
)
doc_splits = text_splitter.split_documents(pages)
```


```python
texts = [doc.page_content for doc in doc_splits]
metadatas = [doc.metadata for doc in doc_splits]
```


```python
texts[0]
```


```python
# Inspect Metadata of 1st page
metadatas[0]
```


```python
vector_store = VectorSearchVectorStore.from_components(
    project_id=PROJECT_ID,
    region=REGION,
    gcs_bucket_name=BUCKET,
    index_id=my_index.name,
    endpoint_id=my_index_endpoint.name,
    embedding=embedding_model,
)

vector_store.add_texts(texts=texts, metadatas=metadatas, is_complete_overwrite=True)
```


```python
vector_store = VectorSearchVectorStore.from_components(
    project_id=PROJECT_ID,
    region=REGION,
    gcs_bucket_name=BUCKET,
    index_id=my_index.name,
    endpoint_id=my_index_endpoint.name,
    embedding=embedding_model,
)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)