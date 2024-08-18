---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/openai.ipynb
description: 이 문서는 OpenAI 채팅 모델을 시작하는 방법에 대한 개요를 제공하며, API 참조 및 Azure OpenAI 통합에 대한
  정보를 포함합니다.
sidebar_label: OpenAI
---

# ChatOpenAI

이 노트북은 OpenAI [채팅 모델](/docs/concepts/#chat-models)을 시작하는 데 필요한 간단한 개요를 제공합니다. ChatOpenAI의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html)에서 확인하세요.

OpenAI는 여러 채팅 모델을 제공합니다. 최신 모델과 비용, 컨텍스트 창, 지원되는 입력 유형에 대한 정보는 [OpenAI 문서](https://platform.openai.com/docs/models)에서 확인할 수 있습니다.

:::info Azure OpenAI

특정 OpenAI 모델은 [Microsoft Azure 플랫폼](https://azure.microsoft.com/en-us/products/ai-services/openai-service)을 통해서도 접근할 수 있습니다. Azure OpenAI 서비스를 사용하려면 [AzureChatOpenAI 통합](/docs/integrations/chat/azure_chat_openai/)을 사용하세요.

:::

## 개요

### 통합 세부정보
| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/openai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatOpenAI](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html) | [langchain-openai](https://api.python.langchain.com/en/latest/openai_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-openai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-openai?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | 이미지 입력 | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [Logprobs](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | 

## 설정

OpenAI 모델에 접근하려면 OpenAI 계정을 생성하고, API 키를 얻고, `langchain-openai` 통합 패키지를 설치해야 합니다.

### 자격 증명

https://platform.openai.com 에서 OpenAI에 가입하고 API 키를 생성하세요. 이 작업을 완료한 후 OPENAI_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

if not os.environ.get("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass("Enter your OpenAI API key: ")
```


모델 호출에 대한 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain OpenAI 통합은 `langchain-openai` 패키지에 있습니다:

```python
%pip install -qU langchain-openai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "ChatOpenAI"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="gpt-4o",
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
    # api_key="...",  # if you prefer to pass api key in directly instaed of using env vars
    # base_url="...",
    # organization="...",
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
AIMessage(content="J'adore la programmation.", additional_kwargs={'refusal': None}, response_metadata={'token_usage': {'completion_tokens': 5, 'prompt_tokens': 31, 'total_tokens': 36}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_3aa7262c27', 'finish_reason': 'stop', 'logprobs': None}, id='run-63219b22-03e3-4561-8cc4-78b7c7c3a3ca-0', usage_metadata={'input_tokens': 31, 'output_tokens': 5, 'total_tokens': 36})
```


```python
print(ai_msg.content)
```

```output
J'adore la programmation.
```

## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatOpenAI"}]-->
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
AIMessage(content='Ich liebe das Programmieren.', additional_kwargs={'refusal': None}, response_metadata={'token_usage': {'completion_tokens': 6, 'prompt_tokens': 26, 'total_tokens': 32}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_3aa7262c27', 'finish_reason': 'stop', 'logprobs': None}, id='run-350585e1-16ca-4dad-9460-3d9e7e49aaf1-0', usage_metadata={'input_tokens': 26, 'output_tokens': 6, 'total_tokens': 32})
```


## 도구 호출

OpenAI는 도구와 그 인수를 설명하고 모델이 호출할 도구와 해당 도구의 입력을 포함하는 JSON 객체를 반환하도록 하는 [도구 호출](https://platform.openai.com/docs/guides/function-calling) API를 제공합니다. 도구 호출은 도구를 사용하는 체인과 에이전트를 구축하고, 모델에서 구조화된 출력을 얻는 데 매우 유용합니다.

### ChatOpenAI.bind_tools()

`ChatOpenAI.bind_tools`를 사용하면 Pydantic 클래스, dict 스키마, LangChain 도구 또는 심지어 함수를 도구로 모델에 쉽게 전달할 수 있습니다. 내부적으로 이러한 것은 OpenAI 도구 스키마로 변환되어 다음과 같이 보입니다:
```
{
    "name": "...",
    "description": "...",
    "parameters": {...}  # JSONSchema
}
```

모든 모델 호출에 전달됩니다.

```python
from pydantic import BaseModel, Field


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
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_o9udf3EVOWiV4Iupktpbpofk', 'function': {'arguments': '{"location":"San Francisco, CA"}', 'name': 'GetWeather'}, 'type': 'function'}], 'refusal': None}, response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 68, 'total_tokens': 85}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_3aa7262c27', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-1617c9b2-dda5-4120-996b-0333ed5992e2-0', tool_calls=[{'name': 'GetWeather', 'args': {'location': 'San Francisco, CA'}, 'id': 'call_o9udf3EVOWiV4Iupktpbpofk', 'type': 'tool_call'}], usage_metadata={'input_tokens': 68, 'output_tokens': 17, 'total_tokens': 85})
```


### `strict=True`

:::info `langchain-openai>=0.1.21rc1` 필요

:::

2024년 8월 6일 기준으로 OpenAI는 도구를 호출할 때 모델이 도구 인수 스키마를 준수하도록 강제하는 `strict` 인수를 지원합니다. 자세한 내용은 여기에서 확인하세요: https://platform.openai.com/docs/guides/function-calling

**참고**: `strict=True`인 경우 도구 정의도 검증되며, JSON 스키마의 하위 집합이 허용됩니다. 중요한 것은 스키마에 선택적 인수(기본값이 있는 인수)를 포함할 수 없다는 것입니다. 지원되는 스키마의 유형에 대한 전체 문서는 여기에서 확인하세요: https://platform.openai.com/docs/guides/structured-outputs/supported-schemas. 

```python
llm_with_tools = llm.bind_tools([GetWeather], strict=True)
ai_msg = llm_with_tools.invoke(
    "what is the weather like in San Francisco",
)
ai_msg
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_jUqhd8wzAIzInTJl72Rla8ht', 'function': {'arguments': '{"location":"San Francisco, CA"}', 'name': 'GetWeather'}, 'type': 'function'}], 'refusal': None}, response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 68, 'total_tokens': 85}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_3aa7262c27', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-5e3356a9-132d-4623-8e73-dd5a898cf4a6-0', tool_calls=[{'name': 'GetWeather', 'args': {'location': 'San Francisco, CA'}, 'id': 'call_jUqhd8wzAIzInTJl72Rla8ht', 'type': 'tool_call'}], usage_metadata={'input_tokens': 68, 'output_tokens': 17, 'total_tokens': 85})
```


### AIMessage.tool_calls
AIMessage에는 `tool_calls` 속성이 있습니다. 이는 모델 제공자에 구애받지 않는 표준화된 ToolCall 형식을 포함합니다.

```python
ai_msg.tool_calls
```


```output
[{'name': 'GetWeather',
  'args': {'location': 'San Francisco, CA'},
  'id': 'call_jUqhd8wzAIzInTJl72Rla8ht',
  'type': 'tool_call'}]
```


도구 바인딩 및 도구 호출 출력에 대한 자세한 내용은 [도구 호출](/docs/how_to/function_calling) 문서를 참조하세요.

## 미세 조정

해당하는 `modelName` 매개변수를 전달하여 미세 조정된 OpenAI 모델을 호출할 수 있습니다.

일반적으로 이는 `ft:{OPENAI_MODEL_NAME}:{ORG_NAME}::{MODEL_ID}` 형식을 취합니다. 예를 들어:

```python
fine_tuned_model = ChatOpenAI(
    temperature=0, model_name="ft:gpt-3.5-turbo-0613:langchain::7qTVM5AR"
)

fine_tuned_model.invoke(messages)
```


```output
AIMessage(content="J'adore la programmation.", additional_kwargs={'refusal': None}, response_metadata={'token_usage': {'completion_tokens': 8, 'prompt_tokens': 31, 'total_tokens': 39}, 'model_name': 'ft:gpt-3.5-turbo-0613:langchain::7qTVM5AR', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-0f39b30e-c56e-4f3b-af99-5c948c984146-0', usage_metadata={'input_tokens': 31, 'output_tokens': 8, 'total_tokens': 39})
```


## API 참조

ChatOpenAI의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)