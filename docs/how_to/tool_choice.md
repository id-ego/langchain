---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_choice.ipynb
description: 모델이 특정 도구를 호출하도록 강제하는 방법을 설명하는 가이드입니다. `tool_choice` 매개변수를 활용한 예시를 제공합니다.
---

# 도구를 호출하도록 모델을 강제하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [LangChain 도구](/docs/concepts/#tools)
- [모델을 사용하여 도구를 호출하는 방법](/docs/how_to/tool_calling)
:::

특정 도구를 호출하도록 LLM을 강제하기 위해 `tool_choice` 매개변수를 사용하여 특정 동작을 보장할 수 있습니다. 먼저, 모델과 도구를 정의해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to force models to call a tool"}]-->
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


예를 들어, 다음 코드를 사용하여 도구가 곱셈 도구를 호출하도록 강제할 수 있습니다:

```python
llm_forced_to_multiply = llm.bind_tools(tools, tool_choice="Multiply")
llm_forced_to_multiply.invoke("what is 2 + 4")
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_9cViskmLvPnHjXk9tbVla5HA', 'function': {'arguments': '{"a":2,"b":4}', 'name': 'Multiply'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 103, 'total_tokens': 112}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-095b827e-2bdd-43bb-8897-c843f4504883-0', tool_calls=[{'name': 'Multiply', 'args': {'a': 2, 'b': 4}, 'id': 'call_9cViskmLvPnHjXk9tbVla5HA'}], usage_metadata={'input_tokens': 103, 'output_tokens': 9, 'total_tokens': 112})
```


곱셈이 필요하지 않은 것을 전달하더라도 - 여전히 도구를 호출할 것입니다!

또한 `tool_choice` 매개변수에 "any" (또는 OpenAI 전용인 "required") 키워드를 전달하여 도구가 최소한 하나의 도구를 선택하도록 강제할 수 있습니다.

```python
llm_forced_to_use_tool = llm.bind_tools(tools, tool_choice="any")
llm_forced_to_use_tool.invoke("What day is today?")
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_mCSiJntCwHJUBfaHZVUB2D8W', 'function': {'arguments': '{"a":1,"b":2}', 'name': 'Add'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 15, 'prompt_tokens': 94, 'total_tokens': 109}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-28f75260-9900-4bed-8cd3-f1579abb65e5-0', tool_calls=[{'name': 'Add', 'args': {'a': 1, 'b': 2}, 'id': 'call_mCSiJntCwHJUBfaHZVUB2D8W'}], usage_metadata={'input_tokens': 94, 'output_tokens': 15, 'total_tokens': 109})
```