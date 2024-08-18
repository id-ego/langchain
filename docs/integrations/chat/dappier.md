---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/dappier.ipynb
description: Dappier는 개발자에게 실시간 데이터 모델을 제공하여 AI 애플리케이션의 정확성과 신뢰성을 높입니다. 간편한 API로 혁신을
  지원합니다.
---

# Dappier AI

**Dappier: AI를 동적이고 실시간 데이터 모델로 강화하기**

Dappier는 뉴스, 엔터테인먼트, 금융, 시장 데이터, 날씨 등 다양한 실시간 데이터 모델에 즉시 접근할 수 있는 최첨단 플랫폼을 제공합니다. 사전 훈련된 데이터 모델을 통해 AI 애플리케이션을 강화하여 정확하고 최신의 응답을 제공하고 부정확성을 최소화할 수 있습니다.

Dappier 데이터 모델은 세계 유수 브랜드의 신뢰할 수 있는 최신 콘텐츠로 차세대 LLM 앱을 구축하는 데 도움을 줍니다. 창의력을 발휘하고 간단한 API를 통해 실행 가능한 독점 데이터를 사용하여 모든 GPT 앱이나 AI 워크플로를 향상시키세요. 신뢰할 수 있는 출처의 독점 데이터를 통해 AI를 보강하는 것은 질문에 관계없이 사실적이고 최신의 응답을 보장하는 가장 좋은 방법입니다.

개발자를 위한, 개발자에 의해
개발자를 염두에 두고 설계된 Dappier는 데이터 통합에서 수익화까지의 여정을 간소화하여 AI 모델을 배포하고 수익을 올릴 수 있는 명확하고 간단한 경로를 제공합니다. 새로운 인터넷을 위한 수익화 인프라의 미래를 **https://dappier.com/**에서 경험하세요.

이 예제는 LangChain을 사용하여 Dappier AI 모델과 상호작용하는 방법을 설명합니다.

* * *

Dappier AI 데이터 모델 중 하나를 사용하려면 API 키가 필요합니다. Dappier 플랫폼(https://platform.dappier.com/)에 로그인하여 프로필에서 API 키를 생성하세요.

API 참조에 대한 자세한 내용은 다음을 참조하세요: https://docs.dappier.com/introduction

Dappier Chat 모델과 작업하려면 클래스를 초기화할 때 dappier_api_key라는 매개변수를 통해 키를 직접 전달하거나 환경 변수로 설정할 수 있습니다.

```bash
export DAPPIER_API_KEY="..."
```


```python
<!--IMPORTS:[{"imported": "ChatDappierAI", "source": "langchain_community.chat_models.dappier", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.dappier.ChatDappierAI.html", "title": "Dappier AI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Dappier AI"}]-->
from langchain_community.chat_models.dappier import ChatDappierAI
from langchain_core.messages import HumanMessage
```


```python
chat = ChatDappierAI(
    dappier_endpoint="https://api.dappier.com/app/datamodelconversation",
    dappier_model="dm_01hpsxyfm2fwdt2zet9cg6fdxt",
    dappier_api_key="...",
)
```


```python
messages = [HumanMessage(content="Who won the super bowl in 2024?")]
chat.invoke(messages)
```


```output
AIMessage(content='Hey there! The Kansas City Chiefs won Super Bowl LVIII in 2024. They beat the San Francisco 49ers in overtime with a final score of 25-22. It was quite the game! 🏈')
```


```python
await chat.ainvoke(messages)
```


```output
AIMessage(content='The Kansas City Chiefs won Super Bowl LVIII in 2024! 🏈')
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)