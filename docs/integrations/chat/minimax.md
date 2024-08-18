---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/minimax.ipynb
description: MiniMaxChat은 LangChain을 사용하여 MiniMax Inference와 상호작용하는 방법을 설명하는 문서입니다.
sidebar_label: MiniMax
---

# MiniMaxChat

[Minimax](https://api.minimax.chat)는 기업과 개인을 위한 LLM 서비스를 제공하는 중국 스타트업입니다.

이 예제는 LangChain을 사용하여 MiniMax 추론과 상호작용하는 방법을 설명합니다.

```python
import os

os.environ["MINIMAX_GROUP_ID"] = "MINIMAX_GROUP_ID"
os.environ["MINIMAX_API_KEY"] = "MINIMAX_API_KEY"
```


```python
<!--IMPORTS:[{"imported": "MiniMaxChat", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.minimax.MiniMaxChat.html", "title": "MiniMaxChat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "MiniMaxChat"}]-->
from langchain_community.chat_models import MiniMaxChat
from langchain_core.messages import HumanMessage
```


```python
chat = MiniMaxChat()
```


```python
chat(
    [
        HumanMessage(
            content="Translate this sentence from English to French. I love programming."
        )
    ]
)
```


## Related

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)