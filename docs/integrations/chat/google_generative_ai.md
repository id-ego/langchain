---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/google_generative_ai.ipynb
description: Google AI의 채팅 모델을 시작하는 방법과 API 참조에 대한 정보를 제공합니다. 최신 모델 및 기능에 대한 자세한 내용을
  확인하세요.
sidebar_label: Google AI
---

# ChatGoogleGenerativeAI

이 문서는 Google AI [채팅 모델](/docs/concepts/#chat-models)로 시작하는 데 도움이 됩니다. ChatGoogleGenerativeAI의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_google_genai.chat_models.ChatGoogleGenerativeAI.html)를 참조하세요.

Google AI는 여러 가지 다른 채팅 모델을 제공합니다. 최신 모델, 기능, 컨텍스트 윈도우 등에 대한 정보는 [Google AI 문서](https://ai.google.dev/gemini-api/docs/models/gemini)를 참조하세요.

:::info Google AI vs Google Cloud Vertex AI

Google의 Gemini 모델은 Google AI와 Google Cloud Vertex AI를 통해 접근할 수 있습니다. Google AI를 사용하려면 Google 계정과 API 키만 필요합니다. Google Cloud Vertex AI를 사용하려면 Google Cloud 계정(약관 동의 및 청구 포함)이 필요하지만, 고객 암호화 키, 가상 사설 클라우드 등과 같은 엔터프라이즈 기능을 제공합니다.

두 API의 주요 기능에 대해 자세히 알아보려면 [Google 문서](https://cloud.google.com/vertex-ai/generative-ai/docs/migrate/migrate-google-ai#google-ai)를 참조하세요.

:::

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/google_generativeai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatGoogleGenerativeAI](https://api.python.langchain.com/en/latest/chat_models/langchain_google_genai.chat_models.ChatGoogleGenerativeAI.html) | [langchain-google-genai](https://api.python.langchain.com/en/latest/google_genai_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-google-genai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-google-genai?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | 

## 설정

Google AI 모델에 접근하려면 Google Acount 계정을 생성하고, Google AI API 키를 얻고, `langchain-google-genai` 통합 패키지를 설치해야 합니다.

### 자격 증명

https://ai.google.dev/gemini-api/docs/api-key로 이동하여 Google AI API 키를 생성하세요. 완료되면 GOOGLE_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["GOOGLE_API_KEY"] = getpass.getpass("Enter your Google AI API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 제거하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Google AI 통합은 `langchain-google-genai` 패키지에 있습니다:

```python
%pip install -qU langchain-google-genai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완료를 생성할 수 있습니다:

```python
from langchain_google_genai import ChatGoogleGenerativeAI

llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-pro",
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
AIMessage(content="J'adore programmer. \n", response_metadata={'prompt_feedback': {'block_reason': 0, 'safety_ratings': []}, 'finish_reason': 'STOP', 'safety_ratings': [{'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability': 'NEGLIGIBLE', 'blocked': False}]}, id='run-eef5b138-1da6-4226-9cfe-ab9073ddd77e-0', usage_metadata={'input_tokens': 21, 'output_tokens': 5, 'total_tokens': 26})
```


```python
print(ai_msg.content)
```

```output
J'adore programmer.
```

## 체이닝

다음과 같이 프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatGoogleGenerativeAI"}]-->
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
AIMessage(content='Ich liebe das Programmieren. \n', response_metadata={'prompt_feedback': {'block_reason': 0, 'safety_ratings': []}, 'finish_reason': 'STOP', 'safety_ratings': [{'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'probability': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HATE_SPEECH', 'probability': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_HARASSMENT', 'probability': 'NEGLIGIBLE', 'blocked': False}, {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'probability': 'NEGLIGIBLE', 'blocked': False}]}, id='run-fbb35f30-4937-4a81-ae68-f7cb35721a0c-0', usage_metadata={'input_tokens': 16, 'output_tokens': 7, 'total_tokens': 23})
```


## 안전 설정

Gemini 모델은 기본 안전 설정이 있으며 이를 재정의할 수 있습니다. 모델에서 "안전 경고"가 많이 발생하는 경우 모델의 `safety_settings` 속성을 조정해 볼 수 있습니다. 예를 들어, 위험한 콘텐츠에 대한 안전 차단을 끄려면 다음과 같이 LLM을 구성할 수 있습니다:

```python
from langchain_google_genai import (
    ChatGoogleGenerativeAI,
    HarmBlockThreshold,
    HarmCategory,
)

llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-pro",
    safety_settings={
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
    },
)
```


사용 가능한 카테고리 및 임계값의 열거에 대해서는 Google의 [안전 설정 유형](https://ai.google.dev/api/python/google/generativeai/types/SafetySettingDict)을 참조하세요.

## API 참조

ChatGoogleGenerativeAI의 모든 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_google_genai.chat_models.ChatGoogleGenerativeAI.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)