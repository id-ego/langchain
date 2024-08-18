---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/deepinfra.ipynb
description: DeepInfra는 다양한 LLM 및 임베딩 모델에 대한 서버리스 추론 서비스를 제공하며, LangChain과의 통합 방법을
  설명합니다.
---

# DeepInfra

[DeepInfra](https://deepinfra.com/?utm_source=langchain)는 다양한 [LLM](https://deepinfra.com/models?utm_source=langchain) 및 [임베딩 모델](https://deepinfra.com/models?type=embeddings&utm_source=langchain)에 대한 접근을 제공하는 서버리스 추론 서비스입니다. 이 노트북에서는 DeepInfra와 함께 LangChain을 사용하여 채팅 모델을 사용하는 방법을 설명합니다.

## 환경 API 키 설정
DeepInfra에서 API 키를 받아야 합니다. [로그인](https://deepinfra.com/login?from=%2Fdash)하여 새 토큰을 받아야 합니다.

다양한 모델을 테스트하기 위해 1시간의 무료 서버리스 GPU 컴퓨팅이 제공됩니다. (자세한 내용은 [여기](https://github.com/deepinfra/deepctl#deepctl) 참조)
`deepctl auth token`으로 토큰을 출력할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatDeepInfra", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.deepinfra.ChatDeepInfra.html", "title": "DeepInfra"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "DeepInfra"}]-->
# get a new token: https://deepinfra.com/login?from=%2Fdash

import os
from getpass import getpass

from langchain_community.chat_models import ChatDeepInfra
from langchain_core.messages import HumanMessage

DEEPINFRA_API_TOKEN = getpass()

# or pass deepinfra_api_token parameter to the ChatDeepInfra constructor
os.environ["DEEPINFRA_API_TOKEN"] = DEEPINFRA_API_TOKEN

chat = ChatDeepInfra(model="meta-llama/Llama-2-7b-chat-hf")

messages = [
    HumanMessage(
        content="Translate this sentence from English to French. I love programming."
    )
]
chat.invoke(messages)
```


## `ChatDeepInfra`는 비동기 및 스트리밍 기능도 지원합니다:

```python
<!--IMPORTS:[{"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "DeepInfra"}]-->
from langchain_core.callbacks import StreamingStdOutCallbackHandler
```


```python
await chat.agenerate([messages])
```


```python
chat = ChatDeepInfra(
    streaming=True,
    verbose=True,
    callbacks=[StreamingStdOutCallbackHandler()],
)
chat.invoke(messages)
```


# 도구 호출

DeepInfra는 현재 invoke 및 async invoke 도구 호출만 지원합니다.

도구 호출을 지원하는 모델의 전체 목록은 [도구 호출 문서](https://deepinfra.com/docs/advanced/function_calling)를 참조하시기 바랍니다.

```python
<!--IMPORTS:[{"imported": "ChatDeepInfra", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.deepinfra.ChatDeepInfra.html", "title": "DeepInfra"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "DeepInfra"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "DeepInfra"}]-->
import asyncio

from dotenv import find_dotenv, load_dotenv
from langchain_community.chat_models import ChatDeepInfra
from langchain_core.messages import HumanMessage
from langchain_core.pydantic_v1 import BaseModel
from langchain_core.tools import tool

model_name = "meta-llama/Meta-Llama-3-70B-Instruct"

_ = load_dotenv(find_dotenv())


# Langchain tool
@tool
def foo(something):
    """
    Called when foo
    """
    pass


# Pydantic class
class Bar(BaseModel):
    """
    Called when Bar
    """

    pass


llm = ChatDeepInfra(model=model_name)
tools = [foo, Bar]
llm_with_tools = llm.bind_tools(tools)
messages = [
    HumanMessage("Foo and bar, please."),
]

response = llm_with_tools.invoke(messages)
print(response.tool_calls)
# [{'name': 'foo', 'args': {'something': None}, 'id': 'call_Mi4N4wAtW89OlbizFE1aDxDj'}, {'name': 'Bar', 'args': {}, 'id': 'call_daiE0mW454j2O1KVbmET4s2r'}]


async def call_ainvoke():
    result = await llm_with_tools.ainvoke(messages)
    print(result.tool_calls)


# Async call
asyncio.run(call_ainvoke())
# [{'name': 'foo', 'args': {'something': None}, 'id': 'call_ZH7FetmgSot4LHcMU6CEb8tI'}, {'name': 'Bar', 'args': {}, 'id': 'call_2MQhDifAJVoijZEvH8PeFSVB'}]
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)