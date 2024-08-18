---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/astradb.ipynb
description: Astra DB의 키-값 저장소를 시작하는 방법과 AstraDBByteStore의 기능 및 구성에 대한 자세한 정보를 제공합니다.
sidebar_label: AstraDB
---

# AstraDBByteStore

이 문서는 Astra DB [키-값 저장소](/docs/concepts/#key-value-stores)를 시작하는 데 도움이 됩니다. 모든 `AstraDBByteStore` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/storage/langchain_astradb.storage.AstraDBByteStore.html)로 이동하세요.

## 개요

DataStax [Astra DB](https://docs.datastax.com/en/astra/home/astra.html)는 Cassandra를 기반으로 한 서버리스 벡터 지원 데이터베이스로, 사용하기 쉬운 JSON API를 통해 편리하게 제공됩니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [AstraDBByteStore](https://api.python.langchain.com/en/latest/storage/langchain_astradb.storage.AstraDBByteStore.html) | [langchain_astradb](https://api.python.langchain.com/en/latest/astradb_api_reference.html) | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_astradb?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_astradb?style=flat-square&label=%20) |

## 설정

`AstraDBByteStore` 바이트 저장소를 생성하려면 [DataStax 계정 생성](https://www.datastax.com/products/datastax-astra)이 필요합니다.

### 자격 증명

가입 후 다음 자격 증명을 설정하세요:

```python
from getpass import getpass

ASTRA_DB_API_ENDPOINT = getpass("ASTRA_DB_API_ENDPOINT = ")
ASTRA_DB_APPLICATION_TOKEN = getpass("ASTRA_DB_APPLICATION_TOKEN = ")
```


### 설치

LangChain AstraDB 통합은 `langchain_astradb` 패키지에 있습니다:

```python
%pip install -qU langchain_astradb
```


## 인스턴스화

이제 바이트 저장소를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AstraDBByteStore", "source": "langchain_astradb", "docs": "https://api.python.langchain.com/en/latest/storage/langchain_astradb.storage.AstraDBByteStore.html", "title": "AstraDBByteStore"}]-->
from langchain_astradb import AstraDBByteStore

kv_store = AstraDBByteStore(
    api_endpoint=ASTRA_DB_API_ENDPOINT,
    token=ASTRA_DB_APPLICATION_TOKEN,
    collection_name="my_store",
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


`AstraDBByteStore`는 다른 ByteStores를 사용할 수 있는 곳 어디에서나 사용할 수 있으며, [임베딩 캐시](/docs/how_to/caching_embeddings)로도 사용할 수 있습니다.

## API 참조

모든 `AstraDBByteStore` 기능 및 구성에 대한 자세한 문서는 API 참조로 이동하세요: https://api.python.langchain.com/en/latest/storage/langchain_astradb.storage.AstraDBByteStore.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)