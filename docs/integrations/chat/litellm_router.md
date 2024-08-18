---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/litellm_router.ipynb
description: 이 문서는 Langchain과 LiteLLM Router I/O 라이브러리를 사용하여 Anthropic, Azure, Huggingface
  등을 호출하는 방법을 소개합니다.
sidebar_label: LiteLLM Router
---

# ChatLiteLLMRouter

[LiteLLM](https://github.com/BerriAI/litellm)은 Anthropic, Azure, Huggingface, Replicate 등을 호출하는 것을 간소화하는 라이브러리입니다.

이 노트북에서는 Langchain + LiteLLM Router I/O 라이브러리를 사용하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "ChatLiteLLMRouter", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.litellm_router.ChatLiteLLMRouter.html", "title": "ChatLiteLLMRouter"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatLiteLLMRouter"}]-->
from langchain_community.chat_models import ChatLiteLLMRouter
from langchain_core.messages import HumanMessage
from litellm import Router
```


```python
model_list = [
    {
        "model_name": "gpt-4",
        "litellm_params": {
            "model": "azure/gpt-4-1106-preview",
            "api_key": "<your-api-key>",
            "api_version": "2023-05-15",
            "api_base": "https://<your-endpoint>.openai.azure.com/",
        },
    },
    {
        "model_name": "gpt-4",
        "litellm_params": {
            "model": "azure/gpt-4-1106-preview",
            "api_key": "<your-api-key>",
            "api_version": "2023-05-15",
            "api_base": "https://<your-endpoint>.openai.azure.com/",
        },
    },
]
litellm_router = Router(model_list=model_list)
chat = ChatLiteLLMRouter(router=litellm_router)
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
AIMessage(content="J'aime programmer.")
```


## `ChatLiteLLMRouter`는 비동기 및 스트리밍 기능도 지원합니다:

```python
<!--IMPORTS:[{"imported": "CallbackManager", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "ChatLiteLLMRouter"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "ChatLiteLLMRouter"}]-->
from langchain_core.callbacks import CallbackManager, StreamingStdOutCallbackHandler
```


```python
await chat.agenerate([messages])
```


```output
LLMResult(generations=[[ChatGeneration(text="J'adore programmer.", generation_info={'finish_reason': 'stop'}, message=AIMessage(content="J'adore programmer."))]], llm_output={'token_usage': {'completion_tokens': 6, 'prompt_tokens': 19, 'total_tokens': 25}, 'model_name': None}, run=[RunInfo(run_id=UUID('75003ec9-1e2b-43b7-a216-10dcc0f75e00'))])
```


```python
chat = ChatLiteLLMRouter(
    router=litellm_router,
    streaming=True,
    verbose=True,
    callback_manager=CallbackManager([StreamingStdOutCallbackHandler()]),
)
chat(messages)
```

```output
J'adore programmer.
```


```output
AIMessage(content="J'adore programmer.")
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)