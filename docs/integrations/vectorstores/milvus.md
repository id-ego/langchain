---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/milvus.ipynb
description: Milvus는 딥러닝 및 머신러닝 모델이 생성한 대규모 임베딩 벡터를 저장하고 관리하는 데이터베이스입니다.
---

# Milvus

> [Milvus](https://milvus.io/docs/overview.md)는 딥 뉴럴 네트워크 및 기타 머신 러닝(ML) 모델에 의해 생성된 대규모 임베딩 벡터를 저장, 인덱싱 및 관리하는 데이터베이스입니다.

이 노트북은 Milvus 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

이 통합을 사용하려면 `pip install -qU langchain-milvus`로 `langchain-milvus`를 설치해야 합니다.

```python
%pip install -qU  langchain_milvus
```


pymilvus의 최신 버전은 프로토타입에 적합한 로컬 벡터 데이터베이스 Milvus Lite를 포함합니다. 백만 개 이상의 문서와 같은 대규모 데이터를 보유하고 있다면 [docker 또는 kubernetes](https://milvus.io/docs/install_standalone-docker.md#Start-Milvus)에서 더 성능이 좋은 Milvus 서버를 설정하는 것을 권장합니다.

### 자격 증명

`Milvus` 벡터 저장소를 사용하기 위해서는 자격 증명이 필요하지 않습니다.

## 초기화

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "Milvus", "source": "langchain_milvus", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_milvus.vectorstores.milvus.Milvus.html", "title": "Milvus"}]-->
from langchain_milvus import Milvus

# The easiest way is to use Milvus Lite where everything is stored in a local file.
# If you have a Milvus server you can use the server URI such as "http://localhost:19530".
URI = "./milvus_example.db"

vector_store = Milvus(
    embedding_function=embeddings,
    connection_args={"uri": URI},
)
```


### Milvus 컬렉션으로 데이터 분리하기

같은 Milvus 인스턴스 내에서 서로 관련 없는 문서를 다른 컬렉션에 저장하여 컨텍스트를 유지할 수 있습니다.

새로운 컬렉션을 만드는 방법은 다음과 같습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Milvus"}]-->
from langchain_core.documents import Document

vector_store_saved = Milvus.from_documents(
    [Document(page_content="foo!")],
    embeddings,
    collection_name="langchain_example",
    connection_args={"uri": URI},
)
```


저장된 컬렉션을 검색하는 방법은 다음과 같습니다.

```python
vector_store_loaded = Milvus(
    embeddings,
    connection_args={"uri": URI},
    collection_name="langchain_example",
)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가하기

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Milvus"}]-->
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
['b0248595-2a41-4f6b-9c25-3a24c1278bb3',
 'fa642726-5329-4495-a072-187e948dd71f',
 '9905001c-a4a3-455e-ab94-72d0ed11b476',
 'eacc7256-d7fa-4036-b1f7-83d7a4bee0c5',
 '7508f7ff-c0c9-49ea-8189-634f8a0244d8',
 '2e179609-3ff7-4c6a-9e05-08978903fe26',
 'fab1f2ac-43e1-45f9-b81b-fc5d334c6508',
 '1206d237-ee3a-484f-baf2-b5ac38eeb314',
 'd43cbf9a-a772-4c40-993b-9439065fec01',
 '25e667bb-6f09-4574-a368-661069301906']
```


### 벡터 저장소에서 항목 삭제하기

```python
vector_store.delete(ids=[uuids[-1]])
```


```output
(insert count: 0, delete count: 1, upsert count: 0, timestamp: 0, success count: 0, err count: 0, cost: 0)
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트를 실행하는 동안 쿼리를 수행하고 싶을 것입니다.

### 직접 쿼리하기

#### 유사성 검색

메타데이터 필터링을 통한 간단한 유사성 검색은 다음과 같이 수행할 수 있습니다:

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
* Building an exciting new project with LangChain - come check it out! [{'pk': '9905001c-a4a3-455e-ab94-72d0ed11b476', 'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'pk': '1206d237-ee3a-484f-baf2-b5ac38eeb314', 'source': 'tweet'}]
```

#### 점수가 있는 유사성 검색

점수로 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_with_score(
    "Will it be hot tomorrow?", k=1, filter={"source": "news"}
)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=21192.628906] bar [{'pk': '2', 'source': 'https://example.com'}]
```

`Milvus` 벡터 저장소를 사용할 때 사용할 수 있는 모든 검색 옵션의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_milvus.vectorstores.milvus.Milvus.html)에서 확인할 수 있습니다.

### 검색기로 변환하여 쿼리하기

벡터 저장소를 체인에서 더 쉽게 사용할 수 있도록 검색기로 변환할 수도 있습니다.

```python
retriever = vector_store.as_retriever(search_type="mmr", search_kwargs={"k": 1})
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


```output
[Document(metadata={'pk': 'eacc7256-d7fa-4036-b1f7-83d7a4bee0c5', 'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 보강 생성 사용법

검색 보강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하십시오:

- [튜토리얼: 외부 지식과 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변하기](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

### 사용자별 검색

검색 앱을 구축할 때는 여러 사용자를 염두에 두고 구축해야 합니다. 이는 한 사용자뿐만 아니라 여러 다른 사용자를 위해 데이터를 저장해야 하며, 이들이 서로의 데이터를 볼 수 없어야 함을 의미합니다.

Milvus는 [partition_key](https://milvus.io/docs/multi_tenancy.md#Partition-key-based-multi-tenancy)를 사용하여 다중 테넌시를 구현할 것을 권장합니다. 여기 예시가 있습니다.
> 파티션 키 기능은 현재 Milvus Lite에서 사용할 수 없으며, 사용하려면 [docker 또는 kubernetes](https://milvus.io/docs/install_standalone-docker.md#Start-Milvus)에서 Milvus 서버를 시작해야 합니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Milvus"}]-->
from langchain_core.documents import Document

docs = [
    Document(page_content="i worked at kensho", metadata={"namespace": "harrison"}),
    Document(page_content="i worked at facebook", metadata={"namespace": "ankush"}),
]
vectorstore = Milvus.from_documents(
    docs,
    embeddings,
    connection_args={"uri": URI},
    drop_old=True,
    partition_key_field="namespace",  # Use the "namespace" field as the partition key
)
```


파티션 키를 사용하여 검색을 수행하려면 검색 요청의 부울 표현식에 다음 중 하나를 포함해야 합니다:

`search_kwargs={"expr": '<partition_key> == "xxxx"'}`

`search_kwargs={"expr": '<partition_key> == in ["xxx", "xxx"]'}`

`<partition_key>`를 파티션 키로 지정된 필드의 이름으로 바꾸십시오.

Milvus는 지정된 파티션 키에 따라 파티션을 변경하고, 파티션 키에 따라 엔티티를 필터링하며, 필터링된 엔티티 중에서 검색합니다.

```python
# This will only get documents for Ankush
vectorstore.as_retriever(search_kwargs={"expr": 'namespace == "ankush"'}).invoke(
    "where did i work?"
)
```


```output
[Document(page_content='i worked at facebook', metadata={'namespace': 'ankush'})]
```


```python
# This will only get documents for Harrison
vectorstore.as_retriever(search_kwargs={"expr": 'namespace == "harrison"'}).invoke(
    "where did i work?"
)
```


```output
[Document(page_content='i worked at kensho', metadata={'namespace': 'harrison'})]
```


## API 참조

모든 __ModuleName__VectorStore 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/vectorstores/langchain_milvus.vectorstores.milvus.Milvus.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [방법 가이드](/docs/how_to/#vector-stores)