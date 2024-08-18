---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/astradb.ipynb
description: 이 문서는 Astra DB를 벡터 스토어로 사용하는 방법에 대한 빠른 시작 가이드를 제공합니다. 간편한 JSON API를 통해
  서버리스 데이터베이스를 활용하세요.
---

# Astra DB 벡터 스토어

이 페이지는 [Astra DB](https://docs.datastax.com/en/astra/home/astra.html)를 벡터 스토어로 사용하는 빠른 시작 가이드를 제공합니다.

> DataStax [Astra DB](https://docs.datastax.com/en/astra/home/astra.html)는 Apache Cassandra®를 기반으로 구축된 서버리스 벡터 기능 데이터베이스로, 사용하기 쉬운 JSON API를 통해 편리하게 제공됩니다.

## 설정

통합을 사용하려면 `langchain-astradb` 파트너 패키지가 필요합니다:

```python
pip install -qU "langchain-astradb>=0.3.3"
```


### 자격 증명

AstraDB 벡터 스토어를 사용하려면 먼저 [AstraDB 웹사이트](https://astra.datastax.com)로 이동하여 계정을 만들고 새 데이터베이스를 생성해야 합니다. 초기화에는 몇 분이 걸릴 수 있습니다.

데이터베이스가 초기화되면 [애플리케이션 토큰을 생성](https://docs.datastax.com/en/astra-db-serverless/administration/manage-application-tokens.html#generate-application-token)하고 나중에 사용할 수 있도록 저장해야 합니다.

또한 `Database Details`에서 `API Endpoint`를 복사하여 `ASTRA_DB_API_ENDPOINT` 변수에 저장해야 합니다.

선택적으로 네임스페이스를 제공할 수 있으며, 이는 데이터베이스 대시보드의 `Data Explorer` 탭에서 관리할 수 있습니다. 네임스페이스를 설정하지 않으려면 `ASTRA_DB_NAMESPACE`에 대한 `getpass` 프롬프트를 비워둘 수 있습니다.

```python
import getpass

ASTRA_DB_API_ENDPOINT = getpass.getpass("ASTRA_DB_API_ENDPOINT = ")
ASTRA_DB_APPLICATION_TOKEN = getpass.getpass("ASTRA_DB_APPLICATION_TOKEN = ")

desired_namespace = getpass.getpass("ASTRA_DB_NAMESPACE = ")
if desired_namespace:
    ASTRA_DB_NAMESPACE = desired_namespace
else:
    ASTRA_DB_NAMESPACE = None
```


모델 호출의 최상급 자동 추적을 원하신다면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

Astra DB 벡터 스토어를 생성하는 방법은 두 가지가 있으며, 임베딩이 계산되는 방식이 다릅니다.

#### 방법 1: 명시적 임베딩

대부분의 다른 LangChain 벡터 스토어와 마찬가지로 `langchain_core.embeddings.Embeddings` 클래스를 별도로 인스턴스화하고 이를 `AstraDBVectorStore` 생성자에 전달할 수 있습니다.

#### 방법 2: 통합 임베딩 계산

또는 Astra DB의 [Vectorize](https://www.datastax.com/blog/simplifying-vector-embedding-generation-with-astra-vectorize) 기능을 사용하여 스토어를 생성할 때 지원되는 임베딩 모델의 이름을 지정할 수 있습니다. 임베딩 계산은 데이터베이스 내에서 완전히 처리됩니다. (이 방법을 진행하려면, 원하는 임베딩 통합을 데이터베이스에 대해 활성화해야 하며, 이에 대한 설명은 [문서](https://docs.datastax.com/en/astra-db-serverless/databases/embedding-generation.html)를 참조하십시오.)

### 명시적 임베딩 초기화

아래에서는 명시적 임베딩 클래스를 사용하여 벡터 스토어를 인스턴스화합니다:

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "AstraDBVectorStore", "source": "langchain_astradb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_astradb.vectorstores.AstraDBVectorStore.html", "title": "Astra DB Vector Store"}]-->
from langchain_astradb import AstraDBVectorStore

vector_store = AstraDBVectorStore(
    collection_name="astra_vector_langchain",
    embedding=embeddings,
    api_endpoint=ASTRA_DB_API_ENDPOINT,
    token=ASTRA_DB_APPLICATION_TOKEN,
    namespace=ASTRA_DB_NAMESPACE,
)
```


### 통합 임베딩 초기화

여기서는 다음과 같은 조건이 충족된다고 가정합니다:

- Astra DB 조직에서 OpenAI 통합을 활성화했습니다.
- `"OPENAI_API_KEY"`라는 이름의 API 키를 통합에 추가하고, 사용 중인 데이터베이스에 범위를 지정했습니다.

이 작업을 수행하는 방법에 대한 자세한 내용은 [문서](https://docs.datastax.com/en/astra-db-serverless/integrations/embedding-providers/openai.html)를 참조하십시오.

```python
from astrapy.info import CollectionVectorServiceOptions

openai_vectorize_options = CollectionVectorServiceOptions(
    provider="openai",
    model_name="text-embedding-3-small",
    authentication={
        "providerKey": "OPENAI_API_KEY",
    },
)

vector_store_integrated = AstraDBVectorStore(
    collection_name="astra_vector_langchain_integrated",
    api_endpoint=ASTRA_DB_API_ENDPOINT,
    token=ASTRA_DB_APPLICATION_TOKEN,
    namespace=ASTRA_DB_NAMESPACE,
    collection_vector_service_options=openai_vectorize_options,
)
```


## 벡터 스토어 관리

벡터 스토어를 생성한 후, 다양한 항목을 추가 및 삭제하여 상호작용할 수 있습니다.

### 벡터 스토어에 항목 추가

`add_documents` 함수를 사용하여 벡터 스토어에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Astra DB Vector Store"}]-->
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
[UUID('89a5cea1-5f3d-47c1-89dc-7e36e12cf4de'),
 UUID('d4e78c48-f954-4612-8a38-af22923ba23b'),
 UUID('058e4046-ded0-4fc1-b8ac-60e5a5f08ea0'),
 UUID('50ab2a9a-762c-4b78-b102-942a86d77288'),
 UUID('1da5a3c1-ba51-4f2f-aaaf-79a8f5011ce3'),
 UUID('f3055d9e-2eb1-4d25-838e-2c70548f91b5'),
 UUID('4bf0613d-08d0-4fbc-a43c-4955e4c9e616'),
 UUID('18008625-8fd4-45c2-a0d7-92a2cde23dbc'),
 UUID('c712e06f-790b-4fd4-9040-7ab3898965d0'),
 UUID('a9b84820-3445-4810-a46c-e77b76ab85bc')]
```


### 벡터 스토어에서 항목 삭제

`delete` 함수를 사용하여 ID로 벡터 스토어에서 항목을 삭제할 수 있습니다.

```python
vector_store.delete(ids=uuids[-1])
```


```output
True
```


## 벡터 스토어 쿼리

벡터 스토어가 생성되고 관련 문서가 추가된 후, 체인이나 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

#### 유사성 검색

메타데이터 필터링을 통해 간단한 유사성 검색을 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy",
    k=2,
    filter={"source": "tweet"},
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

```output
* Building an exciting new project with LangChain - come check it out! [{'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'source': 'tweet'}]
```


#### 점수가 있는 유사성 검색

점수와 함께 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_with_score(
    "Will it be hot tomorrow?", k=1, filter={"source": "news"}
)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=0.776585] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news'}]
```


#### 기타 검색 방법

MMR 검색이나 벡터로 검색하는 것과 같이 이 노트북에서 다루지 않는 다양한 다른 검색 방법이 있습니다. `AstraDBVectorStore`에서 사용할 수 있는 검색 기능의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_astradb.vectorstores.AstraDBVectorStore.html)를 확인하십시오.

### 검색기로 변환하여 쿼리

벡터 스토어를 검색기로 변환하여 체인에서 더 쉽게 사용할 수 있습니다.

벡터 스토어를 검색기로 변환하고 간단한 쿼리와 필터로 검색기를 호출하는 방법은 다음과 같습니다.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.5},
)
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


```output
[Document(metadata={'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 증강 생성 사용

검색 증강 생성(RAG)을 위해 이 벡터 스토어를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하십시오:

- [튜토리얼: 외부 지식과 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

자세한 내용은 Astra DB를 사용한 완전한 RAG 템플릿을 [여기](https://github.com/langchain-ai/langchain/tree/master/templates/rag-astradb)에서 확인하십시오.

## 벡터 스토어 정리

Astra DB 인스턴스에서 컬렉션을 완전히 삭제하려면 다음을 실행하십시오.

*(저장된 데이터가 손실됩니다.)*

```python
vector_store.delete_collection()
```


## API 참조

모든 `AstraDBVectorStore` 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하십시오: https://api.python.langchain.com/en/latest/vectorstores/langchain_astradb.vectorstores.AstraDBVectorStore.html

## 관련

- 벡터 스토어 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 스토어 [방법 가이드](/docs/how_to/#vector-stores)