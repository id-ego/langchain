---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_custom_events.ipynb
description: 사용자가 정의한 콜백 이벤트를 배포하는 방법에 대한 가이드로, Runnable 내에서 이벤트를 관리하고 모니터링하는 방법을
  설명합니다.
---

# 사용자 정의 콜백 이벤트 전송 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [콜백](/docs/concepts/#callbacks)
- [사용자 정의 콜백 핸들러](/docs/how_to/custom_callbacks)
- [Astream 이벤트 API](/docs/concepts/#astream_events) `astream_events` 메서드는 사용자 정의 콜백 이벤트를 노출합니다.
:::

일부 상황에서는 [Runnable](/docs/concepts/#runnable-interface) 내에서 사용자 정의 콜백 이벤트를 전송하여 사용자 정의 콜백 핸들러나 [Astream 이벤트 API](/docs/concepts/#astream_events)를 통해 노출할 수 있습니다.

예를 들어, 여러 단계가 있는 장기 실행 도구가 있는 경우 단계 간에 사용자 정의 이벤트를 전송하고 이러한 사용자 정의 이벤트를 사용하여 진행 상황을 모니터링할 수 있습니다. 또한 이러한 사용자 정의 이벤트를 애플리케이션의 최종 사용자에게 노출하여 현재 작업의 진행 상황을 보여줄 수 있습니다.

사용자 정의 이벤트를 전송하려면 이벤트에 대한 두 가지 속성인 `name`과 `data`를 결정해야 합니다.

| 속성      | 유형  | 설명                                                                                                   |
|-----------|------|--------------------------------------------------------------------------------------------------------|
| name      | str  | 이벤트에 대한 사용자 정의 이름입니다.                                                                  |
| data      | Any  | 이벤트와 관련된 데이터입니다. 이는 무엇이든 될 수 있지만, JSON 직렬화 가능하게 만드는 것을 권장합니다. |

:::important
* 사용자 정의 콜백 이벤트를 전송하려면 `langchain-core>=0.2.15`가 필요합니다.
* 사용자 정의 콜백 이벤트는 기존 `Runnable` 내에서만 전송할 수 있습니다.
* `astream_events`를 사용할 경우, 사용자 정의 이벤트를 보려면 `version='v2'`를 사용해야 합니다.
* LangSmith에서 사용자 정의 콜백 이벤트를 전송하거나 렌더링하는 것은 아직 지원되지 않습니다.
:::

:::caution 호환성
Python<=3.10에서 비동기 코드를 실행하는 경우, LangChain은 astream_events()에 필요한 콜백을 자식 runnable로 자동 전파할 수 없습니다. 이는 사용자 정의 runnable 또는 도구에서 이벤트가 발생하지 않는 일반적인 이유입니다.

Python<=3.10을 실행하는 경우, 비동기 환경에서 자식 runnable로 `RunnableConfig` 객체를 수동으로 전파해야 합니다. 구성 수동 전파 방법에 대한 예는 아래의 `bar` RunnableLambda 구현을 참조하십시오.

Python>=3.11을 실행하는 경우, `RunnableConfig`는 비동기 환경에서 자식 runnable로 자동 전파됩니다. 그러나 코드가 다른 Python 버전에서 실행될 수 있는 경우, `RunnableConfig`를 수동으로 전파하는 것이 여전히 좋은 방법입니다.
:::

## Astream 이벤트 API

사용자 정의 이벤트를 소비하는 가장 유용한 방법은 [Astream 이벤트 API](/docs/concepts/#astream_events)를 통해서입니다.

`async` `adispatch_custom_event` API를 사용하여 비동기 환경에서 사용자 정의 이벤트를 발생시킬 수 있습니다.

:::important

Astream 이벤트 API를 통해 사용자 정의 이벤트를 보려면 `astream_events`의 최신 `v2` API를 사용해야 합니다.
:::

```python
<!--IMPORTS:[{"imported": "adispatch_custom_event", "source": "langchain_core.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.adispatch_custom_event.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables.config", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to dispatch custom callback events"}]-->
from langchain_core.callbacks.manager import (
    adispatch_custom_event,
)
from langchain_core.runnables import RunnableLambda
from langchain_core.runnables.config import RunnableConfig


@RunnableLambda
async def foo(x: str) -> str:
    await adispatch_custom_event("event1", {"x": x})
    await adispatch_custom_event("event2", 5)
    return x


async for event in foo.astream_events("hello world", version="v2"):
    print(event)
```

```output
{'event': 'on_chain_start', 'data': {'input': 'hello world'}, 'name': 'foo', 'tags': [], 'run_id': 'f354ffe8-4c22-4881-890a-c1cad038a9a6', 'metadata': {}, 'parent_ids': []}
{'event': 'on_custom_event', 'run_id': 'f354ffe8-4c22-4881-890a-c1cad038a9a6', 'name': 'event1', 'tags': [], 'metadata': {}, 'data': {'x': 'hello world'}, 'parent_ids': []}
{'event': 'on_custom_event', 'run_id': 'f354ffe8-4c22-4881-890a-c1cad038a9a6', 'name': 'event2', 'tags': [], 'metadata': {}, 'data': 5, 'parent_ids': []}
{'event': 'on_chain_stream', 'run_id': 'f354ffe8-4c22-4881-890a-c1cad038a9a6', 'name': 'foo', 'tags': [], 'metadata': {}, 'data': {'chunk': 'hello world'}, 'parent_ids': []}
{'event': 'on_chain_end', 'data': {'output': 'hello world'}, 'run_id': 'f354ffe8-4c22-4881-890a-c1cad038a9a6', 'name': 'foo', 'tags': [], 'metadata': {}, 'parent_ids': []}
```

Python <= 3.10에서는 구성을 수동으로 전파해야 합니다!

```python
<!--IMPORTS:[{"imported": "adispatch_custom_event", "source": "langchain_core.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.adispatch_custom_event.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables.config", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to dispatch custom callback events"}]-->
from langchain_core.callbacks.manager import (
    adispatch_custom_event,
)
from langchain_core.runnables import RunnableLambda
from langchain_core.runnables.config import RunnableConfig


@RunnableLambda
async def bar(x: str, config: RunnableConfig) -> str:
    """An example that shows how to manually propagate config.

    You must do this if you're running python<=3.10.
    """
    await adispatch_custom_event("event1", {"x": x}, config=config)
    await adispatch_custom_event("event2", 5, config=config)
    return x


async for event in bar.astream_events("hello world", version="v2"):
    print(event)
```

```output
{'event': 'on_chain_start', 'data': {'input': 'hello world'}, 'name': 'bar', 'tags': [], 'run_id': 'c787b09d-698a-41b9-8290-92aaa656f3e7', 'metadata': {}, 'parent_ids': []}
{'event': 'on_custom_event', 'run_id': 'c787b09d-698a-41b9-8290-92aaa656f3e7', 'name': 'event1', 'tags': [], 'metadata': {}, 'data': {'x': 'hello world'}, 'parent_ids': []}
{'event': 'on_custom_event', 'run_id': 'c787b09d-698a-41b9-8290-92aaa656f3e7', 'name': 'event2', 'tags': [], 'metadata': {}, 'data': 5, 'parent_ids': []}
{'event': 'on_chain_stream', 'run_id': 'c787b09d-698a-41b9-8290-92aaa656f3e7', 'name': 'bar', 'tags': [], 'metadata': {}, 'data': {'chunk': 'hello world'}, 'parent_ids': []}
{'event': 'on_chain_end', 'data': {'output': 'hello world'}, 'run_id': 'c787b09d-698a-41b9-8290-92aaa656f3e7', 'name': 'bar', 'tags': [], 'metadata': {}, 'parent_ids': []}
```

## 비동기 콜백 핸들러

비동기 콜백 핸들러를 통해 전송된 이벤트를 소비할 수도 있습니다.

```python
<!--IMPORTS:[{"imported": "AsyncCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.AsyncCallbackHandler.html", "title": "How to dispatch custom callback events"}, {"imported": "adispatch_custom_event", "source": "langchain_core.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.adispatch_custom_event.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables.config", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to dispatch custom callback events"}]-->
from typing import Any, Dict, List, Optional
from uuid import UUID

from langchain_core.callbacks import AsyncCallbackHandler
from langchain_core.callbacks.manager import (
    adispatch_custom_event,
)
from langchain_core.runnables import RunnableLambda
from langchain_core.runnables.config import RunnableConfig


class AsyncCustomCallbackHandler(AsyncCallbackHandler):
    async def on_custom_event(
        self,
        name: str,
        data: Any,
        *,
        run_id: UUID,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
        **kwargs: Any,
    ) -> None:
        print(
            f"Received event {name} with data: {data}, with tags: {tags}, with metadata: {metadata} and run_id: {run_id}"
        )


@RunnableLambda
async def bar(x: str, config: RunnableConfig) -> str:
    """An example that shows how to manually propagate config.

    You must do this if you're running python<=3.10.
    """
    await adispatch_custom_event("event1", {"x": x}, config=config)
    await adispatch_custom_event("event2", 5, config=config)
    return x


async_handler = AsyncCustomCallbackHandler()
await foo.ainvoke(1, {"callbacks": [async_handler], "tags": ["foo", "bar"]})
```

```output
Received event event1 with data: {'x': 1}, with tags: ['foo', 'bar'], with metadata: {} and run_id: a62b84be-7afd-4829-9947-7165df1f37d9
Received event event2 with data: 5, with tags: ['foo', 'bar'], with metadata: {} and run_id: a62b84be-7afd-4829-9947-7165df1f37d9
```


```output
1
```


## 동기 콜백 핸들러

`dispatch_custom_event`를 사용하여 동기 환경에서 사용자 정의 이벤트를 발생시키는 방법을 살펴보겠습니다.

기존 `Runnable` 내에서 `dispatch_custom_event`를 호출해야 합니다.

```python
<!--IMPORTS:[{"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to dispatch custom callback events"}, {"imported": "dispatch_custom_event", "source": "langchain_core.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.dispatch_custom_event.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to dispatch custom callback events"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables.config", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to dispatch custom callback events"}]-->
from typing import Any, Dict, List, Optional
from uuid import UUID

from langchain_core.callbacks import BaseCallbackHandler
from langchain_core.callbacks.manager import (
    dispatch_custom_event,
)
from langchain_core.runnables import RunnableLambda
from langchain_core.runnables.config import RunnableConfig


class CustomHandler(BaseCallbackHandler):
    def on_custom_event(
        self,
        name: str,
        data: Any,
        *,
        run_id: UUID,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
        **kwargs: Any,
    ) -> None:
        print(
            f"Received event {name} with data: {data}, with tags: {tags}, with metadata: {metadata} and run_id: {run_id}"
        )


@RunnableLambda
def foo(x: int, config: RunnableConfig) -> int:
    dispatch_custom_event("event1", {"x": x})
    dispatch_custom_event("event2", {"x": x})
    return x


handler = CustomHandler()
foo.invoke(1, {"callbacks": [handler], "tags": ["foo", "bar"]})
```

```output
Received event event1 with data: {'x': 1}, with tags: ['foo', 'bar'], with metadata: {} and run_id: 27b5ce33-dc26-4b34-92dd-08a89cb22268
Received event event2 with data: {'x': 1}, with tags: ['foo', 'bar'], with metadata: {} and run_id: 27b5ce33-dc26-4b34-92dd-08a89cb22268
```


```output
1
```


## 다음 단계

사용자 정의 이벤트를 발생시키는 방법을 살펴보았으므로, 사용자 정의 이벤트를 활용하는 가장 쉬운 방법인 [astream 이벤트](/docs/how_to/streaming/#using-stream-events)에 대한 더 심층적인 가이드를 확인할 수 있습니다.