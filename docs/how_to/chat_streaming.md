---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chat_streaming.ipynb
description: 채팅 모델 응답을 스트리밍하는 방법에 대한 가이드로, 기본 실행 가능한 메서드와 토큰별 스트리밍 지원 여부를 설명합니다.
sidebar_position: 1.5
---

# 채팅 모델 응답 스트리밍 방법

모든 [채팅 모델](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.BaseChatModel.html)은 [Runnable 인터페이스](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable)를 구현하며, 여기에는 표준 실행 가능한 메서드(즉, `ainvoke`, `batch`, `abatch`, `stream`, `astream`, `astream_events`)의 **기본** 구현이 포함됩니다.

**기본** 스트리밍 구현은 단일 값을 생성하는 `Iterator`(비동기 스트리밍의 경우 `AsyncIterator`)를 제공합니다: 기본 채팅 모델 제공자의 최종 출력입니다.

:::tip

**기본** 구현은 토큰 단위 스트리밍을 지원하지 않지만, 동일한 표준 인터페이스를 지원하므로 모델을 다른 모델로 교체할 수 있도록 보장합니다.

:::

출력을 토큰 단위로 스트리밍할 수 있는 능력은 제공자가 적절한 스트리밍 지원을 구현했는지 여부에 따라 달라집니다.

어떤 [통합이 토큰 단위 스트리밍을 지원하는지 여기에서 확인하세요](/docs/integrations/chat/).

## 동기 스트리밍

아래에서는 토큰 사이의 구분 기호를 시각화하기 위해 `|`를 사용합니다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to stream chat model responses"}]-->
from langchain_anthropic.chat_models import ChatAnthropic

chat = ChatAnthropic(model="claude-3-haiku-20240307")
for chunk in chat.stream("Write me a 1 verse song about goldfish on the moon"):
    print(chunk.content, end="|", flush=True)
```

```output
Here| is| a| |1| |verse| song| about| gol|dfish| on| the| moon|:|

Floating| up| in| the| star|ry| night|,|
Fins| a|-|gl|im|mer| in| the| pale| moon|light|.|
Gol|dfish| swimming|,| peaceful| an|d free|,|
Se|ren|ely| |drif|ting| across| the| lunar| sea|.|
```

## 비동기 스트리밍

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to stream chat model responses"}]-->
from langchain_anthropic.chat_models import ChatAnthropic

chat = ChatAnthropic(model="claude-3-haiku-20240307")
async for chunk in chat.astream("Write me a 1 verse song about goldfish on the moon"):
    print(chunk.content, end="|", flush=True)
```

```output
Here| is| a| |1| |verse| song| about| gol|dfish| on| the| moon|:|

Floating| up| above| the| Earth|,|
Gol|dfish| swim| in| alien| m|irth|.|
In| their| bowl| of| lunar| dust|,|
Gl|it|tering| scales| reflect| the| trust|
Of| swimming| free| in| this| new| worl|d,|
Where| their| aqu|atic| dream|'s| unf|ur|le|d.|
```

## Astream 이벤트

채팅 모델은 또한 표준 [astream 이벤트](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.astream_events) 메서드를 지원합니다.

이 메서드는 여러 단계가 포함된 더 큰 LLM 애플리케이션에서 출력을 스트리밍하는 경우 유용합니다(예: 프롬프트, LLM 및 파서를 포함하는 LLM 체인). 

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to stream chat model responses"}]-->
from langchain_anthropic.chat_models import ChatAnthropic

chat = ChatAnthropic(model="claude-3-haiku-20240307")
idx = 0

async for event in chat.astream_events(
    "Write me a 1 verse song about goldfish on the moon", version="v1"
):
    idx += 1
    if idx >= 5:  # Truncate the output
        print("...Truncated")
        break
    print(event)
```

```output
{'event': 'on_chat_model_start', 'run_id': '08da631a-12a0-4f07-baee-fc9a175ad4ba', 'name': 'ChatAnthropic', 'tags': [], 'metadata': {}, 'data': {'input': 'Write me a 1 verse song about goldfish on the moon'}}
{'event': 'on_chat_model_stream', 'run_id': '08da631a-12a0-4f07-baee-fc9a175ad4ba', 'tags': [], 'metadata': {}, 'name': 'ChatAnthropic', 'data': {'chunk': AIMessageChunk(content='Here', id='run-08da631a-12a0-4f07-baee-fc9a175ad4ba')}}
{'event': 'on_chat_model_stream', 'run_id': '08da631a-12a0-4f07-baee-fc9a175ad4ba', 'tags': [], 'metadata': {}, 'name': 'ChatAnthropic', 'data': {'chunk': AIMessageChunk(content="'s", id='run-08da631a-12a0-4f07-baee-fc9a175ad4ba')}}
{'event': 'on_chat_model_stream', 'run_id': '08da631a-12a0-4f07-baee-fc9a175ad4ba', 'tags': [], 'metadata': {}, 'name': 'ChatAnthropic', 'data': {'chunk': AIMessageChunk(content=' a', id='run-08da631a-12a0-4f07-baee-fc9a175ad4ba')}}
...Truncated
```