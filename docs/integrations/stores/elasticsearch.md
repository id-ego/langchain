---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/elasticsearch.ipynb
description: ElasticsearchEmbeddingsCache는 Elasticsearch 인스턴스를 활용하여 임베딩의 효율적인 저장 및
  검색을 지원하는 ByteStore 구현입니다.
sidebar_label: Elasticsearch
---

# ElasticsearchEmbeddingsCache

이 문서는 Elasticsearch [키-값 저장소](/docs/concepts/#key-value-stores)를 시작하는 데 도움이 됩니다. `ElasticsearchEmbeddingsCache`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchEmbeddingsCache.html)에서 확인할 수 있습니다.

## 개요

`ElasticsearchEmbeddingsCache`는 Elasticsearch 인스턴스를 사용하여 임베딩의 효율적인 저장 및 검색을 위한 `ByteStore` 구현입니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [ElasticsearchEmbeddingsCache](https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchEmbeddingsCache.html) | [langchain_elasticsearch](https://api.python.langchain.com/en/latest/elasticsearch_api_reference.html) | ✅ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_elasticsearch?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_elasticsearch?style=flat-square&label=%20) |

## 설정

`ElasticsearchEmbeddingsCache` 바이트 저장소를 생성하려면 Elasticsearch 클러스터가 필요합니다. [로컬로 설정](https://www.elastic.co/downloads/elasticsearch)하거나 [Elastic 계정](https://www.elastic.co/elasticsearch)을 생성할 수 있습니다.

### 설치

LangChain `ElasticsearchEmbeddingsCache` 통합은 `__package_name__` 패키지에 있습니다:

```python
%pip install -qU langchain_elasticsearch
```


## 인스턴스화

이제 바이트 저장소를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ElasticsearchEmbeddingsCache", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchEmbeddingsCache.html", "title": "ElasticsearchEmbeddingsCache"}]-->
from langchain_elasticsearch import ElasticsearchEmbeddingsCache

# Example config for a locally running Elasticsearch instance
kv_store = ElasticsearchEmbeddingsCache(
    es_url="https://localhost:9200",
    index_name="llm-chat-cache",
    metadata={"project": "my_chatgpt_project"},
    namespace="my_chatgpt_project",
    es_user="elastic",
    es_password="<GENERATED PASSWORD>",
    es_params={
        "ca_certs": "~/http_ca.crt",
    },
)
```


## 사용법

다음과 같이 `mset` 메서드를 사용하여 키 아래에 데이터를 설정할 수 있습니다:

```python
kv_store.mset(
    [
        ["key1", b"value1"],
        ["key2", b"value2"],
    ]
)

kv_store.mget(
    [
        "key1",
        "key2",
    ]
)
```


```output
[b'value1', b'value2']
```


그리고 `mdelete` 메서드를 사용하여 데이터를 삭제할 수 있습니다:

```python
kv_store.mdelete(
    [
        "key1",
        "key2",
    ]
)

kv_store.mget(
    [
        "key1",
        "key2",
    ]
)
```


```output
[None, None]
```


## 임베딩 캐시로 사용

다른 `ByteStores`와 마찬가지로, `ElasticsearchEmbeddingsCache` 인스턴스를 RAG를 위한 [문서 수집에서의 지속적인 캐싱](/docs/how_to/caching_embeddings/)에 사용할 수 있습니다.

그러나 기본적으로 캐시된 벡터는 검색할 수 없습니다. 개발자는 인덱스된 벡터 필드를 추가하기 위해 Elasticsearch 문서의 빌드를 사용자 정의할 수 있습니다.

이는 서브클래싱하고 메서드를 재정의하여 수행할 수 있습니다:

```python
from typing import Any, Dict, List


class SearchableElasticsearchStore(ElasticsearchEmbeddingsCache):
    @property
    def mapping(self) -> Dict[str, Any]:
        mapping = super().mapping
        mapping["mappings"]["properties"]["vector"] = {
            "type": "dense_vector",
            "dims": 1536,
            "index": True,
            "similarity": "dot_product",
        }
        return mapping

    def build_document(self, llm_input: str, vector: List[float]) -> Dict[str, Any]:
        body = super().build_document(llm_input, vector)
        body["vector"] = vector
        return body
```


매핑 및 문서 빌드를 재정의할 때는 기본 매핑을 그대로 유지하면서 추가적인 수정만 하십시오.

## API 참조

`ElasticsearchEmbeddingsCache`의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchEmbeddingsCache.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)