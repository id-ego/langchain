---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/memorydb.ipynb
description: Amazon MemoryDB는 Redis OSS와 호환되며, 벡터 검색 기능을 통해 고속 데이터 저장 및 검색을 지원하는 메모리
  기반 데이터 저장소입니다.
---

# 아마존 메모리DB

> [벡터 검색](https://docs.aws.amazon.com/memorydb/latest/devguide/vector-search.html/) 소개 및 랭체인 통합 가이드.

## 아마존 메모리DB란 무엇인가요?

메모리DB는 인기 있는 오픈 소스 데이터 저장소인 Redis OSS와 호환되어, 사용자가 이미 사용하고 있는 유연하고 친숙한 Redis OSS 데이터 구조, API 및 명령어를 사용하여 애플리케이션을 신속하게 구축할 수 있게 합니다. 메모리DB를 사용하면 모든 데이터가 메모리에 저장되어 마이크로초 단위의 읽기 및 단일 자리 밀리초 단위의 쓰기 지연 시간과 높은 처리량을 달성할 수 있습니다. 메모리DB는 또한 여러 가용 영역(AZ) 전반에 걸쳐 데이터를 내구성 있게 저장하며, 빠른 장애 조치, 데이터베이스 복구 및 노드 재시작을 가능하게 하는 다중 AZ 트랜잭션 로그를 사용합니다.

## 메모리DB의 벡터 검색

메모리DB의 벡터 검색은 메모리DB의 기능을 확장합니다. 벡터 검색은 기존 메모리DB 기능과 함께 사용할 수 있습니다. 벡터 검색을 사용하지 않는 애플리케이션은 그 존재에 영향을 받지 않습니다. 벡터 검색은 메모리DB가 제공되는 모든 리전에서 사용할 수 있습니다. 기존 메모리DB 데이터 또는 Redis OSS API를 사용하여 검색 보강 생성, 이상 탐지, 문서 검색 및 실시간 추천과 같은 기계 학습 및 생성 AI 사용 사례를 구축할 수 있습니다.

* Redis 해시 및 `JSON`의 여러 필드 인덱싱
* 벡터 유사성 검색 (`HNSW` (ANN) 또는 `FLAT` (KNN) 사용)
* 벡터 범위 검색 (예: 쿼리 벡터의 반경 내 모든 벡터 찾기)
* 성능 손실 없이 점진적 인덱싱

## 설정하기

### Redis Python 클라이언트 설치

`Redis-py`는 메모리DB에 연결하는 데 사용할 수 있는 파이썬 클라이언트입니다.

```python
%pip install --upgrade --quiet  redis langchain-aws
```


```python
from langchain_aws.embeddings import BedrockEmbeddings

embeddings = BedrockEmbeddings()
```


### 메모리DB 연결

유효한 Redis URL 스키마는 다음과 같습니다:
1. `redis://`  - 암호화되지 않은 Redis 클러스터에 연결
2. `rediss://` - TLS 암호화가 적용된 Redis 클러스터에 연결

추가 연결 매개변수에 대한 자세한 정보는 [redis-py 문서](https://redis-py.readthedocs.io/en/stable/connections.html)에서 확인할 수 있습니다.

### 샘플 데이터

먼저 Redis 벡터 저장소의 다양한 속성을 보여주기 위해 일부 샘플 데이터를 설명하겠습니다.

```python
metadata = [
    {
        "user": "john",
        "age": 18,
        "job": "engineer",
        "credit_score": "high",
    },
    {
        "user": "derrick",
        "age": 45,
        "job": "doctor",
        "credit_score": "low",
    },
    {
        "user": "nancy",
        "age": 94,
        "job": "doctor",
        "credit_score": "high",
    },
    {
        "user": "tyler",
        "age": 100,
        "job": "engineer",
        "credit_score": "high",
    },
    {
        "user": "joe",
        "age": 35,
        "job": "dentist",
        "credit_score": "medium",
    },
]
texts = ["foo", "foo", "foo", "bar", "bar"]
index_name = "users"
```


### 메모리DB 벡터 저장소 생성

InMemoryVectorStore 인스턴스는 아래 방법을 사용하여 초기화할 수 있습니다.
- `InMemoryVectorStore.__init__` - 직접 초기화
- `InMemoryVectorStore.from_documents` - `Langchain.docstore.Document` 객체 목록에서 초기화
- `InMemoryVectorStore.from_texts` - 텍스트 목록에서 초기화 (메타데이터와 함께 선택적으로)
- `InMemoryVectorStore.from_existing_index` - 기존 메모리DB 인덱스에서 초기화

```python
from langchain_aws.vectorstores.inmemorydb import InMemoryVectorStore

vds = InMemoryVectorStore.from_texts(
    embeddings,
    redis_url="rediss://cluster_endpoint:6379/ssl=True ssl_cert_reqs=none",
)
```


```python
vds.index_name
```


```output
'users'
```


## 쿼리하기

사용 사례에 따라 `InMemoryVectorStore` 구현을 쿼리하는 여러 방법이 있습니다:

- `similarity_search`: 주어진 벡터와 가장 유사한 벡터를 찾습니다.
- `similarity_search_with_score`: 주어진 벡터와 가장 유사한 벡터를 찾고 벡터 거리를 반환합니다.
- `similarity_search_limit_score`: 주어진 벡터와 가장 유사한 벡터를 찾고 결과 수를 `score_threshold`로 제한합니다.
- `similarity_search_with_relevance_scores`: 주어진 벡터와 가장 유사한 벡터를 찾고 벡터 유사성을 반환합니다.
- `max_marginal_relevance_search`: 주어진 벡터와 가장 유사한 벡터를 찾으면서 다양성을 최적화합니다.

```python
results = vds.similarity_search("foo")
print(results[0].page_content)
```

```output
foo
```


```python
# with scores (distances)
results = vds.similarity_search_with_score("foo", k=5)
for result in results:
    print(f"Content: {result[0].page_content} --- Score: {result[1]}")
```

```output
Content: foo --- Score: 0.0
Content: foo --- Score: 0.0
Content: foo --- Score: 0.0
Content: bar --- Score: 0.1566
Content: bar --- Score: 0.1566
```


```python
# limit the vector distance that can be returned
results = vds.similarity_search_with_score("foo", k=5, distance_threshold=0.1)
for result in results:
    print(f"Content: {result[0].page_content} --- Score: {result[1]}")
```

```output
Content: foo --- Score: 0.0
Content: foo --- Score: 0.0
Content: foo --- Score: 0.0
```


```python
# with scores
results = vds.similarity_search_with_relevance_scores("foo", k=5)
for result in results:
    print(f"Content: {result[0].page_content} --- Similiarity: {result[1]}")
```

```output
Content: foo --- Similiarity: 1.0
Content: foo --- Similiarity: 1.0
Content: foo --- Similiarity: 1.0
Content: bar --- Similiarity: 0.8434
Content: bar --- Similiarity: 0.8434
```


```python
# you can also add new documents as follows
new_document = ["baz"]
new_metadata = [{"user": "sam", "age": 50, "job": "janitor", "credit_score": "high"}]
# both the document and metadata must be lists
vds.add_texts(new_document, new_metadata)
```


```output
['doc:users:b9c71d62a0a34241a37950b448dafd38']
```


## 메모리DB를 검색기로 사용하기

여기에서는 벡터 저장소를 검색기로 사용하는 다양한 옵션을 살펴봅니다.

검색을 수행하기 위해 사용할 수 있는 세 가지 검색 방법이 있습니다. 기본적으로 의미적 유사성을 사용합니다.

```python
query = "foo"
results = vds.similarity_search_with_score(query, k=3, return_metadata=True)

for result in results:
    print("Content:", result[0].page_content, " --- Score: ", result[1])
```

```output
Content: foo  --- Score:  0.0
Content: foo  --- Score:  0.0
Content: foo  --- Score:  0.0
```


```python
retriever = vds.as_retriever(search_type="similarity", search_kwargs={"k": 4})
```


```python
docs = retriever.invoke(query)
docs
```


```output
[Document(page_content='foo', metadata={'id': 'doc:users_modified:988ecca7574048e396756efc0e79aeca', 'user': 'john', 'job': 'engineer', 'credit_score': 'high', 'age': '18'}),
 Document(page_content='foo', metadata={'id': 'doc:users_modified:009b1afeb4084cc6bdef858c7a99b48e', 'user': 'derrick', 'job': 'doctor', 'credit_score': 'low', 'age': '45'}),
 Document(page_content='foo', metadata={'id': 'doc:users_modified:7087cee9be5b4eca93c30fbdd09a2731', 'user': 'nancy', 'job': 'doctor', 'credit_score': 'high', 'age': '94'}),
 Document(page_content='bar', metadata={'id': 'doc:users_modified:01ef6caac12b42c28ad870aefe574253', 'user': 'tyler', 'job': 'engineer', 'credit_score': 'high', 'age': '100'})]
```


또한 사용자가 벡터 거리를 지정할 수 있는 `similarity_distance_threshold` 검색기가 있습니다.

```python
retriever = vds.as_retriever(
    search_type="similarity_distance_threshold",
    search_kwargs={"k": 4, "distance_threshold": 0.1},
)
```


```python
docs = retriever.invoke(query)
docs
```


```output
[Document(page_content='foo', metadata={'id': 'doc:users_modified:988ecca7574048e396756efc0e79aeca', 'user': 'john', 'job': 'engineer', 'credit_score': 'high', 'age': '18'}),
 Document(page_content='foo', metadata={'id': 'doc:users_modified:009b1afeb4084cc6bdef858c7a99b48e', 'user': 'derrick', 'job': 'doctor', 'credit_score': 'low', 'age': '45'}),
 Document(page_content='foo', metadata={'id': 'doc:users_modified:7087cee9be5b4eca93c30fbdd09a2731', 'user': 'nancy', 'job': 'doctor', 'credit_score': 'high', 'age': '94'})]
```


마지막으로, `similarity_score_threshold`는 사용자가 유사한 문서의 최소 점수를 정의할 수 있게 합니다.

```python
retriever = vds.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"score_threshold": 0.9, "k": 10},
)
```


```python
retriever.invoke("foo")
```


```output
[Document(page_content='foo', metadata={'id': 'doc:users_modified:988ecca7574048e396756efc0e79aeca', 'user': 'john', 'job': 'engineer', 'credit_score': 'high', 'age': '18'}),
 Document(page_content='foo', metadata={'id': 'doc:users_modified:009b1afeb4084cc6bdef858c7a99b48e', 'user': 'derrick', 'job': 'doctor', 'credit_score': 'low', 'age': '45'}),
 Document(page_content='foo', metadata={'id': 'doc:users_modified:7087cee9be5b4eca93c30fbdd09a2731', 'user': 'nancy', 'job': 'doctor', 'credit_score': 'high', 'age': '94'})]
```


```python
retriever.invoke("foo")
```


```output
[Document(page_content='foo', metadata={'id': 'doc:users:8f6b673b390647809d510112cde01a27', 'user': 'john', 'job': 'engineer', 'credit_score': 'high', 'age': '18'}),
 Document(page_content='bar', metadata={'id': 'doc:users:93521560735d42328b48c9c6f6418d6a', 'user': 'tyler', 'job': 'engineer', 'credit_score': 'high', 'age': '100'}),
 Document(page_content='foo', metadata={'id': 'doc:users:125ecd39d07845eabf1a699d44134a5b', 'user': 'nancy', 'job': 'doctor', 'credit_score': 'high', 'age': '94'}),
 Document(page_content='foo', metadata={'id': 'doc:users:d6200ab3764c466082fde3eaab972a2a', 'user': 'derrick', 'job': 'doctor', 'credit_score': 'low', 'age': '45'})]
```


## 인덱스 삭제

항목을 삭제하려면 키로 주소를 지정해야 합니다.

```python
# delete the indices too
InMemoryVectorStore.drop_index(
    index_name="users", delete_documents=True, redis_url="redis://localhost:6379"
)
InMemoryVectorStore.drop_index(
    index_name="users_modified",
    delete_documents=True,
    redis_url="redis://localhost:6379",
)
```


```output
True
```


## 관련 자료

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)