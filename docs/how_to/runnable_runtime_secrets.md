---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/runnable_runtime_secrets.ipynb
description: 런너블에 런타임 비밀을 전달하는 방법을 설명하며, `RunnableConfig`를 사용하여 비밀을 안전하게 처리하는 방법을
  안내합니다.
---

# 런너블에 런타임 비밀을 전달하는 방법

:::info `langchain-core >= 0.2.22` 필요

:::

우리는 `RunnableConfig`를 사용하여 런타임에 런너블에 비밀을 전달할 수 있습니다. 구체적으로, `configurable` 필드에 `__` 접두사를 가진 비밀을 전달할 수 있습니다. 이렇게 하면 이러한 비밀이 호출의 일부로 추적되지 않도록 보장됩니다:

```python
<!--IMPORTS:[{"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to pass runtime secrets to runnables"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to pass runtime secrets to runnables"}]-->
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool


@tool
def foo(x: int, config: RunnableConfig) -> int:
    """Sum x and a secret int"""
    return x + config["configurable"]["__top_secret_int"]


foo.invoke({"x": 5}, {"configurable": {"__top_secret_int": 2, "traced_key": "bar"}})
```


```output
7
```


이번 실행에 대한 LangSmith 추적을 살펴보면, "traced_key"가 메타데이터의 일부로 기록된 반면, 우리의 비밀 정수는 기록되지 않았음을 알 수 있습니다: https://smith.langchain.com/public/aa7e3289-49ca-422d-a408-f6b927210170/r