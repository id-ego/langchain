---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/coze.ipynb
description: Coze Bot과의 채팅을 위한 API 사용법과 스트리밍 기능에 대한 정보를 제공합니다. 자세한 내용은 공식 문서를 참조하세요.
sidebar_label: Coze Chat
---

# Coze 봇과 채팅하기

coze.com의 ChatCoze 채팅 모델 API. 자세한 내용은 [https://www.coze.com/open/docs/chat](https://www.coze.com/open/docs/chat)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "ChatCoze", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.coze.ChatCoze.html", "title": "Chat with Coze Bot"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Chat with Coze Bot"}]-->
from langchain_community.chat_models import ChatCoze
from langchain_core.messages import HumanMessage
```


```python
chat = ChatCoze(
    coze_api_base="YOUR_API_BASE",
    coze_api_key="YOUR_API_KEY",
    bot_id="YOUR_BOT_ID",
    user="YOUR_USER_ID",
    conversation_id="YOUR_CONVERSATION_ID",
    streaming=False,
)
```


또는 다음과 같이 API 키와 API 기본값을 설정할 수 있습니다:

```python
import os

os.environ["COZE_API_KEY"] = "YOUR_API_KEY"
os.environ["COZE_API_BASE"] = "YOUR_API_BASE"
```


```python
chat([HumanMessage(content="什么是扣子(coze)")])
```


```output
AIMessage(content='为你找到关于 coze 的信息如下：

Coze 是一个由字节跳动推出的 AI 聊天机器人和应用程序编辑开发平台。

用户无论是否有编程经验，都可以通过该平台快速创建各种类型的聊天机器人、智能体、AI 应用和插件，并将其部署在社交平台和即时聊天应用程序中。

国际版使用的模型比国内版更强大。')
```


## Coze 스트리밍으로 채팅하기

```python
chat = ChatCoze(
    coze_api_base="YOUR_API_BASE",
    coze_api_key="YOUR_API_KEY",
    bot_id="YOUR_BOT_ID",
    user="YOUR_USER_ID",
    conversation_id="YOUR_CONVERSATION_ID",
    streaming=True,
)
```


```python
chat([HumanMessage(content="什么是扣子(coze)")])
```


```output
AIMessageChunk(content='为你查询到 Coze 是一个由字节跳动推出的 AI 聊天机器人和应用程序编辑开发平台。')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)