---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/gpt_router.ipynb
description: GPTRouter는 30개 이상의 LLM 및 이미지 모델을 위한 오픈 소스 API 게이트웨이로, 스마트 폴백 및 스트리밍 기능을
  제공합니다.
sidebar_label: GPTRouter
---

# GPTRouter

[GPTRouter](https://github.com/Writesonic/GPTRouter)는 30개 이상의 LLM, 비전 및 이미지 모델을 위한 보편적인 API를 제공하는 오픈 소스 LLM API 게이트웨이로, 가동 시간 및 대기 시간을 기반으로 한 스마트 폴백, 자동 재시도 및 스트리밍 기능을 제공합니다.

이 노트북에서는 Langchain + GPTRouter I/O 라이브러리를 사용하는 방법을 다룹니다.

* `GPT_ROUTER_API_KEY` 환경 변수를 설정합니다.
* 또는 `gpt_router_api_key` 키워드 인수를 사용합니다.

```python
%pip install --upgrade --quiet  GPTRouter
```

```output
Requirement already satisfied: GPTRouter in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (0.1.3)
Requirement already satisfied: pydantic==2.5.2 in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from GPTRouter) (2.5.2)
Requirement already satisfied: httpx>=0.25.2 in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from GPTRouter) (0.25.2)
Requirement already satisfied: annotated-types>=0.4.0 in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from pydantic==2.5.2->GPTRouter) (0.6.0)
Requirement already satisfied: pydantic-core==2.14.5 in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from pydantic==2.5.2->GPTRouter) (2.14.5)
Requirement already satisfied: typing-extensions>=4.6.1 in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from pydantic==2.5.2->GPTRouter) (4.8.0)
Requirement already satisfied: idna in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from httpx>=0.25.2->GPTRouter) (3.6)
Requirement already satisfied: anyio in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from httpx>=0.25.2->GPTRouter) (3.7.1)
Requirement already satisfied: sniffio in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from httpx>=0.25.2->GPTRouter) (1.3.0)
Requirement already satisfied: certifi in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from httpx>=0.25.2->GPTRouter) (2023.11.17)
Requirement already satisfied: httpcore==1.* in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from httpx>=0.25.2->GPTRouter) (1.0.2)
Requirement already satisfied: h11<0.15,>=0.13 in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from httpcore==1.*->httpx>=0.25.2->GPTRouter) (0.14.0)
Requirement already satisfied: exceptiongroup in /Users/sirjan-ws/.pyenv/versions/3.10.13/envs/langchain_venv5/lib/python3.10/site-packages (from anyio->httpx>=0.25.2->GPTRouter) (1.2.0)

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m23.0.1[0m[39;49m -> [0m[32;49m23.3.2[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
Note: you may need to restart the kernel to use updated packages.
```


```python
<!--IMPORTS:[{"imported": "GPTRouter", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.gpt_router.GPTRouter.html", "title": "GPTRouter"}, {"imported": "GPTRouterModel", "source": "langchain_community.chat_models.gpt_router", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.gpt_router.GPTRouterModel.html", "title": "GPTRouter"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "GPTRouter"}]-->
from langchain_community.chat_models import GPTRouter
from langchain_community.chat_models.gpt_router import GPTRouterModel
from langchain_core.messages import HumanMessage
```


```python
anthropic_claude = GPTRouterModel(name="claude-instant-1.2", provider_name="anthropic")
```


```python
chat = GPTRouter(models_priority_list=[anthropic_claude])
```


```python
messages = [
    HumanMessage(
        content="Translate this sentence from English to French. I love programming."
    )
]
chat(messages)
```


```output
AIMessage(content=" J'aime programmer.")
```


## `GPTRouter`는 비동기 및 스트리밍 기능도 지원합니다:

```python
<!--IMPORTS:[{"imported": "CallbackManager", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "GPTRouter"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "GPTRouter"}]-->
from langchain_core.callbacks import CallbackManager, StreamingStdOutCallbackHandler
```


```python
await chat.agenerate([messages])
```


```output
LLMResult(generations=[[ChatGeneration(text=" J'aime programmer.", generation_info={'finish_reason': 'stop_sequence'}, message=AIMessage(content=" J'aime programmer."))]], llm_output={}, run=[RunInfo(run_id=UUID('9885f27f-c35a-4434-9f37-c254259762a5'))])
```


```python
chat = GPTRouter(
    models_priority_list=[anthropic_claude],
    streaming=True,
    verbose=True,
    callback_manager=CallbackManager([StreamingStdOutCallbackHandler()]),
)
chat(messages)
```

```output
 J'aime programmer.
```


```output
AIMessage(content=" J'aime programmer.")
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)