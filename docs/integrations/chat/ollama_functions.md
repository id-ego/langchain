---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/ollama_functions.ipynb
description: 이 문서는 Ollama의 도구 호출 기능을 지원하는 실험적 래퍼 사용법을 설명합니다. 다양한 모델과 통합 세부정보를 포함합니다.
sidebar_class_name: hidden
sidebar_label: Ollama Functions
---

# OllamaFunctions

:::warning

이것은 본래 도구 호출 지원이 원래 내장되어 있지 않은 모델에 추가하기 위한 실험적인 래퍼입니다. [주요 Ollama 통합](/docs/integrations/chat/ollama/)은 이제 도구 호출을 지원하며, 대신 사용해야 합니다.

:::
이 노트북은 Ollama 주위에 실험적인 래퍼를 사용하는 방법을 보여주며, 이를 통해 [도구 호출 기능](https://python.langchain.com/v0.2/docs/concepts/#functiontool-calling)을 제공합니다.

더 강력하고 유능한 모델이 복잡한 스키마 및/또는 여러 기능을 사용할 때 더 나은 성능을 발휘할 것입니다. 아래 예제는 llama3 및 phi3 모델을 사용합니다.
지원되는 모델 및 모델 변형의 전체 목록은 [Ollama 모델 라이브러리](https://ollama.ai/library)를 참조하십시오.

## 개요

### 통합 세부정보

|                                                                클래스                                                                | 패키지 | 로컬 | 직렬화 가능 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
|:-----------------------------------------------------------------------------------------------------------------------------------:|:-------:|:-----:|:------------:|:----------:|:-----------------:|:--------------:|
| [OllamaFunctions](https://api.python.langchain.com/en/latest/llms/langchain_experimental.llms.ollama_function.OllamaFunctions.html) | [langchain-experimental](https://api.python.langchain.com/en/latest/openai_api_reference.html) | ✅ | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-experimental?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-experimental?style=flat-square&label=%20) |

### 모델 기능

| [도구 호출](/docs/how_to/tool_calling/) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | 이미지 입력 | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [Logprobs](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |

## 설정

`OllamaFunctions`에 접근하려면 `langchain-experimental` 통합 패키지를 설치해야 합니다.
[이 지침](https://github.com/jmorganca/ollama)에 따라 로컬 Ollama 인스턴스를 설정하고 실행하며 [지원되는 모델](https://ollama.com/library)을 다운로드하고 제공하십시오.

### 자격 증명

현재 자격 증명 지원은 없습니다.

### 설치

`OllamaFunctions` 클래스는 `langchain-experimental` 패키지에 있습니다:

```python
%pip install -qU langchain-experimental
```


## 인스턴스화

`OllamaFunctions`는 `ChatOllama`와 동일한 초기화 매개변수를 사용합니다.

도구 호출을 사용하려면 `format="json"`을 지정해야 합니다.

```python
<!--IMPORTS:[{"imported": "OllamaFunctions", "source": "langchain_experimental.llms.ollama_functions", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_experimental.llms.ollama_functions.OllamaFunctions.html", "title": "OllamaFunctions"}]-->
from langchain_experimental.llms.ollama_functions import OllamaFunctions

llm = OllamaFunctions(model="phi3")
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
AIMessage(content="J'adore programmer.", id='run-94815fcf-ae11-438a-ba3f-00819328b5cd-0')
```


```python
ai_msg.content
```


```output
"J'adore programmer."
```


## 체이닝

다음과 같이 프롬프트 템플릿으로 모델을 [체인](https://python.langchain.com/v0.2/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "OllamaFunctions"}]-->
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
AIMessage(content='Programmieren ist sehr verrückt! Es freut mich, dass Sie auf Programmierung so positiv eingestellt sind.', id='run-ee99be5e-4d48-4ab6-b602-35415f0bdbde-0')
```


## 도구 호출

### OllamaFunctions.bind_tools()

`OllamaFunctions.bind_tools`를 사용하면 Pydantic 클래스, dict 스키마, LangChain 도구 또는 함수조차도 모델에 도구로 쉽게 전달할 수 있습니다. 내부적으로 이는 도구 정의 스키마로 변환됩니다. 이는 다음과 같습니다:

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class GetWeather(BaseModel):
    """Get the current weather in a given location"""

    location: str = Field(..., description="The city and state, e.g. San Francisco, CA")


llm_with_tools = llm.bind_tools([GetWeather])
```


```python
ai_msg = llm_with_tools.invoke(
    "what is the weather like in San Francisco",
)
ai_msg
```


```output
AIMessage(content='', id='run-b9769435-ec6a-4cb8-8545-5a5035fc19bd-0', tool_calls=[{'name': 'GetWeather', 'args': {'location': 'San Francisco, CA'}, 'id': 'call_064c4e1cb27e4adb9e4e7ed60362ecc9'}])
```


### AIMessage.tool_calls

AIMessage에는 `tool_calls` 속성이 있습니다. 이는 표준화된 `ToolCall` 형식으로 포함되어 있으며, 모델 제공자에 독립적입니다.

```python
ai_msg.tool_calls
```


```output
[{'name': 'GetWeather',
  'args': {'location': 'San Francisco, CA'},
  'id': 'call_064c4e1cb27e4adb9e4e7ed60362ecc9'}]
```


도구 바인딩 및 도구 호출 출력에 대한 자세한 내용은 [도구 호출](../../how_to/function_calling.md) 문서를 참조하십시오.

## API 참조

모든 ToolCallingLLM 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/llms/langchain_experimental.llms.ollama_functions.OllamaFunctions.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)