---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/upstage/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/upstage.ipynb
sidebar_label: Upstage
---

# ChatUpstage

This notebook covers how to get started with Upstage chat models.

## Installation

Install `langchain-upstage` package.

```bash
pip install -U langchain-upstage
```

## Environment Setup

Make sure to set the following environment variables:

- `UPSTAGE_API_KEY`: Your Upstage API key from [Upstage console](https://console.upstage.ai/).

## Usage


```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatUpstage"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_upstage import ChatUpstage

chat = ChatUpstage()
```


```python
# using chat invoke
chat.invoke("Hello, how are you?")
```


```python
# using chat stream
for m in chat.stream("Hello, how are you?"):
    print(m)
```

## Chaining


```python
# using chain
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant that translates English to French."),
        ("human", "Translate this sentence from English to French. {english_text}."),
    ]
)
chain = prompt | chat

chain.invoke({"english_text": "Hello, how are you?"})
```


## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)