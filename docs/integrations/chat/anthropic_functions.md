---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/anthropic_functions/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/anthropic_functions.ipynb
sidebar_class_name: hidden
---

# [Deprecated] Experimental Anthropic Tools Wrapper

::: {.callout-warning}

The Anthropic API officially supports tool-calling so this workaround is no longer needed. Please use [ChatAnthropic](/docs/integrations/chat/anthropic) with `langchain-anthropic>=0.1.5`.

:::

This notebook shows how to use an experimental wrapper around Anthropic that gives it tool calling and structured output capabilities. It follows Anthropic's guide [here](https://docs.anthropic.com/claude/docs/functions-external-tools)

The wrapper is available from the `langchain-anthropic` package, and it also requires the optional dependency `defusedxml` for parsing XML output from the llm.

Note: this is a beta feature that will be replaced by Anthropic's formal implementation of tool calling, but it is useful for testing and experimentation in the meantime.


```python
<!--IMPORTS:[{"imported": "ChatAnthropicTools", "source": "langchain_anthropic.experimental", "docs": "https://api.python.langchain.com/en/latest/experimental/langchain_anthropic.experimental.ChatAnthropicTools.html", "title": "[Deprecated] Experimental Anthropic Tools Wrapper"}]-->
%pip install -qU langchain-anthropic defusedxml
from langchain_anthropic.experimental import ChatAnthropicTools
```

## Tool Binding

`ChatAnthropicTools` exposes a `bind_tools` method that allows you to pass in Pydantic models or BaseTools to the llm.


```python
from langchain_core.pydantic_v1 import BaseModel


class Person(BaseModel):
    name: str
    age: int


model = ChatAnthropicTools(model="claude-3-opus-20240229").bind_tools(tools=[Person])
model.invoke("I am a 27 year old named Erick")
```



```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'function': {'name': 'Person', 'arguments': '{"name": "Erick", "age": "27"}'}, 'type': 'function'}]})
```


## Structured Output

`ChatAnthropicTools` also implements the [`with_structured_output` spec](/docs/how_to/structured_output) for extracting values. Note: this may not be as stable as with models that explicitly offer tool calling.


```python
chain = ChatAnthropicTools(model="claude-3-opus-20240229").with_structured_output(
    Person
)
chain.invoke("I am a 27 year old named Erick")
```



```output
Person(name='Erick', age=27)
```



## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)