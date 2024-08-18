---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/mistralai.ipynb
description: Mistral AI의 채팅 모델을 시작하는 데 도움이 되는 문서로, ChatMistralAI의 기능 및 구성에 대한 정보를
  제공합니다.
sidebar_label: MistralAI
---

# ChatMistralAI

이 문서는 Mistral [채팅 모델](/docs/concepts/#chat-models) 사용을 시작하는 데 도움이 됩니다. `ChatMistralAI`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_mistralai.chat_models.ChatMistralAI.html)를 참조하세요. `ChatMistralAI` 클래스는 [Mistral API](https://docs.mistral.ai/api/) 위에 구축되었습니다. Mistral에서 지원하는 모든 모델 목록은 [이 페이지](https://docs.mistral.ai/getting-started/models/)를 확인하세요.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/mistral) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatMistralAI](https://api.python.langchain.com/en/latest/chat_models/langchain_mistralai.chat_models.ChatMistralAI.html) | [langchain_mistralai](https://api.python.langchain.com/en/latest/mistralai_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_mistralai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_mistralai?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [로그확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | 

## 설정

`ChatMistralAI` 모델에 접근하려면 Mistral 계정을 생성하고, API 키를 얻고, `langchain_mistralai` 통합 패키지를 설치해야 합니다.

### 자격 증명

API와 통신하기 위해 유효한 [API 키](https://console.mistral.ai/users/api-keys/)가 필요합니다. 이를 설정한 후 MISTRAL_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["MISTRAL_API_KEY"] = getpass.getpass("Enter your Mistral API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Mistral 통합은 `langchain_mistralai` 패키지에 있습니다:

```python
%pip install -qU langchain_mistralai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatMistralAI", "source": "langchain_mistralai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_mistralai.chat_models.ChatMistralAI.html", "title": "ChatMistralAI"}]-->
from langchain_mistralai import ChatMistralAI

llm = ChatMistralAI(
    model="mistral-large-latest",
    temperature=0,
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
AIMessage(content='Sure, I\'d be happy to help you translate that sentence into French! The English sentence "I love programming" translates to "J\'aime programmer" in French. Let me know if you have any other questions or need further assistance!', response_metadata={'token_usage': {'prompt_tokens': 32, 'total_tokens': 84, 'completion_tokens': 52}, 'model': 'mistral-small', 'finish_reason': 'stop'}, id='run-64bac156-7160-4b68-b67e-4161f63e021f-0', usage_metadata={'input_tokens': 32, 'output_tokens': 52, 'total_tokens': 84})
```


```python
print(ai_msg.content)
```

```output
Sure, I'd be happy to help you translate that sentence into French! The English sentence "I love programming" translates to "J'aime programmer" in French. Let me know if you have any other questions or need further assistance!
```

## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatMistralAI"}]-->
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
AIMessage(content='Ich liebe Programmierung. (German translation)', response_metadata={'token_usage': {'prompt_tokens': 26, 'total_tokens': 38, 'completion_tokens': 12}, 'model': 'mistral-small', 'finish_reason': 'stop'}, id='run-dfd4094f-e347-47b0-9056-8ebd7ea35fe7-0', usage_metadata={'input_tokens': 26, 'output_tokens': 12, 'total_tokens': 38})
```


## API 참조

모든 속성과 메서드에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_mistralai.chat_models.ChatMistralAI.html)를 참조하세요.

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)