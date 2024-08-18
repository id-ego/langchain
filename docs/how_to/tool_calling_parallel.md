---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_calling_parallel.ipynb
description: OpenAI의 도구 호출에서 병렬 호출을 비활성화하는 방법을 설명하며, 단일 도구 호출을 설정하는 방법을 안내합니다.
---

# 병렬 도구 호출 비활성화 방법

:::info OpenAI 전용

이 API는 현재 OpenAI에서만 지원됩니다.

:::

OpenAI 도구 호출은 기본적으로 병렬로 도구 호출을 수행합니다. 즉, "도쿄, 뉴욕, 시카고의 날씨는 어때?"와 같은 질문을 하면 날씨를 가져오는 도구가 있을 경우, 도구를 3번 병렬로 호출합니다. `parallel_tool_call` 매개변수를 사용하여 단일 도구를 한 번만 호출하도록 강제할 수 있습니다.

먼저 도구와 모델을 설정해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to disable parallel tool calling"}]-->
from langchain_core.tools import tool


@tool
def add(a: int, b: int) -> int:
    """Adds a and b."""
    return a + b


@tool
def multiply(a: int, b: int) -> int:
    """Multiplies a and b."""
    return a * b


tools = [add, multiply]
```


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to disable parallel tool calling"}]-->
import os
from getpass import getpass

from langchain_openai import ChatOpenAI

os.environ["OPENAI_API_KEY"] = getpass()

llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
```


이제 병렬 도구 호출 비활성화가 어떻게 작동하는지 간단한 예를 보여드리겠습니다:

```python
llm_with_tools = llm.bind_tools(tools, parallel_tool_calls=False)
llm_with_tools.invoke("Please call the first tool two times").tool_calls
```


```output
[{'name': 'add',
  'args': {'a': 2, 'b': 2},
  'id': 'call_Hh4JOTCDM85Sm9Pr84VKrWu5'}]
```


보시다시피, 모델에 도구를 두 번 호출하라고 명시적으로 지시했음에도 불구하고, 병렬 도구 호출을 비활성화함으로써 모델은 단 한 번만 호출하도록 제한되었습니다.