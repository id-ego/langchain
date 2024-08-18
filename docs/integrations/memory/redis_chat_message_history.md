---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/redis_chat_message_history.ipynb
description: 이 문서는 Redis를 사용하여 채팅 메시지 기록을 저장하고 검색하는 방법에 대해 설명합니다. Redis의 설치 및 사용법을
  다룹니다.
---

# Redis

> [Redis (원격 사전 서버)](https://en.wikipedia.org/wiki/Redis)는 분산형 인메모리 키-값 데이터베이스, 캐시 및 메시지 브로커로 사용되는 오픈 소스 인메모리 저장소로, 선택적 내구성을 제공합니다. 모든 데이터를 메모리에 보관하고 설계 덕분에 `Redis`는 낮은 대기 시간의 읽기 및 쓰기를 제공하여 캐시가 필요한 사용 사례에 특히 적합합니다. Redis는 가장 인기 있는 NoSQL 데이터베이스이며, 전체적으로 가장 인기 있는 데이터베이스 중 하나입니다.

이 노트북은 `Redis`를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다.

## 설정
먼저 종속성을 설치하고 `redis-server`와 같은 명령어를 사용하여 redis 인스턴스를 시작해야 합니다.

```python
pip install -U langchain-community redis
```


```python
<!--IMPORTS:[{"imported": "RedisChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.redis.RedisChatMessageHistory.html", "title": "Redis"}]-->
from langchain_community.chat_message_histories import RedisChatMessageHistory
```


## 메시지 저장 및 검색

```python
history = RedisChatMessageHistory("foo", url="redis://localhost:6379")

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


```python
history.messages
```


```output
[HumanMessage(content='hi!'), AIMessage(content='whats up?')]
```


## 체인에서 사용하기

```python
pip install -U langchain-openai
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Redis"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Redis"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Redis"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Redis"}]-->
from typing import Optional

from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You're an assistant。"),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}"),
    ]
)

chain = prompt | ChatOpenAI()

chain_with_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: RedisChatMessageHistory(
        session_id, url="redis://localhost:6379"
    ),
    input_messages_key="question",
    history_messages_key="history",
)

config = {"configurable": {"session_id": "foo"}}

chain_with_history.invoke({"question": "Hi! I'm bob"}, config=config)

chain_with_history.invoke({"question": "Whats my name"}, config=config)
```


```output
AIMessage(content='Your name is Bob, as you mentioned earlier. Is there anything specific you would like assistance with, Bob?')
```