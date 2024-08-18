---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/upstash_redis.ipynb
description: UpstashRedisByteStore는 Upstash에서 호스팅되는 Redis 인스턴스에 데이터를 저장하는 ByteStore
  구현입니다.
sidebar_label: Upstash Redis
---

# UpstashRedisByteStore

이 문서는 Upstash redis [키-값 저장소](/docs/concepts/#key-value-stores)를 시작하는 데 도움이 됩니다. `UpstashRedisByteStore`의 모든 기능과 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html)로 이동하세요.

## 개요

`UpstashRedisStore`는 [Upstash](https://upstash.com/)에서 호스팅되는 Redis 인스턴스에 모든 것을 저장하는 `ByteStore`의 구현입니다.

기본 `RedisStore`를 대신 사용하려면 [이 가이드](/docs/integrations/stores/redis/)를 참조하세요.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/stores/upstash_redis_storage) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [UpstashRedisByteStore](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

## 설정

먼저 [Upstash 계정에 가입](https://upstash.com/docs/redis/overall/getstarted)해야 합니다. 다음으로 연결할 Redis 데이터베이스를 생성해야 합니다.

### 자격 증명

데이터베이스를 생성한 후 데이터베이스 URL( `https://`를 잊지 마세요!)과 토큰을 가져옵니다:

```python
from getpass import getpass

URL = getpass("Enter your Upstash URL")
TOKEN = getpass("Enter your Upstash REST token")
```


### 설치

LangChain Upstash 통합은 `langchain_community` 패키지에 있습니다. 또한 `upstash-redis` 패키지를 동등한 종속성으로 설치해야 합니다:

```python
%pip install -qU langchain_community upstash-redis
```


## 인스턴스화

이제 바이트 저장소를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "UpstashRedisByteStore", "source": "langchain_community.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html", "title": "UpstashRedisByteStore"}]-->
from langchain_community.storage import UpstashRedisByteStore
from upstash_redis import Redis

redis_client = Redis(url=URL, token=TOKEN)
kv_store = UpstashRedisByteStore(client=redis_client, ttl=None, namespace="test-ns")
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

`UpstashRedisByteStore`의 모든 기능과 구성에 대한 자세한 문서는 API 참조로 이동하세요: https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)