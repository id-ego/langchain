---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/astradb_chat_message_history.ipynb
description: 이 문서는 Astra DB를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다. 서버리스 데이터베이스의 설정 및 연결
  방법을 안내합니다.
---

# Astra DB

> DataStax [Astra DB](https://docs.datastax.com/en/astra/home/astra.html)는 Cassandra를 기반으로 한 서버리스 벡터 지원 데이터베이스로, 사용하기 쉬운 JSON API를 통해 편리하게 제공됩니다.

이 노트북은 Astra DB를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.

## 설정

이 노트북을 실행하려면 실행 중인 Astra DB가 필요합니다. Astra 대시보드에서 연결 비밀을 가져옵니다:

- API 엔드포인트는 `https://01234567-89ab-cdef-0123-456789abcdef-us-east1.apps.astra.datastax.com`와 같습니다;
- 토큰은 `AstraCS:6gBhNmsk135...`와 같습니다.

```python
%pip install --upgrade --quiet  "astrapy>=0.7.1 langchain-community" 
```


### 데이터베이스 연결 매개변수 및 비밀 설정

```python
import getpass

ASTRA_DB_API_ENDPOINT = input("ASTRA_DB_API_ENDPOINT = ")
ASTRA_DB_APPLICATION_TOKEN = getpass.getpass("ASTRA_DB_APPLICATION_TOKEN = ")
```

```output
ASTRA_DB_API_ENDPOINT =  https://01234567-89ab-cdef-0123-456789abcdef-us-east1.apps.astra.datastax.com
ASTRA_DB_APPLICATION_TOKEN =  ········
```

로컬 또는 클라우드 기반 Astra DB에 따라 해당 데이터베이스 연결 "세션" 객체를 생성합니다.

## 예제

```python
<!--IMPORTS:[{"imported": "AstraDBChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.astradb.AstraDBChatMessageHistory.html", "title": "Astra DB "}]-->
from langchain_community.chat_message_histories import AstraDBChatMessageHistory

message_history = AstraDBChatMessageHistory(
    session_id="test-session",
    api_endpoint=ASTRA_DB_API_ENDPOINT,
    token=ASTRA_DB_APPLICATION_TOKEN,
)

message_history.add_user_message("hi!")

message_history.add_ai_message("whats up?")
```


```python
message_history.messages
```


```output
[HumanMessage(content='hi!'), AIMessage(content='whats up?')]
```