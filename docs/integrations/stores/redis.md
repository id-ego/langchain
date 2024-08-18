---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/redis.ipynb
description: RedisStore는 Redis 인스턴스에 모든 데이터를 저장하는 ByteStore 구현체로, 간편한 키-값 저장소를 제공합니다.
sidebar_label: Redis
---

# RedisStore

이 문서는 Redis [키-값 저장소](/docs/concepts/#key-value-stores)를 시작하는 데 도움이 됩니다. 모든 `RedisStore` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.redis.RedisStore.html)에서 확인하세요.

## 개요

`RedisStore`는 모든 것을 Redis 인스턴스에 저장하는 `ByteStore`의 구현입니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/stores/ioredis_storage) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [RedisStore](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.redis.RedisStore.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

## 설정

Redis 바이트 저장소를 생성하려면 Redis 인스턴스를 설정해야 합니다. 로컬에서 또는 제공자를 통해 설정할 수 있습니다. 옵션에 대한 개요는 [Redis 가이드](/docs/integrations/providers/redis)를 참조하세요.

### 설치

LangChain `RedisStore` 통합은 `langchain_community` 패키지에 있습니다:

```python
%pip install -qU langchain_community redis
```


## 인스턴스화

이제 바이트 저장소를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "RedisStore", "source": "langchain_community.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain_community.storage.redis.RedisStore.html", "title": "RedisStore"}]-->
from langchain_community.storage import RedisStore

kv_store = RedisStore(redis_url="redis://localhost:6379")
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


## API 참조

모든 `RedisStore` 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/storage/langchain_community.storage.redis.RedisStore.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)