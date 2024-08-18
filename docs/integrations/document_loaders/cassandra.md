---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/cassandra.ipynb
description: Cassandra는 NoSQL, 행 지향의 고도로 확장 가능하고 가용성이 높은 데이터베이스로, 5.0 버전부터 벡터 검색 기능을
  지원합니다.
---

# 카산드라

[Cassandra](https://cassandra.apache.org/)는 NoSQL, 행 지향, 고도로 확장 가능하고 고가용성 데이터베이스입니다. 5.0 버전부터 데이터베이스는 [벡터 검색 기능](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html)을 제공합니다.

## 개요

Cassandra 문서 로더는 Cassandra 데이터베이스에서 Langchain 문서 목록을 반환합니다.

문서를 검색하려면 CQL 쿼리 또는 테이블 이름을 제공해야 합니다.
로더는 다음 매개변수를 사용합니다:

* table: (선택 사항) 데이터를 로드할 테이블.
* session: (선택 사항) 카산드라 드라이버 세션. 제공되지 않으면 cassio에서 해결된 세션이 사용됩니다.
* keyspace: (선택 사항) 테이블의 키스페이스. 제공되지 않으면 cassio에서 해결된 키스페이스가 사용됩니다.
* query: (선택 사항) 데이터를 로드하는 데 사용되는 쿼리.
* page_content_mapper: (선택 사항) 행을 문자열 페이지 콘텐츠로 변환하는 함수. 기본값은 행을 JSON으로 변환합니다.
* metadata_mapper: (선택 사항) 행을 메타데이터 딕셔너리로 변환하는 함수.
* query_parameters: (선택 사항) session.execute를 호출할 때 사용되는 쿼리 매개변수.
* query_timeout: (선택 사항) session.execute를 호출할 때 사용되는 쿼리 타임아웃.
* query_custom_payload: (선택 사항) `session.execute`를 호출할 때 사용되는 쿼리 custom_payload.
* query_execution_profile: (선택 사항) session.execute를 호출할 때 사용되는 쿼리 execution_profile.
* query_host: (선택 사항) session.execute를 호출할 때 사용되는 쿼리 호스트.
* query_execute_as: (선택 사항) session.execute를 호출할 때 사용되는 쿼리 execute_as.

## 문서 로더로 문서 로드하기

```python
<!--IMPORTS:[{"imported": "CassandraLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.cassandra.CassandraLoader.html", "title": "Cassandra"}]-->
from langchain_community.document_loaders import CassandraLoader
```


### 카산드라 드라이버 세션에서 초기화

[Cassandra 드라이버 문서](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster)에서 설명한 대로 `cassandra.cluster.Session` 객체를 생성해야 합니다. 세부 사항은 네트워크 설정 및 인증 등으로 다를 수 있지만, 다음과 같을 수 있습니다:

```python
from cassandra.cluster import Cluster

cluster = Cluster()
session = cluster.connect()
```


카산드라 인스턴스의 기존 키스페이스 이름을 제공해야 합니다:

```python
CASSANDRA_KEYSPACE = input("CASSANDRA_KEYSPACE = ")
```


문서 로더 생성:

```python
loader = CassandraLoader(
    table="movie_reviews",
    session=session,
    keyspace=CASSANDRA_KEYSPACE,
)
```


```python
docs = loader.load()
```


```python
docs[0]
```


```output
Document(page_content='Row(_id=\'659bdffa16cbc4586b11a423\', title=\'Dangerous Men\', reviewtext=\'"Dangerous Men,"  the picture\\\'s production notes inform, took 26 years to reach the big screen. After having seen it, I wonder: What was the rush?\')', metadata={'table': 'movie_reviews', 'keyspace': 'default_keyspace'})
```


### cassio에서 초기화

세션과 키스페이스를 구성하기 위해 cassio를 사용할 수도 있습니다.

```python
import cassio

cassio.init(contact_points="127.0.0.1", keyspace=CASSANDRA_KEYSPACE)

loader = CassandraLoader(
    table="movie_reviews",
)

docs = loader.load()
```


#### 저작권 고지

> Apache Cassandra, Cassandra 및 Apache는 [Apache Software Foundation](http://www.apache.org/)의 등록 상표 또는 상표입니다. 미국 및/또는 기타 국가에서.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)