---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/gigachat.ipynb
description: 이 노트북은 LangChain을 사용하여 GigaChat을 활용하는 방법을 보여줍니다. GigaChat API 사용을 위한
  인증 정보 획득 방법도 포함되어 있습니다.
---

# 기가챗
이 노트북은 LangChain을 [기가챗](https://developers.sber.ru/portal/products/gigachat)과 함께 사용하는 방법을 보여줍니다. 사용하려면 `gigachat` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  gigachat
```


기가챗 자격 증명을 얻으려면 [계정을 생성](https://developers.sber.ru/studio/login)하고 [API에 접근](https://developers.sber.ru/docs/ru/gigachat/individuals-quickstart)해야 합니다.

## 예제

```python
import os
from getpass import getpass

os.environ["GIGACHAT_CREDENTIALS"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "GigaChat", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.gigachat.GigaChat.html", "title": "GigaChat"}]-->
from langchain_community.chat_models import GigaChat

chat = GigaChat(verify_ssl_certs=False, scope="GIGACHAT_API_PERS")
```


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "GigaChat"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "GigaChat"}]-->
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(
        content="You are a helpful AI that shares everything you know. Talk in English."
    ),
    HumanMessage(content="What is capital of Russia?"),
]

print(chat.invoke(messages).content)
```

```output
The capital of Russia is Moscow.
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)