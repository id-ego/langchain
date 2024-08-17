---
canonical: https://python.langchain.com/v0.2/docs/how_to/tool_calling_parallel/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_calling_parallel.ipynb
---

# How to disable parallel tool calling

:::info OpenAI-specific

This API is currently only supported by OpenAI.

:::

OpenAI tool calling performs tool calling in parallel by default. That means that if we ask a question like "What is the weather in Tokyo, New York, and Chicago?" and we have a tool for getting the weather, it will call the tool 3 times in parallel. We can force it to call only a single tool once by using the `parallel_tool_call` parameter.

First let's set up our tools and model:

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

Now let's show a quick example of how disabling parallel tool calls work:

```python
llm_with_tools = llm.bind_tools(tools, parallel_tool_calls=False)
llm_with_tools.invoke("Please call the first tool two times").tool_calls
```

```output
[{'name': 'add',
  'args': {'a': 2, 'b': 2},
  'id': 'call_Hh4JOTCDM85Sm9Pr84VKrWu5'}]
```

As we can see, even though we explicitly told the model to call a tool twice, by disabling parallel tool calls the model was constrained to only calling one.