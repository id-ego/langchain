---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/aws_dynamodb.ipynb
description: AWS DynamoDB를 사용하여 채팅 메시지 기록을 저장하는 방법을 다루는 노트북입니다. DynamoDBChatMessageHistory
  클래스를 활용합니다.
---

# AWS DynamoDB

> [Amazon AWS DynamoDB](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/dynamodb/index.html)는 빠르고 예측 가능한 성능을 제공하며 원활한 확장성을 갖춘 완전 관리형 `NoSQL` 데이터베이스 서비스입니다.

이 노트북은 `DynamoDBChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다.

## 설정

먼저 [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)가 올바르게 구성되었는지 확인하십시오. 그런 다음 `langchain-community` 패키지가 설치되어 있는지 확인해야 하며, 이를 설치해야 합니다. 또한 `boto3` 패키지를 설치해야 합니다.

```bash
pip install -U langchain-community boto3
```


최고 수준의 가시성을 위해 [LangSmith](https://smith.langchain.com/)를 설정하는 것도 유용하지만 필수는 아닙니다.

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


```python
<!--IMPORTS:[{"imported": "DynamoDBChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.dynamodb.DynamoDBChatMessageHistory.html", "title": "AWS DynamoDB"}]-->
from langchain_community.chat_message_histories import (
    DynamoDBChatMessageHistory,
)
```


## 테이블 생성

이제 메시지를 저장할 `DynamoDB` 테이블을 생성합니다:

```python
import boto3

# Get the service resource.
dynamodb = boto3.resource("dynamodb")

# Create the DynamoDB table.
table = dynamodb.create_table(
    TableName="SessionTable",
    KeySchema=[{"AttributeName": "SessionId", "KeyType": "HASH"}],
    AttributeDefinitions=[{"AttributeName": "SessionId", "AttributeType": "S"}],
    BillingMode="PAY_PER_REQUEST",
)

# Wait until the table exists.
table.meta.client.get_waiter("table_exists").wait(TableName="SessionTable")

# Print out some data about the table.
print(table.item_count)
```

```output
0
```


## DynamoDBChatMessageHistory

```python
history = DynamoDBChatMessageHistory(table_name="SessionTable", session_id="0")

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


```python
history.messages
```


```output
[HumanMessage(content='hi!'), AIMessage(content='whats up?')]
```


## 사용자 지정 엔드포인트 URL을 사용하는 DynamoDBChatMessageHistory

때때로 AWS 엔드포인트에 연결하기 위해 URL을 지정하는 것이 유용합니다. 예를 들어, [Localstack](https://localstack.cloud/)에 대해 로컬에서 실행할 때입니다. 이러한 경우 생성자에서 `endpoint_url` 매개변수를 통해 URL을 지정할 수 있습니다.

```python
history = DynamoDBChatMessageHistory(
    table_name="SessionTable",
    session_id="0",
    endpoint_url="http://localhost.localstack.cloud:4566",
)
```


## 복합 키가 있는 DynamoDBChatMessageHistory
DynamoDBChatMessageHistory의 기본 키는 `{"SessionId": self.session_id}`이지만, 이를 테이블 설계에 맞게 수정할 수 있습니다.

### 기본 키 이름
생성자에서 primary_key_name 값을 전달하여 기본 키를 수정할 수 있으며, 결과는 다음과 같습니다:
`{self.primary_key_name: self.session_id}`

### 복합 키
기존 DynamoDB 테이블을 사용할 때 기본값에서 정렬 키를 포함하는 구조로 키 구조를 수정해야 할 수 있습니다. 이를 위해 `key` 매개변수를 사용할 수 있습니다.

키에 대한 값을 전달하면 primary_key 매개변수를 무시하고, 결과 키 구조는 전달된 값이 됩니다.

```python
composite_table = dynamodb.create_table(
    TableName="CompositeTable",
    KeySchema=[
        {"AttributeName": "PK", "KeyType": "HASH"},
        {"AttributeName": "SK", "KeyType": "RANGE"},
    ],
    AttributeDefinitions=[
        {"AttributeName": "PK", "AttributeType": "S"},
        {"AttributeName": "SK", "AttributeType": "S"},
    ],
    BillingMode="PAY_PER_REQUEST",
)

# Wait until the table exists.
composite_table.meta.client.get_waiter("table_exists").wait(TableName="CompositeTable")

# Print out some data about the table.
print(composite_table.item_count)
```

```output
0
```


```python
my_key = {
    "PK": "session_id::0",
    "SK": "langchain_history",
}

composite_key_history = DynamoDBChatMessageHistory(
    table_name="CompositeTable",
    session_id="0",
    endpoint_url="http://localhost.localstack.cloud:4566",
    key=my_key,
)

composite_key_history.add_user_message("hello, composite dynamodb table!")

composite_key_history.messages
```


```output
[HumanMessage(content='hello, composite dynamodb table!')]
```


## 체이닝

이 메시지 기록 클래스를 [LCEL Runnables](/docs/how_to/message_history)와 쉽게 결합할 수 있습니다.

이를 위해 OpenAI를 사용해야 하므로 이를 설치해야 합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "AWS DynamoDB"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "AWS DynamoDB"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "AWS DynamoDB"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "AWS DynamoDB"}]-->
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
    lambda session_id: DynamoDBChatMessageHistory(
        table_name="SessionTable", session_id=session_id
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