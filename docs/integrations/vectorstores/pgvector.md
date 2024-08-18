---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/pgvector.ipynb
description: PGVector는 `postgres`를 백엔드로 사용하고 `pgvector` 확장을 활용하는 LangChain 벡터 저장소
  추상화 구현입니다.
---

# PGVector

> `postgres`를 백엔드로 사용하고 `pgvector` 확장을 활용한 LangChain 벡터 저장소 추상화의 구현입니다.

코드는 [langchain_postgres](https://github.com/langchain-ai/langchain-postgres/)라는 통합 패키지에 있습니다.

## 상태

이 코드는 `langchain_community`에서 `langchain-postgres`라는 전용 패키지로 포팅되었습니다. 다음과 같은 변경 사항이 있습니다:

* langchain_postgres는 psycopg3와만 작동합니다. 연결 문자열을 `postgresql+psycopg2://...`에서 `postgresql+psycopg://langchain:langchain@...`로 업데이트하십시오 (예, 드라이버 이름은 `psycopg`이며 `psycopg3`가 아닙니다. 그러나 `psycopg3`를 사용할 것입니다).
* 임베딩 저장소 및 컬렉션의 스키마가 변경되어 사용자 지정 ID로 add_documents가 올바르게 작동합니다.
* 이제 명시적인 연결 객체를 전달해야 합니다.

현재 스키마 변경에 대한 쉬운 데이터 마이그레이션을 지원하는 **메커니즘**은 없습니다. 따라서 벡터 저장소의 스키마 변경은 사용자가 테이블을 재생성하고 문서를 다시 추가해야 합니다. 이것이 걱정된다면 다른 벡터 저장소를 사용하십시오. 그렇지 않다면 이 구현은 귀하의 사용 사례에 적합할 것입니다.

## 설정

먼저 파트너 패키지를 다운로드하십시오:

```python
pip install -qU langchain_postgres
```


다음 명령을 실행하여 `pgvector` 확장이 포함된 postgres 컨테이너를 시작할 수 있습니다:

```python
%docker run --name pgvector-container -e POSTGRES_USER=langchain -e POSTGRES_PASSWORD=langchain -e POSTGRES_DB=langchain -p 6024:5432 -d pgvector/pgvector:pg16
```


### 자격 증명

이 노트북을 실행하는 데 필요한 자격 증명은 없으며, `langchain_postgres` 패키지를 다운로드하고 postgres 컨테이너를 올바르게 시작했는지 확인하십시오.

모델 호출에 대한 최상의 자동 추적을 원하신다면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 인스턴스화

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "PGVector"}]-->
from langchain_core.documents import Document
from langchain_postgres import PGVector
from langchain_postgres.vectorstores import PGVector

# See docker command above to launch a postgres instance with pgvector enabled.
connection = "postgresql+psycopg://langchain:langchain@localhost:6024/langchain"  # Uses psycopg3!
collection_name = "my_docs"


vector_store = PGVector(
    embeddings=embeddings,
    collection_name=collection_name,
    connection=connection,
    use_jsonb=True,
)
```


## 벡터 저장소 관리

### 벡터 저장소에 항목 추가

ID로 문서를 추가하면 해당 ID와 일치하는 기존 문서가 덮어씌워집니다.

```python
docs = [
    Document(
        page_content="there are cats in the pond",
        metadata={"id": 1, "location": "pond", "topic": "animals"},
    ),
    Document(
        page_content="ducks are also found in the pond",
        metadata={"id": 2, "location": "pond", "topic": "animals"},
    ),
    Document(
        page_content="fresh apples are available at the market",
        metadata={"id": 3, "location": "market", "topic": "food"},
    ),
    Document(
        page_content="the market also sells fresh oranges",
        metadata={"id": 4, "location": "market", "topic": "food"},
    ),
    Document(
        page_content="the new art exhibit is fascinating",
        metadata={"id": 5, "location": "museum", "topic": "art"},
    ),
    Document(
        page_content="a sculpture exhibit is also at the museum",
        metadata={"id": 6, "location": "museum", "topic": "art"},
    ),
    Document(
        page_content="a new coffee shop opened on Main Street",
        metadata={"id": 7, "location": "Main Street", "topic": "food"},
    ),
    Document(
        page_content="the book club meets at the library",
        metadata={"id": 8, "location": "library", "topic": "reading"},
    ),
    Document(
        page_content="the library hosts a weekly story time for kids",
        metadata={"id": 9, "location": "library", "topic": "reading"},
    ),
    Document(
        page_content="a cooking class for beginners is offered at the community center",
        metadata={"id": 10, "location": "community center", "topic": "classes"},
    ),
]

vector_store.add_documents(docs, ids=[doc.metadata["id"] for doc in docs])
```


```output
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=["3"])
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인 또는 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 필터링 지원

벡터 저장소는 문서의 메타데이터 필드에 적용할 수 있는 필터 집합을 지원합니다.

| 연산자 | 의미/카테고리        |
|--------|---------------------|
| \$eq   | 동등성 (==)         |
| \$ne   | 불평등 (!=)         |
| \$lt   | 미만 (<)            |
| \$lte  | 이하 (<=)           |
| \$gt   | 초과 (>)            |
| \$gte  | 이상 (>=)           |
| \$in   | 특별한 경우 (in)    |
| \$nin  | 특별한 경우 (not in)|
| \$between | 특별한 경우 (between) |
| \$like | 텍스트 (like)       |
| \$ilike| 텍스트 (대소문자 구분 없음 like) |
| \$and  | 논리적 (and)       |
| \$or   | 논리적 (or)        |

### 직접 쿼리

간단한 유사성 검색은 다음과 같이 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    "kitty", k=10, filter={"id": {"$in": [1, 5, 2, 9]}}
)
for doc in results:
    print(f"* {doc.page_content} [{doc.metadata}]")
```

```output
* there are cats in the pond [{'id': 1, 'topic': 'animals', 'location': 'pond'}]
* the library hosts a weekly story time for kids [{'id': 9, 'topic': 'reading', 'location': 'library'}]
* ducks are also found in the pond [{'id': 2, 'topic': 'animals', 'location': 'pond'}]
* the new art exhibit is fascinating [{'id': 5, 'topic': 'art', 'location': 'museum'}]
```

여러 필드가 포함된 dict를 제공하지만 연산자가 없는 경우 최상위 수준은 논리적 **AND** 필터로 해석됩니다.

```python
vector_store.similarity_search(
    "ducks",
    k=10,
    filter={"id": {"$in": [1, 5, 2, 9]}, "location": {"$in": ["pond", "market"]}},
)
```


```output
[Document(metadata={'id': 1, 'topic': 'animals', 'location': 'pond'}, page_content='there are cats in the pond'),
 Document(metadata={'id': 2, 'topic': 'animals', 'location': 'pond'}, page_content='ducks are also found in the pond')]
```


```python
vector_store.similarity_search(
    "ducks",
    k=10,
    filter={
        "$and": [
            {"id": {"$in": [1, 5, 2, 9]}},
            {"location": {"$in": ["pond", "market"]}},
        ]
    },
)
```


```output
[Document(metadata={'id': 1, 'topic': 'animals', 'location': 'pond'}, page_content='there are cats in the pond'),
 Document(metadata={'id': 2, 'topic': 'animals', 'location': 'pond'}, page_content='ducks are also found in the pond')]
```


유사성 검색을 실행하고 해당 점수를 받으려면 다음을 실행할 수 있습니다:

```python
results = vector_store.similarity_search_with_score(query="cats", k=1)
for doc, score in results:
    print(f"* [SIM={score:3f}] {doc.page_content} [{doc.metadata}]")
```

```output
* [SIM=0.763449] there are cats in the pond [{'id': 1, 'topic': 'animals', 'location': 'pond'}]
```

`PGVector` 벡터 저장소에서 실행할 수 있는 다양한 검색의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_postgres.vectorstores.PGVector.html)를 참조하십시오.

### 검색기로 변환하여 쿼리

벡터 저장소를 체인에서 더 쉽게 사용하기 위해 검색기로 변환할 수 있습니다.

```python
retriever = vector_store.as_retriever(search_type="mmr", search_kwargs={"k": 1})
retriever.invoke("kitty")
```


```output
[Document(metadata={'id': 1, 'topic': 'animals', 'location': 'pond'}, page_content='there are cats in the pond')]
```


## 검색 증강 생성 사용법

이 벡터 저장소를 검색 증강 생성(RAG)에 사용하는 방법에 대한 가이드는 다음 섹션을 참조하십시오:

- [튜토리얼: 외부 지식과 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## API 참조

모든 __ModuleName__VectorStore 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/vectorstores/langchain_postgres.vectorstores.PGVector.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)