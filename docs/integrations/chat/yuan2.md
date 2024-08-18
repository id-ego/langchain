---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/yuan2.ipynb
description: 이 문서는 LangChain에서 YUAN2 API를 사용하는 방법과 ChatYuan2 통합에 대한 내용을 다룹니다. Yuan2.0
  모델의 특징도 설명합니다.
sidebar_label: Yuan2.0
---

# Yuan2.0

이 노트북은 LangChain에서 langchain.chat_models.ChatYuan2를 사용하여 [YUAN2 API](https://github.com/IEIT-Yuan/Yuan-2.0/blob/main/docs/inference_server.md)를 사용하는 방법을 보여줍니다.

[*Yuan2.0*](https://github.com/IEIT-Yuan/Yuan-2.0/blob/main/README-EN.md)은 IEIT System에서 개발한 새로운 세대의 기본 대규모 언어 모델입니다. 우리는 Yuan 2.0-102B, Yuan 2.0-51B, Yuan 2.0-2B의 세 가지 모델을 모두 발표했습니다. 그리고 다른 개발자를 위한 사전 훈련, 미세 조정 및 추론 서비스에 대한 관련 스크립트를 제공합니다. Yuan2.0은 Yuan1.0을 기반으로 하며, 모델의 의미, 수학, 추론, 코드, 지식 및 기타 측면에 대한 이해를 향상시키기 위해 더 넓은 범위의 고품질 사전 훈련 데이터와 지침 미세 조정 데이터 세트를 활용합니다.

## 시작하기
### 설치
먼저, Yuan2.0은 OpenAI 호환 API를 제공하며, OpenAI 클라이언트를 사용하여 langchain 채팅 모델에 ChatYuan2를 통합합니다.  
따라서 Python 환경에 openai 패키지가 설치되어 있는지 확인하십시오. 다음 명령을 실행하십시오:

```python
%pip install --upgrade --quiet openai
```


### 필요한 모듈 가져오기
설치 후, 필요한 모듈을 Python 스크립트에 가져옵니다:

```python
<!--IMPORTS:[{"imported": "ChatYuan2", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yuan2.ChatYuan2.html", "title": "Yuan2.0"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Yuan2.0"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Yuan2.0"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Yuan2.0"}]-->
from langchain_community.chat_models import ChatYuan2
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
```


### API 서버 설정
[yuan2 openai api server](https://github.com/IEIT-Yuan/Yuan-2.0/blob/main/docs/Yuan2_fastchat.md)를 따라 OpenAI 호환 API 서버를 설정합니다.  
API 서버를 로컬에 배포한 경우, `yuan2_api_key="EMPTY"` 또는 원하는 값을 설정하면 됩니다.  
단, `yuan2_api_base`가 올바르게 설정되어 있는지 확인하십시오.

```python
yuan2_api_key = "your_api_key"
yuan2_api_base = "http://127.0.0.1:8001/v1"
```


### ChatYuan2 모델 초기화
채팅 모델을 초기화하는 방법은 다음과 같습니다:

```python
chat = ChatYuan2(
    yuan2_api_base="http://127.0.0.1:8001/v1",
    temperature=1.0,
    model_name="yuan2",
    max_retries=3,
    streaming=False,
)
```


### 기본 사용법
시스템 및 인간 메시지로 모델을 호출합니다:

```python
messages = [
    SystemMessage(content="你是一个人工智能助手。"),
    HumanMessage(content="你好，你是谁？"),
]
```


```python
print(chat.invoke(messages))
```


### 스트리밍을 통한 기본 사용법
지속적인 상호작용을 위해 스트리밍 기능을 사용합니다:

```python
<!--IMPORTS:[{"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Yuan2.0"}]-->
from langchain_core.callbacks import StreamingStdOutCallbackHandler

chat = ChatYuan2(
    yuan2_api_base="http://127.0.0.1:8001/v1",
    temperature=1.0,
    model_name="yuan2",
    max_retries=3,
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()],
)
messages = [
    SystemMessage(content="你是个旅游小助手。"),
    HumanMessage(content="给我介绍一下北京有哪些好玩的。"),
]
```


```python
chat.invoke(messages)
```


## 고급 기능
### 비동기 호출을 통한 사용법

비차단 호출로 모델을 호출합니다, 다음과 같이:

```python
async def basic_agenerate():
    chat = ChatYuan2(
        yuan2_api_base="http://127.0.0.1:8001/v1",
        temperature=1.0,
        model_name="yuan2",
        max_retries=3,
    )
    messages = [
        [
            SystemMessage(content="你是个旅游小助手。"),
            HumanMessage(content="给我介绍一下北京有哪些好玩的。"),
        ]
    ]

    result = await chat.agenerate(messages)
    print(result)
```


```python
import asyncio

asyncio.run(basic_agenerate())
```


### 프롬프트 템플릿을 통한 사용법

비차단 호출 및 채팅 템플릿을 사용하여 모델을 호출합니다, 다음과 같이:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Yuan2.0"}]-->
async def ainvoke_with_prompt_template():
    from langchain_core.prompts.chat import (
        ChatPromptTemplate,
    )

    chat = ChatYuan2(
        yuan2_api_base="http://127.0.0.1:8001/v1",
        temperature=1.0,
        model_name="yuan2",
        max_retries=3,
    )
    prompt = ChatPromptTemplate.from_messages(
        [
            ("system", "你是一个诗人，擅长写诗。"),
            ("human", "给我写首诗，主题是{theme}。"),
        ]
    )
    chain = prompt | chat
    result = await chain.ainvoke({"theme": "明月"})
    print(f"type(result): {type(result)}; {result}")
```


```python
asyncio.run(ainvoke_with_prompt_template())
```


### 스트리밍에서 비동기 호출을 통한 사용법
스트리밍 출력을 위한 비차단 호출을 위해 astream 메서드를 사용합니다:

```python
async def basic_astream():
    chat = ChatYuan2(
        yuan2_api_base="http://127.0.0.1:8001/v1",
        temperature=1.0,
        model_name="yuan2",
        max_retries=3,
    )
    messages = [
        SystemMessage(content="你是个旅游小助手。"),
        HumanMessage(content="给我介绍一下北京有哪些好玩的。"),
    ]
    result = chat.astream(messages)
    async for chunk in result:
        print(chunk.content, end="", flush=True)
```


```python
import asyncio

asyncio.run(basic_astream())
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)