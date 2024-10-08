---
canonical: https://python.langchain.com/v0.2/docs/how_to/tool_streaming/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_streaming.ipynb
---

# How to stream tool calls

When tools are called in a streaming context,
[message chunks](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html#langchain_core.messages.ai.AIMessageChunk)
will be populated with [tool call chunk](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolCallChunk.html#langchain_core.messages.tool.ToolCallChunk)
objects in a list via the `.tool_call_chunks` attribute. A `ToolCallChunk` includes
optional string fields for the tool `name`, `args`, and `id`, and includes an optional
integer field `index` that can be used to join chunks together. Fields are optional
because portions of a tool call may be streamed across different chunks (e.g., a chunk
that includes a substring of the arguments may have null values for the tool name and id).

Because message chunks inherit from their parent message class, an
[AIMessageChunk](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html#langchain_core.messages.ai.AIMessageChunk)
with tool call chunks will also include `.tool_calls` and `.invalid_tool_calls` fields.
These fields are parsed best-effort from the message's tool call chunks.

Note that not all providers currently support streaming for tool calls. Before we start let's define our tools and our model.

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

Now let's define our query and stream our output:

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
Note that adding message chunks will merge their corresponding tool call chunks. This is the principle by which LangChain's various [tool output parsers](/docs/how_to/output_parser_structured) support streaming.

For example, below we accumulate tool call chunks:

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
And below we accumulate tool calls to demonstrate partial parsing:

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