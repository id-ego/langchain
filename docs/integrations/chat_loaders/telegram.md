---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/telegram.ipynb
description: 이 문서는 Telegram 채팅 로더를 사용하여 내보낸 Telegram 대화를 LangChain 메시지로 변환하는 방법을 설명합니다.
---

# 텔레그램

이 노트북은 텔레그램 채팅 로더를 사용하는 방법을 보여줍니다. 이 클래스는 내보낸 텔레그램 대화를 LangChain 채팅 메시지에 매핑하는 데 도움을 줍니다.

이 과정은 세 단계로 이루어져 있습니다:
1. 텔레그램 앱에서 채팅을 복사하여 로컬 컴퓨터의 파일에 붙여넣어 .txt 파일로 내보냅니다.
2. json 파일 또는 JSON 파일 디렉토리를 가리키는 파일 경로로 `TelegramChatLoader`를 생성합니다.
3. 변환을 수행하기 위해 `loader.load()` (또는 `loader.lazy_load()`)를 호출합니다. 선택적으로 `merge_chat_runs`를 사용하여 동일한 발신자의 메시지를 순서대로 결합하고, 또는 `map_ai_messages`를 사용하여 지정된 발신자의 메시지를 "AIMessage" 클래스로 변환합니다.

## 1. 메시지 덤프 생성

현재(2023/08/23) 이 로더는 [텔레그램 데스크탑 앱](https://desktop.telegram.org/)에서 채팅 기록을 내보내는 형식으로 생성된 json 파일을 가장 잘 지원합니다.

**중요:** "MacOS용 텔레그램"과 같이 내보내기 기능이 없는 '라이트' 버전의 텔레그램이 있습니다. 파일을 내보내기 위해 올바른 앱을 사용하고 있는지 확인하십시오.

내보내기를 하려면:
1. 텔레그램 데스크탑을 다운로드하고 엽니다.
2. 대화를 선택합니다.
3. 대화 설정으로 이동합니다(현재 오른쪽 상단의 세 개의 점).
4. "채팅 기록 내보내기"를 클릭합니다.
5. 사진 및 기타 미디어의 선택을 해제합니다. "기계 판독 가능 JSON" 형식을 선택하여 내보냅니다.

예시는 아래와 같습니다:

```python
%%writefile telegram_conversation.json
{
 "name": "Jiminy",
 "type": "personal_chat",
 "id": 5965280513,
 "messages": [
  {
   "id": 1,
   "type": "message",
   "date": "2023-08-23T13:11:23",
   "date_unixtime": "1692821483",
   "from": "Jiminy Cricket",
   "from_id": "user123450513",
   "text": "You better trust your conscience",
   "text_entities": [
    {
     "type": "plain",
     "text": "You better trust your conscience"
    }
   ]
  },
  {
   "id": 2,
   "type": "message",
   "date": "2023-08-23T13:13:20",
   "date_unixtime": "1692821600",
   "from": "Batman & Robin",
   "from_id": "user6565661032",
   "text": "What did you just say?",
   "text_entities": [
    {
     "type": "plain",
     "text": "What did you just say?"
    }
   ]
  }
 ]
}
```

```output
Overwriting telegram_conversation.json
```

## 2. 채팅 로더 생성

필요한 것은 파일 경로뿐입니다. 선택적으로 ai 메시지에 매핑되는 사용자 이름을 지정하고 메시지 실행을 병합할지 여부를 구성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "TelegramChatLoader", "source": "langchain_community.chat_loaders.telegram", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.telegram.TelegramChatLoader.html", "title": "Telegram"}]-->
from langchain_community.chat_loaders.telegram import TelegramChatLoader
```


```python
loader = TelegramChatLoader(
    path="./telegram_conversation.json",
)
```


## 3. 메시지 로드

`load()` (또는 `lazy_load`) 메서드는 현재 로드된 대화당 메시지 목록을 포함하는 "ChatSessions" 목록을 반환합니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "Telegram"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "Telegram"}, {"imported": "ChatSession", "source": "langchain_core.chat_sessions", "docs": "https://api.python.langchain.com/en/latest/chat_sessions/langchain_core.chat_sessions.ChatSession.html", "title": "Telegram"}]-->
from typing import List

from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
from langchain_core.chat_sessions import ChatSession

raw_messages = loader.lazy_load()
# Merge consecutive messages from the same sender into a single message
merged_messages = merge_chat_runs(raw_messages)
# Convert messages from "Jiminy Cricket" to AI messages
messages: List[ChatSession] = list(
    map_ai_messages(merged_messages, sender="Jiminy Cricket")
)
```


### 다음 단계

그런 다음 이러한 메시지를 모델 미세 조정, 몇 샷 예제 선택 또는 다음 메시지에 대한 직접 예측과 같이 적합하다고 생각하는 방식으로 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Telegram"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

for chunk in llm.stream(messages[0]["messages"]):
    print(chunk.content, end="", flush=True)
```

```output
I said, "You better trust your conscience."
```