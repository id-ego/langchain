---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/baidu_qianfan_endpoint.ipynb
description: 바이두 AI 클라우드 치안판 플랫폼은 기업 개발자를 위한 대형 모델 개발 및 서비스 운영 플랫폼입니다. 다양한 AI 개발 도구를
  제공합니다.
sidebar_label: Baidu Qianfan
---

# QianfanChatEndpoint

바이두 AI 클라우드 Qianfan 플랫폼은 기업 개발자를 위한 원스톱 대형 모델 개발 및 서비스 운영 플랫폼입니다. Qianfan은 Wenxin Yiyan (ERNIE-Bot) 모델과 제3자 오픈 소스 모델을 포함하여 다양한 AI 개발 도구와 전체 개발 환경을 제공하여 고객이 대형 모델 애플리케이션을 쉽게 사용하고 개발할 수 있도록 합니다.

기본적으로 이러한 모델은 다음과 같은 유형으로 나뉩니다:

- 임베딩
- 채팅
- 완성

이 노트북에서는 `langchain/chat_models` 패키지에 해당하는 `Chat`을 주로 사용하여 [Qianfan](https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html)과 함께 langchain을 사용하는 방법을 소개합니다:

## API 초기화

바이두 Qianfan을 기반으로 한 LLM 서비스를 사용하려면 다음 매개변수를 초기화해야 합니다:

환경 변수에서 AK, SK를 초기화하거나 매개변수를 초기화할 수 있습니다:

```base
export QIANFAN_AK=XXX
export QIANFAN_SK=XXX
```


## 현재 지원되는 모델:

- ERNIE-Bot-turbo (기본 모델)
- ERNIE-Bot
- BLOOMZ-7B
- Llama-2-7b-chat
- Llama-2-13b-chat
- Llama-2-70b-chat
- Qianfan-BLOOMZ-7B-compressed
- Qianfan-Chinese-Llama-2-7B
- ChatGLM2-6B-32K
- AquilaChat-7B

## 설정

```python
<!--IMPORTS:[{"imported": "QianfanChatEndpoint", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.baidu_qianfan_endpoint.QianfanChatEndpoint.html", "title": "QianfanChatEndpoint"}, {"imported": "HumanMessage", "source": "langchain_core.language_models.chat_models", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "QianfanChatEndpoint"}]-->
"""For basic init and call"""
import os

from langchain_community.chat_models import QianfanChatEndpoint
from langchain_core.language_models.chat_models import HumanMessage

os.environ["QIANFAN_AK"] = "Your_api_key"
os.environ["QIANFAN_SK"] = "You_secret_Key"
```


## 사용법

```python
chat = QianfanChatEndpoint(streaming=True)
messages = [HumanMessage(content="Hello")]
chat.invoke(messages)
```


```output
AIMessage(content='您好！请问您需要什么帮助？我将尽力回答您的问题。')
```


```python
await chat.ainvoke(messages)
```


```output
AIMessage(content='您好！有什么我可以帮助您的吗？')
```


```python
chat.batch([messages])
```


```output
[AIMessage(content='您好！有什么我可以帮助您的吗？')]
```


### 스트리밍

```python
try:
    for chunk in chat.stream(messages):
        print(chunk.content, end="", flush=True)
except TypeError as e:
    print("")
```

```output
您好！有什么我可以帮助您的吗？
```

## Qianfan에서 다른 모델 사용하기

기본 모델은 ERNIE-Bot-turbo이며, Ernie Bot 또는 제3자 오픈 소스 모델을 기반으로 자신의 모델을 배포하고자 하는 경우 다음 단계를 따를 수 있습니다:

1. (선택 사항, 모델이 기본 모델에 포함된 경우 생략) Qianfan 콘솔에서 모델을 배포하고 자신만의 맞춤형 배포 엔드포인트를 가져옵니다.
2. 초기화에서 `endpoint`라는 필드를 설정합니다:

```python
chatBot = QianfanChatEndpoint(
    streaming=True,
    model="ERNIE-Bot",
)

messages = [HumanMessage(content="Hello")]
chatBot.invoke(messages)
```


```output
AIMessage(content='Hello，可以回答问题了，我会竭尽全力为您解答，请问有什么问题吗？')
```


## 모델 매개변수:

현재 `ERNIE-Bot` 및 `ERNIE-Bot-turbo`만 아래의 모델 매개변수를 지원하며, 향후 더 많은 모델을 지원할 수 있습니다.

- 온도
- top_p
- 패널티 점수

```python
chat.invoke(
    [HumanMessage(content="Hello")],
    **{"top_p": 0.4, "temperature": 0.1, "penalty_score": 1},
)
```


```output
AIMessage(content='您好！有什么我可以帮助您的吗？')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)