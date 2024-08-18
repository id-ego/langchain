---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/edenai.ipynb
description: Eden AI는 다양한 AI 제공업체를 통합하여 사용자가 인공지능의 잠재력을 최대한 활용할 수 있도록 돕는 혁신적인 플랫폼입니다.
---

# 에덴 AI

에덴 AI는 최고의 AI 제공업체를 통합하여 AI 환경을 혁신하고, 사용자가 무한한 가능성을 열고 인공지능의 진정한 잠재력을 활용할 수 있도록 합니다. 올인원 종합 플랫폼을 통해 사용자는 AI 기능을 신속하게 배포할 수 있으며, 단일 API를 통해 AI 기능의 모든 범위에 쉽게 접근할 수 있습니다. (웹사이트: https://edenai.co/)

이 예제는 LangChain을 사용하여 에덴 AI 모델과 상호작용하는 방법을 설명합니다.

* * *

`EdenAI`는 단순한 모델 호출을 넘어섭니다. 다음과 같은 고급 기능을 제공합니다:

- **다양한 제공업체**: 다양한 제공업체가 제공하는 다양한 언어 모델에 접근하여 사용 사례에 가장 적합한 모델을 선택할 수 있는 자유를 제공합니다.
- **대체 메커니즘**: 기본 제공업체가 사용할 수 없는 경우에도 원활한 작업을 보장하기 위해 대체 메커니즘을 설정할 수 있으며, 쉽게 다른 제공업체로 전환할 수 있습니다.
- **사용량 추적**: 프로젝트별 및 API 키별로 사용량 통계를 추적할 수 있습니다. 이 기능을 통해 리소스 소비를 효과적으로 모니터링하고 관리할 수 있습니다.
- **모니터링 및 관찰 가능성**: `EdenAI`는 플랫폼에서 포괄적인 모니터링 및 관찰 가능성 도구를 제공합니다. 언어 모델의 성능을 모니터링하고, 사용 패턴을 분석하며, 애플리케이션을 최적화하기 위한 귀중한 통찰력을 얻을 수 있습니다.

EDENAI의 API에 접근하려면 API 키가 필요합니다,

계정을 생성하여 https://app.edenai.run/user/register 에서 키를 받을 수 있으며, 여기로 이동하여 https://app.edenai.run/admin/iam/api-keys 키를 받을 수 있습니다.

키를 받은 후, 다음 명령어를 실행하여 환경 변수로 설정합니다:

```bash
export EDENAI_API_KEY="..."
```


API 참조에 대한 자세한 내용은 다음 링크를 참조하세요: https://docs.edenai.co/reference

환경 변수를 설정하지 않으려면 EdenAI Chat Model 클래스를 초기화할 때 edenai_api_key라는 매개변수를 통해 직접 키를 전달할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatEdenAI", "source": "langchain_community.chat_models.edenai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.edenai.ChatEdenAI.html", "title": "Eden AI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Eden AI"}]-->
from langchain_community.chat_models.edenai import ChatEdenAI
from langchain_core.messages import HumanMessage
```


```python
chat = ChatEdenAI(
    edenai_api_key="...", provider="openai", temperature=0.2, max_tokens=250
)
```


```python
messages = [HumanMessage(content="Hello !")]
chat.invoke(messages)
```


```output
AIMessage(content='Hello! How can I assist you today?')
```


```python
await chat.ainvoke(messages)
```


```output
AIMessage(content='Hello! How can I assist you today?')
```


## 스트리밍 및 배치

`ChatEdenAI`는 스트리밍 및 배치를 지원합니다. 아래는 예제입니다.

```python
for chunk in chat.stream(messages):
    print(chunk.content, end="", flush=True)
```

```output
Hello! How can I assist you today?
```


```python
chat.batch([messages])
```


```output
[AIMessage(content='Hello! How can I assist you today?')]
```


## 대체 메커니즘

에덴 AI를 사용하면 기본 제공업체가 사용할 수 없는 경우에도 원활한 작업을 보장하기 위해 대체 메커니즘을 설정할 수 있으며, 쉽게 다른 제공업체로 전환할 수 있습니다.

```python
chat = ChatEdenAI(
    edenai_api_key="...",
    provider="openai",
    temperature=0.2,
    max_tokens=250,
    fallback_providers="google",
)
```


이 예제에서는 OpenAI에 문제가 발생할 경우 Google을 백업 제공업체로 사용할 수 있습니다.

에덴 AI에 대한 더 많은 정보와 세부 사항은 다음 링크를 확인하세요: https://docs.edenai.co/docs/additional-parameters

## 호출 연결

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Eden AI"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template(
    "What is a good name for a company that makes {product}?"
)
chain = prompt | chat
```


```python
chain.invoke({"product": "healthy snacks"})
```


```output
AIMessage(content='VitalBites')
```


## 도구

### bind_tools()

`ChatEdenAI.bind_tools`를 사용하면 Pydantic 클래스, dict 스키마, LangChain 도구 또는 함수 등을 모델에 도구로 쉽게 전달할 수 있습니다.

```python
from langchain_core.pydantic_v1 import BaseModel, Field

llm = ChatEdenAI(provider="openai", temperature=0.2, max_tokens=500)


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
AIMessage(content='', response_metadata={'openai': {'status': 'success', 'generated_text': None, 'message': [{'role': 'user', 'message': 'what is the weather like in San Francisco', 'tools': [{'name': 'GetWeather', 'description': 'Get the current weather in a given location', 'parameters': {'type': 'object', 'properties': {'location': {'description': 'The city and state, e.g. San Francisco, CA', 'type': 'string'}}, 'required': ['location']}}], 'tool_calls': None}, {'role': 'assistant', 'message': None, 'tools': None, 'tool_calls': [{'id': 'call_tRpAO7KbQwgTjlka70mCQJdo', 'name': 'GetWeather', 'arguments': '{"location":"San Francisco"}'}]}], 'cost': 0.000194}}, id='run-5c44c01a-d7bb-4df6-835e-bda596080399-0', tool_calls=[{'name': 'GetWeather', 'args': {'location': 'San Francisco'}, 'id': 'call_tRpAO7KbQwgTjlka70mCQJdo'}])
```


```python
ai_msg.tool_calls
```


```output
[{'name': 'GetWeather',
  'args': {'location': 'San Francisco'},
  'id': 'call_tRpAO7KbQwgTjlka70mCQJdo'}]
```


### with_structured_output()

BaseChatModel.with_structured_output 인터페이스를 사용하면 채팅 모델에서 구조화된 출력을 쉽게 얻을 수 있습니다. 도구 호출을 사용하여 ChatEdenAI.with_structured_output를 사용하여 모델이 특정 형식으로 출력을 더 신뢰성 있게 반환하도록 할 수 있습니다:

```python
structured_llm = llm.with_structured_output(GetWeather)
structured_llm.invoke(
    "what is the weather like in San Francisco",
)
```


```output
GetWeather(location='San Francisco')
```


### 도구 결과를 모델에 전달하기

도구를 사용하는 방법에 대한 전체 예제입니다. 도구 출력을 모델에 전달하고, 모델로부터 결과를 다시 받습니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Eden AI"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "Eden AI"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "Eden AI"}]-->
from langchain_core.messages import HumanMessage, ToolMessage
from langchain_core.tools import tool


@tool
def add(a: int, b: int) -> int:
    """Adds a and b.

    Args:
        a: first int
        b: second int
    """
    return a + b


llm = ChatEdenAI(
    provider="openai",
    max_tokens=1000,
    temperature=0.2,
)

llm_with_tools = llm.bind_tools([add], tool_choice="required")

query = "What is 11 + 11?"

messages = [HumanMessage(query)]
ai_msg = llm_with_tools.invoke(messages)
messages.append(ai_msg)

tool_call = ai_msg.tool_calls[0]
tool_output = add.invoke(tool_call["args"])

# This append the result from our tool to the model
messages.append(ToolMessage(tool_output, tool_call_id=tool_call["id"]))

llm_with_tools.invoke(messages).content
```


```output
'11 + 11 = 22'
```


### 스트리밍

에덴 AI는 현재 스트리밍 도구 호출을 지원하지 않습니다. 스트리밍을 시도하면 단일 최종 메시지가 생성됩니다.

```python
list(llm_with_tools.stream("What's 9 + 9"))
```

```output
/home/eden/Projects/edenai-langchain/libs/community/langchain_community/chat_models/edenai.py:603: UserWarning: stream: Tool use is not yet supported in streaming mode.
  warnings.warn("stream: Tool use is not yet supported in streaming mode.")
```


```output
[AIMessageChunk(content='', id='run-fae32908-ec48-4ab2-ad96-bb0d0511754f', tool_calls=[{'name': 'add', 'args': {'a': 9, 'b': 9}, 'id': 'call_n0Tm7I9zERWa6UpxCAVCweLN'}], tool_call_chunks=[{'name': 'add', 'args': '{"a": 9, "b": 9}', 'id': 'call_n0Tm7I9zERWa6UpxCAVCweLN', 'index': 0}])]
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)