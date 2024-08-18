---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/konko.ipynb
description: Konko API는 애플리케이션 개발자가 LLM 선택, 통합, 미세 조정 및 배포를 통해 효율적으로 애플리케이션을 구축할 수
  있도록 지원합니다.
sidebar_label: Konko
---

# ChatKonko

# Konko

> [Konko](https://www.konko.ai/) API는 애플리케이션 개발자를 돕기 위해 설계된 완전 관리형 웹 API입니다:

1. **적절한** 오픈 소스 또는 독점 LLM을 애플리케이션에 선택합니다.
2. **애플리케이션을** 선도하는 애플리케이션 프레임워크 및 완전 관리형 API와의 통합을 통해 더 빠르게 구축합니다.
3. **소규모** 오픈 소스 LLM을 미세 조정하여 비용의 일부로 업계 최고의 성능을 달성합니다.
4. **생산 규모의 API를 배포**하여 보안, 개인 정보 보호, 처리량 및 대기 시간 SLA를 충족하며, Konko AI의 SOC 2 준수 다중 클라우드 인프라를 사용하여 인프라 설정이나 관리 없이 가능합니다.

이 예제는 LangChain을 사용하여 `Konko` ChatCompletion [모델](https://docs.konko.ai/docs/list-of-models#konko-hosted-models)과 상호 작용하는 방법을 설명합니다.

이 노트북을 실행하려면 Konko API 키가 필요합니다. 웹 앱에 로그인하여 [API 키를 생성](https://platform.konko.ai/settings/api-keys)하여 모델에 접근하세요.

```python
<!--IMPORTS:[{"imported": "ChatKonko", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.konko.ChatKonko.html", "title": "ChatKonko"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatKonko"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatKonko"}]-->
from langchain_community.chat_models import ChatKonko
from langchain_core.messages import HumanMessage, SystemMessage
```


#### 환경 변수 설정

1. 다음에 대한 환경 변수를 설정할 수 있습니다:
   1. KONKO_API_KEY (필수)
   2. OPENAI_API_KEY (선택 사항)
2. 현재 셸 세션에서 export 명령을 사용하세요:

```shell
export KONKO_API_KEY={your_KONKO_API_KEY_here}
export OPENAI_API_KEY={your_OPENAI_API_KEY_here} #Optional
```


## 모델 호출

[Konko 개요 페이지](https://docs.konko.ai/docs/list-of-models)에서 모델을 찾으세요.

Konko 인스턴스에서 실행 중인 모델 목록을 찾는 또 다른 방법은 이 [엔드포인트](https://docs.konko.ai/reference/get-models)를 통해 가능합니다.

여기서 모델을 초기화할 수 있습니다:

```python
chat = ChatKonko(max_tokens=400, model="meta-llama/llama-2-13b-chat")
```


```python
messages = [
    SystemMessage(content="You are a helpful assistant."),
    HumanMessage(content="Explain Big Bang Theory briefly"),
]
chat(messages)
```


```output
AIMessage(content="  Sure thing! The Big Bang Theory is a scientific theory that explains the origins of the universe. In short, it suggests that the universe began as an infinitely hot and dense point around 13.8 billion years ago and expanded rapidly. This expansion continues to this day, and it's what makes the universe look the way it does.\n\nHere's a brief overview of the key points:\n\n1. The universe started as a singularity, a point of infinite density and temperature.\n2. The singularity expanded rapidly, causing the universe to cool and expand.\n3. As the universe expanded, particles began to form, including protons, neutrons, and electrons.\n4. These particles eventually came together to form atoms, and later, stars and galaxies.\n5. The universe is still expanding today, and the rate of this expansion is accelerating.\n\nThat's the Big Bang Theory in a nutshell! It's a pretty mind-blowing idea when you think about it, and it's supported by a lot of scientific evidence. Do you have any other questions about it?")
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)