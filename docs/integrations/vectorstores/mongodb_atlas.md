---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/mongodb_atlas.ipynb
description: 이 문서는 LangChain에서 MongoDB Atlas 벡터 검색을 사용하는 방법과 `langchain-mongodb` 패키지에
  대해 설명합니다.
---

# MongoDB Atlas

이 노트북은 `langchain-mongodb` 패키지를 사용하여 LangChain에서 MongoDB Atlas 벡터 검색을 수행하는 방법을 다룹니다.

> [MongoDB Atlas](https://www.mongodb.com/docs/atlas/)는 AWS, Azure 및 GCP에서 사용할 수 있는 완전 관리형 클라우드 데이터베이스입니다. MongoDB 문서 데이터에 대한 기본 벡터 검색 및 전체 텍스트 검색(BM25)을 지원합니다.

> [MongoDB Atlas 벡터 검색](https://www.mongodb.com/products/platform/atlas-vector-search)은 MongoDB 문서에 임베딩을 저장하고, 벡터 검색 인덱스를 생성하며, 근사 최근접 이웃 알고리즘(`Hierarchical Navigable Small Worlds`)을 사용하여 KNN 검색을 수행할 수 있게 해줍니다. 이는 [$vectorSearch MQL Stage](https://www.mongodb.com/docs/atlas/atlas-vector-search/vector-search-overview/)를 사용합니다.

## 설정

> *MongoDB 버전 6.0.11, 7.0.2 이상(RC 포함)에서 실행되는 Atlas 클러스터.

MongoDB Atlas를 사용하려면 먼저 클러스터를 배포해야 합니다. Forever-Free 계층의 클러스터가 제공됩니다. 시작하려면 여기에서 Atlas로 이동하세요: [빠른 시작](https://www.mongodb.com/docs/atlas/getting-started/).

이 통합을 사용하려면 `langchain-mongodb`와 `pymongo`를 설치해야 합니다.

```python
pip install -qU langchain-mongodb pymongo
```


### 자격 증명

이 노트북을 위해 MongoDB 클러스터 URI를 찾아야 합니다.

클러스터 URI를 찾는 방법에 대한 정보는 [이 가이드](https://www.mongodb.com/docs/manual/reference/connection-string/)를 읽어보세요.

```python
import getpass

MONGODB_ATLAS_CLUSTER_URI = getpass.getpass("MongoDB Atlas Cluster URI:")
```


모델 호출에 대한 최고의 자동 추적을 얻고 싶다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "MongoDBAtlasVectorSearch", "source": "langchain_mongodb.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_mongodb.vectorstores.MongoDBAtlasVectorSearch.html", "title": "MongoDB Atlas"}]-->
from langchain_mongodb.vectorstores import MongoDBAtlasVectorSearch
from pymongo import MongoClient

# initialize MongoDB python client
client = MongoClient(MONGODB_ATLAS_CLUSTER_URI)

DB_NAME = "langchain_test_db"
COLLECTION_NAME = "langchain_test_vectorstores"
ATLAS_VECTOR_SEARCH_INDEX_NAME = "langchain-test-index-vectorstores"

MONGODB_COLLECTION = client[DB_NAME][COLLECTION_NAME]

vector_store = MongoDBAtlasVectorSearch(
    collection=MONGODB_COLLECTION,
    embedding=embeddings,
    index_name=ATLAS_VECTOR_SEARCH_INDEX_NAME,
    relevance_score_fn="cosine",
)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "MongoDB Atlas"}]-->
from uuid import uuid4

from langchain_core.documents import Document

document_1 = Document(
    page_content="I had chocalate chip pancakes and scrambled eggs for breakfast this morning.",
    metadata={"source": "tweet"},
)

document_2 = Document(
    page_content="The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees.",
    metadata={"source": "news"},
)

document_3 = Document(
    page_content="Building an exciting new project with LangChain - come check it out!",
    metadata={"source": "tweet"},
)

document_4 = Document(
    page_content="Robbers broke into the city bank and stole $1 million in cash.",
    metadata={"source": "news"},
)

document_5 = Document(
    page_content="Wow! That was an amazing movie. I can't wait to see it again.",
    metadata={"source": "tweet"},
)

document_6 = Document(
    page_content="Is the new iPhone worth the price? Read this review to find out.",
    metadata={"source": "website"},
)

document_7 = Document(
    page_content="The top 10 soccer players in the world right now.",
    metadata={"source": "website"},
)

document_8 = Document(
    page_content="LangGraph is the best framework for building stateful, agentic applications!",
    metadata={"source": "tweet"},
)

document_9 = Document(
    page_content="The stock market is down 500 points today due to fears of a recession.",
    metadata={"source": "news"},
)

document_10 = Document(
    page_content="I have a bad feeling I am going to get deleted :(",
    metadata={"source": "tweet"},
)

documents = [
    document_1,
    document_2,
    document_3,
    document_4,
    document_5,
    document_6,
    document_7,
    document_8,
    document_9,
    document_10,
]
uuids = [str(uuid4()) for _ in range(len(documents))]

vector_store.add_documents(documents=documents, ids=uuids)
```


```output
['03ad81e8-32a0-46f0-b7d8-f5b977a6b52a',
 '8396a68d-f4a3-4176-a581-a1a8c303eea4',
 'e7d95150-67f6-499f-b611-84367c50fa60',
 '8c31b84e-2636-48b6-8b99-9fccb47f7051',
 'aa02e8a2-a811-446a-9785-8cea0faba7a9',
 '19bd72ff-9766-4c3b-b1fd-195c732c562b',
 '642d6f2f-3e34-4efa-a1ed-c4ba4ef0da8d',
 '7614bb54-4eb5-4b3b-990c-00e35cb31f99',
 '69e18c67-bf1b-43e5-8a6e-64fb3f240e52',
 '30d599a7-4a1a-47a9-bbf8-6ed393e2e33c']
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=[uuids[-1]])
```


```output
True
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

#### 유사성 검색

간단한 유사성 검색은 다음과 같이 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy", k=2
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

```output
* Building an exciting new project with LangChain - come check it out! [{'_id': 'e7d95150-67f6-499f-b611-84367c50fa60', 'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'_id': '7614bb54-4eb5-4b3b-990c-00e35cb31f99', 'source': 'tweet'}]
```


#### 점수가 있는 유사성 검색

점수가 있는 검색도 가능합니다:

```python
results = vector_store.similarity_search_with_score("Will it be hot tomorrow?", k=1)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=0.784560] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'_id': '8396a68d-f4a3-4176-a581-a1a8c303eea4', 'source': 'news'}]
```


### 유사성 검색을 통한 사전 필터링

Atlas 벡터 검색은 필터링을 위한 MQL 연산자를 사용하여 사전 필터링을 지원합니다. 아래는 위에 로드된 동일한 데이터에 대한 예제 인덱스와 쿼리로, "page" 필드에서 메타데이터 필터링을 수행할 수 있게 해줍니다. 정의된 필터로 기존 인덱스를 업데이트하고 벡터 검색으로 사전 필터링을 수행할 수 있습니다.

```json
{
  "fields":[
    {
      "type": "vector",
      "path": "embedding",
      "numDimensions": 1536,
      "similarity": "cosine"
    },
    {
      "type": "filter",
      "path": "source"
    }
  ]
}
```


`MongoDBAtlasVectorSearch.create_index` 메서드를 사용하여 프로그래밍 방식으로 인덱스를 업데이트할 수도 있습니다.

```python
vectorstore.create_index(
  dimensions=1536,
  filters=[{"type":"filter", "path":"source"}],
  update=True
)
```


그런 다음 다음과 같이 필터와 함께 쿼리를 실행할 수 있습니다:

```python
results = vector_store.similarity_search(query="foo",k=1,pre_filter={"source": {"$eq": "https://example.com"}})
for doc in results:
    print(f"* {doc.page_content} [{doc.metadata}]")
```


#### 기타 검색 방법

MMR 검색이나 벡터로 검색하는 것과 같이 이 노트북에서 다루지 않는 다양한 다른 검색 방법이 있습니다. `AstraDBVectorStore`에 대해 사용할 수 있는 검색 기능의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_astradb.vectorstores.AstraDBVectorStore.html)를 확인하세요.

### 검색기로 변환하여 쿼리하기

벡터 저장소를 검색기로 변환하여 체인에서 더 쉽게 사용할 수 있습니다.

벡터 저장소를 검색기로 변환하고 간단한 쿼리와 필터로 검색기를 호출하는 방법은 다음과 같습니다.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.2},
)
retriever.invoke("Stealing from the bank is a crime")
```


```output
[Document(metadata={'_id': '8c31b84e-2636-48b6-8b99-9fccb47f7051', 'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 보강 생성에 대한 사용법

검색 보강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG를 통한 질문 및 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

# 기타 참고 사항
> * 더 많은 문서는 [LangChain-MongoDB](https://www.mongodb.com/docs/atlas/atlas-vector-search/ai-integrations/langchain/) 사이트에서 확인할 수 있습니다.
> * 이 기능은 일반적으로 사용 가능하며 프로덕션 배포를 위해 준비되었습니다.
> * langchain 버전 0.0.305 ([릴리스 노트](https://github.com/langchain-ai/langchain/releases/tag/v0.0.305))는 MongoDB Atlas 6.0.11 및 7.0.2와 함께 사용할 수 있는 $vectorSearch MQL 단계를 지원합니다. 이전 버전의 MongoDB Atlas를 사용하는 사용자는 LangChain 버전을 <=0.0.304로 고정해야 합니다.
> 

## API 참조

`MongoDBAtlasVectorSearch`의 모든 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/mongodb_api_reference.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)