---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/nvidia_ai_endpoints.ipynb
description: NVIDIA의 채팅 모델을 시작하는 데 도움이 되는 문서로, LangChain 통합 및 NIM 추론 마이크로서비스에 대한 정보를
  제공합니다.
sidebar_label: NVIDIA AI Endpoints
---

# ChatNVIDIA

이 문서는 NVIDIA [채팅 모델](/docs/concepts/#chat-models)을 시작하는 데 도움이 됩니다. 모든 `ChatNVIDIA` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html)에서 확인할 수 있습니다.

## 개요
`langchain-nvidia-ai-endpoints` 패키지는 NVIDIA NIM 추론 마이크로서비스에서 모델을 사용하여 애플리케이션을 구축하는 LangChain 통합을 포함합니다. NIM은 커뮤니티와 NVIDIA의 채팅, 임베딩 및 재순위 모델과 같은 다양한 도메인에서 모델을 지원합니다. 이러한 모델은 NVIDIA에 의해 최적화되어 NVIDIA 가속 인프라에서 최고의 성능을 제공하며, 단일 명령으로 어디서나 배포할 수 있는 사용하기 쉬운 사전 구축된 컨테이너인 NIM으로 배포됩니다.

NVIDIA가 호스팅하는 NIM의 배포는 [NVIDIA API 카탈로그](https://build.nvidia.com/)에서 테스트할 수 있습니다. 테스트 후, NIM은 NVIDIA AI 엔터프라이즈 라이센스를 사용하여 NVIDIA의 API 카탈로그에서 내보내고 온프레미스 또는 클라우드에서 실행할 수 있어 기업이 자신의 IP 및 AI 애플리케이션에 대한 소유권과 완전한 제어를 가질 수 있습니다.

NIM은 모델별로 컨테이너 이미지로 패키징되며 NVIDIA NGC 카탈로그를 통해 NGC 컨테이너 이미지로 배포됩니다. NIM의 핵심은 AI 모델에서 추론을 실행하기 위한 쉽고 일관되며 친숙한 API를 제공하는 것입니다.

이 예제는 `ChatNVIDIA` 클래스를 통해 NVIDIA 지원과 상호작용하는 방법을 설명합니다.

이 API를 통해 채팅 모델에 액세스하는 방법에 대한 자세한 내용은 [ChatNVIDIA](https://python.langchain.com/docs/integrations/chat/nvidia_ai_endpoints/) 문서를 확인하십시오.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatNVIDIA](https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html) | [langchain_nvidia_ai_endpoints](https://api.python.langchain.com/en/latest/nvidia_ai_endpoints_api_reference.html) | ✅ | beta | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_nvidia_ai_endpoints?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_nvidia_ai_endpoints?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [Logprobs](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | 

## 설정

**시작하려면:**

1. NVIDIA AI Foundation 모델을 호스팅하는 [NVIDIA](https://build.nvidia.com/)에서 무료 계정을 만드세요.
2. 원하는 모델을 클릭하세요.
3. `Input`에서 `Python` 탭을 선택하고 `Get API Key`를 클릭하세요. 그런 다음 `Generate Key`를 클릭하세요.
4. 생성된 키를 `NVIDIA_API_KEY`로 복사하고 저장하세요. 그 후, 엔드포인트에 액세스할 수 있어야 합니다.

### 자격 증명

```python
import getpass
import os

if not os.getenv("NVIDIA_API_KEY"):
    # Note: the API key should start with "nvapi-"
    os.environ["NVIDIA_API_KEY"] = getpass.getpass("Enter your NVIDIA API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain NVIDIA AI Endpoints 통합은 `langchain_nvidia_ai_endpoints` 패키지에 있습니다:

```python
%pip install --upgrade --quiet langchain-nvidia-ai-endpoints
```


## 인스턴스화

이제 NVIDIA API 카탈로그에서 모델에 액세스할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatNVIDIA", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html", "title": "ChatNVIDIA"}]-->
## Core LC Chat Interface
from langchain_nvidia_ai_endpoints import ChatNVIDIA

llm = ChatNVIDIA(model="mistralai/mixtral-8x7b-instruct-v0.1")
```


## 호출

```python
result = llm.invoke("Write a ballad about LangChain.")
print(result.content)
```


## NVIDIA NIM 작업
배포할 준비가 되면 NVIDIA NIM으로 모델을 자체 호스팅할 수 있으며, 이는 NVIDIA AI 엔터프라이즈 소프트웨어 라이센스에 포함되어 있으며 어디서나 실행할 수 있어 사용자 정의에 대한 소유권과 지적 재산(IP) 및 AI 애플리케이션에 대한 완전한 제어를 제공합니다.

[NIM에 대해 자세히 알아보기](https://developer.nvidia.com/blog/nvidia-nim-offers-optimized-inference-microservices-for-deploying-ai-models-at-scale/)

```python
<!--IMPORTS:[{"imported": "ChatNVIDIA", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html", "title": "ChatNVIDIA"}]-->
from langchain_nvidia_ai_endpoints import ChatNVIDIA

# connect to an embedding NIM running at localhost:8000, specifying a specific model
llm = ChatNVIDIA(base_url="http://localhost:8000/v1", model="meta/llama3-8b-instruct")
```


## 스트리밍, 배치 및 비동기

이 모델은 기본적으로 스트리밍을 지원하며, 모든 LangChain LLM과 마찬가지로 동시 요청을 처리하기 위한 배치 메서드와 호출, 스트리밍 및 배치를 위한 비동기 메서드를 제공합니다. 아래는 몇 가지 예입니다.

```python
print(llm.batch(["What's 2*3?", "What's 2*6?"]))
# Or via the async API
# await llm.abatch(["What's 2*3?", "What's 2*6?"])
```


```python
for chunk in llm.stream("How far can a seagull fly in one day?"):
    # Show the token separations
    print(chunk.content, end="|")
```


```python
async for chunk in llm.astream(
    "How long does it take for monarch butterflies to migrate?"
):
    print(chunk.content, end="|")
```


## 지원되는 모델

`available_models`를 쿼리하면 API 자격 증명으로 제공되는 모든 다른 모델을 여전히 얻을 수 있습니다.

`playground_` 접두사는 선택 사항입니다.

```python
ChatNVIDIA.get_available_models()
# llm.get_available_models()
```


## 모델 유형

위의 모든 모델은 지원되며 `ChatNVIDIA`를 통해 액세스할 수 있습니다.

일부 모델 유형은 고유한 프롬프트 기법 및 채팅 메시지를 지원합니다. 아래에서 몇 가지 중요한 내용을 검토하겠습니다.

**특정 모델에 대한 자세한 내용을 보려면 AI Foundation 모델의 API 섹션 [여기 링크](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/ai-foundation/models/codellama-13b/api)로 이동하십시오.**

### 일반 채팅

`meta/llama3-8b-instruct` 및 `mistralai/mixtral-8x22b-instruct-v0.1`와 같은 모델은 LangChain 채팅 메시지와 함께 사용할 수 있는 좋은 전반적인 모델입니다. 아래 예시를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "ChatNVIDIA"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatNVIDIA"}, {"imported": "ChatNVIDIA", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html", "title": "ChatNVIDIA"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_nvidia_ai_endpoints import ChatNVIDIA

prompt = ChatPromptTemplate.from_messages(
    [("system", "You are a helpful AI assistant named Fred."), ("user", "{input}")]
)
chain = prompt | ChatNVIDIA(model="meta/llama3-8b-instruct") | StrOutputParser()

for txt in chain.stream({"input": "What's your name?"}):
    print(txt, end="")
```


### 코드 생성

이 모델은 일반 채팅 모델과 동일한 인수 및 입력 구조를 수용하지만 코드 생성 및 구조화된 코드 작업에서 더 나은 성능을 발휘하는 경향이 있습니다. 이의 예로는 `meta/codellama-70b`가 있습니다.

```python
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an expert coding AI. Respond only in valid python; no narration whatsoever.",
        ),
        ("user", "{input}"),
    ]
)
chain = prompt | ChatNVIDIA(model="meta/codellama-70b") | StrOutputParser()

for txt in chain.stream({"input": "How do I solve this fizz buzz problem?"}):
    print(txt, end="")
```


## 다중 모드

NVIDIA는 또한 다중 모드 입력을 지원하여 모델이 이미지와 텍스트를 모두 제공받아 추론할 수 있습니다. 다중 모드 입력을 지원하는 모델의 예로는 `nvidia/neva-22b`가 있습니다.

아래는 사용 예입니다:

```python
import IPython
import requests

image_url = "https://www.nvidia.com/content/dam/en-zz/Solutions/research/ai-playground/nvidia-picasso-3c33-p@2x.jpg"  ## Large Image
image_content = requests.get(image_url).content

IPython.display.Image(image_content)
```


```python
<!--IMPORTS:[{"imported": "ChatNVIDIA", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html", "title": "ChatNVIDIA"}]-->
from langchain_nvidia_ai_endpoints import ChatNVIDIA

llm = ChatNVIDIA(model="nvidia/neva-22b")
```


#### URL로 이미지를 전달하기

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatNVIDIA"}]-->
from langchain_core.messages import HumanMessage

llm.invoke(
    [
        HumanMessage(
            content=[
                {"type": "text", "text": "Describe this image:"},
                {"type": "image_url", "image_url": {"url": image_url}},
            ]
        )
    ]
)
```


#### base64 인코딩된 문자열로 이미지를 전달하기

현재 위와 같은 큰 이미지를 지원하기 위해 클라이언트 측에서 추가 처리가 발생합니다. 그러나 더 작은 이미지(그리고 프로세스가 진행되는 방식을 더 잘 설명하기 위해)에서는 아래와 같이 이미지를 직접 전달할 수 있습니다:

```python
import IPython
import requests

image_url = "https://picsum.photos/seed/kitten/300/200"
image_content = requests.get(image_url).content

IPython.display.Image(image_content)
```


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatNVIDIA"}]-->
import base64

from langchain_core.messages import HumanMessage

## Works for simpler images. For larger images, see actual implementation
b64_string = base64.b64encode(image_content).decode("utf-8")

llm.invoke(
    [
        HumanMessage(
            content=[
                {"type": "text", "text": "Describe this image:"},
                {
                    "type": "image_url",
                    "image_url": {"url": f"data:image/png;base64,{b64_string}"},
                },
            ]
        )
    ]
)
```


#### 문자열 내에서 직접

NVIDIA API는 `<img/>` HTML 태그 내에 인라인된 base64 이미지로 이미지를 독특하게 수용합니다. 이는 다른 LLM과 상호 운용되지 않지만, 모델을 적절히 프롬프트할 수 있습니다.

```python
base64_with_mime_type = f"data:image/png;base64,{b64_string}"
llm.invoke(f'What\'s in this image?\n<img src="{base64_with_mime_type}" />')
```


## RunnableWithMessageHistory 내에서의 예제 사용

다른 통합과 마찬가지로 ChatNVIDIA는 `ConversationChain`을 사용하는 것과 유사한 RunnableWithMessageHistory와 같은 채팅 유틸리티를 지원합니다. 아래에서는 `mistralai/mixtral-8x22b-instruct-v0.1` 모델에 적용된 [LangChain RunnableWithMessageHistory](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html) 예제를 보여줍니다.

```python
%pip install --upgrade --quiet langchain
```


```python
<!--IMPORTS:[{"imported": "InMemoryChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.InMemoryChatMessageHistory.html", "title": "ChatNVIDIA"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "ChatNVIDIA"}]-->
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

# store is a dictionary that maps session IDs to their corresponding chat histories.
store = {}  # memory is maintained outside the chain


# A function that returns the chat history for a given session ID.
def get_session_history(session_id: str) -> InMemoryChatMessageHistory:
    if session_id not in store:
        store[session_id] = InMemoryChatMessageHistory()
    return store[session_id]


chat = ChatNVIDIA(
    model="mistralai/mixtral-8x22b-instruct-v0.1",
    temperature=0.1,
    max_tokens=100,
    top_p=1.0,
)

#  Define a RunnableConfig object, with a `configurable` key. session_id determines thread
config = {"configurable": {"session_id": "1"}}

conversation = RunnableWithMessageHistory(
    chat,
    get_session_history,
)

conversation.invoke(
    "Hi I'm Srijan Dubey.",  # input or query
    config=config,
)
```


```python
conversation.invoke(
    "I'm doing well! Just having a conversation with an AI.",
    config=config,
)
```


```python
conversation.invoke(
    "Tell me about yourself.",
    config=config,
)
```


## 도구 호출

v0.2부터 `ChatNVIDIA`는 [bind_tools](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.BaseChatModel.html#langchain_core.language_models.chat_models.BaseChatModel.bind_tools)를 지원합니다.

`ChatNVIDIA`는 [build.nvidia.com](https://build.nvidia.com)에서 다양한 모델과 로컬 NIM과 통합을 제공합니다. 이러한 모든 모델이 도구 호출을 위해 훈련된 것은 아닙니다. 실험 및 애플리케이션을 위해 도구 호출이 가능한 모델을 선택해야 합니다.

도구 호출을 지원하는 모델 목록을 얻으려면,

```python
tool_models = [
    model for model in ChatNVIDIA.get_available_models() if model.supports_tools
]
tool_models
```


도구가 가능한 모델로,

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "ChatNVIDIA"}]-->
from langchain_core.pydantic_v1 import Field
from langchain_core.tools import tool


@tool
def get_current_weather(
    location: str = Field(..., description="The location to get the weather for."),
):
    """Get the current weather for a location."""
    ...


llm = ChatNVIDIA(model=tool_models[0].id).bind_tools(tools=[get_current_weather])
response = llm.invoke("What is the weather in Boston?")
response.tool_calls
```


추가 예제는 [도구 호출을 위한 채팅 모델 사용 방법](https://python.langchain.com/v0.2/docs/how_to/tool_calling/)을 참조하십시오.

## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatNVIDIA"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate(
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


## API 참조

모든 `ChatNVIDIA` 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)