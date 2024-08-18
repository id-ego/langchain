---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/elasticsearch_retriever.ipynb
description: ElasticsearchRetriever는 Elasticsearch의 다양한 기능에 접근할 수 있는 유연한 래퍼로, 쿼리 DSL을
  통해 사용됩니다.
sidebar_label: Elasticsearch
---

# ElasticsearchRetriever

> [Elasticsearch](https://www.elastic.co/elasticsearch/)는 분산형 RESTful 검색 및 분석 엔진입니다. HTTP 웹 인터페이스와 스키마 없는 JSON 문서를 갖춘 분산형 다중 테넌트 지원 전체 텍스트 검색 엔진을 제공합니다. 키워드 검색, 벡터 검색, 하이브리드 검색 및 복잡한 필터링을 지원합니다.

`ElasticsearchRetriever`는 [Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)을 통해 모든 `Elasticsearch` 기능에 유연하게 접근할 수 있도록 하는 일반적인 래퍼입니다. 대부분의 사용 사례에서는 다른 클래스(`ElasticsearchStore`, `ElasticsearchEmbeddings` 등)가 충분하지만, 그렇지 않은 경우 `ElasticsearchRetriever`를 사용할 수 있습니다.

이 가이드는 Elasticsearch [retriever](/docs/concepts/#retrievers)를 시작하는 데 도움을 줄 것입니다. 모든 `ElasticsearchRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_elasticsearch.retrievers.ElasticsearchRetriever.html)에서 확인하세요.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="document_retrievers" item="ElasticsearchRetriever" />


## 설정

Elasticsearch 인스턴스를 설정하는 두 가지 주요 방법이 있습니다:

- Elastic Cloud: [Elastic Cloud](https://cloud.elastic.co/)는 관리형 Elasticsearch 서비스입니다. [무료 체험](https://www.elastic.co/cloud/cloud-trial-overview)에 가입하세요.
로그인 자격 증명이 필요 없는 Elasticsearch 인스턴스에 연결하려면(보안이 활성화된 도커 인스턴스 시작), Elasticsearch URL과 인덱스 이름을 임베딩 객체와 함께 생성자에 전달하세요.
- 로컬 설치 Elasticsearch: Elasticsearch를 로컬에서 실행하여 시작하세요. 가장 쉬운 방법은 공식 Elasticsearch 도커 이미지를 사용하는 것입니다. 자세한 내용은 [Elasticsearch Docker 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)를 참조하세요.

개별 쿼리에서 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 리트리버는 `langchain-elasticsearch` 패키지에 포함되어 있습니다. 시연 목적으로, 텍스트 [임베딩](/docs/concepts/#embedding-models)을 생성하기 위해 `langchain-community`도 설치할 것입니다.

```python
%pip install -qU langchain-community langchain-elasticsearch
```


```python
<!--IMPORTS:[{"imported": "DeterministicFakeEmbedding", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.DeterministicFakeEmbedding.html", "title": "ElasticsearchRetriever"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "ElasticsearchRetriever"}, {"imported": "Embeddings", "source": "langchain_core.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_core.embeddings.embeddings.Embeddings.html", "title": "ElasticsearchRetriever"}, {"imported": "ElasticsearchRetriever", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_elasticsearch.retrievers.ElasticsearchRetriever.html", "title": "ElasticsearchRetriever"}]-->
from typing import Any, Dict, Iterable

from elasticsearch import Elasticsearch
from elasticsearch.helpers import bulk
from langchain_community.embeddings import DeterministicFakeEmbedding
from langchain_core.documents import Document
from langchain_core.embeddings import Embeddings
from langchain_elasticsearch import ElasticsearchRetriever
```


### 구성

여기서는 Elasticsearch에 대한 연결을 정의합니다. 이 예제에서는 로컬에서 실행 중인 인스턴스를 사용합니다. 또는 [Elastic Cloud](https://cloud.elastic.co/)에 계정을 만들고 [무료 체험](https://www.elastic.co/cloud/cloud-trial-overview)을 시작할 수 있습니다.

```python
es_url = "http://localhost:9200"
es_client = Elasticsearch(hosts=[es_url])
es_client.info()
```


벡터 검색을 위해, 예시를 위해 랜덤 임베딩을 사용할 것입니다. 실제 사용 사례에서는 사용 가능한 LangChain [임베딩](/docs/integrations/text_embedding) 클래스 중 하나를 선택하세요.

```python
embeddings = DeterministicFakeEmbedding(size=3)
```


#### 예제 데이터 정의

```python
index_name = "test-langchain-retriever"
text_field = "text"
dense_vector_field = "fake_embedding"
num_characters_field = "num_characters"
texts = [
    "foo",
    "bar",
    "world",
    "hello world",
    "hello",
    "foo bar",
    "bla bla foo",
]
```


#### 데이터 인덱스

일반적으로 사용자는 이미 Elasticsearch 인덱스에 데이터가 있을 때 `ElasticsearchRetriever`를 사용합니다. 여기서는 몇 가지 예제 텍스트 문서를 인덱스합니다. `ElasticsearchStore.from_documents`를 사용하여 인덱스를 생성한 경우에도 괜찮습니다.

```python
def create_index(
    es_client: Elasticsearch,
    index_name: str,
    text_field: str,
    dense_vector_field: str,
    num_characters_field: str,
):
    es_client.indices.create(
        index=index_name,
        mappings={
            "properties": {
                text_field: {"type": "text"},
                dense_vector_field: {"type": "dense_vector"},
                num_characters_field: {"type": "integer"},
            }
        },
    )


def index_data(
    es_client: Elasticsearch,
    index_name: str,
    text_field: str,
    dense_vector_field: str,
    embeddings: Embeddings,
    texts: Iterable[str],
    refresh: bool = True,
) -> None:
    create_index(
        es_client, index_name, text_field, dense_vector_field, num_characters_field
    )

    vectors = embeddings.embed_documents(list(texts))
    requests = [
        {
            "_op_type": "index",
            "_index": index_name,
            "_id": i,
            text_field: text,
            dense_vector_field: vector,
            num_characters_field: len(text),
        }
        for i, (text, vector) in enumerate(zip(texts, vectors))
    ]

    bulk(es_client, requests)

    if refresh:
        es_client.indices.refresh(index=index_name)

    return len(requests)
```


```python
index_data(es_client, index_name, text_field, dense_vector_field, embeddings, texts)
```


```output
7
```


## 인스턴스화

### 벡터 검색

이 예제에서는 가짜 임베딩을 사용하여 밀집 벡터 검색을 수행합니다.

```python
def vector_query(search_query: str) -> Dict:
    vector = embeddings.embed_query(search_query)  # same embeddings as for indexing
    return {
        "knn": {
            "field": dense_vector_field,
            "query_vector": vector,
            "k": 5,
            "num_candidates": 10,
        }
    }


vector_retriever = ElasticsearchRetriever.from_es_params(
    index_name=index_name,
    body_func=vector_query,
    content_field=text_field,
    url=es_url,
)

vector_retriever.invoke("foo")
```


```output
[Document(page_content='foo', metadata={'_index': 'test-langchain-index', '_id': '0', '_score': 1.0, '_source': {'fake_embedding': [-2.336764233933763, 0.27510289545940503, -0.7957597268194339], 'num_characters': 3}}),
 Document(page_content='world', metadata={'_index': 'test-langchain-index', '_id': '2', '_score': 0.6770179, '_source': {'fake_embedding': [-0.7041151202179595, -1.4652961969276497, -0.25786766898672847], 'num_characters': 5}}),
 Document(page_content='hello world', metadata={'_index': 'test-langchain-index', '_id': '3', '_score': 0.4816144, '_source': {'fake_embedding': [0.42728413221815387, -1.1889908285425348, -1.445433230084671], 'num_characters': 11}}),
 Document(page_content='hello', metadata={'_index': 'test-langchain-index', '_id': '4', '_score': 0.46853775, '_source': {'fake_embedding': [-0.28560441330564046, 0.9958894823084921, 1.5489829880195058], 'num_characters': 5}}),
 Document(page_content='foo bar', metadata={'_index': 'test-langchain-index', '_id': '5', '_score': 0.2086992, '_source': {'fake_embedding': [0.2533670476638539, 0.08100381646160418, 0.7763644080870179], 'num_characters': 7}})]
```


### BM25

전통적인 키워드 매칭입니다.

```python
def bm25_query(search_query: str) -> Dict:
    return {
        "query": {
            "match": {
                text_field: search_query,
            },
        },
    }


bm25_retriever = ElasticsearchRetriever.from_es_params(
    index_name=index_name,
    body_func=bm25_query,
    content_field=text_field,
    url=es_url,
)

bm25_retriever.invoke("foo")
```


```output
[Document(page_content='foo', metadata={'_index': 'test-langchain-index', '_id': '0', '_score': 0.9711467, '_source': {'fake_embedding': [-2.336764233933763, 0.27510289545940503, -0.7957597268194339], 'num_characters': 3}}),
 Document(page_content='foo bar', metadata={'_index': 'test-langchain-index', '_id': '5', '_score': 0.7437035, '_source': {'fake_embedding': [0.2533670476638539, 0.08100381646160418, 0.7763644080870179], 'num_characters': 7}}),
 Document(page_content='bla bla foo', metadata={'_index': 'test-langchain-index', '_id': '6', '_score': 0.6025789, '_source': {'fake_embedding': [1.7365927060137358, -0.5230400847844948, 0.7978339724186192], 'num_characters': 11}})]
```


### 하이브리드 검색

[Reciprocal Rank Fusion](https://www.elastic.co/guide/en/elasticsearch/reference/current/rrf.html) (RRF)를 사용하여 벡터 검색과 BM25 검색의 결과 집합을 결합합니다.

```python
def hybrid_query(search_query: str) -> Dict:
    vector = embeddings.embed_query(search_query)  # same embeddings as for indexing
    return {
        "query": {
            "match": {
                text_field: search_query,
            },
        },
        "knn": {
            "field": dense_vector_field,
            "query_vector": vector,
            "k": 5,
            "num_candidates": 10,
        },
        "rank": {"rrf": {}},
    }


hybrid_retriever = ElasticsearchRetriever.from_es_params(
    index_name=index_name,
    body_func=hybrid_query,
    content_field=text_field,
    url=es_url,
)

hybrid_retriever.invoke("foo")
```


```output
[Document(page_content='foo', metadata={'_index': 'test-langchain-index', '_id': '0', '_score': 0.9711467, '_source': {'fake_embedding': [-2.336764233933763, 0.27510289545940503, -0.7957597268194339], 'num_characters': 3}}),
 Document(page_content='foo bar', metadata={'_index': 'test-langchain-index', '_id': '5', '_score': 0.7437035, '_source': {'fake_embedding': [0.2533670476638539, 0.08100381646160418, 0.7763644080870179], 'num_characters': 7}}),
 Document(page_content='bla bla foo', metadata={'_index': 'test-langchain-index', '_id': '6', '_score': 0.6025789, '_source': {'fake_embedding': [1.7365927060137358, -0.5230400847844948, 0.7978339724186192], 'num_characters': 11}})]
```


### 퍼지 매칭

오타 허용을 포함한 키워드 매칭입니다.

```python
def fuzzy_query(search_query: str) -> Dict:
    return {
        "query": {
            "match": {
                text_field: {
                    "query": search_query,
                    "fuzziness": "AUTO",
                }
            },
        },
    }


fuzzy_retriever = ElasticsearchRetriever.from_es_params(
    index_name=index_name,
    body_func=fuzzy_query,
    content_field=text_field,
    url=es_url,
)

fuzzy_retriever.invoke("fox")  # note the character tolernace
```


```output
[Document(page_content='foo', metadata={'_index': 'test-langchain-index', '_id': '0', '_score': 0.6474311, '_source': {'fake_embedding': [-2.336764233933763, 0.27510289545940503, -0.7957597268194339], 'num_characters': 3}}),
 Document(page_content='foo bar', metadata={'_index': 'test-langchain-index', '_id': '5', '_score': 0.49580228, '_source': {'fake_embedding': [0.2533670476638539, 0.08100381646160418, 0.7763644080870179], 'num_characters': 7}}),
 Document(page_content='bla bla foo', metadata={'_index': 'test-langchain-index', '_id': '6', '_score': 0.40171927, '_source': {'fake_embedding': [1.7365927060137358, -0.5230400847844948, 0.7978339724186192], 'num_characters': 11}})]
```


### 복잡한 필터링

다양한 필드에 대한 필터 조합입니다.

```python
def filter_query_func(search_query: str) -> Dict:
    return {
        "query": {
            "bool": {
                "must": [
                    {"range": {num_characters_field: {"gte": 5}}},
                ],
                "must_not": [
                    {"prefix": {text_field: "bla"}},
                ],
                "should": [
                    {"match": {text_field: search_query}},
                ],
            }
        }
    }


filtering_retriever = ElasticsearchRetriever.from_es_params(
    index_name=index_name,
    body_func=filter_query_func,
    content_field=text_field,
    url=es_url,
)

filtering_retriever.invoke("foo")
```


```output
[Document(page_content='foo bar', metadata={'_index': 'test-langchain-index', '_id': '5', '_score': 1.7437035, '_source': {'fake_embedding': [0.2533670476638539, 0.08100381646160418, 0.7763644080870179], 'num_characters': 7}}),
 Document(page_content='world', metadata={'_index': 'test-langchain-index', '_id': '2', '_score': 1.0, '_source': {'fake_embedding': [-0.7041151202179595, -1.4652961969276497, -0.25786766898672847], 'num_characters': 5}}),
 Document(page_content='hello world', metadata={'_index': 'test-langchain-index', '_id': '3', '_score': 1.0, '_source': {'fake_embedding': [0.42728413221815387, -1.1889908285425348, -1.445433230084671], 'num_characters': 11}}),
 Document(page_content='hello', metadata={'_index': 'test-langchain-index', '_id': '4', '_score': 1.0, '_source': {'fake_embedding': [-0.28560441330564046, 0.9958894823084921, 1.5489829880195058], 'num_characters': 5}})]
```


쿼리 매치는 최상단에 있습니다. 필터를 통과한 다른 문서들도 결과 집합에 포함되지만, 모두 동일한 점수를 가집니다.

### 사용자 정의 문서 매퍼

Elasticsearch 결과(히트)를 LangChain 문서로 매핑하는 기능을 사용자 정의할 수 있습니다.

```python
def num_characters_mapper(hit: Dict[str, Any]) -> Document:
    num_chars = hit["_source"][num_characters_field]
    content = hit["_source"][text_field]
    return Document(
        page_content=f"This document has {num_chars} characters",
        metadata={"text_content": content},
    )


custom_mapped_retriever = ElasticsearchRetriever.from_es_params(
    index_name=index_name,
    body_func=filter_query_func,
    document_mapper=num_characters_mapper,
    url=es_url,
)

custom_mapped_retriever.invoke("foo")
```


```output
[Document(page_content='This document has 7 characters', metadata={'text_content': 'foo bar'}),
 Document(page_content='This document has 5 characters', metadata={'text_content': 'world'}),
 Document(page_content='This document has 11 characters', metadata={'text_content': 'hello world'}),
 Document(page_content='This document has 5 characters', metadata={'text_content': 'hello'})]
```


## 사용법

위의 예제를 따라 `.invoke`를 사용하여 단일 쿼리를 발행합니다. 리트리버는 Runnables이므로, `.batch`와 같은 [Runnable 인터페이스](/docs/concepts/#runnable-interface)의 모든 메서드를 사용할 수 있습니다.

## 체인 내에서 사용

리트리버를 [체인](/docs/how_to/sequence/)에 통합하여 간단한 [RAG](/docs/tutorials/rag/) 애플리케이션과 같은 더 큰 애플리케이션을 구축할 수 있습니다. 시연 목적으로 OpenAI 채팅 모델도 인스턴스화합니다.

```python
%pip install -qU langchain-openai
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "ElasticsearchRetriever"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ElasticsearchRetriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "ElasticsearchRetriever"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "ElasticsearchRetriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_template(
    """Answer the question based only on the context provided.

Context: {context}

Question: {question}"""
)

llm = ChatOpenAI(model="gpt-3.5-turbo-0125")


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


chain = (
    {"context": vector_retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```


```python
chain.invoke("what is foo?")
```


## API 참조

모든 `ElasticsearchRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_elasticsearch.retrievers.ElasticsearchRetriever.html)에서 확인하세요.

## 관련

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)