---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/anthropic.ipynb
description: 이 문서는 Anthropic의 채팅 모델을 시작하는 방법에 대한 개요를 제공합니다. API 참조 및 통합 정보도 포함되어 있습니다.
sidebar_label: Anthropic
---

# ChatAnthropic

이 노트북은 Anthropic [채팅 모델](/docs/concepts/#chat-models)을 시작하는 데 필요한 간단한 개요를 제공합니다. ChatAnthropic의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html)에서 확인할 수 있습니다.

Anthropic에는 여러 채팅 모델이 있습니다. 최신 모델과 비용, 컨텍스트 윈도우, 지원되는 입력 유형에 대한 정보는 [Anthropic 문서](https://docs.anthropic.com/en/docs/models-overview)에서 확인할 수 있습니다.

:::info AWS Bedrock 및 Google VertexAI

일부 Anthropic 모델은 AWS Bedrock 및 Google VertexAI를 통해서도 접근할 수 있습니다. 이러한 서비스를 통해 Anthropic 모델을 사용하려면 [ChatBedrock](/docs/integrations/chat/bedrock/) 및 [ChatVertexAI](/docs/integrations/chat/google_vertex_ai_palm/) 통합을 참조하세요.

:::

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/anthropic) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatAnthropic](https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html) | [langchain-anthropic](https://api.python.langchain.com/en/latest/anthropic_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-anthropic?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-anthropic?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [Logprobs](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | 

## 설정

Anthropic 모델에 접근하려면 Anthropic 계정을 생성하고, API 키를 얻고, `langchain-anthropic` 통합 패키지를 설치해야 합니다.

### 자격 증명

https://console.anthropic.com/ 에 접속하여 Anthropic에 가입하고 API 키를 생성하세요. 이 작업을 완료한 후 ANTHROPIC_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

os.environ["ANTHROPIC_API_KEY"] = getpass.getpass("Enter your Anthropic API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain Anthropic 통합은 `langchain-anthropic` 패키지에 있습니다:

```python
%pip install -qU langchain-anthropic
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "ChatAnthropic"}]-->
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(
    model="claude-3-5-sonnet-20240620",
    temperature=0,
    max_tokens=1024,
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
AIMessage(content="J'adore la programmation.", response_metadata={'id': 'msg_018Nnu76krRPq8HvgKLW4F8T', 'model': 'claude-3-5-sonnet-20240620', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 29, 'output_tokens': 11}}, id='run-57e9295f-db8a-48dc-9619-babd2bedd891-0', usage_metadata={'input_tokens': 29, 'output_tokens': 11, 'total_tokens': 40})
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
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatAnthropic"}]-->
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
AIMessage(content="Here's the German translation:\n\nIch liebe Programmieren.", response_metadata={'id': 'msg_01GhkRtQZUkA5Ge9hqmD8HGY', 'model': 'claude-3-5-sonnet-20240620', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 23, 'output_tokens': 18}}, id='run-da5906b4-b200-4e08-b81a-64d4453643b6-0', usage_metadata={'input_tokens': 23, 'output_tokens': 18, 'total_tokens': 41})
```


## 콘텐츠 블록

Anthropic 모델과 대부분의 다른 모델 간의 주요 차이점 중 하나는 단일 Anthropic AI 메시지의 내용이 단일 문자열이거나 **콘텐츠 블록 목록**일 수 있다는 점입니다. 예를 들어, Anthropic 모델이 도구를 호출할 때, 도구 호출은 메시지 내용의 일부입니다 (표준화된 `AIMessage.tool_calls`에서 노출됨):

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class GetWeather(BaseModel):
    """Get the current weather in a given location"""

    location: str = Field(..., description="The city and state, e.g. San Francisco, CA")


llm_with_tools = llm.bind_tools([GetWeather])
ai_msg = llm_with_tools.invoke("Which city is hotter today: LA or NY?")
ai_msg.content
```


```output
[{'text': "To answer this question, we'll need to check the current weather in both Los Angeles (LA) and New York (NY). I'll use the GetWeather function to retrieve this information for both cities.",
  'type': 'text'},
 {'id': 'toolu_01Ddzj5PkuZkrjF4tafzu54A',
  'input': {'location': 'Los Angeles, CA'},
  'name': 'GetWeather',
  'type': 'tool_use'},
 {'id': 'toolu_012kz4qHZQqD4qg8sFPeKqpP',
  'input': {'location': 'New York, NY'},
  'name': 'GetWeather',
  'type': 'tool_use'}]
```


```python
ai_msg.tool_calls
```


```output
[{'name': 'GetWeather',
  'args': {'location': 'Los Angeles, CA'},
  'id': 'toolu_01Ddzj5PkuZkrjF4tafzu54A'},
 {'name': 'GetWeather',
  'args': {'location': 'New York, NY'},
  'id': 'toolu_012kz4qHZQqD4qg8sFPeKqpP'}]
```


## API 참조

ChatAnthropic의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)