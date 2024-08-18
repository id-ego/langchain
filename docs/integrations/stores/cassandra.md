---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/cassandra.ipynb
description: CassandraByteStore는 Cassandra를 기반으로 한 키-값 저장소로, 고성능 및 확장성을 제공합니다. 자세한
  내용은 API 참조를 확인하세요.
sidebar_label: Cassandra
---

# CassandraByteStore

이 문서는 Cassandra [키-값 저장소](/docs/concepts/#key-value-stores) 사용을 시작하는 데 도움이 됩니다. 모든 `CassandraByteStore` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html)로 이동하세요.

## 개요

[Cassandra](https://cassandra.apache.org/)는 NoSQL, 행 지향, 고도로 확장 가능하고 고가용성 데이터베이스입니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/stores/cassandra_storage) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [CassandraByteStore](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

## 설정

`CassandraByteStore`는 Cassandra 인스턴스에 데이터를 저장하는 `ByteStore`의 구현입니다. 저장소 키는 문자열이어야 하며 Cassandra 테이블의 `row_id` 열에 매핑됩니다. 저장소 `bytes` 값은 Cassandra 테이블의 `body_blob` 열에 매핑됩니다.

### 설치

LangChain `CassandraByteStore` 통합은 `langchain_community` 패키지에 있습니다. 사용 중인 초기화 방법에 따라 `cassio` 패키지 또는 `cassandra-driver` 패키지를 동반 종속성으로 설치해야 합니다:

```python
%pip install -qU langchain_community
%pip install -qU cassandra-driver
%pip install -qU cassio
```


또한 [Cassandra 드라이버 문서](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster)에서 설명한 대로 `cassandra.cluster.Session` 객체를 생성해야 합니다. 세부 사항은 네트워크 설정 및 인증에 따라 다르지만, 다음과 같을 수 있습니다:

## 인스턴스화

먼저 [Cassandra 드라이버 문서](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster)에서 설명한 대로 `cassandra.cluster.Session` 객체를 생성해야 합니다. 세부 사항은 네트워크 설정 및 인증에 따라 다르지만, 다음과 같을 수 있습니다:

```python
from cassandra.cluster import Cluster

cluster = Cluster()
session = cluster.connect()
```


그런 다음 저장소를 생성할 수 있습니다! Cassandra 인스턴스의 기존 키스페이스 이름도 제공해야 합니다:

```python
<!--IMPORTS:[{"imported": "CassandraByteStore", "source": "langchain_community.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html", "title": "CassandraByteStore"}]-->
from langchain_community.storage import CassandraByteStore

kv_store = CassandraByteStore(
    table="my_store",
    session=session,
    keyspace="<YOUR KEYSPACE>",
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


## `cassio`를 사용한 초기화

세션과 키스페이스를 구성하기 위해 cassio를 사용할 수도 있습니다.

```python
import cassio

cassio.init(contact_points="127.0.0.1", keyspace="<YOUR KEYSPACE>")

store = CassandraByteStore(
    table="my_store",
)

store.mset([("k1", b"v1"), ("k2", b"v2")])
print(store.mget(["k1", "k2"]))
```


## API 참조

모든 `CassandraByteStore` 기능 및 구성에 대한 자세한 문서는 API 참조로 이동하세요: https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)