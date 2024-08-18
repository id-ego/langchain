---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/octoai.ipynb
description: OctoAI는 효율적인 컴퓨팅을 제공하며, 사용자가 AI 모델을 애플리케이션에 통합할 수 있도록 지원하는 서비스입니다.
---

# ChatOctoAI

[OctoAI](https://docs.octoai.cloud/docs)는 효율적인 컴퓨팅에 쉽게 접근할 수 있도록 하며 사용자가 선택한 AI 모델을 애플리케이션에 통합할 수 있게 합니다. `OctoAI` 컴퓨팅 서비스는 AI 애플리케이션을 쉽게 실행, 조정 및 확장할 수 있도록 도와줍니다.

이 노트북은 [OctoAI 엔드포인트](https://octoai.cloud/text)를 위해 `langchain.chat_models.ChatOctoAI`의 사용을 보여줍니다.

## 설정

예제 애플리케이션을 실행하기 위해 두 가지 간단한 단계를 수행해야 합니다:

1. [귀하의 OctoAI 계정 페이지](https://octoai.cloud/settings)에서 API 토큰을 가져옵니다.
2. 아래 코드 셀에 API 토큰을 붙여넣거나 `octoai_api_token` 키워드 인수를 사용합니다.

참고: [사용 가능한 모델](https://octoai.cloud/text?selectedTags=Chat)과 다른 모델을 사용하고 싶다면, 모델을 컨테이너화하고 직접 사용자 정의 OctoAI 엔드포인트를 만들 수 있습니다. [Python에서 컨테이너 빌드하기](https://octo.ai/docs/bring-your-own-model/advanced-build-a-container-from-scratch-in-python) 및 [컨테이너에서 사용자 정의 엔드포인트 만들기](https://octo.ai/docs/bring-your-own-model/create-custom-endpoints-from-a-container/create-custom-endpoints-from-a-container)를 따라한 후 `OCTOAI_API_BASE` 환경 변수를 업데이트하세요.

```python
import os

os.environ["OCTOAI_API_TOKEN"] = "OCTOAI_API_TOKEN"
```


```python
<!--IMPORTS:[{"imported": "ChatOctoAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.octoai.ChatOctoAI.html", "title": "ChatOctoAI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatOctoAI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatOctoAI"}]-->
from langchain_community.chat_models import ChatOctoAI
from langchain_core.messages import HumanMessage, SystemMessage
```


## 예제

```python
chat = ChatOctoAI(max_tokens=300, model_name="mixtral-8x7b-instruct")
```


```python
messages = [
    SystemMessage(content="You are a helpful assistant."),
    HumanMessage(content="Tell me about Leonardo da Vinci briefly."),
]
print(chat(messages).content)
```


레오나르도 다 빈치 (1452-1519)는 역사상 가장 위대한 화가 중 한 명으로 여겨지는 이탈리아의 다재다능한 인물입니다. 그러나 그의 천재성은 예술을 넘어 확장되었습니다. 그는 또한 과학자, 발명가, 수학자, 엔지니어, 해부학자, 지질학자 및 지도 제작자였습니다.

다 빈치는 모나리자, 최후의 만찬, 바위의 성모와 같은 그의 그림으로 가장 잘 알려져 있습니다. 그의 과학적 연구는 시대를 앞서 있었으며, 그의 노트북에는 다양한 기계, 인체 해부학 및 자연 현상에 대한 상세한 그림과 설명이 포함되어 있습니다.

정식 교육을 받지 않았음에도 불구하고, 다 빈치의 끊임없는 호기심과 관찰 능력은 그를 여러 분야의 선구자로 만들었습니다. 그의 작업은 오늘날에도 예술가, 과학자 및 사상가들에게 영감을 주고 영향을 미치고 있습니다.

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용법 가이드](/docs/how_to/#chat-models)