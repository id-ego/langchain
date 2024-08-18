---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/baichuan.ipynb
description: Baichuan-192K와의 채팅을 위한 API 문서로, 스트리밍 기능 및 관련 가이드를 제공합니다. 더 많은 정보는 공식
  웹사이트를 참조하세요.
sidebar_label: Baichuan Chat
---

# Baichuan-192K와 대화하기

Baichuan Intelligent Technology의 Baichuan 채팅 모델 API. 자세한 내용은 [https://platform.baichuan-ai.com/docs/api](https://platform.baichuan-ai.com/docs/api)에서 확인하세요.

```python
<!--IMPORTS:[{"imported": "ChatBaichuan", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.baichuan.ChatBaichuan.html", "title": "Chat with Baichuan-192K"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Chat with Baichuan-192K"}]-->
from langchain_community.chat_models import ChatBaichuan
from langchain_core.messages import HumanMessage
```


```python
chat = ChatBaichuan(baichuan_api_key="YOUR_API_KEY")
```


또는 다음과 같이 API 키를 설정할 수 있습니다:

```python
import os

os.environ["BAICHUAN_API_KEY"] = "YOUR_API_KEY"
```


```python
chat([HumanMessage(content="我日薪 8 块钱，请问在闰年的二月，我月薪多少")])
```


```output
AIMessage(content='首先，我们需要确定闰年的二月有多少天。闰年的二月有 29 天。\n\n 然后，我们可以计算你的月薪：\n\n 日薪 = 月薪 / (当月天数)\n\n 所以，你的月薪 = 日薪 * 当月天数\n\n 将数值代入公式：\n\n 月薪 = 8 元/天 * 29 天 = 232 元\n\n 因此，你在闰年的二月的月薪是 232 元。')
```


## 스트리밍을 통한 Baichuan-192K와 대화하기

```python
chat = ChatBaichuan(
    baichuan_api_key="YOUR_API_KEY",
    streaming=True,
)
```


```python
chat([HumanMessage(content="我日薪 8 块钱，请问在闰年的二月，我月薪多少")])
```


```output
AIMessageChunk(content='首先，我们需要确定闰年的二月有多少天。闰年的二月有 29 天。\n\n 然后，我们可以计算你的月薪：\n\n 日薪 = 月薪 / (当月天数)\n\n 所以，你的月薪 = 日薪 * 当月天数\n\n 将数值代入公式：\n\n 月薪 = 8 元/天 * 29 天 = 232 元\n\n 因此，你在闰年的二月的月薪是 232 元。')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)