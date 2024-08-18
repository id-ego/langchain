---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/ibm_watsonx.ipynb
description: ChatWatsonx는 IBM watsonx.ai 모델과 LangChain LLMs API를 사용하여 통신하는 방법을 보여주는
  래퍼입니다.
sidebar_label: IBM watsonx.ai
---

# ChatWatsonx

> ChatWatsonx는 IBM [watsonx.ai](https://www.ibm.com/products/watsonx-ai) 기초 모델을 위한 래퍼입니다.

이 예제의 목적은 `LangChain` LLMs API를 사용하여 `watsonx.ai` 모델과 소통하는 방법을 보여주는 것입니다.

## 개요

### 통합 세부정보
| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/openai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatWatsonx](https://api.python.langchain.com/en/latest/ibm_api_reference.html) | [langchain-ibm](https://api.python.langchain.com/en/latest/ibm_api_reference.html) | ❌ | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-ibm?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-ibm?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling/) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | 이미지 입력 | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용량](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | 

## 설정

IBM watsonx.ai 모델에 접근하려면 IBM watsonx.ai 계정을 생성하고, API 키를 얻고, `langchain-ibm` 통합 패키지를 설치해야 합니다.

### 자격 증명

아래 셀은 watsonx 기초 모델 추론을 위해 필요한 자격 증명을 정의합니다.

**작업:** IBM Cloud 사용자 API 키를 제공하십시오. 자세한 내용은 [사용자 API 키 관리](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui)를 참조하십시오.

```python
import os
from getpass import getpass

watsonx_api_key = getpass()
os.environ["WATSONX_APIKEY"] = watsonx_api_key
```


추가 비밀을 환경 변수로 전달할 수도 있습니다.

```python
import os

os.environ["WATSONX_URL"] = "your service instance url"
os.environ["WATSONX_TOKEN"] = "your token for accessing the CPD cluster"
os.environ["WATSONX_PASSWORD"] = "your password for accessing the CPD cluster"
os.environ["WATSONX_USERNAME"] = "your username for accessing the CPD cluster"
os.environ["WATSONX_INSTANCE_ID"] = "your instance_id for accessing the CPD cluster"
```


### 설치

LangChain IBM 통합은 `langchain-ibm` 패키지에 있습니다:

```python
!pip install -qU langchain-ibm
```


## 인스턴스화

다양한 모델이나 작업에 대해 모델 `parameters`를 조정해야 할 수 있습니다. 자세한 내용은 [사용 가능한 메타 이름](https://ibm.github.io/watsonx-ai-python-sdk/fm_model.html#metanames.GenTextParamsMetaNames)을 참조하십시오.

```python
parameters = {
    "decoding_method": "sample",
    "max_new_tokens": 100,
    "min_new_tokens": 1,
    "stop_sequences": ["."],
}
```


이전 설정된 매개변수로 `WatsonxLLM` 클래스를 초기화합니다.

**참고**: 

- API 호출에 대한 컨텍스트를 제공하려면 `project_id` 또는 `space_id`를 전달해야 합니다. 프로젝트 또는 공간 ID를 얻으려면 프로젝트 또는 공간을 열고 **관리** 탭으로 이동한 후 **일반**을 클릭하십시오. 자세한 내용은 [프로젝트 문서](https://www.ibm.com/docs/en/watsonx-as-a-service?topic=projects) 또는 [배포 공간 문서](https://www.ibm.com/docs/en/watsonx/saas?topic=spaces-creating-deployment)를 참조하십시오.
- 프로비저닝된 서비스 인스턴스의 지역에 따라 [watsonx.ai API 인증](https://ibm.github.io/watsonx-ai-python-sdk/setup_cloud.html#authentication)에 나열된 URL 중 하나를 사용하십시오.

이 예제에서는 `project_id`와 Dallas URL을 사용할 것입니다.

추론에 사용할 `model_id`를 지정해야 합니다. 사용 가능한 모든 모델의 목록은 [지원되는 기초 모델](https://ibm.github.io/watsonx-ai-python-sdk/fm_model.html#ibm_watsonx_ai.foundation_models.utils.enums.ModelTypes)에서 확인할 수 있습니다.

```python
from langchain_ibm import ChatWatsonx

chat = ChatWatsonx(
    model_id="ibm/granite-13b-chat-v2",
    url="https://us-south.ml.cloud.ibm.com",
    project_id="PASTE YOUR PROJECT_ID HERE",
    params=parameters,
)
```


대신 Cloud Pak for Data 자격 증명을 사용할 수도 있습니다. 자세한 내용은 [watsonx.ai 소프트웨어 설정](https://ibm.github.io/watsonx-ai-python-sdk/setup_cpd.html)을 참조하십시오.  

```python
chat = ChatWatsonx(
    model_id="ibm/granite-13b-chat-v2",
    url="PASTE YOUR URL HERE",
    username="PASTE YOUR USERNAME HERE",
    password="PASTE YOUR PASSWORD HERE",
    instance_id="openshift",
    version="4.8",
    project_id="PASTE YOUR PROJECT_ID HERE",
    params=parameters,
)
```


`model_id` 대신 이전에 조정된 모델의 `deployment_id`를 전달할 수도 있습니다. 전체 모델 조정 워크플로우는 [TuneExperiment 및 PromptTuner 작업하기](https://ibm.github.io/watsonx-ai-python-sdk/pt_working_with_class_and_prompt_tuner.html)에서 설명되어 있습니다.

```python
chat = ChatWatsonx(
    deployment_id="PASTE YOUR DEPLOYMENT_ID HERE",
    url="https://us-south.ml.cloud.ibm.com",
    project_id="PASTE YOUR PROJECT_ID HERE",
    params=parameters,
)
```


## 호출

완성을 얻으려면 문자열 프롬프트를 사용하여 모델을 직접 호출할 수 있습니다.

```python
# Invocation

messages = [
    ("system", "You are a helpful assistant that translates English to French."),
    (
        "human",
        "I love you for listening to Rock.",
    ),
]

chat.invoke(messages)
```


```output
AIMessage(content="Je t'aime pour écouter la Rock.", response_metadata={'token_usage': {'generated_token_count': 12, 'input_token_count': 28}, 'model_name': 'ibm/granite-13b-chat-v2', 'system_fingerprint': '', 'finish_reason': 'stop_sequence'}, id='run-05b305ce-5401-4a10-b557-41a4b15c7f6f-0')
```


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatWatsonx"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatWatsonx"}]-->
# Invocation multiple chat
from langchain_core.messages import (
    HumanMessage,
    SystemMessage,
)

system_message = SystemMessage(
    content="You are a helpful assistant which telling short-info about provided topic."
)
human_message = HumanMessage(content="horse")

chat.invoke([system_message, human_message])
```


```output
AIMessage(content='Sure, I can help you with that! Horses are large, powerful mammals that belong to the family Equidae.', response_metadata={'token_usage': {'generated_token_count': 24, 'input_token_count': 24}, 'model_name': 'ibm/granite-13b-chat-v2', 'system_fingerprint': '', 'finish_reason': 'stop_sequence'}, id='run-391776ff-3b38-4768-91e8-ff64177149e5-0')
```


## 체인
무작위 질문을 생성하는 `ChatPromptTemplate` 객체를 생성합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatWatsonx"}]-->
from langchain_core.prompts import ChatPromptTemplate

system = (
    "You are a helpful assistant that translates {input_language} to {output_language}."
)
human = "{input}"
prompt = ChatPromptTemplate.from_messages([("system", system), ("human", human)])
```


입력을 제공하고 체인을 실행합니다.

```python
chain = prompt | chat
chain.invoke(
    {
        "input_language": "English",
        "output_language": "German",
        "input": "I love Python",
    }
)
```


```output
AIMessage(content='Ich liebe Python.', response_metadata={'token_usage': {'generated_token_count': 5, 'input_token_count': 23}, 'model_name': 'ibm/granite-13b-chat-v2', 'system_fingerprint': '', 'finish_reason': 'stop_sequence'}, id='run-1b1ccf5d-0e33-46f2-a087-e2a136ba1fb7-0')
```


## 모델 출력 스트리밍

모델 출력을 스트리밍할 수 있습니다.

```python
system_message = SystemMessage(
    content="You are a helpful assistant which telling short-info about provided topic."
)
human_message = HumanMessage(content="moon")

for chunk in chat.stream([system_message, human_message]):
    print(chunk.content, end="")
```

```output
The moon is a natural satellite of the Earth, and it has been a source of fascination for humans for centuries.
```


## 모델 출력 배치

모델 출력을 배치할 수 있습니다.

```python
message_1 = [
    SystemMessage(
        content="You are a helpful assistant which telling short-info about provided topic."
    ),
    HumanMessage(content="cat"),
]
message_2 = [
    SystemMessage(
        content="You are a helpful assistant which telling short-info about provided topic."
    ),
    HumanMessage(content="dog"),
]

chat.batch([message_1, message_2])
```


```output
[AIMessage(content='Cats are domestic animals that belong to the Felidae family.', response_metadata={'token_usage': {'generated_token_count': 13, 'input_token_count': 24}, 'model_name': 'ibm/granite-13b-chat-v2', 'system_fingerprint': '', 'finish_reason': 'stop_sequence'}, id='run-71a8bd7a-a1aa-497b-9bdd-a4d6fe1d471a-0'),
 AIMessage(content='Dogs are domesticated mammals of the family Canidae, characterized by their adaptability to various environments and social structures.', response_metadata={'token_usage': {'generated_token_count': 24, 'input_token_count': 24}, 'model_name': 'ibm/granite-13b-chat-v2', 'system_fingerprint': '', 'finish_reason': 'stop_sequence'}, id='run-22b7a0cb-e44a-4b68-9921-872f82dcd82b-0')]
```


## 도구 호출

### ChatWatsonx.bind_tools()

`ChatWatsonx.bind_tools`는 베타 상태에 있으므로 현재 `mistralai/mixtral-8x7b-instruct-v01` 모델만 지원합니다.

전체 모델 응답을 얻으려면 `max_new_tokens` 매개변수를 재정의해야 합니다. 기본적으로 `max_new_tokens`는 20으로 설정되어 있습니다.

```python
from langchain_ibm import ChatWatsonx

parameters = {"max_new_tokens": 200}

chat = ChatWatsonx(
    model_id="mistralai/mixtral-8x7b-instruct-v01",
    url="https://us-south.ml.cloud.ibm.com",
    project_id="PASTE YOUR PROJECT_ID HERE",
    params=parameters,
)
```


```python
from langchain_core.pydantic_v1 import BaseModel, Field


class GetWeather(BaseModel):
    """Get the current weather in a given location"""

    location: str = Field(..., description="The city and state, e.g. San Francisco, CA")


llm_with_tools = chat.bind_tools([GetWeather])
```


```python
ai_msg = llm_with_tools.invoke(
    "Which city is hotter today: LA or NY?",
)
ai_msg
```


```output
AIMessage(content='', additional_kwargs={'function_call': {'type': 'function'}, 'tool_calls': [{'type': 'function', 'function': {'name': 'GetWeather', 'arguments': '{"location": "Los Angeles"}'}, 'id': None}, {'type': 'function', 'function': {'name': 'GetWeather', 'arguments': '{"location": "New York"}'}, 'id': None}]}, response_metadata={'token_usage': {'generated_token_count': 99, 'input_token_count': 320}, 'model_name': 'mistralai/mixtral-8x7b-instruct-v01', 'system_fingerprint': '', 'finish_reason': 'eos_token'}, id='run-38627104-f2ac-4edb-8390-d5425fb65979-0', tool_calls=[{'name': 'GetWeather', 'args': {'location': 'Los Angeles'}, 'id': None}, {'name': 'GetWeather', 'args': {'location': 'New York'}, 'id': None}])
```


### AIMessage.tool_calls
AIMessage에는 `tool_calls` 속성이 있습니다. 이는 모델 제공자에 구애받지 않는 표준화된 ToolCall 형식을 포함합니다.

```python
ai_msg.tool_calls
```


```output
[{'name': 'GetWeather', 'args': {'location': 'Los Angeles'}, 'id': None},
 {'name': 'GetWeather', 'args': {'location': 'New York'}, 'id': None}]
```


## API 참조

IBM watsonx.ai의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하십시오: https://api.python.langchain.com/en/latest/ibm_api_reference.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)