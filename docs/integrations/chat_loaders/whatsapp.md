---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/whatsapp.ipynb
description: 이 문서는 WhatsApp 대화를 LangChain 채팅 메시지로 변환하는 WhatsAppChatLoader 사용 방법을 설명합니다.
---

# WhatsApp

이 노트북은 WhatsApp 채팅 로더를 사용하는 방법을 보여줍니다. 이 클래스는 내보낸 WhatsApp 대화를 LangChain 채팅 메시지에 매핑하는 데 도움을 줍니다.

프로세스는 세 단계로 구성됩니다:
1. 채팅 대화를 컴퓨터로 내보내기
2. JSON 파일 또는 JSON 파일 디렉토리를 가리키는 파일 경로로 `WhatsAppChatLoader` 생성
3. 변환을 수행하기 위해 `loader.load()` (또는 `loader.lazy_load()`) 호출

## 1. 메시지 덤프 생성

WhatsApp 대화를 내보내려면 다음 단계를 완료하세요:

1. 대상 대화를 엽니다.
2. 오른쪽 상단 모서리에 있는 세 개의 점을 클릭하고 "더보기"를 선택합니다.
3. 그런 다음 "채팅 내보내기"를 선택하고 "미디어 없이"를 선택합니다.

각 대화에 대한 데이터 형식의 예는 아래와 같습니다: 

```python
%%writefile whatsapp_chat.txt
[8/15/23, 9:12:33 AM] Dr. Feather: ‎Messages and calls are end-to-end encrypted. No one outside of this chat, not even WhatsApp, can read or listen to them.
[8/15/23, 9:12:43 AM] Dr. Feather: I spotted a rare Hyacinth Macaw yesterday in the Amazon Rainforest. Such a magnificent creature!
‎[8/15/23, 9:12:48 AM] Dr. Feather: ‎image omitted
[8/15/23, 9:13:15 AM] Jungle Jane: That's stunning! Were you able to observe its behavior?
‎[8/15/23, 9:13:23 AM] Dr. Feather: ‎image omitted
[8/15/23, 9:14:02 AM] Dr. Feather: Yes, it seemed quite social with other macaws. They're known for their playful nature.
[8/15/23, 9:14:15 AM] Jungle Jane: How's the research going on parrot communication?
‎[8/15/23, 9:14:30 AM] Dr. Feather: ‎image omitted
[8/15/23, 9:14:50 AM] Dr. Feather: It's progressing well. We're learning so much about how they use sound and color to communicate.
[8/15/23, 9:15:10 AM] Jungle Jane: That's fascinating! Can't wait to read your paper on it.
[8/15/23, 9:15:20 AM] Dr. Feather: Thank you! I'll send you a draft soon.
[8/15/23, 9:25:16 PM] Jungle Jane: Looking forward to it! Keep up the great work.
```

```output
Writing whatsapp_chat.txt
```


## 2. 채팅 로더 생성

WhatsAppChatLoader는 결과 zip 파일, 압축 해제된 디렉토리 또는 그 안에 있는 채팅 `.txt` 파일의 경로를 수락합니다.

그것과 함께 "AI" 역할을 맡고 싶은 사용자 이름을 제공하세요.

```python
<!--IMPORTS:[{"imported": "WhatsAppChatLoader", "source": "langchain_community.chat_loaders.whatsapp", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.whatsapp.WhatsAppChatLoader.html", "title": "WhatsApp"}]-->
from langchain_community.chat_loaders.whatsapp import WhatsAppChatLoader
```


```python
loader = WhatsAppChatLoader(
    path="./whatsapp_chat.txt",
)
```


## 3. 메시지 로드

`load()` (또는 `lazy_load`) 메서드는 현재 로드된 대화당 메시지 목록을 저장하는 "ChatSessions" 목록을 반환합니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "WhatsApp"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "WhatsApp"}, {"imported": "ChatSession", "source": "langchain_core.chat_sessions", "docs": "https://api.python.langchain.com/en/latest/chat_sessions/langchain_core.chat_sessions.ChatSession.html", "title": "WhatsApp"}]-->
from typing import List

from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
from langchain_core.chat_sessions import ChatSession

raw_messages = loader.lazy_load()
# Merge consecutive messages from the same sender into a single message
merged_messages = merge_chat_runs(raw_messages)
# Convert messages from "Dr. Feather" to AI messages
messages: List[ChatSession] = list(
    map_ai_messages(merged_messages, sender="Dr. Feather")
)
```


```output
[{'messages': [AIMessage(content='I spotted a rare Hyacinth Macaw yesterday in the Amazon Rainforest. Such a magnificent creature!', additional_kwargs={'sender': 'Dr. Feather', 'events': [{'message_time': '8/15/23, 9:12:43 AM'}]}, example=False),
   HumanMessage(content="That's stunning! Were you able to observe its behavior?", additional_kwargs={'sender': 'Jungle Jane', 'events': [{'message_time': '8/15/23, 9:13:15 AM'}]}, example=False),
   AIMessage(content="Yes, it seemed quite social with other macaws. They're known for their playful nature.", additional_kwargs={'sender': 'Dr. Feather', 'events': [{'message_time': '8/15/23, 9:14:02 AM'}]}, example=False),
   HumanMessage(content="How's the research going on parrot communication?", additional_kwargs={'sender': 'Jungle Jane', 'events': [{'message_time': '8/15/23, 9:14:15 AM'}]}, example=False),
   AIMessage(content="It's progressing well. We're learning so much about how they use sound and color to communicate.", additional_kwargs={'sender': 'Dr. Feather', 'events': [{'message_time': '8/15/23, 9:14:50 AM'}]}, example=False),
   HumanMessage(content="That's fascinating! Can't wait to read your paper on it.", additional_kwargs={'sender': 'Jungle Jane', 'events': [{'message_time': '8/15/23, 9:15:10 AM'}]}, example=False),
   AIMessage(content="Thank you! I'll send you a draft soon.", additional_kwargs={'sender': 'Dr. Feather', 'events': [{'message_time': '8/15/23, 9:15:20 AM'}]}, example=False),
   HumanMessage(content='Looking forward to it! Keep up the great work.', additional_kwargs={'sender': 'Jungle Jane', 'events': [{'message_time': '8/15/23, 9:25:16 PM'}]}, example=False)]}]
```


### 다음 단계

그런 다음 이러한 메시지를 모델 미세 조정, 몇 가지 예제 선택 또는 다음 메시지에 대한 직접 예측과 같이 원하는 대로 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "WhatsApp"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

for chunk in llm.stream(messages[0]["messages"]):
    print(chunk.content, end="", flush=True)
```

```output
Thank you for the encouragement! I'll do my best to continue studying and sharing fascinating insights about parrot communication.
```