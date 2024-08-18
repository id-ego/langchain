---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/rockset_chat_message_history.ipynb
description: Rockset을 사용하여 채팅 메시지 기록을 저장하는 방법을 설명하는 노트북입니다. 실시간 분석 데이터베이스 서비스에 대해
  다룹니다.
---

# 록셋

> [록셋](https://rockset.com/product/)은 낮은 지연 시간과 높은 동시성을 가진 분석 쿼리를 대규모로 제공하는 실시간 분석 데이터베이스 서비스입니다. 구조화된 데이터와 반구조화된 데이터에 대해 효율적인 벡터 임베딩 저장소를 갖춘 통합 인덱스™를 구축합니다. 스키마 없는 데이터에서 SQL을 실행할 수 있는 지원 덕분에 메타데이터 필터와 함께 벡터 검색을 실행하는 데 완벽한 선택입니다.

이 노트북에서는 [록셋](https://rockset.com/docs)을 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다.

## 설정

```python
%pip install --upgrade --quiet  rockset langchain-community
```


시작하려면 [록셋 콘솔](https://console.rockset.com/apikeys)에서 API 키를 가져옵니다. 록셋 [API 참조](https://rockset.com/docs/rest-api#introduction)에서 API 지역을 찾으세요.

## 예제

```python
<!--IMPORTS:[{"imported": "RocksetChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.rocksetdb.RocksetChatMessageHistory.html", "title": "Rockset"}]-->
from langchain_community.chat_message_histories import (
    RocksetChatMessageHistory,
)
from rockset import Regions, RocksetClient

history = RocksetChatMessageHistory(
    session_id="MySession",
    client=RocksetClient(
        api_key="YOUR API KEY",
        host=Regions.usw2a1,  # us-west-2 Oregon
    ),
    collection="langchain_demo",
    sync=True,
)
history.add_user_message("hi!")
history.add_ai_message("whats up?")
print(history.messages)
```


출력은 다음과 같아야 합니다:

```python
[
    HumanMessage(content='hi!', additional_kwargs={'id': '2e62f1c2-e9f7-465e-b551-49bae07fe9f0'}, example=False), 
    AIMessage(content='whats up?', additional_kwargs={'id': 'b9be8eda-4c18-4cf8-81c3-e91e876927d0'}, example=False)
]

```