---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/qdrant.ipynb
description: Qdrant는 벡터 유사성 검색 엔진으로, Langchain과 함께 밀집/희소 및 하이브리드 검색을 지원하는 API를 제공합니다.
---

# Qdrant

> [Qdrant](https://qdrant.tech/documentation/) (읽기: 쿼드런트)는 벡터 유사성 검색 엔진입니다. 추가 페이로드 및 확장된 필터링 지원과 함께 벡터를 저장, 검색 및 관리할 수 있는 편리한 API를 제공하는 프로덕션 준비 서비스입니다. 이는 모든 종류의 신경망 또는 의미 기반 매칭, 패싯 검색 및 기타 애플리케이션에 유용합니다.

이 문서는 Langchain과 함께 Qdrant를 사용하여 밀집/희소 및 하이브리드 검색을 수행하는 방법을 보여줍니다.

> 이 페이지는 Qdrant의 새로운 [Query API](https://qdrant.tech/blog/qdrant-1.10.x/)를 통해 여러 검색 모드를 지원하는 `QdrantVectorStore` 클래스를 문서화합니다. Qdrant v1.10.0 이상을 실행해야 합니다.

## 설정

`Qdrant`를 실행하는 방법에는 여러 가지 모드가 있으며, 선택한 모드에 따라 미세한 차이가 있습니다. 옵션은 다음과 같습니다:
- 로컬 모드, 서버 필요 없음
- 도커 배포
- Qdrant 클라우드

[설치 지침](https://qdrant.tech/documentation/install/)을 참조하세요.

```python
%pip install -qU langchain-qdrant
```


### 자격 증명

이 노트북에서 코드를 실행하는 데 필요한 자격 증명은 없습니다.

모델 호출에 대한 최고의 자동 추적을 원하신다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

### 로컬 모드

Python 클라이언트를 사용하면 Qdrant 서버를 실행하지 않고도 로컬 모드에서 동일한 코드를 실행할 수 있습니다. 이는 테스트 및 디버깅 또는 소량의 벡터 저장에 유용합니다. 임베딩은 메모리에 완전히 유지되거나 디스크에 지속될 수 있습니다.

#### 인메모리

일부 테스트 시나리오 및 빠른 실험을 위해 모든 데이터를 메모리에만 유지하는 것을 선호할 수 있으며, 클라이언트가 파괴될 때 데이터는 손실됩니다 - 일반적으로 스크립트/노트북의 끝에서.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "QdrantVectorStore", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.QdrantVectorStore.html", "title": "Qdrant"}]-->
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams

client = QdrantClient(":memory:")

client.create_collection(
    collection_name="demo_collection",
    vectors_config=VectorParams(size=3072, distance=Distance.COSINE),
)

vector_store = QdrantVectorStore(
    client=client,
    collection_name="demo_collection",
    embedding=embeddings,
)
```


#### 디스크 저장

Qdrant 서버를 사용하지 않는 로컬 모드는 벡터를 디스크에 저장하여 실행 간에 지속될 수 있습니다.

```python
client = QdrantClient(path="/tmp/langchain_qdrant")

client.create_collection(
    collection_name="demo_collection",
    vectors_config=VectorParams(size=3072, distance=Distance.COSINE),
)

vector_store = QdrantVectorStore(
    client=client,
    collection_name="demo_collection",
    embedding=embeddings,
)
```


### 온프레미스 서버 배포

Qdrant를 [도커 컨테이너](https://qdrant.tech/documentation/install/)로 로컬에서 실행하든, [공식 Helm 차트](https://github.com/qdrant/qdrant-helm)를 사용하여 Kubernetes 배포를 선택하든, 그러한 인스턴스에 연결하는 방법은 동일합니다. 서비스에 대한 URL을 제공해야 합니다.

```python
url = "<---qdrant url here --->"
docs = []  # put docs here
qdrant = QdrantVectorStore.from_documents(
    docs,
    embeddings,
    url=url,
    prefer_grpc=True,
    collection_name="my_documents",
)
```


### Qdrant 클라우드

인프라 관리를 원하지 않는 경우 [Qdrant Cloud](https://cloud.qdrant.io/)에서 완전 관리형 Qdrant 클러스터를 설정할 수 있습니다. 사용해 볼 수 있는 무료 영구 1GB 클러스터가 포함되어 있습니다. 관리형 Qdrant 버전을 사용할 때의 주요 차이점은 배포가 공개적으로 접근되지 않도록 API 키를 제공해야 한다는 것입니다. 이 값은 `QDRANT_API_KEY` 환경 변수로 설정할 수도 있습니다.

```python
url = "<---qdrant cloud cluster url here --->"
api_key = "<---api key here--->"
qdrant = QdrantVectorStore.from_documents(
    docs,
    embeddings,
    url=url,
    prefer_grpc=True,
    api_key=api_key,
    collection_name="my_documents",
)
```


## 기존 컬렉션 사용

새 문서나 텍스트를 로드하지 않고 `langchain_qdrant.Qdrant`의 인스턴스를 얻으려면 `Qdrant.from_existing_collection()` 메서드를 사용할 수 있습니다.

```python
qdrant = QdrantVectorStore.from_existing_collection(
    embedding=embeddings,
    collection_name="my_documents",
    url="http://localhost:6333",
)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가 및 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Qdrant"}]-->
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
['c04134c3-273d-4766-949a-eee46052ad32',
 '9e6ba50c-794f-4b88-94e5-411f15052a02',
 'd3202666-6f2b-4186-ac43-e35389de8166',
 '50d8d6ee-69bf-4173-a6a2-b254e9928965',
 'bd2eae02-74b5-43ec-9fcf-09e9d9db6fd3',
 '6dae6b37-826d-4f14-8376-da4603b35de3',
 'b0964ab5-5a14-47b4-a983-37fa5c5bd154',
 '91ed6c56-fe53-49e2-8199-c3bb3c33c3eb',
 '42a580cb-7469-4324-9927-0febab57ce92',
 'ff774e5c-f158-4d12-94e2-0a0162b22f27']
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=[uuids[-1]])
```


```output
True
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트 실행 중에 쿼리하고 싶을 것입니다.

### 직접 쿼리

Qdrant 벡터 저장소를 사용하는 가장 간단한 시나리오는 유사성 검색을 수행하는 것입니다. 내부적으로 우리의 쿼리는 벡터 임베딩으로 인코딩되어 Qdrant 컬렉션에서 유사한 문서를 찾는 데 사용됩니다.

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy", k=2
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

```output
* Building an exciting new project with LangChain - come check it out! [{'source': 'tweet', '_id': 'd3202666-6f2b-4186-ac43-e35389de8166', '_collection_name': 'demo_collection'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'source': 'tweet', '_id': '91ed6c56-fe53-49e2-8199-c3bb3c33c3eb', '_collection_name': 'demo_collection'}]
```

`QdrantVectorStore`는 유사성 검색을 위한 3가지 모드를 지원합니다. 클래스 설정 시 `retrieval_mode` 매개변수를 사용하여 구성할 수 있습니다.

- 밀집 벡터 검색(기본값)
- 희소 벡터 검색
- 하이브리드 검색

### 밀집 벡터 검색

밀집 벡터만으로 검색하려면,

- `retrieval_mode` 매개변수를 `RetrievalMode.DENSE`(기본값)으로 설정해야 합니다.
- `embedding` 매개변수에 [밀집 임베딩](https://python.langchain.com/v0.2/docs/integrations/text_embedding/) 값을 제공해야 합니다.

```python
<!--IMPORTS:[{"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import RetrievalMode

qdrant = QdrantVectorStore.from_documents(
    docs,
    embedding=embeddings,
    location=":memory:",
    collection_name="my_documents",
    retrieval_mode=RetrievalMode.DENSE,
)

query = "What did the president say about Ketanji Brown Jackson"
found_docs = qdrant.similarity_search(query)
```


### 희소 벡터 검색

희소 벡터만으로 검색하려면,

- `retrieval_mode` 매개변수를 `RetrievalMode.SPARSE`로 설정해야 합니다.
- `sparse_embedding` 매개변수에 희소 임베딩 제공자를 사용하여 [`SparseEmbeddings`](https://github.com/langchain-ai/langchain/blob/master/libs/partners/qdrant/langchain_qdrant/sparse_embeddings.py) 인터페이스의 구현을 제공해야 합니다.

`langchain-qdrant` 패키지는 기본적으로 [FastEmbed](https://github.com/qdrant/fastembed) 기반 구현을 제공합니다.

이를 사용하려면 FastEmbed 패키지를 설치하세요.

```python
%pip install fastembed
```


```python
<!--IMPORTS:[{"imported": "FastEmbedSparse", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/fastembed_sparse/langchain_qdrant.fastembed_sparse.FastEmbedSparse.html", "title": "Qdrant"}, {"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import FastEmbedSparse, RetrievalMode

sparse_embeddings = FastEmbedSparse(model_name="Qdrant/BM25")

qdrant = QdrantVectorStore.from_documents(
    docs,
    sparse_embedding=sparse_embeddings,
    location=":memory:",
    collection_name="my_documents",
    retrieval_mode=RetrievalMode.SPARSE,
)

query = "What did the president say about Ketanji Brown Jackson"
found_docs = qdrant.similarity_search(query)
```


### 하이브리드 벡터 검색

밀집 및 희소 벡터를 사용하여 점수 융합으로 하이브리드 검색을 수행하려면,

- `retrieval_mode` 매개변수를 `RetrievalMode.HYBRID`로 설정해야 합니다.
- `embedding` 매개변수에 [밀집 임베딩](https://python.langchain.com/v0.2/docs/integrations/text_embedding/) 값을 제공해야 합니다.
- `sparse_embedding` 매개변수에 희소 임베딩 제공자를 사용하여 [`SparseEmbeddings`](https://github.com/langchain-ai/langchain/blob/master/libs/partners/qdrant/langchain_qdrant/sparse_embeddings.py) 인터페이스의 구현을 제공해야 합니다.

`HYBRID` 모드로 문서를 추가한 경우 검색 시 모든 검색 모드로 전환할 수 있습니다. 밀집 및 희소 벡터가 모두 컬렉션에 있기 때문입니다.

```python
<!--IMPORTS:[{"imported": "FastEmbedSparse", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/fastembed_sparse/langchain_qdrant.fastembed_sparse.FastEmbedSparse.html", "title": "Qdrant"}, {"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import FastEmbedSparse, RetrievalMode

sparse_embeddings = FastEmbedSparse(model_name="Qdrant/BM25")

qdrant = QdrantVectorStore.from_documents(
    docs,
    embedding=embeddings,
    sparse_embedding=sparse_embeddings,
    location=":memory:",
    collection_name="my_documents",
    retrieval_mode=RetrievalMode.HYBRID,
)

query = "What did the president say about Ketanji Brown Jackson"
found_docs = qdrant.similarity_search(query)
```


유사성 검색을 실행하고 해당 점수를 받으려면 다음을 실행할 수 있습니다:

```python
results = vector_store.similarity_search_with_score(
    query="Will it be hot tomorrow", k=1
)
for doc, score in results:
    print(f"* [SIM={score:3f}] {doc.page_content} [{doc.metadata}]")
```

```output
* [SIM=0.531834] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news', '_id': '9e6ba50c-794f-4b88-94e5-411f15052a02', '_collection_name': 'demo_collection'}]
```

`QdrantVectorStore`에서 사용할 수 있는 모든 검색 함수의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.QdrantVectorStore.html)를 읽어보세요.

### 메타데이터 필터링

Qdrant는 풍부한 유형 지원을 갖춘 [광범위한 필터링 시스템](https://qdrant.tech/documentation/concepts/filtering/)을 제공합니다. 추가 매개변수를 `similarity_search_with_score` 및 `similarity_search` 메서드에 전달하여 Langchain에서 필터를 사용할 수도 있습니다.

```python
from qdrant_client.http import models

results = vector_store.similarity_search(
    query="Who are the best soccer players in the world?",
    k=1,
    filter=models.Filter(
        should=[
            models.FieldCondition(
                key="page_content",
                match=models.MatchValue(
                    value="The top 10 soccer players in the world right now."
                ),
            ),
        ]
    ),
)
for doc in results:
    print(f"* {doc.page_content} [{doc.metadata}]")
```

```output
* The top 10 soccer players in the world right now. [{'source': 'website', '_id': 'b0964ab5-5a14-47b4-a983-37fa5c5bd154', '_collection_name': 'demo_collection'}]
```

### 검색기로 변환하여 쿼리하기

벡터 저장소를 검색기로 변환하여 체인에서 더 쉽게 사용할 수 있습니다.

```python
retriever = vector_store.as_retriever(search_type="mmr", search_kwargs={"k": 1})
retriever.invoke("Stealing from the bank is a crime")
```


```output
[Document(metadata={'source': 'news', '_id': '50d8d6ee-69bf-4173-a6a2-b254e9928965', '_collection_name': 'demo_collection'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 보강 생성 사용

검색 보강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변하기](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## Qdrant 사용자 정의

Langchain 애플리케이션 내에서 기존 Qdrant 컬렉션을 사용할 수 있는 옵션이 있습니다. 이러한 경우 Qdrant 포인트를 Langchain `Document`로 매핑하는 방법을 정의해야 할 수 있습니다.

### 명명된 벡터

Qdrant는 명명된 벡터를 통해 [포인트당 여러 벡터](https://qdrant.tech/documentation/concepts/collections/#collection-with-multiple-vectors)를 지원합니다. 외부에서 생성된 컬렉션으로 작업하거나 다르게 명명된 벡터를 사용하려는 경우 이름을 제공하여 구성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import RetrievalMode

QdrantVectorStore.from_documents(
    docs,
    embedding=embeddings,
    sparse_embedding=sparse_embeddings,
    location=":memory:",
    collection_name="my_documents_2",
    retrieval_mode=RetrievalMode.HYBRID,
    vector_name="custom_vector",
    sparse_vector_name="custom_sparse_vector",
)
```


### 메타데이터

Qdrant는 선택적 JSON 유사 페이로드와 함께 벡터 임베딩을 저장합니다. 페이로드는 선택 사항이지만 LangChain은 임베딩이 문서에서 생성된 것으로 가정하므로 원본 텍스트를 추출할 수 있도록 컨텍스트 데이터를 유지합니다.

기본적으로 문서는 다음 페이로드 구조에 저장됩니다:

```json
{
    "page_content": "Lorem ipsum dolor sit amet",
    "metadata": {
        "foo": "bar"
    }
}
```


그러나 페이지 내용과 메타데이터에 대해 다른 키를 사용할지 결정할 수 있습니다. 이는 재사용하고 싶은 컬렉션이 이미 있는 경우 유용합니다.

```python
QdrantVectorStore.from_documents(
    docs,
    embeddings,
    location=":memory:",
    collection_name="my_documents_2",
    content_payload_key="my_page_content_key",
    metadata_payload_key="my_meta",
)
```


## API 참조

모든 `QdrantVectorStore` 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.QdrantVectorStore.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [방법 가이드](/docs/how_to/#vector-stores)