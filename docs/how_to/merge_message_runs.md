---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/merge_message_runs.ipynb
description: 연속 메시지를 병합하는 방법에 대한 가이드를 제공합니다. `merge_message_runs` 유틸리티를 사용하여 메시지를
  쉽게 병합할 수 있습니다.
---

# 같은 유형의 연속 메시지를 병합하는 방법

일부 모델은 같은 유형의 연속 메시지를 전달하는 것을 지원하지 않습니다(즉, "같은 메시지 유형의 연속"이라고도 함).

`merge_message_runs` 유틸리티는 같은 유형의 연속 메시지를 쉽게 병합할 수 있도록 합니다.

## 기본 사용법

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to merge consecutive messages of the same type"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to merge consecutive messages of the same type"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to merge consecutive messages of the same type"}, {"imported": "merge_message_runs", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.merge_message_runs.html", "title": "How to merge consecutive messages of the same type"}]-->
from langchain_core.messages import (
    AIMessage,
    HumanMessage,
    SystemMessage,
    merge_message_runs,
)

messages = [
    SystemMessage("you're a good assistant."),
    SystemMessage("you always respond with a joke."),
    HumanMessage([{"type": "text", "text": "i wonder why it's called langchain"}]),
    HumanMessage("and who is harrison chasing anyways"),
    AIMessage(
        'Well, I guess they thought "WordRope" and "SentenceString" just didn\'t have the same ring to it!'
    ),
    AIMessage("Why, he's probably chasing after the last cup of coffee in the office!"),
]

merged = merge_message_runs(messages)
print("\n\n".join([repr(x) for x in merged]))
```

```output
SystemMessage(content="you're a good assistant.\nyou always respond with a joke.")

HumanMessage(content=[{'type': 'text', 'text': "i wonder why it's called langchain"}, 'and who is harrison chasing anyways'])

AIMessage(content='Well, I guess they thought "WordRope" and "SentenceString" just didn\'t have the same ring to it!\nWhy, he\'s probably chasing after the last cup of coffee in the office!')
```

병합할 메시지 중 하나의 내용이 콘텐츠 블록 목록인 경우 병합된 메시지는 콘텐츠 블록 목록을 갖습니다. 그리고 병합할 두 메시지가 문자열 내용을 갖는 경우, 이들은 줄 바꿈 문자로 연결됩니다.

`merge_message_runs` 유틸리티는 오버로드된 `+` 연산자를 사용하여 함께 구성된 메시지와도 작동합니다:

```python
messages = (
    SystemMessage("you're a good assistant.")
    + SystemMessage("you always respond with a joke.")
    + HumanMessage([{"type": "text", "text": "i wonder why it's called langchain"}])
    + HumanMessage("and who is harrison chasing anyways")
    + AIMessage(
        'Well, I guess they thought "WordRope" and "SentenceString" just didn\'t have the same ring to it!'
    )
    + AIMessage(
        "Why, he's probably chasing after the last cup of coffee in the office!"
    )
)

merged = merge_message_runs(messages)
print("\n\n".join([repr(x) for x in merged]))
```


## 체이닝

`merge_message_runs`는 위와 같이 명령형으로 또는 선언형으로 사용할 수 있어, 체인에서 다른 구성 요소와 쉽게 조합할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to merge consecutive messages of the same type"}]-->
# pip install -U langchain-anthropic
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-3-sonnet-20240229", temperature=0)
# Notice we don't pass in messages. This creates
# a RunnableLambda that takes messages as input
merger = merge_message_runs()
chain = merger | llm
chain.invoke(messages)
```


```output
AIMessage(content=[], response_metadata={'id': 'msg_01D6R8Naum57q8qBau9vLBUX', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 84, 'output_tokens': 3}}, id='run-ac0c465b-b54f-4b8b-9295-e5951250d653-0', usage_metadata={'input_tokens': 84, 'output_tokens': 3, 'total_tokens': 87})
```


LangSmith 추적을 보면 메시지가 모델에 전달되기 전에 병합되는 것을 볼 수 있습니다: https://smith.langchain.com/public/ab558677-cac9-4c59-9066-1ecce5bcd87c/r

병합만 살펴보면, 모든 Runnable처럼 호출할 수 있는 Runnable 객체임을 알 수 있습니다:

```python
merger.invoke(messages)
```


```output
[SystemMessage(content="you're a good assistant.\nyou always respond with a joke."),
 HumanMessage(content=[{'type': 'text', 'text': "i wonder why it's called langchain"}, 'and who is harrison chasing anyways']),
 AIMessage(content='Well, I guess they thought "WordRope" and "SentenceString" just didn\'t have the same ring to it!\nWhy, he\'s probably chasing after the last cup of coffee in the office!')]
```


## API 참조

모든 인수에 대한 완전한 설명은 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.merge_message_runs.html