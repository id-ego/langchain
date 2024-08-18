---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/snowflake.ipynb
description: Snowflake Cortex는 Mistral, Reka, Meta, Google의 LLM을 활용하여 LangChain으로
  상호작용하는 방법을 제공합니다.
---

# 스노우플레이크 코르텍스

[스노우플레이크 코르텍스](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions)는 Mistral, Reka, Meta, Google과 같은 회사의 연구자들이 훈련한 업계 최고의 대형 언어 모델(LLM)에 즉시 접근할 수 있게 해줍니다. 여기에는 스노우플레이크에서 개발한 오픈 엔터프라이즈급 모델인 [스노우플레이크 아크틱](https://www.snowflake.com/en/data-cloud/arctic/)이 포함됩니다.

이 예제에서는 LangChain을 사용하여 스노우플레이크 코르텍스와 상호작용하는 방법을 설명합니다.

### 설치 및 설정

먼저 아래 명령어를 사용하여 `snowflake-snowpark-python` 라이브러리를 설치합니다. 그런 다음 스노우플레이크에 연결하기 위한 자격 증명을 환경 변수로 설정하거나 직접 전달합니다.

```python
%pip install --upgrade --quiet snowflake-snowpark-python
```

```output
Note: you may need to restart the kernel to use updated packages.
```


```python
import getpass
import os

# First step is to set up the environment variables, to connect to Snowflake,
# you can also pass these snowflake credentials while instantiating the model

if os.environ.get("SNOWFLAKE_ACCOUNT") is None:
    os.environ["SNOWFLAKE_ACCOUNT"] = getpass.getpass("Account: ")

if os.environ.get("SNOWFLAKE_USERNAME") is None:
    os.environ["SNOWFLAKE_USERNAME"] = getpass.getpass("Username: ")

if os.environ.get("SNOWFLAKE_PASSWORD") is None:
    os.environ["SNOWFLAKE_PASSWORD"] = getpass.getpass("Password: ")

if os.environ.get("SNOWFLAKE_DATABASE") is None:
    os.environ["SNOWFLAKE_DATABASE"] = getpass.getpass("Database: ")

if os.environ.get("SNOWFLAKE_SCHEMA") is None:
    os.environ["SNOWFLAKE_SCHEMA"] = getpass.getpass("Schema: ")

if os.environ.get("SNOWFLAKE_WAREHOUSE") is None:
    os.environ["SNOWFLAKE_WAREHOUSE"] = getpass.getpass("Warehouse: ")

if os.environ.get("SNOWFLAKE_ROLE") is None:
    os.environ["SNOWFLAKE_ROLE"] = getpass.getpass("Role: ")
```


```python
<!--IMPORTS:[{"imported": "ChatSnowflakeCortex", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.snowflake.ChatSnowflakeCortex.html", "title": "Snowflake Cortex"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Snowflake Cortex"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Snowflake Cortex"}]-->
from langchain_community.chat_models import ChatSnowflakeCortex
from langchain_core.messages import HumanMessage, SystemMessage

# By default, we'll be using the cortex provided model: `snowflake-arctic`, with function: `complete`
chat = ChatSnowflakeCortex()
```


위의 셀은 귀하의 스노우플레이크 자격 증명이 환경 변수에 설정되어 있다고 가정합니다. 자격 증명을 수동으로 지정하려면 다음 코드를 사용하십시오:

```python
chat = ChatSnowflakeCortex(
    # change default cortex model and function
    model="snowflake-arctic",
    cortex_function="complete",

    # change default generation parameters
    temperature=0,
    max_tokens=10,
    top_p=0.95,

    # specify snowflake credentials
    account="YOUR_SNOWFLAKE_ACCOUNT",
    username="YOUR_SNOWFLAKE_USERNAME",
    password="YOUR_SNOWFLAKE_PASSWORD",
    database="YOUR_SNOWFLAKE_DATABASE",
    schema="YOUR_SNOWFLAKE_SCHEMA",
    role="YOUR_SNOWFLAKE_ROLE",
    warehouse="YOUR_SNOWFLAKE_WAREHOUSE"
)
```


### 모델 호출
이제 `invoke` 또는 `generate` 메서드를 사용하여 모델을 호출할 수 있습니다.

#### 생성

```python
messages = [
    SystemMessage(content="You are a friendly assistant."),
    HumanMessage(content="What are large language models?"),
]
chat.invoke(messages)
```


```output
AIMessage(content=" Large language models are artificial intelligence systems designed to understand, generate, and manipulate human language. These models are typically based on deep learning techniques and are trained on vast amounts of text data to learn patterns and structures in language. They can perform a wide range of language-related tasks, such as language translation, text generation, sentiment analysis, and answering questions. Some well-known large language models include Google's BERT, OpenAI's GPT series, and Facebook's RoBERTa. These models have shown remarkable performance in various natural language processing tasks, and their applications continue to expand as research in AI progresses.", response_metadata={'completion_tokens': 131, 'prompt_tokens': 29, 'total_tokens': 160}, id='run-5435bd0a-83fd-4295-b237-66cbd1b5c0f3-0')
```


### 스트리밍
현재 `ChatSnowflakeCortex`는 스트리밍을 지원하지 않습니다. 스트리밍 지원은 이후 버전에서 제공될 예정입니다!

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)