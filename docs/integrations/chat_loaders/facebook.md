---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat_loaders/facebook.ipynb
description: 이 문서는 Facebook Messenger 데이터를 다운로드하고, 변환하여 모델을 세밀하게 조정하는 방법을 설명합니다.
---

# 페이스북 메신저

이 노트북은 페이스북에서 데이터를 로드하여 세부 조정할 수 있는 형식으로 변환하는 방법을 보여줍니다. 전체 단계는 다음과 같습니다:

1. 메신저 데이터를 디스크에 다운로드합니다.
2. 채팅 로더를 생성하고 `loader.load()` (또는 `loader.lazy_load()`)를 호출하여 변환을 수행합니다.
3. 선택적으로 `merge_chat_runs`를 사용하여 동일한 발신자로부터의 메시지를 순서대로 결합하고, `map_ai_messages`를 사용하여 지정된 발신자로부터의 메시지를 "AIMessage" 클래스로 변환할 수 있습니다. 이를 완료한 후, `convert_messages_for_finetuning`을 호출하여 데이터를 세부 조정을 위해 준비합니다.

이 작업이 완료되면 모델을 세부 조정할 수 있습니다. 이를 위해 다음 단계를 완료합니다:

4. 메시지를 OpenAI에 업로드하고 세부 조정 작업을 실행합니다.
5. 결과 모델을 LangChain 앱에서 사용합니다!

시작해봅시다.

## 1. 데이터 다운로드

자신의 메신저 데이터를 다운로드하려면 [여기](https://www.zapptales.com/en/download-facebook-messenger-chat-history-how-to/)의 지침을 따르세요. 중요 - JSON 형식으로 다운로드해야 합니다 (HTML 아님).

우리는 이 워크스루에서 사용할 예제 덤프를 [이 구글 드라이브 링크](https://drive.google.com/file/d/1rh1s1o2i7B-Sk1v9o8KNgivLVGwJ-osV/view?usp=sharing)에서 호스팅하고 있습니다.

```python
# This uses some example data
import zipfile

import requests


def download_and_unzip(url: str, output_path: str = "file.zip") -> None:
    file_id = url.split("/")[-2]
    download_url = f"https://drive.google.com/uc?export=download&id={file_id}"

    response = requests.get(download_url)
    if response.status_code != 200:
        print("Failed to download the file.")
        return

    with open(output_path, "wb") as file:
        file.write(response.content)
        print(f"File {output_path} downloaded.")

    with zipfile.ZipFile(output_path, "r") as zip_ref:
        zip_ref.extractall()
        print(f"File {output_path} has been unzipped.")


# URL of the file to download
url = (
    "https://drive.google.com/file/d/1rh1s1o2i7B-Sk1v9o8KNgivLVGwJ-osV/view?usp=sharing"
)

# Download and unzip
download_and_unzip(url)
```

```output
File file.zip downloaded.
File file.zip has been unzipped.
```


## 2. 채팅 로더 생성

우리는 전체 채팅 디렉토리를 위한 `FacebookMessengerChatLoader` 클래스와 개별 파일을 로드하기 위한 클래스를 두 가지 가지고 있습니다. 우리는

```python
directory_path = "./hogwarts"
```


```python
<!--IMPORTS:[{"imported": "FolderFacebookMessengerChatLoader", "source": "langchain_community.chat_loaders.facebook_messenger", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.facebook_messenger.FolderFacebookMessengerChatLoader.html", "title": "Facebook Messenger"}, {"imported": "SingleFileFacebookMessengerChatLoader", "source": "langchain_community.chat_loaders.facebook_messenger", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.facebook_messenger.SingleFileFacebookMessengerChatLoader.html", "title": "Facebook Messenger"}]-->
from langchain_community.chat_loaders.facebook_messenger import (
    FolderFacebookMessengerChatLoader,
    SingleFileFacebookMessengerChatLoader,
)
```


```python
loader = SingleFileFacebookMessengerChatLoader(
    path="./hogwarts/inbox/HermioneGranger/messages_Hermione_Granger.json",
)
```


```python
chat_session = loader.load()[0]
chat_session["messages"][:3]
```


```output
[HumanMessage(content="Hi Hermione! How's your summer going so far?", additional_kwargs={'sender': 'Harry Potter'}),
 HumanMessage(content="Harry! Lovely to hear from you. My summer is going well, though I do miss everyone. I'm spending most of my time going through my books and researching fascinating new topics. How about you?", additional_kwargs={'sender': 'Hermione Granger'}),
 HumanMessage(content="I miss you all too. The Dursleys are being their usual unpleasant selves but I'm getting by. At least I can practice some spells in my room without them knowing. Let me know if you find anything good in your researching!", additional_kwargs={'sender': 'Harry Potter'})]
```


```python
loader = FolderFacebookMessengerChatLoader(
    path="./hogwarts",
)
```


```python
chat_sessions = loader.load()
len(chat_sessions)
```


```output
9
```


## 3. 세부 조정을 위한 준비

`load()`를 호출하면 우리가 추출할 수 있는 모든 채팅 메시지가 인간 메시지로 반환됩니다. 챗봇과 대화할 때, 대화는 일반적으로 실제 대화에 비해 더 엄격한 교대 대화 패턴을 따릅니다.

메시지 "런" (동일한 발신자로부터의 연속 메시지)을 병합하고 "AI"를 나타낼 발신자를 선택할 수 있습니다. 세부 조정된 LLM은 이러한 AI 메시지를 생성하는 방법을 학습할 것입니다.

```python
<!--IMPORTS:[{"imported": "map_ai_messages", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.map_ai_messages.html", "title": "Facebook Messenger"}, {"imported": "merge_chat_runs", "source": "langchain_community.chat_loaders.utils", "docs": "https://api.python.langchain.com/en/latest/chat_loaders/langchain_community.chat_loaders.utils.merge_chat_runs.html", "title": "Facebook Messenger"}]-->
from langchain_community.chat_loaders.utils import (
    map_ai_messages,
    merge_chat_runs,
)
```


```python
merged_sessions = merge_chat_runs(chat_sessions)
alternating_sessions = list(map_ai_messages(merged_sessions, "Harry Potter"))
```


```python
# Now all of Harry Potter's messages will take the AI message class
# which maps to the 'assistant' role in OpenAI's training format
alternating_sessions[0]["messages"][:3]
```


```output
[AIMessage(content="Professor Snape, I was hoping I could speak with you for a moment about something that's been concerning me lately.", additional_kwargs={'sender': 'Harry Potter'}),
 HumanMessage(content="What is it, Potter? I'm quite busy at the moment.", additional_kwargs={'sender': 'Severus Snape'}),
 AIMessage(content="I apologize for the interruption, sir. I'll be brief. I've noticed some strange activity around the school grounds at night. I saw a cloaked figure lurking near the Forbidden Forest last night. I'm worried someone may be plotting something sinister.", additional_kwargs={'sender': 'Harry Potter'})]
```


#### 이제 OpenAI 형식의 딕셔너리로 변환할 수 있습니다

```python
<!--IMPORTS:[{"imported": "convert_messages_for_finetuning", "source": "langchain_community.adapters.openai", "docs": "https://api.python.langchain.com/en/latest/adapters/langchain_community.adapters.openai.convert_messages_for_finetuning.html", "title": "Facebook Messenger"}]-->
from langchain_community.adapters.openai import convert_messages_for_finetuning
```


```python
training_data = convert_messages_for_finetuning(alternating_sessions)
print(f"Prepared {len(training_data)} dialogues for training")
```

```output
Prepared 9 dialogues for training
```


```python
training_data[0][:3]
```


```output
[{'role': 'assistant',
  'content': "Professor Snape, I was hoping I could speak with you for a moment about something that's been concerning me lately."},
 {'role': 'user',
  'content': "What is it, Potter? I'm quite busy at the moment."},
 {'role': 'assistant',
  'content': "I apologize for the interruption, sir. I'll be brief. I've noticed some strange activity around the school grounds at night. I saw a cloaked figure lurking near the Forbidden Forest last night. I'm worried someone may be plotting something sinister."}]
```


OpenAI는 현재 세부 조정 작업을 위해 최소 10개의 훈련 예제가 필요하지만, 대부분의 작업에 대해 50-100개를 권장합니다. 우리는 9개의 채팅 세션만 있으므로, 각 훈련 예제가 전체 대화의 일부로 구성되도록 (선택적으로 일부 중복을 포함하여) 세분화할 수 있습니다.

페이스북 채팅 세션 (1인당 1개)은 종종 여러 날과 대화에 걸쳐 진행되므로, 장기 의존성은 모델링에 그리 중요하지 않을 수 있습니다.

```python
# Our chat is alternating, we will make each datapoint a group of 8 messages,
# with 2 messages overlapping
chunk_size = 8
overlap = 2

training_examples = [
    conversation_messages[i : i + chunk_size]
    for conversation_messages in training_data
    for i in range(0, len(conversation_messages) - chunk_size + 1, chunk_size - overlap)
]

len(training_examples)
```


```output
100
```


## 4. 모델 세부 조정

모델을 세부 조정할 시간입니다. `openai`가 설치되어 있고 `OPENAI_API_KEY`가 적절하게 설정되었는지 확인하세요.

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
for m in training_examples:
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
File file-ULumAXLEFw3vB6bb9uy6DNVC ready after 0.00 seconds.
```


파일이 준비되었으니, 훈련 작업을 시작할 시간입니다.

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
Status=[running]... 874.29s. 56.93s
```


```python
print(job.fine_tuned_model)
```

```output
ft:gpt-3.5-turbo-0613:personal::8QnAzWMr
```


## 5. LangChain에서 사용

결과 모델 ID를 `ChatOpenAI` 모델 클래스에서 직접 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Facebook Messenger"}]-->
from langchain_openai import ChatOpenAI

model = ChatOpenAI(
    model=job.fine_tuned_model,
    temperature=1,
)
```


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Facebook Messenger"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Facebook Messenger"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        ("human", "{input}"),
    ]
)

chain = prompt | model | StrOutputParser()
```


```python
for tok in chain.stream({"input": "What classes are you taking?"}):
    print(tok, end="", flush=True)
```

```output
I'm taking Charms, Defense Against the Dark Arts, Herbology, Potions, Transfiguration, and Ancient Runes. How about you?
```