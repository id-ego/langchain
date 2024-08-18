---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/slack.ipynb
description: 이 문서는 Slack 채팅 로더를 사용하여 Slack 대화를 LangChain 메시지로 변환하는 방법을 설명합니다.
---

# 슬랙

이 노트북은 슬랙 채팅 로더를 사용하는 방법을 보여줍니다. 이 클래스는 내보낸 슬랙 대화를 LangChain 채팅 메시지에 매핑하는 데 도움을 줍니다.

프로세스는 세 단계로 구성됩니다:
1. [여기에서 지침을 따라](https://slack.com/help/articles/1500001548241-Request-to-export-all-conversations) 원하는 대화 스레드를 내보냅니다.
2. json 파일 또는 JSON 파일 디렉토리를 가리키는 파일 경로로 `SlackChatLoader`를 생성합니다.
3. 변환을 수행하기 위해 `loader.load()` (또는 `loader.lazy_load()`)를 호출합니다. 선택적으로 `merge_chat_runs`를 사용하여 동일한 발신자의 메시지를 순서대로 결합하거나, `map_ai_messages`를 사용하여 지정된 발신자의 메시지를 "AIMessage" 클래스로 변환할 수 있습니다.

## 1. 메시지 덤프 생성

현재(2023/08/23) 이 로더는 슬랙에서 직접 메시지 대화를 내보내는 형식으로 생성된 파일의 zip 디렉토리를 가장 잘 지원합니다. 이를 수행하는 방법에 대한 최신 지침을 슬랙에서 확인하세요.

LangChain 레포지토리에 예제가 있습니다.

```python
import requests

permalink = "https://raw.githubusercontent.com/langchain-ai/langchain/342087bdfa3ac31d622385d0f2d09cf5e06c8db3/libs/langchain/tests/integration_tests/examples/slack_export.zip"
response = requests.get(permalink)
with open("slack_dump.zip", "wb") as f:
    f.write(response.content)
```


## 2. 채팅 로더 생성

로더에 zip 디렉토리에 대한 파일 경로를 제공합니다. 선택적으로 AI 메시지에 매핑되는 사용자 ID를 지정하고 메시지 실행을 병합할지 여부를 구성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "SlackChatLoader", "source": "langchain_community.chat_loaders.slack", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.slack.SlackChatLoader.html", "title": "Slack"}]-->
from langchain_community.chat_loaders.slack import SlackChatLoader
```


```python
loader = SlackChatLoader(
    path="slack_dump.zip",
)
```


## 3. 메시지 로드

`load()` (또는 `lazy_load`) 메서드는 현재 로드된 대화당 메시지 목록을 포함하는 "ChatSessions" 목록을 반환합니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "Slack"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "Slack"}, {"imported": "ChatSession", "source": "langchain_core.chat_sessions", "docs": "https://api.python.langchain.com/en/latest/chat_sessions/langchain_core.chat_sessions.ChatSession.html", "title": "Slack"}]-->
from typing import List

from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
from langchain_core.chat_sessions import ChatSession

raw_messages = loader.lazy_load()
# Merge consecutive messages from the same sender into a single message
merged_messages = merge_chat_runs(raw_messages)
# Convert messages from "U0500003428" to AI messages
messages: List[ChatSession] = list(
    map_ai_messages(merged_messages, sender="U0500003428")
)
```


### 다음 단계

이 메시지를 모델 미세 조정, 몇 샷 예제 선택 또는 다음 메시지에 대한 직접 예측과 같이 원하는 대로 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Slack"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

for chunk in llm.stream(messages[1]["messages"]):
    print(chunk.content, end="", flush=True)
```

```output
Hi, 

I hope you're doing well. I wanted to reach out and ask if you'd be available to meet up for coffee sometime next week. I'd love to catch up and hear about what's been going on in your life. Let me know if you're interested and we can find a time that works for both of us. 

Looking forward to hearing from you!

Best, [Your Name]
```