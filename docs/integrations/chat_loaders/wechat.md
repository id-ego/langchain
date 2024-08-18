---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/wechat.ipynb
description: 이 문서는 WeChat 메시지를 LangChain 메시지 목록으로 변환하는 방법을 설명합니다. 간단한 채팅 로더를 만드는 과정을
  안내합니다.
---

# WeChat

개인 WeChat 메시지를 내보내는 간단한 방법은 아직 없습니다. 그러나 모델 미세 조정이나 몇 가지 예시를 위해 몇 백 개의 메시지만 필요하다면, 이 노트북에서는 복사하여 붙여넣은 WeChat 메시지를 LangChain 메시지 목록으로 변환하는 채팅 로더를 만드는 방법을 보여줍니다.

> https://python.langchain.com/docs/integrations/chat_loaders/discord에서 많은 영감을 받았습니다.

이 과정은 다섯 단계로 이루어져 있습니다:
1. WeChat 데스크톱 앱에서 채팅을 엽니다. 마우스를 드래그하거나 오른쪽 클릭하여 필요한 메시지를 선택합니다. 제한으로 인해 한 번에 최대 100개의 메시지를 선택할 수 있습니다. `CMD`/`Ctrl` + `C`로 복사합니다.
2. 선택한 메시지를 로컬 컴퓨터의 파일에 붙여넣어 채팅 .txt 파일을 생성합니다.
3. 아래의 채팅 로더 정의를 로컬 파일에 복사합니다.
4. 텍스트 파일을 가리키는 파일 경로로 `WeChatChatLoader`를 초기화합니다.
5. `loader.load()` (또는 `loader.lazy_load()`)를 호출하여 변환을 수행합니다.

## 1. 메시지 덤프 생성

이 로더는 앱에서 메시지를 복사하여 클립보드에 붙여넣고 파일에 붙여넣어 생성된 형식의 .txt 파일만 지원합니다. 아래는 예시입니다.

```python
%%writefile wechat_chats.txt
女朋友 2023/09/16 2:51 PM
天气有点凉

男朋友 2023/09/16 2:51 PM
珍簟凉风著，瑶琴寄恨生。嵇君懒书札，底物慰秋情。

女朋友 2023/09/16 3:06 PM
忙什么呢

男朋友 2023/09/16 3:06 PM
今天只干成了一件像样的事
那就是想你

女朋友 2023/09/16 3:06 PM
[动画表情]
```

```output
Overwriting wechat_chats.txt
```

## 2. 채팅 로더 정의

LangChain은 현재 지원하지 않습니다 

```python
<!--IMPORTS:[{"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "WeChat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "WeChat"}]-->
import logging
import re
from typing import Iterator, List

from langchain_community.chat_loaders import base as chat_loaders
from langchain_core.messages import BaseMessage, HumanMessage

logger = logging.getLogger()


class WeChatChatLoader(chat_loaders.BaseChatLoader):
    def __init__(self, path: str):
        """
        Initialize the Discord chat loader.

        Args:
            path: Path to the exported Discord chat text file.
        """
        self.path = path
        self._message_line_regex = re.compile(
            r"(?P<sender>.+?) (?P<timestamp>\d{4}/\d{2}/\d{2} \d{1,2}:\d{2} (?:AM|PM))",
            # flags=re.DOTALL,
        )

    def _append_message_to_results(
        self,
        results: List,
        current_sender: str,
        current_timestamp: str,
        current_content: List[str],
    ):
        content = "\n".join(current_content).strip()
        # skip non-text messages like stickers, images, etc.
        if not re.match(r"\[.*\]", content):
            results.append(
                HumanMessage(
                    content=content,
                    additional_kwargs={
                        "sender": current_sender,
                        "events": [{"message_time": current_timestamp}],
                    },
                )
            )
        return results

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
            if re.match(self._message_line_regex, line):
                if current_sender and current_content:
                    results = self._append_message_to_results(
                        results, current_sender, current_timestamp, current_content
                    )
                current_sender, current_timestamp = re.match(
                    self._message_line_regex, line
                ).groups()
                current_content = []
            else:
                current_content.append(line.strip())

        if current_sender and current_content:
            results = self._append_message_to_results(
                results, current_sender, current_timestamp, current_content
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
loader = WeChatChatLoader(
    path="./wechat_chats.txt",
)
```


## 3. 메시지 로드

형식이 올바르다고 가정할 때, 로더는 채팅을 langchain 메시지로 변환합니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "WeChat"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "WeChat"}, {"imported": "ChatSession", "source": "langchain_core.chat_sessions", "docs": "https://api.python.langchain.com/en/latest/chat_sessions/langchain_core.chat_sessions.ChatSession.html", "title": "WeChat"}]-->
from typing import List

from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
from langchain_core.chat_sessions import ChatSession

raw_messages = loader.lazy_load()
# Merge consecutive messages from the same sender into a single message
merged_messages = merge_chat_runs(raw_messages)
# Convert messages from "男朋友" to AI messages
messages: List[ChatSession] = list(map_ai_messages(merged_messages, sender="男朋友"))
```


```python
messages
```


```output
[{'messages': [HumanMessage(content='天气有点凉', additional_kwargs={'sender': '女朋友', 'events': [{'message_time': '2023/09/16 2:51 PM'}]}, example=False),
   AIMessage(content='珍簟凉风著，瑶琴寄恨生。嵇君懒书札，底物慰秋情。', additional_kwargs={'sender': '男朋友', 'events': [{'message_time': '2023/09/16 2:51 PM'}]}, example=False),
   HumanMessage(content='忙什么呢', additional_kwargs={'sender': '女朋友', 'events': [{'message_time': '2023/09/16 3:06 PM'}]}, example=False),
   AIMessage(content='今天只干成了一件像样的事\n 那就是想你', additional_kwargs={'sender': '男朋友', 'events': [{'message_time': '2023/09/16 3:06 PM'}]}, example=False)]}]
```


### 다음 단계

그런 다음 이러한 메시지를 모델 미세 조정, 몇 가지 예시 선택 또는 다음 메시지에 대한 직접 예측과 같이 원하는 대로 사용할 수 있습니다.  

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "WeChat"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()

for chunk in llm.stream(messages[0]["messages"]):
    print(chunk.content, end="", flush=True)
```