---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/moonshot.ipynb
description: MoonshotChat은 LangChain을 사용하여 Moonshot의 LLM 서비스를 통해 기업과 개인이 채팅을 상호작용하는
  방법을 설명합니다.
sidebar_label: Moonshot
---

# MoonshotChat

[Moonshot](https://platform.moonshot.cn/)은 기업과 개인을 위한 LLM 서비스를 제공하는 중국 스타트업입니다.

이 예제는 LangChain을 사용하여 Moonshot Inference와 상호작용하는 방법을 설명합니다.

```python
import os

# Generate your api key from: https://platform.moonshot.cn/console/api-keys
os.environ["MOONSHOT_API_KEY"] = "MOONSHOT_API_KEY"
```


```python
<!--IMPORTS:[{"imported": "MoonshotChat", "source": "langchain_community.chat_models.moonshot", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.moonshot.MoonshotChat.html", "title": "MoonshotChat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "MoonshotChat"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "MoonshotChat"}]-->
from langchain_community.chat_models.moonshot import MoonshotChat
from langchain_core.messages import HumanMessage, SystemMessage
```


```python
chat = MoonshotChat()
# or use a specific model
# Available models: https://platform.moonshot.cn/docs
# chat = MoonshotChat(model="moonshot-v1-128k")
```


```python
messages = [
    SystemMessage(
        content="You are a helpful assistant that translates English to French."
    ),
    HumanMessage(
        content="Translate this sentence from English to French. I love programming."
    ),
]

chat.invoke(messages)
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)