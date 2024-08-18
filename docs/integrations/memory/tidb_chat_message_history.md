---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/tidb_chat_message_history.ipynb
description: TiDB를 사용하여 채팅 메시지 기록을 저장하는 방법을 소개하며, TiDB Serverless의 벡터 검색 기능을 활용합니다.
---

# TiDB

> [TiDB Cloud](https://www.pingcap.com/tidb-serverless/),는 전용 및 서버리스 옵션을 제공하는 종합 데이터베이스 서비스(DBaaS) 솔루션입니다. TiDB Serverless는 이제 MySQL 환경에 내장된 벡터 검색 기능을 통합하고 있습니다. 이 향상된 기능을 통해 새로운 데이터베이스나 추가 기술 스택 없이 TiDB Serverless를 사용하여 AI 애플리케이션을 원활하게 개발할 수 있습니다. 무료 TiDB Serverless 클러스터를 생성하고 https://pingcap.com/ai 에서 벡터 검색 기능을 사용해 보세요.

이 노트북에서는 TiDB를 사용하여 채팅 메시지 기록을 저장하는 방법을 소개합니다.

## 설정

먼저, 다음 종속성을 설치하겠습니다:

```python
%pip install --upgrade --quiet langchain langchain_openai langchain-community
```


OpenAI 키 구성하기

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("Input your OpenAI API key:")
```


마지막으로, TiDB에 대한 연결을 구성하겠습니다. 이 노트북에서는 TiDB Cloud에서 제공하는 표준 연결 방법을 따라 안전하고 효율적인 데이터베이스 연결을 설정합니다.

```python
# copy from tidb cloud console
tidb_connection_string_template = "mysql+pymysql://<USER>:<PASSWORD>@<HOST>:4000/<DB>?ssl_ca=/etc/ssl/cert.pem&ssl_verify_cert=true&ssl_verify_identity=true"
tidb_password = getpass.getpass("Input your TiDB password:")
tidb_connection_string = tidb_connection_string_template.replace(
    "<PASSWORD>", tidb_password
)
```


## 역사적 데이터 생성

향후 데모의 기초가 될 역사적 데이터 세트를 생성합니다.

```python
<!--IMPORTS:[{"imported": "TiDBChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.tidb.TiDBChatMessageHistory.html", "title": "TiDB"}]-->
from datetime import datetime

from langchain_community.chat_message_histories import TiDBChatMessageHistory

history = TiDBChatMessageHistory(
    connection_string=tidb_connection_string,
    session_id="code_gen",
    earliest_time=datetime.utcnow(),  # Optional to set earliest_time to load messages after this time point.
)

history.add_user_message("How's our feature going?")
history.add_ai_message(
    "It's going well. We are working on testing now. It will be released in Feb."
)
```


```python
history.messages
```


```output
[HumanMessage(content="How's our feature going?"),
 AIMessage(content="It's going well. We are working on testing now. It will be released in Feb.")]
```


## 역사적 데이터로 채팅하기

앞서 생성한 역사적 데이터를 바탕으로 동적인 채팅 상호작용을 만들어 보겠습니다.

먼저, LangChain으로 채팅 체인 생성하기:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "TiDB"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "TiDB"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "TiDB"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You're an assistant who's good at coding. You're helping a startup build",
        ),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}"),
    ]
)
chain = prompt | ChatOpenAI()
```


이력을 기반으로 실행 가능 객체 만들기:

```python
<!--IMPORTS:[{"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "TiDB"}]-->
from langchain_core.runnables.history import RunnableWithMessageHistory

chain_with_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: TiDBChatMessageHistory(
        session_id=session_id, connection_string=tidb_connection_string
    ),
    input_messages_key="question",
    history_messages_key="history",
)
```


채팅 시작하기:

```python
response = chain_with_history.invoke(
    {"question": "Today is Jan 1st. How many days until our feature is released?"},
    config={"configurable": {"session_id": "code_gen"}},
)
response
```


```output
AIMessage(content='There are 31 days in January, so there are 30 days until our feature is released in February.')
```


## 역사 데이터 확인하기

```python
history.reload_cache()
history.messages
```


```output
[HumanMessage(content="How's our feature going?"),
 AIMessage(content="It's going well. We are working on testing now. It will be released in Feb."),
 HumanMessage(content='Today is Jan 1st. How many days until our feature is released?'),
 AIMessage(content='There are 31 days in January, so there are 30 days until our feature is released in February.')]
```