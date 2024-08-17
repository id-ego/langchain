---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/together/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/together.ipynb
sidebar_label: Together
---

# ChatTogether

This page will help you get started with Together AI [chat models](../../concepts.mdx#chat-models). For detailed documentation of all ChatTogether features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html).

[Together AI](https://www.together.ai/) offers an API to query [50+ leading open-source models](https://docs.together.ai/docs/chat-models)

## Overview
### Integration details

| Class | Package | Local | Serializable | [JS support](https://js.langchain.com/v0.2/docs/integrations/chat/togetherai) | Package downloads | Package latest |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatTogether](https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html) | [langchain-together](https://api.python.langchain.com/en/latest/together_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-together?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-together?style=flat-square&label=%20) |

### Model features
| [Tool calling](../../how_to/tool_calling.md) | [Structured output](../../how_to/structured_output.md) | JSON mode | [Image input](../../how_to/multimodal_inputs.md) | Audio input | Video input | [Token-level streaming](../../how_to/chat_streaming.md) | Native async | [Token usage](../../how_to/chat_token_usage_tracking.md) | [Logprobs](../../how_to/logprobs.md) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | 

## Setup

To access Together models you'll need to create a/an Together account, get an API key, and install the `langchain-together` integration package.

### Credentials

Head to [this page](https://api.together.ai) to sign up to Together and generate an API key. Once you've done this set the TOGETHER_API_KEY environment variable:

```python
import getpass
import os

if "TOGETHER_API_KEY" not in os.environ:
    os.environ["TOGETHER_API_KEY"] = getpass.getpass("Enter your Together API key: ")
```

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

The LangChain Together integration lives in the `langchain-together` package:

```python
%pip install -qU langchain-together
```

## Instantiation

Now we can instantiate our model object and generate chat completions:

```python
<!--IMPORTS:[{"imported": "ChatTogether", "source": "langchain_together", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html", "title": "ChatTogether"}]-->
from langchain_together import ChatTogether

llm = ChatTogether(
    model="meta-llama/Llama-3-70b-chat-hf",
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
    # other params...
)
```

## Invocation

```python
messages = [
    (
        "system",
        "You are a helpful assistant that translates English to French. Translate the user sentence.",
    ),
    ("human", "I love programming."),
]
ai_msg = llm.invoke(messages)
ai_msg
```

```output
AIMessage(content="J'adore la programmation.", response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 35, 'total_tokens': 44}, 'model_name': 'meta-llama/Llama-3-70b-chat-hf', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-eabcbe33-cdd8-45b8-ab0b-f90b6e7dfad8-0', usage_metadata={'input_tokens': 35, 'output_tokens': 9, 'total_tokens': 44})
```

```python
print(ai_msg.content)
```
```output
J'adore la programmation.
```
## Chaining

We can [chain](../../how_to/sequence.md) our model with a prompt template like so:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatTogether"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant that translates {input_language} to {output_language}.",
        ),
        ("human", "{input}"),
    ]
)

chain = prompt | llm
chain.invoke(
    {
        "input_language": "English",
        "output_language": "German",
        "input": "I love programming.",
    }
)
```

```output
AIMessage(content='Ich liebe das Programmieren.', response_metadata={'token_usage': {'completion_tokens': 7, 'prompt_tokens': 30, 'total_tokens': 37}, 'model_name': 'meta-llama/Llama-3-70b-chat-hf', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-a249aa24-ee31-46ba-9bf9-f4eb135b0a95-0', usage_metadata={'input_tokens': 30, 'output_tokens': 7, 'total_tokens': 37})
```

## API reference

For detailed documentation of all ChatTogether features and configurations head to the API reference: https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html

## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)