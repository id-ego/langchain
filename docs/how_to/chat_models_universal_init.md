---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chat_models_universal_init.ipynb
description: 이 문서는 다양한 LLM 모델을 손쉽게 초기화할 수 있는 `init_chat_model()` 메서드 사용법을 설명합니다.
---

# 모델을 한 줄로 초기화하는 방법

많은 LLM 애플리케이션은 최종 사용자가 애플리케이션이 어떤 모델 제공자와 모델로 구동되기를 원하는지를 지정할 수 있게 합니다. 이는 사용자 구성에 따라 다양한 ChatModel을 초기화하는 로직을 작성해야 함을 의미합니다. `init_chat_model()` 헬퍼 메서드는 import 경로와 클래스 이름에 대해 걱정할 필요 없이 다양한 모델 통합을 쉽게 초기화할 수 있게 해줍니다.

:::tip 지원되는 모델

지원되는 통합의 전체 목록은 [init_chat_model()](https://api.python.langchain.com/en/latest/chat_models/langchain.chat_models.base.init_chat_model.html) API 참조를 확인하세요.

지원하고자 하는 모델 제공자에 대한 통합 패키지가 설치되어 있는지 확인하세요. 예를 들어, OpenAI 모델을 초기화하려면 `langchain-openai`가 설치되어 있어야 합니다.

:::

:::info `langchain >= 0.2.8` 필요

이 기능은 `langchain-core == 0.2.8`에 추가되었습니다. 패키지가 최신 상태인지 확인하세요.

:::

```python
%pip install -qU langchain>=0.2.8 langchain-openai langchain-anthropic langchain-google-vertexai
```


## 기본 사용법

```python
<!--IMPORTS:[{"imported": "init_chat_model", "source": "langchain.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain.chat_models.base.init_chat_model.html", "title": "How to init any model in one line"}]-->
from langchain.chat_models import init_chat_model

# Returns a langchain_openai.ChatOpenAI instance.
gpt_4o = init_chat_model("gpt-4o", model_provider="openai", temperature=0)
# Returns a langchain_anthropic.ChatAnthropic instance.
claude_opus = init_chat_model(
    "claude-3-opus-20240229", model_provider="anthropic", temperature=0
)
# Returns a langchain_google_vertexai.ChatVertexAI instance.
gemini_15 = init_chat_model(
    "gemini-1.5-pro", model_provider="google_vertexai", temperature=0
)

# Since all model integrations implement the ChatModel interface, you can use them in the same way.
print("GPT-4o: " + gpt_4o.invoke("what's your name").content + "\n")
print("Claude Opus: " + claude_opus.invoke("what's your name").content + "\n")
print("Gemini 1.5: " + gemini_15.invoke("what's your name").content + "\n")
```

```output
GPT-4o: I'm an AI created by OpenAI, and I don't have a personal name. You can call me Assistant! How can I help you today?

Claude Opus: My name is Claude. It's nice to meet you!

Gemini 1.5: I am a large language model, trained by Google. I do not have a name.
```

## 모델 제공자 추론

일반적이고 구별되는 모델 이름에 대해 `init_chat_model()`은 모델 제공자를 추론하려고 시도합니다. 추론 동작의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain.chat_models.base.init_chat_model.html)를 확인하세요. 예를 들어, `gpt-3...` 또는 `gpt-4...`로 시작하는 모든 모델은 모델 제공자 `openai`를 사용하는 것으로 추론됩니다.

```python
gpt_4o = init_chat_model("gpt-4o", temperature=0)
claude_opus = init_chat_model("claude-3-opus-20240229", temperature=0)
gemini_15 = init_chat_model("gemini-1.5-pro", temperature=0)
```


## 구성 가능한 모델 만들기

`configurable_fields`를 지정하여 런타임 구성 가능한 모델을 만들 수도 있습니다. `model` 값을 지정하지 않으면 기본적으로 "model"과 "model_provider"가 구성 가능하게 됩니다.

```python
configurable_model = init_chat_model(temperature=0)

configurable_model.invoke(
    "what's your name", config={"configurable": {"model": "gpt-4o"}}
)
```


```output
AIMessage(content="I'm an AI language model created by OpenAI, and I don't have a personal name. You can call me Assistant or any other name you prefer! How can I assist you today?", response_metadata={'token_usage': {'completion_tokens': 37, 'prompt_tokens': 11, 'total_tokens': 48}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_d576307f90', 'finish_reason': 'stop', 'logprobs': None}, id='run-5428ab5c-b5c0-46de-9946-5d4ca40dbdc8-0', usage_metadata={'input_tokens': 11, 'output_tokens': 37, 'total_tokens': 48})
```


```python
configurable_model.invoke(
    "what's your name", config={"configurable": {"model": "claude-3-5-sonnet-20240620"}}
)
```


```output
AIMessage(content="My name is Claude. It's nice to meet you!", response_metadata={'id': 'msg_012XvotUJ3kGLXJUWKBVxJUi', 'model': 'claude-3-5-sonnet-20240620', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 11, 'output_tokens': 15}}, id='run-1ad1eefe-f1c6-4244-8bc6-90e2cb7ee554-0', usage_metadata={'input_tokens': 11, 'output_tokens': 15, 'total_tokens': 26})
```


### 기본값이 있는 구성 가능한 모델

기본 모델 값으로 구성 가능한 모델을 만들고, 어떤 매개변수가 구성 가능한지 지정하며, 구성 가능한 매개변수에 접두사를 추가할 수 있습니다:

```python
first_llm = init_chat_model(
    model="gpt-4o",
    temperature=0,
    configurable_fields=("model", "model_provider", "temperature", "max_tokens"),
    config_prefix="first",  # useful when you have a chain with multiple models
)

first_llm.invoke("what's your name")
```


```output
AIMessage(content="I'm an AI language model created by OpenAI, and I don't have a personal name. You can call me Assistant or any other name you prefer! How can I assist you today?", response_metadata={'token_usage': {'completion_tokens': 37, 'prompt_tokens': 11, 'total_tokens': 48}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_ce0793330f', 'finish_reason': 'stop', 'logprobs': None}, id='run-3923e328-7715-4cd6-b215-98e4b6bf7c9d-0', usage_metadata={'input_tokens': 11, 'output_tokens': 37, 'total_tokens': 48})
```


```python
first_llm.invoke(
    "what's your name",
    config={
        "configurable": {
            "first_model": "claude-3-5-sonnet-20240620",
            "first_temperature": 0.5,
            "first_max_tokens": 100,
        }
    },
)
```


```output
AIMessage(content="My name is Claude. It's nice to meet you!", response_metadata={'id': 'msg_01RyYR64DoMPNCfHeNnroMXm', 'model': 'claude-3-5-sonnet-20240620', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 11, 'output_tokens': 15}}, id='run-22446159-3723-43e6-88df-b84797e7751d-0', usage_metadata={'input_tokens': 11, 'output_tokens': 15, 'total_tokens': 26})
```


### 선언적으로 구성 가능한 모델 사용하기

구성 가능한 모델에서 `bind_tools`, `with_structured_output`, `with_configurable` 등의 선언적 작업을 호출하고, 일반적으로 인스턴스화된 채팅 모델 객체와 같은 방식으로 구성 가능한 모델을 체인할 수 있습니다.

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class GetWeather(BaseModel):
    """Get the current weather in a given location"""

    location: str = Field(..., description="The city and state, e.g. San Francisco, CA")


class GetPopulation(BaseModel):
    """Get the current population in a given location"""

    location: str = Field(..., description="The city and state, e.g. San Francisco, CA")


llm = init_chat_model(temperature=0)
llm_with_tools = llm.bind_tools([GetWeather, GetPopulation])

llm_with_tools.invoke(
    "what's bigger in 2024 LA or NYC", config={"configurable": {"model": "gpt-4o"}}
).tool_calls
```


```output
[{'name': 'GetPopulation',
  'args': {'location': 'Los Angeles, CA'},
  'id': 'call_sYT3PFMufHGWJD32Hi2CTNUP'},
 {'name': 'GetPopulation',
  'args': {'location': 'New York, NY'},
  'id': 'call_j1qjhxRnD3ffQmRyqjlI1Lnk'}]
```


```python
llm_with_tools.invoke(
    "what's bigger in 2024 LA or NYC",
    config={"configurable": {"model": "claude-3-5-sonnet-20240620"}},
).tool_calls
```


```output
[{'name': 'GetPopulation',
  'args': {'location': 'Los Angeles, CA'},
  'id': 'toolu_01CxEHxKtVbLBrvzFS7GQ5xR'},
 {'name': 'GetPopulation',
  'args': {'location': 'New York City, NY'},
  'id': 'toolu_013A79qt5toWSsKunFBDZd5S'}]
```