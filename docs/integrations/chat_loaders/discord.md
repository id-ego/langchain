---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/discord.ipynb
description: 이 문서는 Discord에서 복사한 메시지를 LangChain 메시지 목록으로 변환하는 채팅 로더를 만드는 방법을 설명합니다.
---

# Discord

이 노트북은 복사하여 붙여넣은 메시지(디엠에서)를 LangChain 메시지 목록으로 변환하는 자체 채팅 로더를 만드는 방법을 보여줍니다.

이 과정은 네 단계로 이루어져 있습니다:
1. Discord 앱에서 채팅을 복사하여 로컬 컴퓨터의 파일에 붙여넣어 채팅 .txt 파일을 만듭니다.
2. 아래에서 채팅 로더 정의를 복사하여 로컬 파일에 붙여넣습니다.
3. 텍스트 파일을 가리키는 파일 경로로 `DiscordChatLoader`를 초기화합니다.
4. 변환을 수행하기 위해 `loader.load()` (또는 `loader.lazy_load()`)를 호출합니다.

## 1. 메시지 덤프 생성

현재(2023/08/23) 이 로더는 앱에서 메시지를 복사하여 클립보드에 붙여넣고 파일에 붙여넣어 생성된 형식의 .txt 파일만 지원합니다. 아래는 예시입니다.

```python
%%writefile discord_chats.txt
talkingtower — 08/15/2023 11:10 AM
Love music! Do you like jazz?
reporterbob — 08/15/2023 9:27 PM
Yes! Jazz is fantastic. Ever heard this one?
Website
Listen to classic jazz track...

talkingtower — Yesterday at 5:03 AM
Indeed! Great choice. 🎷
reporterbob — Yesterday at 5:23 AM
Thanks! How about some virtual sightseeing?
Website
Virtual tour of famous landmarks...

talkingtower — Today at 2:38 PM
Sounds fun! Let's explore.
reporterbob — Today at 2:56 PM
Enjoy the tour! See you around.
talkingtower — Today at 3:00 PM
Thank you! Goodbye! 👋
reporterbob — Today at 3:02 PM
Farewell! Happy exploring.
```

```output
Writing discord_chats.txt
```

## 2. 채팅 로더 정의

```python
<!--IMPORTS:[{"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "Discord"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Discord"}]-->
import logging
import re
from typing import Iterator, List

from langchain_community.chat_loaders import base as chat_loaders
from langchain_core.messages import BaseMessage, HumanMessage

logger = logging.getLogger()


class DiscordChatLoader(chat_loaders.BaseChatLoader):
    def __init__(self, path: str):
        """
        Initialize the Discord chat loader.

        Args:
            path: Path to the exported Discord chat text file.
        """
        self.path = path
        self._message_line_regex = re.compile(
            r"(.+?) — (\w{3,9} \d{1,2}(?:st|nd|rd|th)?(?:, \d{4})? \d{1,2}:\d{2} (?:AM|PM)|Today at \d{1,2}:\d{2} (?:AM|PM)|Yesterday at \d{1,2}:\d{2} (?:AM|PM))",
            flags=re.DOTALL,
        )

    def _load_single_chat_session_from_txt(
        self, file_path: str
    ) -> chat_loaders.ChatSession:
        """
        Load a single chat session from a text file.

        Args:
            file_path: Path to the text file containing the chat messages.

        Returns:
            A `ChatSession` object containing the loaded chat messages.
        """
        with open(file_path, "r", encoding="utf-8") as file:
            lines = file.readlines()

        results: List[BaseMessage] = []
        current_sender = None
        current_timestamp = None
        current_content = []
        for line in lines:
            if re.match(
                r".+? — (\d{2}/\d{2}/\d{4} \d{1,2}:\d{2} (?:AM|PM)|Today at \d{1,2}:\d{2} (?:AM|PM)|Yesterday at \d{1,2}:\d{2} (?:AM|PM))",
                line,
            ):
                if current_sender and current_content:
                    results.append(
                        HumanMessage(
                            content="".join(current_content).strip(),
                            additional_kwargs={
                                "sender": current_sender,
                                "events": [{"message_time": current_timestamp}],
                            },
                        )
                    )
                current_sender, current_timestamp = line.split(" — ")[:2]
                current_content = [
                    line[len(current_sender) + len(current_timestamp) + 4 :].strip()
                ]
            elif re.match(r"\[\d{1,2}:\d{2} (?:AM|PM)\]", line.strip()):
                results.append(
                    HumanMessage(
                        content="".join(current_content).strip(),
                        additional_kwargs={
                            "sender": current_sender,
                            "events": [{"message_time": current_timestamp}],
                        },
                    )
                )
                current_timestamp = line.strip()[1:-1]
                current_content = []
            else:
                current_content.append("\n" + line.strip())

        if current_sender and current_content:
            results.append(
                HumanMessage(
                    content="".join(current_content).strip(),
                    additional_kwargs={
                        "sender": current_sender,
                        "events": [{"message_time": current_timestamp}],
                    },
                )
            )

        return chat_loaders.ChatSession(messages=results)

    def lazy_load(self) -> Iterator[chat_loaders.ChatSession]:
        """
        Lazy load the messages from the chat file and yield them in the required format.

        Yields:
            A `ChatSession` object containing the loaded chat messages.
        """
        yield self._load_single_chat_session_from_txt(self.path)
```


## 2. 로더 생성

우리는 방금 디스크에 쓴 파일을 가리킬 것입니다.

```python
loader = DiscordChatLoader(
    path="./discord_chats.txt",
)
```


## 3. 메시지 로드

형식이 올바르다고 가정할 때, 로더는 채팅을 langchain 메시지로 변환합니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "Discord"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "Discord"}, {"imported": "ChatSession", "source": "langchain_core.chat_sessions", "docs": "https://api.python.langchain.com/en/latest/chat_sessions/langchain_core.chat_sessions.ChatSession.html", "title": "Discord"}]-->
from typing import List

from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
from langchain_core.chat_sessions import ChatSession

raw_messages = loader.lazy_load()
# Merge consecutive messages from the same sender into a single message
merged_messages = merge_chat_runs(raw_messages)
# Convert messages from "talkingtower" to AI messages
messages: List[ChatSession] = list(
    map_ai_messages(merged_messages, sender="talkingtower")
)
```


```python
messages
```


```output
[{'messages': [AIMessage(content='Love music! Do you like jazz?', additional_kwargs={'sender': 'talkingtower', 'events': [{'message_time': '08/15/2023 11:10 AM\n'}]}),
   HumanMessage(content='Yes! Jazz is fantastic. Ever heard this one?\nWebsite\nListen to classic jazz track...', additional_kwargs={'sender': 'reporterbob', 'events': [{'message_time': '08/15/2023 9:27 PM\n'}]}),
   AIMessage(content='Indeed! Great choice. 🎷', additional_kwargs={'sender': 'talkingtower', 'events': [{'message_time': 'Yesterday at 5:03 AM\n'}]}),
   HumanMessage(content='Thanks! How about some virtual sightseeing?\nWebsite\nVirtual tour of famous landmarks...', additional_kwargs={'sender': 'reporterbob', 'events': [{'message_time': 'Yesterday at 5:23 AM\n'}]}),
   AIMessage(content="Sounds fun! Let's explore.", additional_kwargs={'sender': 'talkingtower', 'events': [{'message_time': 'Today at 2:38 PM\n'}]}),
   HumanMessage(content='Enjoy the tour! See you around.', additional_kwargs={'sender': 'reporterbob', 'events': [{'message_time': 'Today at 2:56 PM\n'}]}),
   AIMessage(content='Thank you! Goodbye! 👋', additional_kwargs={'sender': 'talkingtower', 'events': [{'message_time': 'Today at 3:00 PM\n'}]}),
   HumanMessage(content='Farewell! Happy exploring.', additional_kwargs={'sender': 'reporterbob', 'events': [{'message_time': 'Today at 3:02 PM\n'}]})]}]
```


### 다음 단계

그런 다음 이러한 메시지를 모델 미세 조정, 몇 가지 예시 선택 또는 다음 메시지에 대한 직접적인 예측과 같이 원하는 대로 사용할 수 있습니다.  

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Discord"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

for chunk in llm.stream(messages[0]["messages"]):
    print(chunk.content, end="", flush=True)
```

```output
Thank you! Have a great day!
```