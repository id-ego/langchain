---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/filter_messages.ipynb
description: 메시지를 유형, ID 또는 이름으로 필터링하는 방법을 설명하며, 복잡한 체인 및 에이전트에서 메시지 관리를 용이하게 합니다.
---

# 메시지 필터링 방법

더 복잡한 체인 및 에이전트에서는 메시지 목록으로 상태를 추적할 수 있습니다. 이 목록은 여러 다른 모델, 발화자, 하위 체인 등에서 메시지를 축적하기 시작할 수 있으며, 우리는 체인/에이전트의 각 모델 호출에 전체 메시지 목록의 하위 집합만 전달하고 싶을 수 있습니다.

`filter_messages` 유틸리티는 유형, ID 또는 이름으로 메시지를 쉽게 필터링할 수 있게 해줍니다.

## 기본 사용법

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to filter messages"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to filter messages"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to filter messages"}, {"imported": "filter_messages", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.filter_messages.html", "title": "How to filter messages"}]-->
from langchain_core.messages import (
    AIMessage,
    HumanMessage,
    SystemMessage,
    filter_messages,
)

messages = [
    SystemMessage("you are a good assistant", id="1"),
    HumanMessage("example input", id="2", name="example_user"),
    AIMessage("example output", id="3", name="example_assistant"),
    HumanMessage("real input", id="4", name="bob"),
    AIMessage("real output", id="5", name="alice"),
]

filter_messages(messages, include_types="human")
```


```output
[HumanMessage(content='example input', name='example_user', id='2'),
 HumanMessage(content='real input', name='bob', id='4')]
```


```python
filter_messages(messages, exclude_names=["example_user", "example_assistant"])
```


```output
[SystemMessage(content='you are a good assistant', id='1'),
 HumanMessage(content='real input', name='bob', id='4'),
 AIMessage(content='real output', name='alice', id='5')]
```


```python
filter_messages(messages, include_types=[HumanMessage, AIMessage], exclude_ids=["3"])
```


```output
[HumanMessage(content='example input', name='example_user', id='2'),
 HumanMessage(content='real input', name='bob', id='4'),
 AIMessage(content='real output', name='alice', id='5')]
```


## 체이닝

`filter_messages`는 위와 같이 명령형 또는 선언형으로 사용될 수 있어 체인의 다른 구성 요소와 쉽게 조합할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to filter messages"}]-->
# pip install -U langchain-anthropic
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=0)
# Notice we don't pass in messages. This creates
# a RunnableLambda that takes messages as input
filter_ = filter_messages(exclude_names=["example_user", "example_assistant"])
chain = filter_ | llm
chain.invoke(messages)
```


```output
AIMessage(content=[], response_metadata={'id': 'msg_01Wz7gBHahAwkZ1KCBNtXmwA', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 3}}, id='run-b5d8a3fe-004f-4502-a071-a6c025031827-0', usage_metadata={'input_tokens': 16, 'output_tokens': 3, 'total_tokens': 19})
```


LangSmith 추적을 살펴보면 메시지가 모델에 전달되기 전에 필터링되는 것을 볼 수 있습니다: https://smith.langchain.com/public/f808a724-e072-438e-9991-657cc9e7e253/r

필터_만 살펴보면, 모든 Runnable처럼 호출할 수 있는 Runnable 객체임을 알 수 있습니다:

```python
filter_.invoke(messages)
```


```output
[HumanMessage(content='real input', name='bob', id='4'),
 AIMessage(content='real output', name='alice', id='5')]
```


## API 참조

모든 인수에 대한 완전한 설명은 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.filter_messages.html