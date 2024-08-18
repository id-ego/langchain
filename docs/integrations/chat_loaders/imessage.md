---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/imessage.ipynb
description: 이 문서는 iMessage 대화 내용을 LangChain 채팅 메시지로 변환하는 방법을 설명합니다. iMessageChatLoader
  클래스를 사용하여 데이터베이스에서 로드합니다.
---

# iMessage

이 노트북은 iMessage 채팅 로더를 사용하는 방법을 보여줍니다. 이 클래스는 iMessage 대화를 LangChain 채팅 메시지로 변환하는 데 도움을 줍니다.

MacOS에서는 iMessage가 대화를 `~/Library/Messages/chat.db`에 있는 sqlite 데이터베이스에 저장합니다 (최소한 macOS Ventura 13.4의 경우). `IMessageChatLoader`는 이 데이터베이스 파일에서 로드합니다.

1. 처리하려는 `chat.db` 데이터베이스의 파일 경로를 가리키는 `IMessageChatLoader`를 생성합니다.
2. 변환을 수행하기 위해 `loader.load()` (또는 `loader.lazy_load()`)를 호출합니다. 선택적으로 `merge_chat_runs`를 사용하여 동일한 발신자의 메시지를 순서대로 결합하고, `map_ai_messages`를 사용하여 지정된 발신자의 메시지를 "AIMessage" 클래스로 변환할 수 있습니다.

## 1. 채팅 DB 접근

터미널이 `~/Library/Messages`에 대한 접근을 거부할 가능성이 높습니다. 이 클래스를 사용하려면 DB를 접근 가능한 디렉토리(예: Documents)로 복사하고 거기에서 로드할 수 있습니다. 또는 (추천하지 않음) 시스템 설정 > 보안 및 개인 정보 보호 > 전체 디스크 접근에서 터미널 에뮬레이터에 대한 전체 디스크 접근을 허용할 수 있습니다.

[이 링크된 드라이브 파일](https://drive.google.com/file/d/1NebNKqTA2NXApCmeH6mu0unJD2tANZzo/view?usp=sharing)에서 사용할 수 있는 예제 데이터베이스를 만들었습니다.

```python
# This uses some example data
import requests


def download_drive_file(url: str, output_path: str = "chat.db") -> None:
    file_id = url.split("/")[-2]
    download_url = f"https://drive.google.com/uc?export=download&id={file_id}"

    response = requests.get(download_url)
    if response.status_code != 200:
        print("Failed to download the file.")
        return

    with open(output_path, "wb") as file:
        file.write(response.content)
        print(f"File {output_path} downloaded.")


url = (
    "https://drive.google.com/file/d/1NebNKqTA2NXApCmeH6mu0unJD2tANZzo/view?usp=sharing"
)

# Download file to chat.db
download_drive_file(url)
```

```output
File chat.db downloaded.
```


## 2. 채팅 로더 생성

로더에 zip 디렉토리에 대한 파일 경로를 제공합니다. 선택적으로 AI 메시지에 매핑되는 사용자 ID를 지정하고 메시지 실행을 병합할지 여부를 구성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "IMessageChatLoader", "source": "langchain_community.chat_loaders.imessage", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.imessage.IMessageChatLoader.html", "title": "iMessage"}]-->
from langchain_community.chat_loaders.imessage import IMessageChatLoader
```


```python
loader = IMessageChatLoader(
    path="./chat.db",
)
```


## 3. 메시지 로드

`load()` (또는 `lazy_load`) 메서드는 현재 로드된 대화당 메시지 목록을 포함하는 "ChatSessions" 목록을 반환합니다. 모든 메시지는 처음에 "HumanMessage" 객체로 매핑됩니다.

선택적으로 메시지 "실행" (동일한 발신자로부터의 연속 메시지)을 병합하고 "AI"를 나타낼 발신자를 선택할 수 있습니다. 미세 조정된 LLM은 이러한 AI 메시지를 생성하는 방법을 학습하게 됩니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "iMessage"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "iMessage"}, {"imported": "ChatSession", "source": "langchain_core.chat_sessions", "docs": "https://api.python.langchain.com/en/latest/chat_sessions/langchain_core.chat_sessions.ChatSession.html", "title": "iMessage"}]-->
from typing import List

from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
from langchain_core.chat_sessions import ChatSession

raw_messages = loader.lazy_load()
# Merge consecutive messages from the same sender into a single message
merged_messages = merge_chat_runs(raw_messages)
# Convert messages from "Tortoise" to AI messages. Do you have a guess who these conversations are between?
chat_sessions: List[ChatSession] = list(
    map_ai_messages(merged_messages, sender="Tortoise")
)
```


```python
# Now all of the Tortoise's messages will take the AI message class
# which maps to the 'assistant' role in OpenAI's training format
chat_sessions[0]["messages"][:3]
```


```output
[AIMessage(content="Slow and steady, that's my motto.", additional_kwargs={'message_time': 1693182723, 'sender': 'Tortoise'}, example=False),
 HumanMessage(content='Speed is key!', additional_kwargs={'message_time': 1693182753, 'sender': 'Hare'}, example=False),
 AIMessage(content='A balanced approach is more reliable.', additional_kwargs={'message_time': 1693182783, 'sender': 'Tortoise'}, example=False)]
```


## 3. 미세 조정을 위한 준비

이제 채팅 메시지를 OpenAI 사전으로 변환할 시간입니다. 이를 위해 `convert_messages_for_finetuning` 유틸리티를 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "convert_messages_for_finetuning", "source": "langchain_community.adapters.openai", "docs": "https://api.python.langchain.com/en/latest/adapters/langchain_community.adapters.openai.convert_messages_for_finetuning.html", "title": "iMessage"}]-->
from langchain_community.adapters.openai import convert_messages_for_finetuning
```


```python
training_data = convert_messages_for_finetuning(chat_sessions)
print(f"Prepared {len(training_data)} dialogues for training")
```

```output
Prepared 10 dialogues for training
```


## 4. 모델 미세 조정

모델을 미세 조정할 시간입니다. `openai`가 설치되어 있고 `OPENAI_API_KEY`가 적절하게 설정되어 있는지 확인하세요.

```python
%pip install --upgrade --quiet  langchain-openai
```


```python
import json
import time
from io import BytesIO

import openai

# We will write the jsonl file in memory
my_file = BytesIO()
for m in training_data:
    my_file.write((json.dumps({"messages": m}) + "\n").encode("utf-8"))

my_file.seek(0)
training_file = openai.files.create(file=my_file, purpose="fine-tune")

# OpenAI audits each training file for compliance reasons.
# This make take a few minutes
status = openai.files.retrieve(training_file.id).status
start_time = time.time()
while status != "processed":
    print(f"Status=[{status}]... {time.time() - start_time:.2f}s", end="\r", flush=True)
    time.sleep(5)
    status = openai.files.retrieve(training_file.id).status
print(f"File {training_file.id} ready after {time.time() - start_time:.2f} seconds.")
```


```output
File file-zHIgf4r8LltZG3RFpkGd4Sjf ready after 10.19 seconds.
```


파일이 준비되면 교육 작업을 시작할 시간입니다.

```python
job = openai.fine_tuning.jobs.create(
    training_file=training_file.id,
    model="gpt-3.5-turbo",
)
```


모델이 준비되는 동안 차 한 잔을 즐기세요. 시간이 좀 걸릴 수 있습니다!

```python
status = openai.fine_tuning.jobs.retrieve(job.id).status
start_time = time.time()
while status != "succeeded":
    print(f"Status=[{status}]... {time.time() - start_time:.2f}s", end="\r", flush=True)
    time.sleep(5)
    job = openai.fine_tuning.jobs.retrieve(job.id)
    status = job.status
```

```output
Status=[running]... 524.95s
```


```python
print(job.fine_tuned_model)
```

```output
ft:gpt-3.5-turbo-0613:personal::7sKoRdlz
```


## 5. LangChain에서 사용

결과 모델 ID를 `ChatOpenAI` 모델 클래스에서 직접 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "iMessage"}]-->
from langchain_openai import ChatOpenAI

model = ChatOpenAI(
    model=job.fine_tuned_model,
    temperature=1,
)
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "iMessage"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "iMessage"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are speaking to hare."),
        ("human", "{input}"),
    ]
)

chain = prompt | model | StrOutputParser()
```


```python
for tok in chain.stream({"input": "What's the golden thread?"}):
    print(tok, end="", flush=True)
```


```output
A symbol of interconnectedness.
```