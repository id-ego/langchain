---
canonical: https://python.langchain.com/v0.2/docs/how_to/tool_choice/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_choice.ipynb
---

# How to force models to call a tool

:::info Prerequisites

This guide assumes familiarity with the following concepts:
- [Chat models](/docs/concepts/#chat-models)
- [LangChain Tools](/docs/concepts/#tools)
- [How to use a model to call tools](/docs/how_to/tool_calling)
:::

In order to force our LLM to spelect a specific tool, we can use the `tool_choice` parameter to ensure certain behavior. First, let's define our model and tools:

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

For example, we can force our tool to call the multiply tool by using the following code:

```python
llm_forced_to_multiply = llm.bind_tools(tools, tool_choice="Multiply")
llm_forced_to_multiply.invoke("what is 2 + 4")
```

```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_9cViskmLvPnHjXk9tbVla5HA', 'function': {'arguments': '{"a":2,"b":4}', 'name': 'Multiply'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 103, 'total_tokens': 112}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-095b827e-2bdd-43bb-8897-c843f4504883-0', tool_calls=[{'name': 'Multiply', 'args': {'a': 2, 'b': 4}, 'id': 'call_9cViskmLvPnHjXk9tbVla5HA'}], usage_metadata={'input_tokens': 103, 'output_tokens': 9, 'total_tokens': 112})
```

Even if we pass it something that doesn't require multiplcation - it will still call the tool!

We can also just force our tool to select at least one of our tools by passing in the "any" (or "required" which is OpenAI specific) keyword to the `tool_choice` parameter.

```python
llm_forced_to_use_tool = llm.bind_tools(tools, tool_choice="any")
llm_forced_to_use_tool.invoke("What day is today?")
```

```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_mCSiJntCwHJUBfaHZVUB2D8W', 'function': {'arguments': '{"a":1,"b":2}', 'name': 'Add'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 15, 'prompt_tokens': 94, 'total_tokens': 109}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-28f75260-9900-4bed-8cd3-f1579abb65e5-0', tool_calls=[{'name': 'Add', 'args': {'a': 1, 'b': 2}, 'id': 'call_mCSiJntCwHJUBfaHZVUB2D8W'}], usage_metadata={'input_tokens': 94, 'output_tokens': 15, 'total_tokens': 109})
```