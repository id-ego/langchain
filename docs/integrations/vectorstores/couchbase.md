---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/couchbase.ipynb
description: Couchbase는 클라우드, 모바일, AI 및 엣지 컴퓨팅 애플리케이션을 위한 분산 NoSQL 데이터베이스로, 벡터 검색
  기능을 제공합니다.
---

# Couchbase
[Couchbase](http://couchbase.com/)는 모든 클라우드, 모바일, AI 및 엣지 컴퓨팅 애플리케이션에 대해 비할 데 없는 다재다능성, 성능, 확장성 및 재정 가치를 제공하는 수상 경력에 빛나는 분산 NoSQL 클라우드 데이터베이스입니다. Couchbase는 개발자를 위한 코딩 지원과 애플리케이션을 위한 벡터 검색을 통해 AI를 수용합니다.

벡터 검색은 Couchbase의 [전체 텍스트 검색 서비스](https://docs.couchbase.com/server/current/learn/services-and-indexes/services/search-service.html) (검색 서비스)의 일부입니다.

이 튜토리얼에서는 Couchbase에서 벡터 검색을 사용하는 방법을 설명합니다. [Couchbase Capella](https://www.couchbase.com/products/capella/) 또는 자가 관리하는 Couchbase 서버에서 작업할 수 있습니다.

## 설정

`CouchbaseVectorStore`에 접근하려면 먼저 `langchain-couchbase` 파트너 패키지를 설치해야 합니다:

```python
pip install -qU langchain-couchbase
```


### 자격 증명

Couchbase [웹사이트](https://cloud.couchbase.com)로 이동하여 새 연결을 생성하고 데이터베이스 사용자 이름과 비밀번호를 저장하세요:

```python
import getpass

COUCHBASE_CONNECTION_STRING = getpass.getpass(
    "Enter the connection string for the Couchbase cluster: "
)
DB_USERNAME = getpass.getpass("Enter the username for the Couchbase cluster: ")
DB_PASSWORD = getpass.getpass("Enter the password for the Couchbase cluster: ")
```


모델 호출에 대한 최상의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 초기화

인스턴스를 생성하기 전에 연결을 만들어야 합니다.

### Couchbase 연결 객체 생성

먼저 Couchbase 클러스터에 연결을 생성한 다음 클러스터 객체를 벡터 저장소에 전달합니다.

여기서는 위에서 언급한 사용자 이름과 비밀번호를 사용하여 연결하고 있습니다. 클러스터에 연결하는 다른 지원되는 방법을 사용하여 연결할 수도 있습니다.

Couchbase 클러스터에 연결하는 방법에 대한 자세한 내용은 [문서](https://docs.couchbase.com/python-sdk/current/hello-world/start-using-sdk.html#connect)를 확인하세요.

```python
from datetime import timedelta

from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions

auth = PasswordAuthenticator(DB_USERNAME, DB_PASSWORD)
options = ClusterOptions(auth)
cluster = Cluster(COUCHBASE_CONNECTION_STRING, options)

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))
```


이제 벡터 검색에 사용할 Couchbase 클러스터의 버킷, 스코프 및 컬렉션 이름을 설정합니다.

이 예제에서는 기본 스코프 및 컬렉션을 사용하고 있습니다.

```python
BUCKET_NAME = "langchain_bucket"
SCOPE_NAME = "_default"
COLLECTION_NAME = "default"
SEARCH_INDEX_NAME = "langchain-test-index"
```


벡터 필드를 지원하는 검색 인덱스를 생성하는 방법에 대한 자세한 내용은 문서를 참조하세요.

- [Couchbase Capella](https://docs.couchbase.com/cloud/vector-search/create-vector-search-index-ui.html)
- [Couchbase Server](https://docs.couchbase.com/server/current/vector-search/create-vector-search-index-ui.html)

### 간단한 인스턴스화

아래에서는 클러스터 정보와 검색 인덱스 이름으로 벡터 저장소 객체를 생성합니다.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
from langchain_couchbase.vectorstores import CouchbaseVectorStore

vector_store = CouchbaseVectorStore(
    cluster=cluster,
    bucket_name=BUCKET_NAME,
    scope_name=SCOPE_NAME,
    collection_name=COLLECTION_NAME,
    embedding=embeddings,
    index_name=SEARCH_INDEX_NAME,
)
```


### 텍스트 및 임베딩 필드 지정

문서의 텍스트 및 임베딩 필드를 선택적으로 `text_key` 및 `embedding_key` 필드를 사용하여 지정할 수 있습니다.

```python
vector_store_specific = CouchbaseVectorStore(
    cluster=cluster,
    bucket_name=BUCKET_NAME,
    scope_name=SCOPE_NAME,
    collection_name=COLLECTION_NAME,
    embedding=embeddings,
    index_name=SEARCH_INDEX_NAME,
    text_key="text",
    embedding_key="embedding",
)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Couchbase "}]-->
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

```python
vector_store.delete(ids=[uuids[-1]])
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인 또는 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

#### 유사성 검색

간단한 유사성 검색을 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy",
    k=2,
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```


#### 점수가 있는 유사성 검색

`similarity_search_with_score` 메서드를 호출하여 결과의 점수를 가져올 수도 있습니다.

```python
results = vector_store.similarity_search_with_score("Will it be hot tomorrow?", k=1)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```


### 반환할 필드 지정

검색에서 `fields` 매개변수를 사용하여 문서에서 반환할 필드를 지정할 수 있습니다. 이러한 필드는 반환된 문서의 `metadata` 객체의 일부로 반환됩니다. 검색 인덱스에 저장된 모든 필드를 가져올 수 있습니다. 문서의 `text_key`는 문서의 `page_content`의 일부로 반환됩니다.

가져올 필드를 지정하지 않으면 인덱스에 저장된 모든 필드가 반환됩니다.

메타데이터에서 필드 중 하나를 가져오려면 `.`을 사용하여 지정해야 합니다.

예를 들어, 메타데이터에서 `source` 필드를 가져오려면 `metadata.source`를 지정해야 합니다.

```python
query = "What did I eat for breakfast today?"
results = vector_store.similarity_search(query, fields=["metadata.source"])
print(results[0])
```


### 하이브리드 쿼리

Couchbase는 벡터 검색 결과와 문서의 비벡터 필드에 대한 검색을 결합하여 하이브리드 검색을 수행할 수 있습니다.

결과는 벡터 검색과 검색 서비스에서 지원하는 검색의 결과 조합을 기반으로 합니다. 각 구성 검색의 점수를 합산하여 결과의 총 점수를 얻습니다.

하이브리드 검색을 수행하려면 모든 유사성 검색에 전달할 수 있는 선택적 매개변수인 `search_options`가 있습니다.\
`search_options`에 대한 다양한 검색/쿼리 가능성은 [여기](https://docs.couchbase.com/server/current/search/search-request-params.html#query-object)에서 확인할 수 있습니다.

#### 하이브리드 검색을 위한 다양한 메타데이터 생성
하이브리드 검색을 시뮬레이션하기 위해 기존 문서에서 무작위 메타데이터를 생성해 보겠습니다.
2010년과 2020년 사이의 `date`, 1과 5 사이의 `rating`, John Doe 또는 Jane Doe로 설정된 `author`의 세 가지 필드를 메타데이터에 균일하게 추가합니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Couchbase "}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Couchbase "}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

# Adding metadata to documents
for i, doc in enumerate(docs):
    doc.metadata["date"] = f"{range(2010, 2020)[i % 10]}-01-01"
    doc.metadata["rating"] = range(1, 6)[i % 5]
    doc.metadata["author"] = ["John Doe", "Jane Doe"][i % 2]

vector_store.add_documents(docs)

query = "What did the president say about Ketanji Brown Jackson"
results = vector_store.similarity_search(query)
print(results[0].metadata)
```


### 정확한 값으로 쿼리
`metadata` 객체의 저자와 같은 텍스트 필드에서 정확한 일치를 검색할 수 있습니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
results = vector_store.similarity_search(
    query,
    search_options={"query": {"field": "metadata.author", "match": "John Doe"}},
    fields=["metadata.author"],
)
print(results[0])
```


### 부분 일치로 쿼리
검색에 대한 퍼지성을 지정하여 부분 일치를 검색할 수 있습니다. 이는 검색 쿼리의 약간의 변형이나 오타를 검색할 때 유용합니다.

여기서 "Jae"는 "Jane"과 가까운 (퍼지성 1) 것입니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
results = vector_store.similarity_search(
    query,
    search_options={
        "query": {"field": "metadata.author", "match": "Jae", "fuzziness": 1}
    },
    fields=["metadata.author"],
)
print(results[0])
```


### 날짜 범위 쿼리로 쿼리
`metadata.date`와 같은 날짜 필드에서 날짜 범위 쿼리에 해당하는 문서를 검색할 수 있습니다.

```python
query = "Any mention about independence?"
results = vector_store.similarity_search(
    query,
    search_options={
        "query": {
            "start": "2016-12-31",
            "end": "2017-01-02",
            "inclusive_start": True,
            "inclusive_end": False,
            "field": "metadata.date",
        }
    },
)
print(results[0])
```


### 숫자 범위 쿼리로 쿼리
`metadata.rating`과 같은 숫자 필드에서 범위에 해당하는 문서를 검색할 수 있습니다.

```python
query = "Any mention about independence?"
results = vector_store.similarity_search_with_score(
    query,
    search_options={
        "query": {
            "min": 3,
            "max": 5,
            "inclusive_min": True,
            "inclusive_max": True,
            "field": "metadata.rating",
        }
    },
)
print(results[0])
```


### 여러 검색 쿼리 결합
AND (접합) 또는 OR (분리) 연산자를 사용하여 서로 다른 검색 쿼리를 결합할 수 있습니다.

이 예제에서는 3과 4 사이의 평가를 가진 문서와 2015년과 2018년 사이의 날짜를 확인하고 있습니다.

```python
query = "Any mention about independence?"
results = vector_store.similarity_search_with_score(
    query,
    search_options={
        "query": {
            "conjuncts": [
                {"min": 3, "max": 4, "inclusive_max": True, "field": "metadata.rating"},
                {"start": "2016-12-31", "end": "2017-01-02", "field": "metadata.date"},
            ]
        }
    },
)
print(results[0])
```


### 기타 쿼리
유사하게, `search_options` 매개변수에서 Geo Distance, Polygon Search, Wildcard, Regular Expressions 등과 같은 지원되는 쿼리 방법을 사용할 수 있습니다. 사용 가능한 쿼리 방법 및 구문에 대한 자세한 내용은 문서를 참조하세요.

- [Couchbase Capella](https://docs.couchbase.com/cloud/search/search-request-params.html#query-object)
- [Couchbase Server](https://docs.couchbase.com/server/current/search/search-request-params.html#query-object)

### 검색기로 변환하여 쿼리하기

벡터 저장소를 검색기로 변환하여 체인에서 더 쉽게 사용할 수 있습니다.

벡터 저장소를 검색기로 변환한 다음 간단한 쿼리와 필터로 검색기를 호출하는 방법은 다음과 같습니다.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.5},
)
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


## 검색 보강 생성을 위한 사용

이 벡터 저장소를 검색 보강 생성(RAG)에 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변하기](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

# 자주 묻는 질문

## 질문: CouchbaseVectorStore 객체를 생성하기 전에 검색 인덱스를 생성해야 하나요?
네, 현재 `CouchbaseVectoreStore` 객체를 생성하기 전에 검색 인덱스를 생성해야 합니다.

## 질문: 검색 결과에서 지정한 모든 필드를 볼 수 없습니다.

Couchbase에서는 검색 인덱스에 저장된 필드만 반환할 수 있습니다. 검색 결과에서 접근하려는 필드가 검색 인덱스의 일부인지 확인하세요.

이를 처리하는 한 가지 방법은 문서의 필드를 동적으로 인덱싱하고 저장하는 것입니다.

- Capella에서는 "고급 모드"로 이동한 다음 "일반 설정" 아래에서 "[X] 동적 필드 저장" 또는 "[X] 동적 필드 인덱싱"을 체크해야 합니다.
- Couchbase Server에서는 인덱스 편집기(빠른 편집기 아님)에서 "고급" 아래에서 "[X] 동적 필드 저장" 또는 "[X] 동적 필드 인덱싱"을 체크해야 합니다.

이 옵션들은 인덱스의 크기를 증가시킵니다.

동적 매핑에 대한 자세한 내용은 [문서](https://docs.couchbase.com/cloud/search/customize-index.html)를 참조하세요.

## 질문: 검색 결과에서 메타데이터 객체를 볼 수 없습니다.
이는 문서의 `metadata` 필드가 Couchbase 검색 인덱스에 의해 인덱싱되거나 저장되지 않기 때문일 가능성이 높습니다. 문서의 `metadata` 필드를 인덱싱하려면 인덱스에 자식 매핑으로 추가해야 합니다.

매핑에서 모든 필드를 매핑하도록 선택하면 모든 메타데이터 필드로 검색할 수 있습니다. 또는 인덱스를 최적화하기 위해 `metadata` 객체 내의 특정 필드를 인덱싱하도록 선택할 수 있습니다. 자식 매핑 인덱싱에 대한 자세한 내용은 [문서](https://docs.couchbase.com/cloud/search/customize-index.html)를 참조하세요.

자식 매핑 생성

* [Couchbase Capella](https://docs.couchbase.com/cloud/search/create-child-mapping.html)
* [Couchbase Server](https://docs.couchbase.com/server/current/search/create-child-mapping.html)

## API 참조

모든 `CouchbaseVectorStore` 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/vectorstores/langchain_couchbase.vectorstores.CouchbaseVectorStore.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)