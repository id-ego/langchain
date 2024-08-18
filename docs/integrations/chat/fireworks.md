---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/fireworks.ipynb
description: Fireworks AI는 모델을 실행하고 사용자화할 수 있는 AI 추론 플랫폼입니다. ChatFireworks 모델에 대한
  시작 가이드를 제공합니다.
sidebar_label: Fireworks
---

# ChatFireworks

이 문서는 Fireworks AI [채팅 모델](/docs/concepts/#chat-models) 시작하는 데 도움을 줍니다. ChatFireworks의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_fireworks.chat_models.ChatFireworks.html)로 이동하세요.

Fireworks AI는 모델을 실행하고 사용자 정의할 수 있는 AI 추론 플랫폼입니다. Fireworks에서 제공하는 모든 모델 목록은 [Fireworks 문서](https://fireworks.ai/models)를 참조하세요.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/fireworks) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatFireworks](https://api.python.langchain.com/en/latest/chat_models/langchain_fireworks.chat_models.ChatFireworks.html) | [langchain-fireworks](https://api.python.langchain.com/en/latest/fireworks_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-fireworks?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-fireworks?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [로그확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | 

## 설정

Fireworks 모델에 접근하려면 Fireworks 계정을 생성하고, API 키를 얻고, `langchain-fireworks` 통합 패키지를 설치해야 합니다.

### 자격 증명

(ttps://fireworks.ai/login)로 이동하여 Fireworks에 가입하고 API 키를 생성하세요. 이 작업을 완료한 후 FIREWORKS_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["FIREWORKS_API_KEY"] = getpass.getpass("Enter your Fireworks API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Fireworks 통합은 `langchain-fireworks` 패키지에 있습니다:

```python
%pip install -qU langchain-fireworks
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

- TODO: 관련 매개변수로 모델 인스턴스화를 업데이트하세요.

```python
<!--IMPORTS:[{"imported": "ChatFireworks", "source": "langchain_fireworks", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_fireworks.chat_models.ChatFireworks.html", "title": "ChatFireworks"}]-->
from langchain_fireworks import ChatFireworks

llm = ChatFireworks(
    model="accounts/fireworks/models/llama-v3-70b-instruct",
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
    # other params...
)
```


## 호출

```python
messages = [
    (
        "system",
        "You are a helpful assistant that translates English to French. Translate the user sentence.",
    ),
    ("human", "I love programming."),
]
ai_msg = llm.invoke(messages)
ai_msg
```


```output
AIMessage(content="J'adore la programmation.", response_metadata={'token_usage': {'prompt_tokens': 35, 'total_tokens': 44, 'completion_tokens': 9}, 'model_name': 'accounts/fireworks/models/llama-v3-70b-instruct', 'system_fingerprint': '', 'finish_reason': 'stop', 'logprobs': None}, id='run-df28e69a-ff30-457e-a743-06eb14d01cb0-0', usage_metadata={'input_tokens': 35, 'output_tokens': 9, 'total_tokens': 44})
```


```python
print(ai_msg.content)
```

```output
J'adore la programmation.
```

## 체이닝

우리는 [체인](/docs/how_to/sequence/)을 사용하여 프롬프트 템플릿과 모델을 연결할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatFireworks"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant that translates {input_language} to {output_language}.",
        ),
        ("human", "{input}"),
    ]
)

chain = prompt | llm
chain.invoke(
    {
        "input_language": "English",
        "output_language": "German",
        "input": "I love programming.",
    }
)
```


```output
AIMessage(content='Ich liebe das Programmieren.', response_metadata={'token_usage': {'prompt_tokens': 30, 'total_tokens': 37, 'completion_tokens': 7}, 'model_name': 'accounts/fireworks/models/llama-v3-70b-instruct', 'system_fingerprint': '', 'finish_reason': 'stop', 'logprobs': None}, id='run-ff3f91ad-ed81-4acf-9f59-7490dc8d8f48-0', usage_metadata={'input_tokens': 30, 'output_tokens': 7, 'total_tokens': 37})
```


## API 참조

ChatFireworks의 모든 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_fireworks.chat_models.ChatFireworks.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)