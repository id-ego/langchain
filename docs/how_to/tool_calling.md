---
canonical: https://python.langchain.com/v0.2/docs/how_to/tool_calling/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_calling.ipynb
keywords:
- tool calling
- tool call
---

# How to use chat models to call tools

:::info Prerequisites

This guide assumes familiarity with the following concepts:

- [Chat models](/docs/concepts/#chat-models)
- [Tool calling](/docs/concepts/#functiontool-calling)
- [Tools](/docs/concepts/#tools)
- [Output parsers](/docs/concepts/#output-parsers)
:::

[Tool calling](/docs/concepts/#functiontool-calling) allows a chat model to respond to a given prompt by "calling a tool".

Remember, while the name "tool calling" implies that the model is directly performing some action, this is actually not the case! The model only generates the arguments to a tool, and actually running the tool (or not) is up to the user.

Tool calling is a general technique that generates structured output from a model, and you can use it even when you don't intend to invoke any tools. An example use-case of that is [extraction from unstructured text](/docs/tutorials/extraction/).

![Diagram of calling a tool](/img/tool_call.png)

If you want to see how to use the model-generated tool call to actually run a tool [check out this guide](/docs/how_to/tool_results_pass_to_model/).

:::note Supported models

Tool calling is not universal, but is supported by many popular LLM providers. You can find a [list of all models that support tool calling here](/docs/integrations/chat/).

:::

LangChain implements standard interfaces for defining tools, passing them to LLMs, and representing tool calls.
This guide will cover how to bind tools to an LLM, then invoke the LLM to generate these arguments.

## Defining tool schemas

For a model to be able to call tools, we need to pass in tool schemas that describe what the tool does and what it's arguments are. Chat models that support tool calling features implement a `.bind_tools()` method for passing tool schemas to the model. Tool schemas can be passed in as Python functions (with typehints and docstrings), Pydantic models, TypedDict classes, or LangChain [Tool objects](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.BaseTool.html#langchain_core.tools.BaseTool). Subsequent invocations of the model will pass in these tool schemas along with the prompt.

### Python functions
Our tool schemas can be Python functions:

```python
# The function name, type hints, and docstring are all part of the tool
# schema that's passed to the model. Defining good, descriptive schemas
# is an extension of prompt engineering and is an important part of
# getting models to perform well.
def add(a: int, b: int) -> int:
    """Add two integers.

    Args:
        a: First integer
        b: Second integer
    """
    return a + b


def multiply(a: int, b: int) -> int:
    """Multiply two integers.

    Args:
        a: First integer
        b: Second integer
    """
    return a * b
```

### LangChain Tool

LangChain also implements a `@tool` decorator that allows for further control of the tool schema, such as tool names and argument descriptions. See the how-to guide [here](/docs/how_to/custom_tools/#creating-tools-from-functions) for details.

### Pydantic class

You can equivalently define the schemas without the accompanying functions using [Pydantic](https://docs.pydantic.dev):

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class add(BaseModel):
    """Add two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


class multiply(BaseModel):
    """Multiply two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")
```

### TypedDict class

:::info Requires `langchain-core>=0.2.25`
:::

Or using TypedDicts and annotations:

```python
from typing_extensions import Annotated, TypedDict


class add(TypedDict):
    """Add two integers."""

    # Annotations must have the type and can optionally include a default value and description (in that order).
    a: Annotated[int, ..., "First integer"]
    b: Annotated[int, ..., "Second integer"]


class multiply(BaseModel):
    """Multiply two integers."""

    a: Annotated[int, ..., "First integer"]
    b: Annotated[int, ..., "Second integer"]


tools = [add, multiply]
```

To actually bind those schemas to a chat model, we'll use the `.bind_tools()` method. This handles converting
the `add` and `multiply` schemas to the proper format for the model. The tool schema will then be passed it in each time the model is invoked.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
fireworksParams={`model="accounts/fireworks/models/firefunction-v1", temperature=0`}
/>

```python
llm_with_tools = llm.bind_tools(tools)

query = "What is 3 * 12?"

llm_with_tools.invoke(query)
```

```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_BwYJ4UgU5pRVCBOUmiu7NhF9', 'function': {'arguments': '{"a":3,"b":12}', 'name': 'multiply'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 80, 'total_tokens': 97}, 'model_name': 'gpt-4o-mini-2024-07-18', 'system_fingerprint': 'fp_ba606877f9', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-7f05e19e-4561-40e2-a2d0-8f4e28e9a00f-0', tool_calls=[{'name': 'multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_BwYJ4UgU5pRVCBOUmiu7NhF9', 'type': 'tool_call'}], usage_metadata={'input_tokens': 80, 'output_tokens': 17, 'total_tokens': 97})
```

As we can see our LLM generated arguments to a tool! You can look at the docs for [bind_tools()](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.BaseChatOpenAI.html#langchain_openai.chat_models.base.BaseChatOpenAI.bind_tools) to learn about all the ways to customize how your LLM selects tools, as well as [this guide on how to force the LLM to call a tool](/docs/how_to/tool_choice/) rather than letting it decide.

## Tool calls

If tool calls are included in a LLM response, they are attached to the corresponding
[message](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html#langchain_core.messages.ai.AIMessage)
or [message chunk](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html#langchain_core.messages.ai.AIMessageChunk)
as a list of [tool call](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolCall.html#langchain_core.messages.tool.ToolCall)
objects in the `.tool_calls` attribute.

Note that chat models can call multiple tools at once.

A `ToolCall` is a typed dict that includes a
tool name, dict of argument values, and (optionally) an identifier. Messages with no
tool calls default to an empty list for this attribute.

```python
query = "What is 3 * 12? Also, what is 11 + 49?"

llm_with_tools.invoke(query).tool_calls
```

```output
[{'name': 'multiply',
  'args': {'a': 3, 'b': 12},
  'id': 'call_rcdMie7E89Xx06lEKKxJyB5N',
  'type': 'tool_call'},
 {'name': 'add',
  'args': {'a': 11, 'b': 49},
  'id': 'call_nheGN8yfvSJsnIuGZaXihou3',
  'type': 'tool_call'}]
```

The `.tool_calls` attribute should contain valid tool calls. Note that on occasion,
model providers may output malformed tool calls (e.g., arguments that are not
valid JSON). When parsing fails in these cases, instances
of [InvalidToolCall](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.InvalidToolCall.html#langchain_core.messages.tool.InvalidToolCall)
are populated in the `.invalid_tool_calls` attribute. An `InvalidToolCall` can have
a name, string arguments, identifier, and error message.

## Parsing

If desired, [output parsers](/docs/how_to#output-parsers) can further process the output. For example, we can convert existing values populated on the `.tool_calls` to Pydantic objects using the
[PydanticToolsParser](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html):

```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "How to use chat models to call tools"}]-->
from langchain_core.output_parsers import PydanticToolsParser
from langchain_core.pydantic_v1 import BaseModel, Field


class add(BaseModel):
    """Add two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


class multiply(BaseModel):
    """Multiply two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


chain = llm_with_tools | PydanticToolsParser(tools=[add, multiply])
chain.invoke(query)
```

```output
[multiply(a=3, b=12), add(a=11, b=49)]
```

## Next steps

Now you've learned how to bind tool schemas to a chat model and have the model call the tool.

Next, check out this guide on actually using the tool by invoking the function and passing the results back to the model:

- Pass [tool results back to model](/docs/how_to/tool_results_pass_to_model)

You can also check out some more specific uses of tool calling:

- Getting [structured outputs](/docs/how_to/structured_output/) from models
- Few shot prompting [with tools](/docs/how_to/tools_few_shot/)
- Stream [tool calls](/docs/how_to/tool_streaming/)
- Pass [runtime values to tools](/docs/how_to/tool_runtime)