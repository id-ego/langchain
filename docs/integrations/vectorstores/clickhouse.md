---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/clickhouse.ipynb
description: ClickHouse는 실시간 앱과 분석을 위한 빠르고 효율적인 오픈 소스 데이터베이스로, SQL 지원 및 벡터 저장 기능을
  제공합니다.
---

# ClickHouse

> [ClickHouse](https://clickhouse.com/)는 실시간 앱 및 분석을 위한 가장 빠르고 자원 효율적인 오픈 소스 데이터베이스로, 전체 SQL 지원과 사용자가 분석 쿼리를 작성하는 데 도움을 주는 다양한 기능을 제공합니다. 최근에 추가된 데이터 구조 및 거리 검색 기능(예: `L2Distance`)과 [근사 최근접 이웃 검색 인덱스](https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/annindexes)는 ClickHouse가 SQL로 벡터를 저장하고 검색할 수 있는 고성능 및 확장 가능한 벡터 데이터베이스로 사용될 수 있게 합니다.

이 노트북은 `ClickHouse` 벡터 저장소와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

먼저 도커를 사용하여 로컬 ClickHouse 서버를 설정합니다:

```python
! docker run -d -p 8123:8123 -p9000:9000 --name langchain-clickhouse-server --ulimit nofile=262144:262144 clickhouse/clickhouse-server:23.4.2.11
```


이 통합을 사용하려면 `langchain-community` 및 `clickhouse-connect`를 설치해야 합니다.

```python
pip install -qU langchain-community clickhouse-connect
```


### 자격 증명

이 노트북에는 자격 증명이 필요하지 않으며, 위에 표시된 대로 패키지를 설치했는지 확인하세요.

모델 호출에 대한 최상의 자동 추적을 원하시면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 인스턴스화

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "Clickhouse", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.clickhouse.Clickhouse.html", "title": "ClickHouse"}, {"imported": "ClickhouseSettings", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.clickhouse.ClickhouseSettings.html", "title": "ClickHouse"}]-->
from langchain_community.vectorstores import Clickhouse, ClickhouseSettings

settings = ClickhouseSettings(table="clickhouse_example")
vector_store = Clickhouse(embeddings, config=settings)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "ClickHouse"}]-->
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


### 벡터 저장소에서 항목 삭제

`delete` 함수를 사용하여 ID로 벡터 저장소에서 항목을 삭제할 수 있습니다.

```python
vector_store.delete(ids=uuids[-1])
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인 또는 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

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


#### 점수와 함께 유사성 검색

점수와 함께 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_with_score("Will it be hot tomorrow?", k=1)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```


## 필터링

ClickHouse SQL의 WHERE 문에 직접 접근할 수 있습니다. 표준 SQL에 따라 `WHERE` 절을 작성할 수 있습니다.

**참고**: SQL 인젝션에 주의하세요. 이 인터페이스는 최종 사용자가 직접 호출해서는 안 됩니다.

설정에서 `column_map`을 사용자 정의한 경우, 다음과 같이 필터로 검색할 수 있습니다:

```python
meta = vector_store.metadata_column
results = vector_store.similarity_search_with_relevance_scores(
    "What did I eat for breakfast?",
    k=4,
    where_str=f"{meta}.source = 'tweet'",
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```


#### 기타 검색 방법

MMR 검색이나 벡터로 검색하는 것과 같이 이 노트북에서 다루지 않은 다양한 다른 검색 방법이 있습니다. `Clickhouse` 벡터 저장소에서 사용할 수 있는 검색 기능의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.clickhouse.Clickhouse.html)를 확인하세요.

### 검색기로 변환하여 쿼리하기

벡터 저장소를 체인에서 더 쉽게 사용하기 위해 검색기로 변환할 수도 있습니다.

벡터 저장소를 검색기로 변환하고 간단한 쿼리와 필터로 검색기를 호출하는 방법은 다음과 같습니다.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.5},
)
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


## 검색 보강 생성 사용법

검색 보강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식과 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변하기](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

자세한 내용은 Astra DB를 사용하는 완전한 RAG 템플릿을 [여기](https://github.com/langchain-ai/langchain/tree/master/templates/rag-astradb)에서 확인하세요.

## API 참조

모든 `AstraDBVectorStore` 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.clickhouse.Clickhouse.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)