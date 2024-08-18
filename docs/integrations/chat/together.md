---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/together.ipynb
description: Together AI의 채팅 모델을 시작하는 방법과 API 참조에 대한 정보를 제공합니다. 50개 이상의 오픈 소스 모델을
  활용하세요.
sidebar_label: Together
---

# ChatTogether

이 페이지는 Together AI [채팅 모델](../../concepts.mdx#chat-models)을 시작하는 데 도움을 줄 것입니다. ChatTogether의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html)로 이동하세요.

[Together AI](https://www.together.ai/)는 [50개 이상의 주요 오픈 소스 모델](https://docs.together.ai/docs/chat-models)을 쿼리할 수 있는 API를 제공합니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/togetherai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatTogether](https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html) | [langchain-together](https://api.python.langchain.com/en/latest/together_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-together?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-together?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](../../how_to/tool_calling.md) | [구조화된 출력](../../how_to/structured_output.md) | JSON 모드 | [이미지 입력](../../how_to/multimodal_inputs.md) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](../../how_to/chat_streaming.md) | 네이티브 비동기 | [토큰 사용](../../how_to/chat_token_usage_tracking.md) | [로그 확률](../../how_to/logprobs.md) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | 

## 설정

Together 모델에 접근하려면 Together 계정을 생성하고, API 키를 얻고, `langchain-together` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Together에 가입하고 API 키를 생성하려면 이 페이지](https://api.together.ai)로 이동하세요. 이 작업을 완료한 후 TOGETHER_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

if "TOGETHER_API_KEY" not in os.environ:
    os.environ["TOGETHER_API_KEY"] = getpass.getpass("Enter your Together API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Together 통합은 `langchain-together` 패키지에 있습니다:

```python
%pip install -qU langchain-together
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완료를 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatTogether", "source": "langchain_together", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html", "title": "ChatTogether"}]-->
from langchain_together import ChatTogether

llm = ChatTogether(
    model="meta-llama/Llama-3-70b-chat-hf",
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
AIMessage(content="J'adore la programmation.", response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 35, 'total_tokens': 44}, 'model_name': 'meta-llama/Llama-3-70b-chat-hf', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-eabcbe33-cdd8-45b8-ab0b-f90b6e7dfad8-0', usage_metadata={'input_tokens': 35, 'output_tokens': 9, 'total_tokens': 44})
```


```python
print(ai_msg.content)
```

```output
J'adore la programmation.
```

## 체인

프롬프트 템플릿과 함께 모델을 [체인](../../how_to/sequence.md)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatTogether"}]-->
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
AIMessage(content='Ich liebe das Programmieren.', response_metadata={'token_usage': {'completion_tokens': 7, 'prompt_tokens': 30, 'total_tokens': 37}, 'model_name': 'meta-llama/Llama-3-70b-chat-hf', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-a249aa24-ee31-46ba-9bf9-f4eb135b0a95-0', usage_metadata={'input_tokens': 30, 'output_tokens': 7, 'total_tokens': 37})
```


## API 참조

ChatTogether의 모든 기능 및 구성에 대한 자세한 문서는 API 참조로 이동하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_together.chat_models.ChatTogether.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)