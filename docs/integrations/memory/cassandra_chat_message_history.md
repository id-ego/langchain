---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/cassandra_chat_message_history.ipynb
description: 이 문서는 Apache Cassandra를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명하며, 데이터베이스 설정 및 연결
  방법을 안내합니다.
---

# 카산드라

> [Apache Cassandra®](https://cassandra.apache.org)는 `NoSQL`, 행 지향, 고도로 확장 가능하고 고도로 가용한 데이터베이스로, 대량의 데이터를 저장하는 데 적합합니다.

> `Cassandra`는 확장이 용이하고 많은 쓰기를 처리할 수 있기 때문에 채팅 메시지 기록을 저장하는 데 좋은 선택입니다.

이 노트북에서는 카산드라를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다.

## 설정

이 노트북을 실행하려면 실행 중인 `Cassandra` 클러스터 또는 클라우드에서 실행 중인 `DataStax Astra DB` 인스턴스가 필요합니다(무료로 [datastax.com](https://astra.datastax.com)에서 하나를 얻을 수 있습니다). 자세한 정보는 [cassio.org](https://cassio.org/start_here/)를 확인하세요.

```python
%pip install --upgrade --quiet  "cassio>=0.1.0 langchain-community"
```


### 데이터베이스 연결 매개변수 및 비밀 설정

```python
import getpass

database_mode = (input("\n(C)assandra or (A)stra DB? ")).upper()

keyspace_name = input("\nKeyspace name? ")

if database_mode == "A":
    ASTRA_DB_APPLICATION_TOKEN = getpass.getpass('\nAstra DB Token ("AstraCS:...") ')
    #
    ASTRA_DB_SECURE_BUNDLE_PATH = input("Full path to your Secure Connect Bundle? ")
elif database_mode == "C":
    CASSANDRA_CONTACT_POINTS = input(
        "Contact points? (comma-separated, empty for localhost) "
    ).strip()
```


로컬 또는 클라우드 기반 Astra DB에 따라 해당 데이터베이스 연결 "세션" 객체를 생성합니다.

```python
from cassandra.auth import PlainTextAuthProvider
from cassandra.cluster import Cluster

if database_mode == "C":
    if CASSANDRA_CONTACT_POINTS:
        cluster = Cluster(
            [cp.strip() for cp in CASSANDRA_CONTACT_POINTS.split(",") if cp.strip()]
        )
    else:
        cluster = Cluster()
    session = cluster.connect()
elif database_mode == "A":
    ASTRA_DB_CLIENT_ID = "token"
    cluster = Cluster(
        cloud={
            "secure_connect_bundle": ASTRA_DB_SECURE_BUNDLE_PATH,
        },
        auth_provider=PlainTextAuthProvider(
            ASTRA_DB_CLIENT_ID,
            ASTRA_DB_APPLICATION_TOKEN,
        ),
    )
    session = cluster.connect()
else:
    raise NotImplementedError
```


## 예제

```python
<!--IMPORTS:[{"imported": "CassandraChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.cassandra.CassandraChatMessageHistory.html", "title": "Cassandra "}]-->
from langchain_community.chat_message_histories import (
    CassandraChatMessageHistory,
)

message_history = CassandraChatMessageHistory(
    session_id="test-session",
    session=session,
    keyspace=keyspace_name,
)

message_history.add_user_message("hi!")

message_history.add_ai_message("whats up?")
```


```python
message_history.messages
```


#### 저작권 명시

> Apache Cassandra, Cassandra 및 Apache는 미국 및/또는 기타 국가에서 [Apache Software Foundation](http://www.apache.org/)의 등록 상표 또는 상표입니다.