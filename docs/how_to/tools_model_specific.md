---
canonical: https://python.langchain.com/v0.2/docs/how_to/tools_model_specific/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_model_specific.ipynb
---

# How to bind model-specific tools

Providers adopt different conventions for formatting tool schemas.
For instance, OpenAI uses a format like this:

- `type`: The type of the tool. At the time of writing, this is always `"function"`.
- `function`: An object containing tool parameters.
- `function.name`: The name of the schema to output.
- `function.description`: A high level description of the schema to output.
- `function.parameters`: The nested details of the schema you want to extract, formatted as a [JSON schema](https://json-schema.org/) dict.

We can bind this model-specific format directly to the model as well if preferred. Here's an example:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to bind model-specific tools"}]-->
from langchain_openai import ChatOpenAI

model = ChatOpenAI()

model_with_tools = model.bind(
    tools=[
        {
            "type": "function",
            "function": {
                "name": "multiply",
                "description": "Multiply two integers together.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "a": {"type": "number", "description": "First integer"},
                        "b": {"type": "number", "description": "Second integer"},
                    },
                    "required": ["a", "b"],
                },
            },
        }
    ]
)

model_with_tools.invoke("Whats 119 times 8?")
```

```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_mn4ELw1NbuE0DFYhIeK0GrPe', 'function': {'arguments': '{"a":119,"b":8}', 'name': 'multiply'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 62, 'total_tokens': 79}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-353e8a9a-7125-4f94-8c68-4f3da4c21120-0', tool_calls=[{'name': 'multiply', 'args': {'a': 119, 'b': 8}, 'id': 'call_mn4ELw1NbuE0DFYhIeK0GrPe'}])
```

This is functionally equivalent to the `bind_tools()` method.