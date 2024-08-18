---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/couchbase_chat_message_history.ipynb
description: Couchbase를 사용하여 채팅 메시지 기록을 저장하는 방법과 Couchbase 클러스터 설정 및 연결 방법을 설명합니다.
---

# Couchbase
> Couchbase는 모든 클라우드, 모바일, AI 및 엣지 컴퓨팅 애플리케이션에 대해 비할 데 없는 다재다능성, 성능, 확장성 및 재정적 가치를 제공하는 수상 경력에 빛나는 분산 NoSQL 클라우드 데이터베이스입니다. Couchbase는 개발자를 위한 코딩 지원과 애플리케이션을 위한 벡터 검색을 통해 AI를 수용합니다.

이 노트북은 Couchbase 클러스터에 채팅 메시지 기록을 저장하기 위해 `CouchbaseChatMessageHistory` 클래스를 사용하는 방법을 다룹니다.

## Couchbase 클러스터 설정
이 데모를 실행하려면 Couchbase 클러스터가 필요합니다.

[Couchbase Capella](https://www.couchbase.com/products/capella/)와 자가 관리하는 Couchbase 서버 모두에서 작업할 수 있습니다.

## 종속성 설치
`CouchbaseChatMessageHistory`는 `langchain-couchbase` 패키지 내에 있습니다.

```python
%pip install --upgrade --quiet langchain-couchbase
```

```output
Note: you may need to restart the kernel to use updated packages.
```


## Couchbase 연결 객체 생성
우리는 처음에 Couchbase 클러스터에 연결을 생성한 다음 클러스터 객체를 벡터 저장소에 전달합니다.

여기서는 사용자 이름과 비밀번호를 사용하여 연결하고 있습니다. 클러스터에 연결하는 다른 지원 방법을 사용할 수도 있습니다.

Couchbase 클러스터에 연결하는 방법에 대한 자세한 정보는 [Python SDK 문서](https://docs.couchbase.com/python-sdk/current/hello-world/start-using-sdk.html#connect)를 확인하십시오.

```python
COUCHBASE_CONNECTION_STRING = (
    "couchbase://localhost"  # or "couchbases://localhost" if using TLS
)
DB_USERNAME = "Administrator"
DB_PASSWORD = "Password"
```


```python
from datetime import timedelta

from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions

auth = PasswordAuthenticator(DB_USERNAME, DB_PASSWORD)
options = ClusterOptions(auth)
cluster = Cluster(COUCHBASE_CONNECTION_STRING, options)

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))
```


이제 메시지 기록을 저장하는 데 사용할 Couchbase 클러스터의 버킷, 스코프 및 컬렉션 이름을 설정하겠습니다.

메시지 기록을 저장하기 위해 사용하기 전에 버킷, 스코프 및 컬렉션이 존재해야 합니다.

```python
BUCKET_NAME = "langchain-testing"
SCOPE_NAME = "_default"
COLLECTION_NAME = "conversational_cache"
```


## 사용법
메시지를 저장하려면 다음이 필요합니다:
- Couchbase 클러스터 객체: Couchbase 클러스터에 대한 유효한 연결
- bucket_name: 채팅 메시지 기록을 저장할 클러스터의 버킷
- scope_name: 메시지 기록을 저장할 버킷의 스코프
- collection_name: 메시지 기록을 저장할 스코프의 컬렉션
- session_id: 세션의 고유 식별자

선택적으로 다음을 구성할 수 있습니다:
- session_id_key: `session_id`를 저장할 채팅 메시지 문서의 필드
- message_key: 메시지 내용을 저장할 채팅 메시지 문서의 필드
- create_index: 컬렉션에 인덱스를 생성해야 하는지 여부를 지정하는 데 사용됩니다. 기본적으로 문서의 `message_key`와 `session_id_key`에 인덱스가 생성됩니다.

```python
from langchain_couchbase.chat_message_histories import CouchbaseChatMessageHistory

message_history = CouchbaseChatMessageHistory(
    cluster=cluster,
    bucket_name=BUCKET_NAME,
    scope_name=SCOPE_NAME,
    collection_name=COLLECTION_NAME,
    session_id="test-session",
)

message_history.add_user_message("hi!")

message_history.add_ai_message("how are you doing?")
```


```python
message_history.messages
```


```output
[HumanMessage(content='hi!'), AIMessage(content='how are you doing?')]
```


## 체이닝
채팅 메시지 기록 클래스는 [LCEL Runnables](https://python.langchain.com/v0.2/docs/how_to/message_history/)와 함께 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Couchbase"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Couchbase"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Couchbase"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Couchbase"}]-->
import getpass
import os

from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI

os.environ["OPENAI_API_KEY"] = getpass.getpass()
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}"),
    ]
)

# Create the LCEL runnable
chain = prompt | ChatOpenAI()
```


```python
chain_with_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: CouchbaseChatMessageHistory(
        cluster=cluster,
        bucket_name=BUCKET_NAME,
        scope_name=SCOPE_NAME,
        collection_name=COLLECTION_NAME,
        session_id=session_id,
    ),
    input_messages_key="question",
    history_messages_key="history",
)
```


```python
# This is where we configure the session id
config = {"configurable": {"session_id": "testing"}}
```


```python
chain_with_history.invoke({"question": "Hi! I'm bob"}, config=config)
```


```output
AIMessage(content='Hello Bob! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 10, 'prompt_tokens': 22, 'total_tokens': 32}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-a0f8a29e-ddf4-4e06-a1fe-cf8c325a2b72-0', usage_metadata={'input_tokens': 22, 'output_tokens': 10, 'total_tokens': 32})
```


```python
chain_with_history.invoke({"question": "Whats my name"}, config=config)
```


```output
AIMessage(content='Your name is Bob.', response_metadata={'token_usage': {'completion_tokens': 5, 'prompt_tokens': 43, 'total_tokens': 48}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-f764a9eb-999e-4042-96b6-fe47b7ae4779-0', usage_metadata={'input_tokens': 43, 'output_tokens': 5, 'total_tokens': 48})
```