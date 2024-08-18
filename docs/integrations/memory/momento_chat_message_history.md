---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/momento_chat_message_history.ipynb
description: Momento Cache는 서버리스 캐싱 서비스로, 채팅 메시지 기록을 저장하는 방법을 설명합니다. 빠르고 유연한 캐싱 솔루션을
  제공합니다.
---

# Momento Cache

> [Momento Cache](https://docs.momentohq.com/)는 세계 최초의 진정한 서버리스 캐싱 서비스입니다. 즉각적인 탄력성, 제로 스케일 기능 및 빠른 성능을 제공합니다.  

이 노트북에서는 `MomentoChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다. Momento에 대한 설정 방법에 대한 자세한 내용은 Momento [문서](https://docs.momentohq.com/getting-started)를 참조하세요.

기본적으로 주어진 이름의 캐시가 이미 존재하지 않으면 캐시를 생성합니다.

이 클래스를 사용하려면 Momento API 키를 받아야 합니다. 이는 momento.CacheClient에 직접 인스턴스화하려는 경우 `api_key`라는 명명된 매개변수로 `MomentoChatMessageHistory.from_client_params`에 전달하거나 환경 변수 `MOMENTO_API_KEY`로 설정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "MomentoChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.momento.MomentoChatMessageHistory.html", "title": "Momento Cache"}]-->
from datetime import timedelta

from langchain_community.chat_message_histories import MomentoChatMessageHistory

session_id = "foo"
cache_name = "langchain"
ttl = timedelta(days=1)
history = MomentoChatMessageHistory.from_client_params(
    session_id,
    cache_name,
    ttl,
)

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


```python
history.messages
```


```output
[HumanMessage(content='hi!', additional_kwargs={}, example=False),
 AIMessage(content='whats up?', additional_kwargs={}, example=False)]
```