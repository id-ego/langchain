---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/litellm.ipynb
description: Langchain과 LiteLLM I/O 라이브러리를 사용하여 Anthropic, Azure, Huggingface 등과의
  통합을 간편하게 시작하는 방법을 다룹니다.
sidebar_label: LiteLLM
---

# ChatLiteLLM

[LiteLLM](https://github.com/BerriAI/litellm)은 Anthropic, Azure, Huggingface, Replicate 등을 호출하는 과정을 간소화하는 라이브러리입니다.

이 노트북은 Langchain + LiteLLM I/O 라이브러리를 사용하는 방법을 소개합니다.

```python
<!--IMPORTS:[{"imported": "ChatLiteLLM", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.litellm.ChatLiteLLM.html", "title": "ChatLiteLLM"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatLiteLLM"}]-->
from langchain_community.chat_models import ChatLiteLLM
from langchain_core.messages import HumanMessage
```


```python
chat = ChatLiteLLM(model="gpt-3.5-turbo")
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
AIMessage(content=" J'aime la programmation.", additional_kwargs={}, example=False)
```


## `ChatLiteLLM`은 비동기 및 스트리밍 기능도 지원합니다:

```python
<!--IMPORTS:[{"imported": "CallbackManager", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "ChatLiteLLM"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "ChatLiteLLM"}]-->
from langchain_core.callbacks import CallbackManager, StreamingStdOutCallbackHandler
```


```python
await chat.agenerate([messages])
```


```output
LLMResult(generations=[[ChatGeneration(text=" J'aime programmer.", generation_info=None, message=AIMessage(content=" J'aime programmer.", additional_kwargs={}, example=False))]], llm_output={}, run=[RunInfo(run_id=UUID('8cc8fb68-1c35-439c-96a0-695036a93652'))])
```


```python
chat = ChatLiteLLM(
    streaming=True,
    verbose=True,
    callback_manager=CallbackManager([StreamingStdOutCallbackHandler()]),
)
chat(messages)
```

```output
 J'aime la programmation.
```


```output
AIMessage(content=" J'aime la programmation.", additional_kwargs={}, example=False)
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)