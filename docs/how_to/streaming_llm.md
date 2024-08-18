---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/streaming_llm.ipynb
description: LLM에서 응답을 스트리밍하는 방법과 기본 구현 및 토큰별 스트리밍 지원 통합에 대한 설명을 제공합니다.
---

# LLM에서 응답 스트리밍하는 방법

모든 `LLM`은 [Runnable 인터페이스](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable)를 구현하며, 여기에는 표준 실행 가능한 메서드(즉, `ainvoke`, `batch`, `abatch`, `stream`, `astream`, `astream_events`)의 **기본** 구현이 포함됩니다.

**기본** 스트리밍 구현은 단일 값을 생성하는 `Iterator`(비동기 스트리밍의 경우 `AsyncIterator`)를 제공합니다: 기본 채팅 모델 제공자의 최종 출력입니다.

출력을 토큰 단위로 스트리밍할 수 있는 능력은 제공자가 적절한 스트리밍 지원을 구현했는지에 따라 달라집니다.

어떤 [통합이 토큰 단위 스트리밍을 지원하는지 여기에서 확인하세요](/docs/integrations/llms/).

:::note

**기본** 구현은 토큰 단위 스트리밍을 지원하지 않지만, 동일한 표준 인터페이스를 지원하므로 모델을 다른 모델로 교체할 수 있도록 보장합니다.

:::

## 동기 스트림

아래에서는 토큰 간 구분 기호를 시각화하는 데 도움이 되는 `|`를 사용합니다.

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to stream responses from an LLM"}]-->
from langchain_openai import OpenAI

llm = OpenAI(model="gpt-3.5-turbo-instruct", temperature=0, max_tokens=512)
for chunk in llm.stream("Write me a 1 verse song about sparkling water."):
    print(chunk, end="|", flush=True)
```

```output


|Spark|ling| water|,| oh| so clear|
|Bubbles dancing|,| without| fear|
|Refreshing| taste|,| a| pure| delight|
|Spark|ling| water|,| my| thirst|'s| delight||
```

## 비동기 스트리밍

`astream`을 사용하여 비동기 설정에서 스트리밍하는 방법을 살펴보겠습니다.

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to stream responses from an LLM"}]-->
from langchain_openai import OpenAI

llm = OpenAI(model="gpt-3.5-turbo-instruct", temperature=0, max_tokens=512)
async for chunk in llm.astream("Write me a 1 verse song about sparkling water."):
    print(chunk, end="|", flush=True)
```

```output


|Spark|ling| water|,| oh| so clear|
|Bubbles dancing|,| without| fear|
|Refreshing| taste|,| a| pure| delight|
|Spark|ling| water|,| my| thirst|'s| delight||
```

## 비동기 이벤트 스트리밍

LLM은 또한 표준 [astream 이벤트](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.astream_events) 메서드를 지원합니다.

:::tip

`astream_events`는 여러 단계를 포함하는 더 큰 LLM 애플리케이션에서 스트리밍을 구현할 때 가장 유용합니다(예: `agent`가 포함된 애플리케이션).
:::

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to stream responses from an LLM"}]-->
from langchain_openai import OpenAI

llm = OpenAI(model="gpt-3.5-turbo-instruct", temperature=0, max_tokens=512)

idx = 0

async for event in llm.astream_events(
    "Write me a 1 verse song about goldfish on the moon", version="v1"
):
    idx += 1
    if idx >= 5:  # Truncate the output
        print("...Truncated")
        break
    print(event)
```