---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_streaming.ipynb
description: 도구 호출이 스트리밍되는 맥락에서 메시지 청크와 도구 호출 청크 객체의 사용법을 설명합니다.
---

# 도구 호출 스트리밍 방법

도구가 스트리밍 컨텍스트에서 호출될 때,
[메시지 청크](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html#langchain_core.messages.ai.AIMessageChunk)
는 `.tool_call_chunks` 속성을 통해 목록에 [도구 호출 청크](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolCallChunk.html#langchain_core.messages.tool.ToolCallChunk) 객체로 채워집니다. `ToolCallChunk`는 도구 `name`, `args`, 및 `id`에 대한 선택적 문자열 필드를 포함하고, 청크를 함께 결합하는 데 사용할 수 있는 선택적 정수 필드 `index`를 포함합니다. 필드는 선택적입니다. 왜냐하면 도구 호출의 일부가 서로 다른 청크에 걸쳐 스트리밍될 수 있기 때문입니다 (예: 인수의 부분 문자열을 포함하는 청크는 도구 이름 및 id에 대해 null 값을 가질 수 있습니다).

메시지 청크는 부모 메시지 클래스에서 상속되므로,
도구 호출 청크가 있는 [AIMessageChunk](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html#langchain_core.messages.ai.AIMessageChunk)도 `.tool_calls` 및 `.invalid_tool_calls` 필드를 포함합니다.
이 필드는 메시지의 도구 호출 청크에서 최선을 다해 구문 분석됩니다.

모든 제공자가 현재 도구 호출에 대한 스트리밍을 지원하는 것은 아닙니다. 시작하기 전에 도구와 모델을 정의해 봅시다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to stream tool calls"}]-->
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
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to stream tool calls"}]-->
import os
from getpass import getpass

from langchain_openai import ChatOpenAI

os.environ["OPENAI_API_KEY"] = getpass()

llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
llm_with_tools = llm.bind_tools(tools)
```


이제 쿼리를 정의하고 출력을 스트리밍해 봅시다:

```python
query = "What is 3 * 12? Also, what is 11 + 49?"

async for chunk in llm_with_tools.astream(query):
    print(chunk.tool_call_chunks)
```

```output
[]
[{'name': 'Multiply', 'args': '', 'id': 'call_3aQwTP9CYlFxwOvQZPHDu6wL', 'index': 0}]
[{'name': None, 'args': '{"a"', 'id': None, 'index': 0}]
[{'name': None, 'args': ': 3, ', 'id': None, 'index': 0}]
[{'name': None, 'args': '"b": 1', 'id': None, 'index': 0}]
[{'name': None, 'args': '2}', 'id': None, 'index': 0}]
[{'name': 'Add', 'args': '', 'id': 'call_SQUoSsJz2p9Kx2x73GOgN1ja', 'index': 1}]
[{'name': None, 'args': '{"a"', 'id': None, 'index': 1}]
[{'name': None, 'args': ': 11,', 'id': None, 'index': 1}]
[{'name': None, 'args': ' "b": ', 'id': None, 'index': 1}]
[{'name': None, 'args': '49}', 'id': None, 'index': 1}]
[]
```

메시지 청크를 추가하면 해당 도구 호출 청크가 병합됩니다. 이것이 LangChain의 다양한 [도구 출력 파서](/docs/how_to/output_parser_structured)가 스트리밍을 지원하는 원리입니다.

예를 들어, 아래에서 도구 호출 청크를 축적합니다:

```python
first = True
async for chunk in llm_with_tools.astream(query):
    if first:
        gathered = chunk
        first = False
    else:
        gathered = gathered + chunk

    print(gathered.tool_call_chunks)
```

```output
[]
[{'name': 'Multiply', 'args': '', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}]
[{'name': 'Multiply', 'args': '{"a"', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}]
[{'name': 'Multiply', 'args': '{"a": 3, ', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 1', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}, {'name': 'Add', 'args': '', 'id': 'call_b4iMiB3chGNGqbt5SjqqD2Wh', 'index': 1}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}, {'name': 'Add', 'args': '{"a"', 'id': 'call_b4iMiB3chGNGqbt5SjqqD2Wh', 'index': 1}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}, {'name': 'Add', 'args': '{"a": 11,', 'id': 'call_b4iMiB3chGNGqbt5SjqqD2Wh', 'index': 1}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}, {'name': 'Add', 'args': '{"a": 11, "b": ', 'id': 'call_b4iMiB3chGNGqbt5SjqqD2Wh', 'index': 1}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}, {'name': 'Add', 'args': '{"a": 11, "b": 49}', 'id': 'call_b4iMiB3chGNGqbt5SjqqD2Wh', 'index': 1}]
[{'name': 'Multiply', 'args': '{"a": 3, "b": 12}', 'id': 'call_AkL3dVeCjjiqvjv8ckLxL3gP', 'index': 0}, {'name': 'Add', 'args': '{"a": 11, "b": 49}', 'id': 'call_b4iMiB3chGNGqbt5SjqqD2Wh', 'index': 1}]
```


```python
print(type(gathered.tool_call_chunks[0]["args"]))
```

```output
<class 'str'>
```

아래에서는 부분 구문 분석을 보여주기 위해 도구 호출을 축적합니다:

```python
first = True
async for chunk in llm_with_tools.astream(query):
    if first:
        gathered = chunk
        first = False
    else:
        gathered = gathered + chunk

    print(gathered.tool_calls)
```

```output
[]
[]
[{'name': 'Multiply', 'args': {}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}]
[{'name': 'Multiply', 'args': {'a': 3}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 1}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}, {'name': 'Add', 'args': {}, 'id': 'call_54Hx3DGjZitFlEjgMe1DYonh'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}, {'name': 'Add', 'args': {'a': 11}, 'id': 'call_54Hx3DGjZitFlEjgMe1DYonh'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}, {'name': 'Add', 'args': {'a': 11}, 'id': 'call_54Hx3DGjZitFlEjgMe1DYonh'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}, {'name': 'Add', 'args': {'a': 11, 'b': 49}, 'id': 'call_54Hx3DGjZitFlEjgMe1DYonh'}]
[{'name': 'Multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_4p0D4tHVXSiae9Mu0e8jlI1m'}, {'name': 'Add', 'args': {'a': 11, 'b': 49}, 'id': 'call_54Hx3DGjZitFlEjgMe1DYonh'}]
```


```python
print(type(gathered.tool_calls[0]["args"]))
```

```output
<class 'dict'>
```