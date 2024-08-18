---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/elasticsearch.ipynb
description: Elasticsearch는 분산형 RESTful 검색 및 분석 엔진으로, 벡터 및 어휘 검색 기능을 제공합니다. Apache
  Lucene 라이브러리를 기반으로 합니다.
---

# Elasticsearch

> [Elasticsearch](https://www.elastic.co/elasticsearch/)는 분산형 RESTful 검색 및 분석 엔진으로, 벡터 및 어휘 검색을 모두 수행할 수 있습니다. Apache Lucene 라이브러리 위에 구축되었습니다.

이 노트북은 `Elasticsearch` 벡터 저장소와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

`Elasticsearch` 벡터 검색을 사용하려면 `langchain-elasticsearch` 패키지를 설치해야 합니다.

```python
%pip install -qU langchain-elasticsearch
```


### 자격 증명

Elasticsearch 인스턴스를 설정하는 주요 방법은 두 가지입니다:

1. Elastic Cloud: Elastic Cloud는 관리형 Elasticsearch 서비스입니다. [무료 체험](https://cloud.elastic.co/registration?utm_source=langchain&utm_content=documentation)에 가입하세요.

로그인 자격 증명이 필요하지 않은 Elasticsearch 인스턴스에 연결하려면(보안이 활성화된 도커 인스턴스 시작), Elasticsearch URL과 인덱스 이름을 임베딩 객체와 함께 생성자에 전달하세요.

2. 로컬 설치 Elasticsearch: Elasticsearch를 로컬에서 실행하여 시작하세요. 가장 쉬운 방법은 공식 Elasticsearch 도커 이미지를 사용하는 것입니다. 자세한 내용은 [Elasticsearch 도커 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)를 참조하세요.

### 도커를 통한 Elasticsearch 실행
예: 보안이 비활성화된 단일 노드 Elasticsearch 인스턴스를 실행합니다. 이는 프로덕션 사용에는 권장되지 않습니다.

```python
%docker run -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" -e "xpack.security.http.ssl.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.12.1
```


### 인증으로 실행
프로덕션에서는 보안을 활성화하여 실행하는 것을 권장합니다. 로그인 자격 증명으로 연결하려면 `es_api_key` 또는 `es_user` 및 `es_password` 매개변수를 사용할 수 있습니다.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}]-->
from langchain_elasticsearch import ElasticsearchStore

elastic_vector_search = ElasticsearchStore(
    es_url="http://localhost:9200",
    index_name="langchain_index",
    embedding=embeddings,
    es_user="elastic",
    es_password="changeme",
)
```


#### 기본 "elastic" 사용자에 대한 비밀번호를 얻는 방법은?

기본 "elastic" 사용자에 대한 Elastic Cloud 비밀번호를 얻으려면:
1. https://cloud.elastic.co에서 Elastic Cloud 콘솔에 로그인합니다.
2. "보안" > "사용자"로 이동합니다.
3. "elastic" 사용자를 찾아 "편집"을 클릭합니다.
4. "비밀번호 재설정"을 클릭합니다.
5. 비밀번호 재설정 안내에 따라 진행합니다.

#### API 키를 얻는 방법은?

API 키를 얻으려면:
1. https://cloud.elastic.co에서 Elastic Cloud 콘솔에 로그인합니다.
2. Kibana를 열고 스택 관리 > API 키로 이동합니다.
3. "API 키 생성"을 클릭합니다.
4. API 키의 이름을 입력하고 "생성"을 클릭합니다.
5. API 키를 복사하여 `api_key` 매개변수에 붙여넣습니다.

### Elastic Cloud

Elastic Cloud의 Elasticsearch 인스턴스에 연결하려면 `es_cloud_id` 매개변수 또는 `es_url`을 사용할 수 있습니다.

```python
elastic_vector_search = ElasticsearchStore(
    es_cloud_id="<cloud_id>",
    index_name="test_index",
    embedding=embeddings,
    es_user="elastic",
    es_password="changeme",
)
```


모델 호출에 대한 최상의 자동 추적을 원하면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

Elasticsearch는 [도커](#running-elasticsearch-via-docker)에서 localhost:9200에서 로컬로 실행되고 있습니다. Elastic Cloud에서 Elasticsearch에 연결하는 방법에 대한 자세한 내용은 위의 [인증으로 연결](#running-with-authentication)을 참조하세요.

```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}]-->
from langchain_elasticsearch import ElasticsearchStore

vector_store = ElasticsearchStore(
    "langchain-demo", embedding=embeddings, es_url="http://localhost:9201"
)
```


## 벡터 저장소 관리

### 벡터 저장소에 항목 추가

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Elasticsearch"}]-->
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
['21cca03c-9089-42d2-b41c-3d156be2b519',
 'a6ceb967-b552-4802-bb06-c0e95fce386e',
 '3a35fac4-e5f0-493b-bee0-9143b41aedae',
 '176da099-66b1-4d6a-811b-dfdfe0808d30',
 'ecfa1a30-3c97-408b-80c0-5c43d68bf5ff',
 'c0f08baa-e70b-4f83-b387-c6e0a0f36f73',
 '489b2c9c-1925-43e1-bcf0-0fa94cf1cbc4',
 '408c6503-9ba4-49fd-b1cc-95584cd914c5',
 '5248c899-16d5-4377-a9e9-736ca443ad4f',
 'ca182769-c4fc-4e25-8f0a-8dd0a525955c']
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=[uuids[-1]])
```


```output
True
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다. 이러한 예제는 검색 시 필터링을 사용하는 방법도 보여줍니다.

### 직접 쿼리

#### 유사성 검색

메타데이터에 대한 필터링을 포함한 간단한 유사성 검색은 다음과 같이 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    query="LangChain provides abstractions to make working with LLMs easy",
    k=2,
    filter=[{"term": {"metadata.source.keyword": "tweet"}}],
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

```output
* Building an exciting new project with LangChain - come check it out! [{'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'source': 'tweet'}]
```

#### 점수가 있는 유사성 검색

유사성 검색을 실행하고 해당 점수를 받으려면 다음을 실행할 수 있습니다:

```python
results = vector_store.similarity_search_with_score(
    query="Will it be hot tomorrow",
    k=1,
    filter=[{"term": {"metadata.source.keyword": "news"}}],
)
for doc, score in results:
    print(f"* [SIM={score:3f}] {doc.page_content} [{doc.metadata}]")
```

```output
* [SIM=0.765887] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news'}]
```

### 검색기로 변환하여 쿼리

벡터 저장소를 체인에서 더 쉽게 사용할 수 있도록 검색기로 변환할 수도 있습니다.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold", search_kwargs={"score_threshold": 0.2}
)
retriever.invoke("Stealing from the bank is a crime")
```


```output
[Document(metadata={'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.'),
 Document(metadata={'source': 'news'}, page_content='The stock market is down 500 points today due to fears of a recession.'),
 Document(metadata={'source': 'website'}, page_content='Is the new iPhone worth the price? Read this review to find out.'),
 Document(metadata={'source': 'tweet'}, page_content='Building an exciting new project with LangChain - come check it out!')]
```


## 검색 보강 생성 사용

검색 보강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

# FAQ

## 질문: 문서를 Elasticsearch에 인덱싱할 때 타임아웃 오류가 발생합니다. 어떻게 해결하나요?
한 가지 가능한 문제는 문서가 Elasticsearch에 인덱싱되는 데 시간이 더 걸릴 수 있다는 것입니다. ElasticsearchStore는 타임아웃 오류 가능성을 줄이기 위해 조정할 수 있는 몇 가지 기본값을 가진 Elasticsearch 벌크 API를 사용합니다.

SparseVectorRetrievalStrategy를 사용할 때도 좋은 아이디어입니다.

기본값은 다음과 같습니다:
- `chunk_size`: 500
- `max_chunk_bytes`: 100MB

이 값을 조정하려면 ElasticsearchStore `add_texts` 메서드에 `chunk_size` 및 `max_chunk_bytes` 매개변수를 전달할 수 있습니다.

```python
    vector_store.add_texts(
        texts,
        bulk_kwargs={
            "chunk_size": 50,
            "max_chunk_bytes": 200000000
        }
    )
```


# ElasticsearchStore로 업그레이드

이미 langchain 기반 프로젝트에서 Elasticsearch를 사용하고 있다면, 이제 더 이상 사용되지 않는 이전 구현인 `ElasticVectorSearch` 및 `ElasticKNNSearch`를 사용하고 있을 수 있습니다. 우리는 더 유연하고 사용하기 쉬운 새로운 구현인 `ElasticsearchStore`를 도입했습니다. 이 노트북은 새로운 구현으로 업그레이드하는 과정을 안내합니다.

## 새로운 점은 무엇인가요?

새로운 구현은 이제 `ElasticsearchStore`라는 하나의 클래스로, 근사 밀집 벡터, 정확한 밀집 벡터, 희소 벡터(ELSER), BM25 검색 및 하이브리드 검색을 전략을 통해 사용할 수 있습니다.

## ElasticKNNSearch를 사용하고 있습니다

이전 구현:

```python

from langchain_community.vectorstores.elastic_vector_search import ElasticKNNSearch

db = ElasticKNNSearch(
  elasticsearch_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding
)

```


새로운 구현:

```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}, {"imported": "DenseVectorStrategy", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/helpers/elasticsearch.helpers.vectorstore._sync.strategies.DenseVectorStrategy.html", "title": "Elasticsearch"}]-->

from langchain_elasticsearch import ElasticsearchStore, DenseVectorStrategy

db = ElasticsearchStore(
  es_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding,
  # if you use the model_id
  # strategy=DenseVectorStrategy(model_id="test_model")
  # if you use hybrid search
  # strategy=DenseVectorStrategy(hybrid=True)
)

```


## ElasticVectorSearch를 사용하고 있습니다

이전 구현:

```python
<!--IMPORTS:[{"imported": "ElasticVectorSearch", "source": "langchain_community.vectorstores.elastic_vector_search", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.elastic_vector_search.ElasticVectorSearch.html", "title": "Elasticsearch"}]-->

from langchain_community.vectorstores.elastic_vector_search import ElasticVectorSearch

db = ElasticVectorSearch(
  elasticsearch_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding
)

```


새로운 구현:

```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}, {"imported": "DenseVectorScriptScoreStrategy", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/helpers/elasticsearch.helpers.vectorstore._sync.strategies.DenseVectorScriptScoreStrategy.html", "title": "Elasticsearch"}]-->

from langchain_elasticsearch import ElasticsearchStore, DenseVectorScriptScoreStrategy

db = ElasticsearchStore(
  es_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding,
  strategy=DenseVectorScriptScoreStrategy()
)

```


```python
db.client.indices.delete(
    index="test-metadata, test-elser, test-basic",
    ignore_unavailable=True,
    allow_no_indices=True,
)
```


## API 참조

모든 `ElasticSearchStore` 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)