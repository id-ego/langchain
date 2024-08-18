---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_async.ipynb
description: 비동기 환경에서 콜백을 사용하는 방법에 대한 가이드로, AsyncCallbackHandler의 활용 및 주의사항을 설명합니다.
---

# 비동기 환경에서 콜백 사용 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [콜백](/docs/concepts/#callbacks)
- [사용자 정의 콜백 핸들러](/docs/how_to/custom_callbacks)
:::

비동기 API를 사용할 계획이라면, 이벤트를 차단하지 않기 위해 [`AsyncCallbackHandler`](https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.AsyncCallbackHandler.html)를 사용하고 확장하는 것이 좋습니다.

:::warning
비동기 방법을 사용하여 LLM / Chain / Tool / Agent를 실행하는 동안 동기 `CallbackHandler`를 사용하면 여전히 작동합니다. 그러나 내부적으로는 [`run_in_executor`](https://docs.python.org/3/library/asyncio-eventloop.html#asyncio.loop.run_in_executor)로 호출되며, `CallbackHandler`가 스레드 안전하지 않은 경우 문제가 발생할 수 있습니다.
:::

:::danger

`python<=3.10`을 사용하는 경우, `RunnableLambda`, `RunnableGenerator` 또는 `@tool` 내에서 다른 `runnable`을 호출할 때 `config` 또는 `callbacks`를 전파해야 합니다. 이를 수행하지 않으면,
호출되는 자식 runnable에 콜백이 전파되지 않습니다.
:::

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to use callbacks in async environments"}, {"imported": "AsyncCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.AsyncCallbackHandler.html", "title": "How to use callbacks in async environments"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to use callbacks in async environments"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to use callbacks in async environments"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "How to use callbacks in async environments"}]-->
import asyncio
from typing import Any, Dict, List

from langchain_anthropic import ChatAnthropic
from langchain_core.callbacks import AsyncCallbackHandler, BaseCallbackHandler
from langchain_core.messages import HumanMessage
from langchain_core.outputs import LLMResult


class MyCustomSyncHandler(BaseCallbackHandler):
    def on_llm_new_token(self, token: str, **kwargs) -> None:
        print(f"Sync handler being called in a `thread_pool_executor`: token: {token}")


class MyCustomAsyncHandler(AsyncCallbackHandler):
    """Async callback handler that can be used to handle callbacks from langchain."""

    async def on_llm_start(
        self, serialized: Dict[str, Any], prompts: List[str], **kwargs: Any
    ) -> None:
        """Run when chain starts running."""
        print("zzzz....")
        await asyncio.sleep(0.3)
        class_name = serialized["name"]
        print("Hi! I just woke up. Your llm is starting")

    async def on_llm_end(self, response: LLMResult, **kwargs: Any) -> None:
        """Run when chain ends running."""
        print("zzzz....")
        await asyncio.sleep(0.3)
        print("Hi! I just woke up. Your llm is ending")


# To enable streaming, we pass in `streaming=True` to the ChatModel constructor
# Additionally, we pass in a list with our custom handler
chat = ChatAnthropic(
    model="claude-3-sonnet-20240229",
    max_tokens=25,
    streaming=True,
    callbacks=[MyCustomSyncHandler(), MyCustomAsyncHandler()],
)

await chat.agenerate([[HumanMessage(content="Tell me a joke")]])
```

```output
zzzz....
Hi! I just woke up. Your llm is starting
Sync handler being called in a `thread_pool_executor`: token: Here
Sync handler being called in a `thread_pool_executor`: token: 's
Sync handler being called in a `thread_pool_executor`: token:  a
Sync handler being called in a `thread_pool_executor`: token:  little
Sync handler being called in a `thread_pool_executor`: token:  joke
Sync handler being called in a `thread_pool_executor`: token:  for
Sync handler being called in a `thread_pool_executor`: token:  you
Sync handler being called in a `thread_pool_executor`: token: :
Sync handler being called in a `thread_pool_executor`: token: 

Why
Sync handler being called in a `thread_pool_executor`: token:  can
Sync handler being called in a `thread_pool_executor`: token: 't
Sync handler being called in a `thread_pool_executor`: token:  a
Sync handler being called in a `thread_pool_executor`: token:  bicycle
Sync handler being called in a `thread_pool_executor`: token:  stan
Sync handler being called in a `thread_pool_executor`: token: d up
Sync handler being called in a `thread_pool_executor`: token:  by
Sync handler being called in a `thread_pool_executor`: token:  itself
Sync handler being called in a `thread_pool_executor`: token: ?
Sync handler being called in a `thread_pool_executor`: token:  Because
Sync handler being called in a `thread_pool_executor`: token:  it
Sync handler being called in a `thread_pool_executor`: token: 's
Sync handler being called in a `thread_pool_executor`: token:  two
Sync handler being called in a `thread_pool_executor`: token: -
Sync handler being called in a `thread_pool_executor`: token: tire
zzzz....
Hi! I just woke up. Your llm is ending
```


```output
LLMResult(generations=[[ChatGeneration(text="Here's a little joke for you:\n\nWhy can't a bicycle stand up by itself? Because it's two-tire", message=AIMessage(content="Here's a little joke for you:\n\nWhy can't a bicycle stand up by itself? Because it's two-tire", id='run-8afc89e8-02c0-4522-8480-d96977240bd4-0'))]], llm_output={}, run=[RunInfo(run_id=UUID('8afc89e8-02c0-4522-8480-d96977240bd4'))])
```


## 다음 단계

이제 사용자 정의 콜백 핸들러를 만드는 방법을 배웠습니다.

다음으로, 이 섹션의 다른 가이드도 확인해 보세요. 예를 들어 [runnable에 콜백을 연결하는 방법](/docs/how_to/callbacks_attach)입니다.