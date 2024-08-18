---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/upstage.ipynb
description: 이 문서는 Upstage 채팅 모델을 시작하는 방법과 설치, 환경 설정, 사용법 및 체인 구성에 대한 안내를 제공합니다.
sidebar_label: Upstage
---

# ChatUpstage

이 노트북은 Upstage 채팅 모델을 시작하는 방법을 다룹니다.

## 설치

`langchain-upstage` 패키지를 설치합니다.

```bash
pip install -U langchain-upstage
```


## 환경 설정

다음 환경 변수를 설정해야 합니다:

- `UPSTAGE_API_KEY`: [Upstage 콘솔](https://console.upstage.ai/)에서 가져온 Upstage API 키입니다.

## 사용법

```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatUpstage"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_upstage import ChatUpstage

chat = ChatUpstage()
```


```python
# using chat invoke
chat.invoke("Hello, how are you?")
```


```python
# using chat stream
for m in chat.stream("Hello, how are you?"):
    print(m)
```


## 체이닝

```python
# using chain
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant that translates English to French."),
        ("human", "Translate this sentence from English to French. {english_text}."),
    ]
)
chain = prompt | chat

chain.invoke({"english_text": "Hello, how are you?"})
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)