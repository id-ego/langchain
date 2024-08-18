---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/trim_messages.ipynb
description: 메시지를 잘라내는 방법에 대한 가이드를 제공하며, 토큰 길이를 관리하기 위한 기본 전략을 설명합니다.
---

# 메시지 다듬는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [메시지](/docs/concepts/#messages)
- [채팅 모델](/docs/concepts/#chat-models)
- [체이닝](/docs/how_to/sequence/)
- [채팅 기록](/docs/concepts/#chat-history)

이 가이드의 방법은 또한 `langchain-core>=0.2.9`를 요구합니다.

:::

모든 모델은 유한한 컨텍스트 창을 가지고 있으며, 이는 입력으로 받을 수 있는 토큰의 수에 제한이 있음을 의미합니다. 매우 긴 메시지나 긴 메시지 기록을 축적하는 체인/에이전트가 있는 경우, 모델에 전달하는 메시지의 길이를 관리해야 합니다.

`trim_messages` 유틸리티는 특정 토큰 길이에 맞게 메시지 목록을 다듬기 위한 몇 가지 기본 전략을 제공합니다.

## 마지막 `max_tokens` 토큰 가져오기

메시지 목록에서 마지막 `max_tokens`를 가져오려면 `strategy="last"`로 설정할 수 있습니다. `token_counter`에는 함수(아래에서 더 설명) 또는 언어 모델을 전달할 수 있습니다(언어 모델에는 메시지 토큰 수 계산 방법이 있기 때문입니다). 특정 모델의 컨텍스트 창에 맞게 메시지를 다듬을 때 모델을 전달하는 것이 합리적입니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to trim messages"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to trim messages"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to trim messages"}, {"imported": "trim_messages", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.trim_messages.html", "title": "How to trim messages"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to trim messages"}]-->
# pip install -U langchain-openai
from langchain_core.messages import (
    AIMessage,
    HumanMessage,
    SystemMessage,
    trim_messages,
)
from langchain_openai import ChatOpenAI

messages = [
    SystemMessage("you're a good assistant, you always respond with a joke."),
    HumanMessage("i wonder why it's called langchain"),
    AIMessage(
        'Well, I guess they thought "WordRope" and "SentenceString" just didn\'t have the same ring to it!'
    ),
    HumanMessage("and who is harrison chasing anyways"),
    AIMessage(
        "Hmmm let me think.\n\nWhy, he's probably chasing after the last cup of coffee in the office!"
    ),
    HumanMessage("what do you call a speechless parrot"),
]

trim_messages(
    messages,
    max_tokens=45,
    strategy="last",
    token_counter=ChatOpenAI(model="gpt-4o"),
)
```


```output
[AIMessage(content="Hmmm let me think.\n\nWhy, he's probably chasing after the last cup of coffee in the office!"),
 HumanMessage(content='what do you call a speechless parrot')]
```


초기 시스템 메시지를 항상 유지하려면 `include_system=True`로 지정할 수 있습니다:

```python
trim_messages(
    messages,
    max_tokens=45,
    strategy="last",
    token_counter=ChatOpenAI(model="gpt-4o"),
    include_system=True,
)
```


```output
[SystemMessage(content="you're a good assistant, you always respond with a joke."),
 HumanMessage(content='what do you call a speechless parrot')]
```


메시지의 내용을 나누는 것을 허용하려면 `allow_partial=True`로 지정할 수 있습니다:

```python
trim_messages(
    messages,
    max_tokens=56,
    strategy="last",
    token_counter=ChatOpenAI(model="gpt-4o"),
    include_system=True,
    allow_partial=True,
)
```


```output
[SystemMessage(content="you're a good assistant, you always respond with a joke."),
 AIMessage(content="\nWhy, he's probably chasing after the last cup of coffee in the office!"),
 HumanMessage(content='what do you call a speechless parrot')]
```


첫 번째 메시지(시스템 메시지를 제외한)가 항상 특정 유형인지 확인해야 하는 경우 `start_on`을 지정할 수 있습니다:

```python
trim_messages(
    messages,
    max_tokens=60,
    strategy="last",
    token_counter=ChatOpenAI(model="gpt-4o"),
    include_system=True,
    start_on="human",
)
```


```output
[SystemMessage(content="you're a good assistant, you always respond with a joke."),
 HumanMessage(content='what do you call a speechless parrot')]
```


## 첫 번째 `max_tokens` 토큰 가져오기

`strategy="first"`로 지정하여 *첫 번째* `max_tokens`를 가져오는 반대 작업을 수행할 수 있습니다:

```python
trim_messages(
    messages,
    max_tokens=45,
    strategy="first",
    token_counter=ChatOpenAI(model="gpt-4o"),
)
```


```output
[SystemMessage(content="you're a good assistant, you always respond with a joke."),
 HumanMessage(content="i wonder why it's called langchain")]
```


## 사용자 정의 토큰 카운터 작성하기

메시지 목록을 입력으로 받아 정수를 반환하는 사용자 정의 토큰 카운터 함수를 작성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to trim messages"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to trim messages"}]-->
from typing import List

# pip install tiktoken
import tiktoken
from langchain_core.messages import BaseMessage, ToolMessage


def str_token_counter(text: str) -> int:
    enc = tiktoken.get_encoding("o200k_base")
    return len(enc.encode(text))


def tiktoken_counter(messages: List[BaseMessage]) -> int:
    """Approximately reproduce https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb

    For simplicity only supports str Message.contents.
    """
    num_tokens = 3  # every reply is primed with <|start|>assistant<|message|>
    tokens_per_message = 3
    tokens_per_name = 1
    for msg in messages:
        if isinstance(msg, HumanMessage):
            role = "user"
        elif isinstance(msg, AIMessage):
            role = "assistant"
        elif isinstance(msg, ToolMessage):
            role = "tool"
        elif isinstance(msg, SystemMessage):
            role = "system"
        else:
            raise ValueError(f"Unsupported messages type {msg.__class__}")
        num_tokens += (
            tokens_per_message
            + str_token_counter(role)
            + str_token_counter(msg.content)
        )
        if msg.name:
            num_tokens += tokens_per_name + str_token_counter(msg.name)
    return num_tokens


trim_messages(
    messages,
    max_tokens=45,
    strategy="last",
    token_counter=tiktoken_counter,
)
```


```output
[AIMessage(content="Hmmm let me think.\n\nWhy, he's probably chasing after the last cup of coffee in the office!"),
 HumanMessage(content='what do you call a speechless parrot')]
```


## 체이닝

`trim_messages`는 위와 같이 명령형으로 또는 선언형으로 사용할 수 있어 체인 내 다른 구성 요소와 쉽게 조합할 수 있습니다.

```python
llm = ChatOpenAI(model="gpt-4o")

# Notice we don't pass in messages. This creates
# a RunnableLambda that takes messages as input
trimmer = trim_messages(
    max_tokens=45,
    strategy="last",
    token_counter=llm,
    include_system=True,
)

chain = trimmer | llm
chain.invoke(messages)
```


```output
AIMessage(content='A: A "Polly-gone"!', response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 32, 'total_tokens': 41}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_66b29dffce', 'finish_reason': 'stop', 'logprobs': None}, id='run-83e96ddf-bcaa-4f63-824c-98b0f8a0d474-0', usage_metadata={'input_tokens': 32, 'output_tokens': 9, 'total_tokens': 41})
```


LangSmith 추적을 보면 메시지가 모델에 전달되기 전에 먼저 다듬어진다는 것을 알 수 있습니다: https://smith.langchain.com/public/65af12c4-c24d-4824-90f0-6547566e59bb/r

트리머만 살펴보면, 모든 Runnables처럼 호출할 수 있는 Runnable 객체라는 것을 알 수 있습니다:

```python
trimmer.invoke(messages)
```


```output
[SystemMessage(content="you're a good assistant, you always respond with a joke."),
 HumanMessage(content='what do you call a speechless parrot')]
```


## ChatMessageHistory와 함께 사용하기

메시지를 다듬는 것은 [채팅 기록](/docs/how_to/message_history/) 작업 시 특히 유용하며, 이는 임의로 길어질 수 있습니다:

```python
<!--IMPORTS:[{"imported": "InMemoryChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.InMemoryChatMessageHistory.html", "title": "How to trim messages"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "How to trim messages"}]-->
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

chat_history = InMemoryChatMessageHistory(messages=messages[:-1])


def dummy_get_session_history(session_id):
    if session_id != "1":
        return InMemoryChatMessageHistory()
    return chat_history


llm = ChatOpenAI(model="gpt-4o")

trimmer = trim_messages(
    max_tokens=45,
    strategy="last",
    token_counter=llm,
    include_system=True,
)

chain = trimmer | llm
chain_with_history = RunnableWithMessageHistory(chain, dummy_get_session_history)
chain_with_history.invoke(
    [HumanMessage("what do you call a speechless parrot")],
    config={"configurable": {"session_id": "1"}},
)
```


```output
AIMessage(content='A "polly-no-wanna-cracker"!', response_metadata={'token_usage': {'completion_tokens': 10, 'prompt_tokens': 32, 'total_tokens': 42}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_5bf7397cd3', 'finish_reason': 'stop', 'logprobs': None}, id='run-054dd309-3497-4e7b-b22a-c1859f11d32e-0', usage_metadata={'input_tokens': 32, 'output_tokens': 10, 'total_tokens': 42})
```


LangSmith 추적을 보면 모든 메시지를 검색하지만, 메시지가 모델에 전달되기 전에 시스템 메시지와 마지막 인간 메시지만 남도록 다듬어진다는 것을 알 수 있습니다: https://smith.langchain.com/public/17dd700b-9994-44ca-930c-116e00997315/r

## API 참조

모든 인수에 대한 완전한 설명은 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.trim_messages.html