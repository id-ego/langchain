---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/vllm/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/vllm.ipynb
sidebar_label: vLLM Chat
---

# vLLM Chat

vLLM can be deployed as a server that mimics the OpenAI API protocol. This allows vLLM to be used as a drop-in replacement for applications using OpenAI API. This server can be queried in the same format as OpenAI API.

## Overview
This will help you getting started with vLLM [chat models](/docs/concepts/#chat-models), which leverage the `langchain-openai` package. For detailed documentation of all `ChatOpenAI` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html).

### Integration details

| Class | Package | Local | Serializable | JS support | Package downloads | Package latest |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatOpenAI](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html) | [langchain_openai](https://api.python.langchain.com/en/latest/langchain_openai.html) | ✅ | beta | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_openai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_openai?style=flat-square&label=%20) |

### Model features
Specific model features-- such as tool calling, support for multi-modal inputs, support for token-level streaming, etc.-- will depend on the hosted model.

## Setup

See the vLLM docs [here](https://docs.vllm.ai/en/latest/).

To access vLLM models through LangChain, you'll need to install the `langchain-openai` integration package.

### Credentials

Authentication will depend on specifics of the inference server.

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:


```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```

### Installation

The LangChain vLLM integration can be accessed via the `langchain-openai` package:


```python
%pip install -qU langchain-openai
```

## Instantiation

Now we can instantiate our model object and generate chat completions:


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "vLLM Chat"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "vLLM Chat"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "vLLM Chat"}, {"imported": "HumanMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html", "title": "vLLM Chat"}, {"imported": "SystemMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.SystemMessagePromptTemplate.html", "title": "vLLM Chat"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "vLLM Chat"}]-->
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)
from langchain_openai import ChatOpenAI
```


```python
inference_server_url = "http://localhost:8000/v1"

llm = ChatOpenAI(
    model="mosaicml/mpt-7b",
    openai_api_key="EMPTY",
    openai_api_base=inference_server_url,
    max_tokens=5,
    temperature=0,
)
```

## Invocation


```python
messages = [
    SystemMessage(
        content="You are a helpful assistant that translates English to Italian."
    ),
    HumanMessage(
        content="Translate the following sentence from English to Italian: I love programming."
    ),
]
llm.invoke(messages)
```



```output
AIMessage(content=' Io amo programmare', additional_kwargs={}, example=False)
```


## Chaining

We can [chain](/docs/how_to/sequence/) our model with a prompt template like so:


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "vLLM Chat"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate(
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

## API reference

For detailed documentation of all features and configurations exposed via `langchain-openai`, head to the API reference: https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html

Refer to the vLLM [documentation](https://docs.vllm.ai/en/latest/) as well.


## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)