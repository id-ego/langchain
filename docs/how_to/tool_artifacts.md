---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_artifacts.ipynb
description: 도구의 실행 결과에서 아티팩트를 반환하는 방법에 대한 가이드로, 모델에 노출하지 않고 메타데이터를 전달하는 방법을 설명합니다.
---

# 도구에서 아티팩트를 반환하는 방법

:::info 전제 조건
이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [ToolMessage](/docs/concepts/#toolmessage)
- [Tools](/docs/concepts/#tools)
- [Function/tool calling](/docs/concepts/#functiontool-calling)

:::

도구는 모델에 의해 호출될 수 있는 유틸리티이며, 그 출력은 모델에 피드백되도록 설계되었습니다. 그러나 때때로 도구 실행의 아티팩트가 체인이나 에이전트의 하위 구성 요소에 접근 가능하도록 만들고 싶지만, 모델 자체에 노출하고 싶지 않은 경우가 있습니다. 예를 들어 도구가 사용자 정의 객체, 데이터프레임 또는 이미지를 반환하는 경우, 실제 출력을 모델에 전달하지 않고 이 출력에 대한 메타데이터를 모델에 전달하고 싶을 수 있습니다. 동시에, 이 전체 출력을 다른 곳, 예를 들어 하위 도구에서 접근할 수 있어야 할 수도 있습니다.

Tool 및 [ToolMessage](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html) 인터페이스는 모델을 위한 도구 출력의 부분(이는 ToolMessage.content)과 모델 외부에서 사용하기 위한 부분(ToolMessage.artifact)을 구분할 수 있게 해줍니다.

:::info `langchain-core >= 0.2.19` 필요

이 기능은 `langchain-core == 0.2.19`에서 추가되었습니다. 패키지가 최신인지 확인하십시오.

:::

## 도구 정의하기

도구가 메시지 내용과 다른 아티팩트를 구분하도록 하려면, 도구를 정의할 때 `response_format="content_and_artifact"`를 지정하고 (content, artifact)의 튜플을 반환해야 합니다:

```python
%pip install -qU "langchain-core>=0.2.19"
```


```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to return artifacts from a tool"}]-->
import random
from typing import List, Tuple

from langchain_core.tools import tool


@tool(response_format="content_and_artifact")
def generate_random_ints(min: int, max: int, size: int) -> Tuple[str, List[int]]:
    """Generate size random ints in the range [min, max]."""
    array = [random.randint(min, max) for _ in range(size)]
    content = f"Successfully generated array of {size} random ints in [{min}, {max}]."
    return content, array
```


## ToolCall로 도구 호출하기

도구 인수만으로 도구를 직접 호출하면, 도구 출력의 내용 부분만 반환된다는 것을 알 수 있습니다:

```python
generate_random_ints.invoke({"min": 0, "max": 9, "size": 10})
```


```output
'Successfully generated array of 10 random ints in [0, 9].'
```


```output
Failed to batch ingest runs: LangSmithRateLimitError('Rate limit exceeded for https://api.smith.langchain.com/runs/batch. HTTPError(\'429 Client Error: Too Many Requests for url: https://api.smith.langchain.com/runs/batch\', \'{"detail":"Monthly unique traces usage limit exceeded"}\')')
```

내용과 아티팩트를 모두 얻으려면, ToolCall로 모델을 호출해야 합니다(이는 "name", "args", "id" 및 "type" 키가 있는 사전입니다). 이 사전은 ToolMessage를 생성하는 데 필요한 추가 정보를 포함합니다, 예를 들어 도구 호출 ID:

```python
generate_random_ints.invoke(
    {
        "name": "generate_random_ints",
        "args": {"min": 0, "max": 9, "size": 10},
        "id": "123",  # required
        "type": "tool_call",  # required
    }
)
```


```output
ToolMessage(content='Successfully generated array of 10 random ints in [0, 9].', name='generate_random_ints', tool_call_id='123', artifact=[2, 8, 0, 6, 0, 0, 1, 5, 0, 0])
```


## 모델과 함께 사용하기

[tool-calling model](/docs/how_to/tool_calling/)을 사용하면, 모델을 쉽게 사용하여 도구를 호출하고 ToolMessages를 생성할 수 있습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
/>

```python
llm_with_tools = llm.bind_tools([generate_random_ints])

ai_msg = llm_with_tools.invoke("generate 6 positive ints less than 25")
ai_msg.tool_calls
```


```output
[{'name': 'generate_random_ints',
  'args': {'min': 1, 'max': 24, 'size': 6},
  'id': 'toolu_01EtALY3Wz1DVYhv1TLvZGvE',
  'type': 'tool_call'}]
```


```python
generate_random_ints.invoke(ai_msg.tool_calls[0])
```


```output
ToolMessage(content='Successfully generated array of 6 random ints in [1, 24].', name='generate_random_ints', tool_call_id='toolu_01EtALY3Wz1DVYhv1TLvZGvE', artifact=[2, 20, 23, 8, 1, 15])
```


도구 호출 인수만 전달하면, 내용만 반환됩니다:

```python
generate_random_ints.invoke(ai_msg.tool_calls[0]["args"])
```


```output
'Successfully generated array of 6 random ints in [1, 24].'
```


체인을 선언적으로 생성하고 싶다면, 다음과 같이 할 수 있습니다:

```python
from operator import attrgetter

chain = llm_with_tools | attrgetter("tool_calls") | generate_random_ints.map()

chain.invoke("give me a random number between 1 and 5")
```


```output
[ToolMessage(content='Successfully generated array of 1 random ints in [1, 5].', name='generate_random_ints', tool_call_id='toolu_01FwYhnkwDPJPbKdGq4ng6uD', artifact=[5])]
```


## BaseTool 클래스에서 생성하기

함수를 `@tool`로 장식하는 대신 BaseTool 객체를 직접 생성하고 싶다면, 다음과 같이 할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "BaseTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.BaseTool.html", "title": "How to return artifacts from a tool"}]-->
from langchain_core.tools import BaseTool


class GenerateRandomFloats(BaseTool):
    name: str = "generate_random_floats"
    description: str = "Generate size random floats in the range [min, max]."
    response_format: str = "content_and_artifact"

    ndigits: int = 2

    def _run(self, min: float, max: float, size: int) -> Tuple[str, List[float]]:
        range_ = max - min
        array = [
            round(min + (range_ * random.random()), ndigits=self.ndigits)
            for _ in range(size)
        ]
        content = f"Generated {size} floats in [{min}, {max}], rounded to {self.ndigits} decimals."
        return content, array

    # Optionally define an equivalent async method

    # async def _arun(self, min: float, max: float, size: int) -> Tuple[str, List[float]]:
    #     ...
```


```python
rand_gen = GenerateRandomFloats(ndigits=4)
rand_gen.invoke({"min": 0.1, "max": 3.3333, "size": 3})
```


```output
'Generated 3 floats in [0.1, 3.3333], rounded to 4 decimals.'
```


```python
rand_gen.invoke(
    {
        "name": "generate_random_floats",
        "args": {"min": 0.1, "max": 3.3333, "size": 3},
        "id": "123",
        "type": "tool_call",
    }
)
```


```output
ToolMessage(content='Generated 3 floats in [0.1, 3.3333], rounded to 4 decimals.', name='generate_random_floats', tool_call_id='123', artifact=[1.5789, 2.464, 2.2719])
```