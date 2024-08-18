---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/sql_chat_message_history.ipynb
description: 이 문서는 SQLAlchemy를 사용하여 데이터베이스에 채팅 기록을 저장하는 SQLChatMessageHistory 클래스에
  대해 설명합니다.
---

# SQL (SQLAlchemy)

> [구조적 쿼리 언어 (SQL)](https://en.wikipedia.org/wiki/SQL)은 프로그래밍에 사용되는 도메인 특화 언어로, 관계형 데이터베이스 관리 시스템 (RDBMS)에서 보유한 데이터를 관리하거나 관계형 데이터 스트림 관리 시스템 (RDSMS)에서 스트림 처리를 위해 설계되었습니다. 이는 특히 엔티티와 변수 간의 관계를 포함하는 구조화된 데이터를 처리하는 데 유용합니다.

> [SQLAlchemy](https://github.com/sqlalchemy/sqlalchemy)는 MIT 라이센스 하에 출시된 파이썬 프로그래밍 언어용 오픈 소스 `SQL` 툴킷 및 객체 관계 매퍼 (ORM)입니다.

이 노트북은 `SQLAlchemy`가 지원하는 모든 데이터베이스에 채팅 기록을 저장할 수 있는 `SQLChatMessageHistory` 클래스를 다룹니다.

`SQLite` 외의 데이터베이스와 함께 사용하려면 해당 데이터베이스 드라이버를 설치해야 합니다.

## 설정

통합은 `langchain-community` 패키지에 있으므로 이를 설치해야 합니다. 또한 `SQLAlchemy` 패키지를 설치해야 합니다.

```bash
pip install -U langchain-community SQLAlchemy langchain-openai
```


최고 수준의 관찰 가능성을 위해 [LangSmith](https://smith.langchain.com/)를 설정하는 것도 도움이 됩니다 (필수는 아님).

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 사용법

저장을 사용하려면 다음 두 가지를 제공해야 합니다:

1. 세션 ID - 사용자 이름, 이메일, 채팅 ID 등과 같은 세션의 고유 식별자입니다.
2. 연결 문자열 - 데이터베이스 연결을 지정하는 문자열입니다. 이는 SQLAlchemy create_engine 함수에 전달됩니다.

```python
<!--IMPORTS:[{"imported": "SQLChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.sql.SQLChatMessageHistory.html", "title": "SQL (SQLAlchemy)"}]-->
from langchain_community.chat_message_histories import SQLChatMessageHistory

chat_message_history = SQLChatMessageHistory(
    session_id="test_session", connection_string="sqlite:///sqlite.db"
)

chat_message_history.add_user_message("Hello")
chat_message_history.add_ai_message("Hi")
```


```python
chat_message_history.messages
```


```output
[HumanMessage(content='Hello'), AIMessage(content='Hi')]
```


## 체이닝

이 메시지 기록 클래스를 [LCEL Runnables](/docs/how_to/message_history)와 쉽게 결합할 수 있습니다.

이를 위해 OpenAI를 사용하고자 하므로 이를 설치해야 합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "SQL (SQLAlchemy)"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "SQL (SQLAlchemy)"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "SQL (SQLAlchemy)"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "SQL (SQLAlchemy)"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}"),
    ]
)

chain = prompt | ChatOpenAI()
```


```python
chain_with_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: SQLChatMessageHistory(
        session_id=session_id, connection_string="sqlite:///sqlite.db"
    ),
    input_messages_key="question",
    history_messages_key="history",
)
```


```python
# This is where we configure the session id
config = {"configurable": {"session_id": "<SESSION_ID>"}}
```


```python
chain_with_history.invoke({"question": "Hi! I'm bob"}, config=config)
```


```output
AIMessage(content='Hello Bob! How can I assist you today?')
```


```python
chain_with_history.invoke({"question": "Whats my name"}, config=config)
```


```output
AIMessage(content='Your name is Bob! Is there anything specific you would like assistance with, Bob?')
```