---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/custom_chat_model.ipynb
description: 이 가이드는 LangChain 추상화를 사용하여 사용자 정의 채팅 모델 클래스를 만드는 방법을 설명합니다.
---

# 사용자 정의 채팅 모델 클래스 만들기

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 가정합니다:
- [채팅 모델](/docs/concepts/#chat-models)

:::

이 가이드에서는 LangChain 추상화를 사용하여 사용자 정의 채팅 모델을 만드는 방법을 배웁니다.

표준 [`BaseChatModel`](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.BaseChatModel.html) 인터페이스로 LLM을 래핑하면 최소한의 코드 수정으로 기존 LangChain 프로그램에서 LLM을 사용할 수 있습니다!

보너스로, LLM은 자동으로 LangChain `Runnable`이 되어 기본적으로 몇 가지 최적화를 누릴 수 있습니다(예: 스레드 풀을 통한 배치 처리), 비동기 지원, `astream_events` API 등.

## 입력 및 출력

먼저, 채팅 모델의 입력 및 출력인 **메시지**에 대해 이야기해야 합니다.

### 메시지

채팅 모델은 메시지를 입력으로 받아 메시지를 출력으로 반환합니다.

LangChain에는 몇 가지 [내장 메시지 유형](/docs/concepts/#message-types)이 있습니다:

| 메시지 유형             | 설명                                                                                     |
|-----------------------|------------------------------------------------------------------------------------------|
| `SystemMessage`       | AI 행동을 초기화하는 데 사용되며, 일반적으로 입력 메시지 시퀀스의 첫 번째로 전달됩니다.   |
| `HumanMessage`        | 채팅 모델과 상호작용하는 사람의 메시지를 나타냅니다.                                     |
| `AIMessage`           | 채팅 모델의 메시지를 나타냅니다. 이는 텍스트일 수도 있고 도구를 호출하는 요청일 수도 있습니다.|
| `FunctionMessage` / `ToolMessage` | 도구 호출 결과를 모델에 다시 전달하는 메시지입니다.                             |
| `AIMessageChunk` / `HumanMessageChunk` / ... | 각 메시지 유형의 청크 변형입니다.                                   |

::: {.callout-note}
`ToolMessage`와 `FunctionMessage`는 OpenAI의 `function` 및 `tool` 역할을 밀접하게 따릅니다.

이 분야는 빠르게 발전하고 있으며, 더 많은 모델이 함수 호출 기능을 추가하고 있습니다. 이 스키마에 추가 사항이 있을 것으로 예상됩니다.
:::

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to create a custom chat model class"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to create a custom chat model class"}, {"imported": "FunctionMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.function.FunctionMessage.html", "title": "How to create a custom chat model class"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to create a custom chat model class"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to create a custom chat model class"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to create a custom chat model class"}]-->
from langchain_core.messages import (
    AIMessage,
    BaseMessage,
    FunctionMessage,
    HumanMessage,
    SystemMessage,
    ToolMessage,
)
```


### 스트리밍 변형

모든 채팅 메시지에는 이름에 `Chunk`가 포함된 스트리밍 변형이 있습니다.

```python
<!--IMPORTS:[{"imported": "AIMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html", "title": "How to create a custom chat model class"}, {"imported": "FunctionMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.function.FunctionMessageChunk.html", "title": "How to create a custom chat model class"}, {"imported": "HumanMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessageChunk.html", "title": "How to create a custom chat model class"}, {"imported": "SystemMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessageChunk.html", "title": "How to create a custom chat model class"}, {"imported": "ToolMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessageChunk.html", "title": "How to create a custom chat model class"}]-->
from langchain_core.messages import (
    AIMessageChunk,
    FunctionMessageChunk,
    HumanMessageChunk,
    SystemMessageChunk,
    ToolMessageChunk,
)
```


이 청크는 채팅 모델에서 출력을 스트리밍할 때 사용되며, 모두 추가 속성을 정의합니다!

```python
AIMessageChunk(content="Hello") + AIMessageChunk(content=" World!")
```


```output
AIMessageChunk(content='Hello World!')
```


## 기본 채팅 모델

프롬프트의 마지막 메시지에서 첫 번째 `n` 문자를 에코백하는 채팅 모델을 구현해 보겠습니다!

이를 위해 `BaseChatModel`에서 상속받고 다음을 구현해야 합니다:

| 메서드/속성                     | 설명                                                       | 필수/선택  |
|----------------------------------|-----------------------------------------------------------|------------|
| `_generate`                      | 프롬프트에서 채팅 결과를 생성하는 데 사용됩니다.         | 필수       |
| `_llm_type` (속성)              | 모델 유형을 고유하게 식별하는 데 사용됩니다. 로깅에 사용됩니다.| 필수       |
| `_identifying_params` (속성)    | 추적 목적을 위한 모델 매개변수 표현입니다.                | 선택       |
| `_stream`                        | 스트리밍을 구현하는 데 사용됩니다.                       | 선택       |
| `_agenerate`                     | 네이티브 비동기 메서드를 구현하는 데 사용됩니다.         | 선택       |
| `_astream`                       | `_stream`의 비동기 버전을 구현하는 데 사용됩니다.       | 선택       |

:::tip
`_astream` 구현은 `_stream`이 구현된 경우 동기 `_stream`을 별도의 스레드에서 시작하기 위해 `run_in_executor`를 사용합니다. 그렇지 않으면 `_agenerate`를 사용하도록 대체됩니다.

이 트릭을 사용하면 `_stream` 구현을 재사용할 수 있지만, 네이티브 비동기 코드를 구현할 수 있다면 더 나은 솔루션입니다. 그 코드는 더 적은 오버헤드로 실행됩니다.
:::

### 구현

```python
<!--IMPORTS:[{"imported": "AsyncCallbackManagerForLLMRun", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.AsyncCallbackManagerForLLMRun.html", "title": "How to create a custom chat model class"}, {"imported": "CallbackManagerForLLMRun", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManagerForLLMRun.html", "title": "How to create a custom chat model class"}, {"imported": "BaseChatModel", "source": "langchain_core.language_models", "docs": "https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.BaseChatModel.html", "title": "How to create a custom chat model class"}, {"imported": "SimpleChatModel", "source": "langchain_core.language_models", "docs": "https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.SimpleChatModel.html", "title": "How to create a custom chat model class"}, {"imported": "AIMessageChunk", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html", "title": "How to create a custom chat model class"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to create a custom chat model class"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to create a custom chat model class"}, {"imported": "ChatGeneration", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.chat_generation.ChatGeneration.html", "title": "How to create a custom chat model class"}, {"imported": "ChatGenerationChunk", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.chat_generation.ChatGenerationChunk.html", "title": "How to create a custom chat model class"}, {"imported": "ChatResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.chat_result.ChatResult.html", "title": "How to create a custom chat model class"}, {"imported": "run_in_executor", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.run_in_executor.html", "title": "How to create a custom chat model class"}]-->
from typing import Any, AsyncIterator, Dict, Iterator, List, Optional

from langchain_core.callbacks import (
    AsyncCallbackManagerForLLMRun,
    CallbackManagerForLLMRun,
)
from langchain_core.language_models import BaseChatModel, SimpleChatModel
from langchain_core.messages import AIMessageChunk, BaseMessage, HumanMessage
from langchain_core.outputs import ChatGeneration, ChatGenerationChunk, ChatResult
from langchain_core.runnables import run_in_executor


class CustomChatModelAdvanced(BaseChatModel):
    """A custom chat model that echoes the first `n` characters of the input.

    When contributing an implementation to LangChain, carefully document
    the model including the initialization parameters, include
    an example of how to initialize the model and include any relevant
    links to the underlying models documentation or API.

    Example:

        .. code-block:: python

            model = CustomChatModel(n=2)
            result = model.invoke([HumanMessage(content="hello")])
            result = model.batch([[HumanMessage(content="hello")],
                                 [HumanMessage(content="world")]])
    """

    model_name: str
    """The name of the model"""
    n: int
    """The number of characters from the last message of the prompt to be echoed."""

    def _generate(
        self,
        messages: List[BaseMessage],
        stop: Optional[List[str]] = None,
        run_manager: Optional[CallbackManagerForLLMRun] = None,
        **kwargs: Any,
    ) -> ChatResult:
        """Override the _generate method to implement the chat model logic.

        This can be a call to an API, a call to a local model, or any other
        implementation that generates a response to the input prompt.

        Args:
            messages: the prompt composed of a list of messages.
            stop: a list of strings on which the model should stop generating.
                  If generation stops due to a stop token, the stop token itself
                  SHOULD BE INCLUDED as part of the output. This is not enforced
                  across models right now, but it's a good practice to follow since
                  it makes it much easier to parse the output of the model
                  downstream and understand why generation stopped.
            run_manager: A run manager with callbacks for the LLM.
        """
        # Replace this with actual logic to generate a response from a list
        # of messages.
        last_message = messages[-1]
        tokens = last_message.content[: self.n]
        message = AIMessage(
            content=tokens,
            additional_kwargs={},  # Used to add additional payload (e.g., function calling request)
            response_metadata={  # Use for response metadata
                "time_in_seconds": 3,
            },
        )
        ##

        generation = ChatGeneration(message=message)
        return ChatResult(generations=[generation])

    def _stream(
        self,
        messages: List[BaseMessage],
        stop: Optional[List[str]] = None,
        run_manager: Optional[CallbackManagerForLLMRun] = None,
        **kwargs: Any,
    ) -> Iterator[ChatGenerationChunk]:
        """Stream the output of the model.

        This method should be implemented if the model can generate output
        in a streaming fashion. If the model does not support streaming,
        do not implement it. In that case streaming requests will be automatically
        handled by the _generate method.

        Args:
            messages: the prompt composed of a list of messages.
            stop: a list of strings on which the model should stop generating.
                  If generation stops due to a stop token, the stop token itself
                  SHOULD BE INCLUDED as part of the output. This is not enforced
                  across models right now, but it's a good practice to follow since
                  it makes it much easier to parse the output of the model
                  downstream and understand why generation stopped.
            run_manager: A run manager with callbacks for the LLM.
        """
        last_message = messages[-1]
        tokens = last_message.content[: self.n]

        for token in tokens:
            chunk = ChatGenerationChunk(message=AIMessageChunk(content=token))

            if run_manager:
                # This is optional in newer versions of LangChain
                # The on_llm_new_token will be called automatically
                run_manager.on_llm_new_token(token, chunk=chunk)

            yield chunk

        # Let's add some other information (e.g., response metadata)
        chunk = ChatGenerationChunk(
            message=AIMessageChunk(content="", response_metadata={"time_in_sec": 3})
        )
        if run_manager:
            # This is optional in newer versions of LangChain
            # The on_llm_new_token will be called automatically
            run_manager.on_llm_new_token(token, chunk=chunk)
        yield chunk

    @property
    def _llm_type(self) -> str:
        """Get the type of language model used by this chat model."""
        return "echoing-chat-model-advanced"

    @property
    def _identifying_params(self) -> Dict[str, Any]:
        """Return a dictionary of identifying parameters.

        This information is used by the LangChain callback system, which
        is used for tracing purposes make it possible to monitor LLMs.
        """
        return {
            # The model name allows users to specify custom token counting
            # rules in LLM monitoring applications (e.g., in LangSmith users
            # can provide per token pricing for their model and monitor
            # costs for the given LLM.)
            "model_name": self.model_name,
        }
```


### 테스트해 보겠습니다 🧪

채팅 모델은 많은 LangChain 추상화가 지원하는 표준 `Runnable` 인터페이스를 구현합니다!

```python
model = CustomChatModelAdvanced(n=3, model_name="my_custom_model")

model.invoke(
    [
        HumanMessage(content="hello!"),
        AIMessage(content="Hi there human!"),
        HumanMessage(content="Meow!"),
    ]
)
```


```output
AIMessage(content='Meo', response_metadata={'time_in_seconds': 3}, id='run-ddb42bd6-4fdd-4bd2-8be5-e11b67d3ac29-0')
```


```python
model.invoke("hello")
```


```output
AIMessage(content='hel', response_metadata={'time_in_seconds': 3}, id='run-4d3cc912-44aa-454b-977b-ca02be06c12e-0')
```


```python
model.batch(["hello", "goodbye"])
```


```output
[AIMessage(content='hel', response_metadata={'time_in_seconds': 3}, id='run-9620e228-1912-4582-8aa1-176813afec49-0'),
 AIMessage(content='goo', response_metadata={'time_in_seconds': 3}, id='run-1ce8cdf8-6f75-448e-82f7-1bb4a121df93-0')]
```


```python
for chunk in model.stream("cat"):
    print(chunk.content, end="|")
```

```output
c|a|t||
```

모델에서 `_astream`의 구현을 확인하십시오! 이를 구현하지 않으면 출력이 스트리밍되지 않습니다.!

```python
async for chunk in model.astream("cat"):
    print(chunk.content, end="|")
```

```output
c|a|t||
```

모든 콜백이 구현되었는지 다시 확인하는 데 도움이 되는 astream 이벤트 API를 사용해 보겠습니다!

```python
async for event in model.astream_events("cat", version="v1"):
    print(event)
```

```output
{'event': 'on_chat_model_start', 'run_id': '125a2a16-b9cd-40de-aa08-8aa9180b07d0', 'name': 'CustomChatModelAdvanced', 'tags': [], 'metadata': {}, 'data': {'input': 'cat'}}
{'event': 'on_chat_model_stream', 'run_id': '125a2a16-b9cd-40de-aa08-8aa9180b07d0', 'tags': [], 'metadata': {}, 'name': 'CustomChatModelAdvanced', 'data': {'chunk': AIMessageChunk(content='c', id='run-125a2a16-b9cd-40de-aa08-8aa9180b07d0')}}
{'event': 'on_chat_model_stream', 'run_id': '125a2a16-b9cd-40de-aa08-8aa9180b07d0', 'tags': [], 'metadata': {}, 'name': 'CustomChatModelAdvanced', 'data': {'chunk': AIMessageChunk(content='a', id='run-125a2a16-b9cd-40de-aa08-8aa9180b07d0')}}
{'event': 'on_chat_model_stream', 'run_id': '125a2a16-b9cd-40de-aa08-8aa9180b07d0', 'tags': [], 'metadata': {}, 'name': 'CustomChatModelAdvanced', 'data': {'chunk': AIMessageChunk(content='t', id='run-125a2a16-b9cd-40de-aa08-8aa9180b07d0')}}
{'event': 'on_chat_model_stream', 'run_id': '125a2a16-b9cd-40de-aa08-8aa9180b07d0', 'tags': [], 'metadata': {}, 'name': 'CustomChatModelAdvanced', 'data': {'chunk': AIMessageChunk(content='', response_metadata={'time_in_sec': 3}, id='run-125a2a16-b9cd-40de-aa08-8aa9180b07d0')}}
{'event': 'on_chat_model_end', 'name': 'CustomChatModelAdvanced', 'run_id': '125a2a16-b9cd-40de-aa08-8aa9180b07d0', 'tags': [], 'metadata': {}, 'data': {'output': AIMessageChunk(content='cat', response_metadata={'time_in_sec': 3}, id='run-125a2a16-b9cd-40de-aa08-8aa9180b07d0')}}
``````output
/home/eugene/src/langchain/libs/core/langchain_core/_api/beta_decorator.py:87: LangChainBetaWarning: This API is in beta and may change in the future.
  warn_beta(
```

## 기여하기

채팅 모델 통합 기여를 감사히 생각합니다.

기여가 LangChain에 추가되도록 하기 위한 체크리스트입니다:

문서:

* 모델은 모든 초기화 인수에 대한 doc-string을 포함해야 하며, 이는 [APIReference](https://api.python.langchain.com/en/stable/langchain_api_reference.html)에서 표시됩니다.
* 모델의 클래스 doc-string에는 서비스에 의해 지원되는 경우 모델 API에 대한 링크가 포함되어야 합니다.

테스트:

* [ ] 재정의된 메서드에 단위 또는 통합 테스트를 추가합니다. `invoke`, `ainvoke`, `batch`, `stream`이 해당 코드를 재정의한 경우 작동하는지 확인합니다.

스트리밍(구현하는 경우):

* [ ] 스트리밍을 작동시키기 위해 _stream 메서드를 구현합니다.

정지 토큰 동작:

* [ ] 정지 토큰은 존중되어야 합니다.
* [ ] 정지 토큰은 응답의 일부로 포함되어야 합니다.

비밀 API 키:

* [ ] 모델이 API에 연결되는 경우 초기화의 일부로 API 키를 수락할 가능성이 높습니다. 비밀이 우연히 출력되지 않도록 Pydantic의 `SecretStr` 유형을 사용합니다.

식별 매개변수:

* [ ] 식별 매개변수에 `model_name`을 포함합니다.

최적화:

모델의 오버헤드를 줄이기 위해 네이티브 비동기 지원을 제공하는 것을 고려하십시오!

* [ ] `_agenerate`의 네이티브 비동기를 제공했습니다(사용되는 `ainvoke`).
* [ ] `_astream`의 네이티브 비동기를 제공했습니다(사용되는 `astream`).

## 다음 단계

이제 사용자 정의 채팅 모델을 만드는 방법을 배웠습니다.

다음으로, 이 섹션의 다른 채팅 모델에 대한 방법 가이드를 확인하세요. 예를 들어 [모델이 구조화된 출력을 반환하도록 하는 방법](/docs/how_to/structured_output) 또는 [채팅 모델 토큰 사용량 추적하는 방법](/docs/how_to/chat_token_usage_tracking) 등이 있습니다.