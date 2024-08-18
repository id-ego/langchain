---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/volcengine_maas.ipynb
description: 이 노트북은 VolcEngine Maas Chat 모델을 시작하는 방법에 대한 가이드를 제공합니다. 코드 예제와 환경 변수
  설정 방법이 포함되어 있습니다.
sidebar_label: Volc Enging Maas
---

# VolcEngineMaasChat

이 노트북은 volc engine maas chat 모델을 시작하는 방법에 대한 가이드를 제공합니다.

```python
# Install the package
%pip install --upgrade --quiet  volcengine
```


```python
<!--IMPORTS:[{"imported": "VolcEngineMaasChat", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.volcengine_maas.VolcEngineMaasChat.html", "title": "VolcEngineMaasChat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "VolcEngineMaasChat"}]-->
from langchain_community.chat_models import VolcEngineMaasChat
from langchain_core.messages import HumanMessage
```


```python
chat = VolcEngineMaasChat(volc_engine_maas_ak="your ak", volc_engine_maas_sk="your sk")
```


또는 환경 변수에 access_key와 secret_key를 설정할 수 있습니다.
```bash
export VOLC_ACCESSKEY=YOUR_AK
export VOLC_SECRETKEY=YOUR_SK
```


```python
chat([HumanMessage(content="给我讲个笑话")])
```


```output
AIMessage(content='好的，这是一个笑话：\n\n 为什么鸟儿不会玩电脑游戏？\n\n 因为它们没有翅膀！')
```


# 스트림을 이용한 volc engine maas chat

```python
chat = VolcEngineMaasChat(
    volc_engine_maas_ak="your ak",
    volc_engine_maas_sk="your sk",
    streaming=True,
)
```


```python
chat([HumanMessage(content="给我讲个笑话")])
```


```output
AIMessage(content='好的，这是一个笑话：\n\n 三岁的女儿说她会造句了，妈妈让她用“年轻”造句，女儿说：“妈妈减肥，一年轻了好几斤”。')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)