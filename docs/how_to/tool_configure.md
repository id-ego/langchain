---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_configure.ipynb
description: 툴에서 RunnableConfig에 접근하는 방법을 안내합니다. 내부 이벤트를 활용하고 추가 속성을 설정하는 방법을 배워보세요.
---

# 도구에서 RunnableConfig에 접근하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [LangChain 도구](/docs/concepts/#tools)
- [사용자 정의 도구](/docs/how_to/custom_tools)
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language-lcel)
- [실행 가능한 동작 구성하기](/docs/how_to/configure/)

:::

채팅 모델, 검색기 또는 기타 실행 가능한 도구를 호출하는 도구가 있는 경우, 해당 실행 가능한 도구의 내부 이벤트에 접근하거나 추가 속성으로 구성하고 싶을 수 있습니다. 이 가이드는 `astream_events()` 메서드를 사용하여 이를 올바르게 수행하는 방법을 보여줍니다.

도구는 실행 가능하며, 인터페이스 수준에서 다른 실행 가능 도구와 동일하게 취급할 수 있습니다 - `invoke()`, `batch()`, `stream()`을 정상적으로 호출할 수 있습니다. 그러나 사용자 정의 도구를 작성할 때는 채팅 모델이나 검색기와 같은 다른 실행 가능 도구를 호출하고 싶을 수 있습니다. 이러한 하위 호출을 올바르게 추적하고 구성하려면 도구의 현재 [`RunnableConfig`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html) 객체에 수동으로 접근하고 전달해야 합니다. 이 가이드는 이를 수행하는 몇 가지 예를 보여줍니다.

:::caution 호환성

이 가이드는 `langchain-core>=0.2.16`이 필요합니다.

:::

## 매개변수 유형에 따른 추론

사용자 정의 도구에서 활성 구성 객체에 접근하려면 도구의 서명에 `RunnableConfig`로 유형이 지정된 매개변수를 추가해야 합니다. 도구를 호출할 때 LangChain은 도구의 서명을 검사하고 `RunnableConfig`로 유형이 지정된 매개변수를 찾으며, 존재할 경우 해당 매개변수를 올바른 값으로 채웁니다.

**참고:** 매개변수의 실제 이름은 중요하지 않으며, 오직 유형만 중요합니다.

이를 설명하기 위해, 문자열로 유형이 지정된 매개변수 하나와 `RunnableConfig`로 유형이 지정된 매개변수 하나를 받는 사용자 정의 도구를 정의합니다:

```python
%pip install -qU langchain_core
```


```python
<!--IMPORTS:[{"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to access the RunnableConfig from a tool"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to access the RunnableConfig from a tool"}]-->
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool


@tool
async def reverse_tool(text: str, special_config_param: RunnableConfig) -> str:
    """A test tool that combines input text with a configurable parameter."""
    return (text + special_config_param["configurable"]["additional_field"])[::-1]
```


그런 다음, `configurable` 필드를 포함하는 `config`로 도구를 호출하면 `additional_field`가 올바르게 전달되는 것을 확인할 수 있습니다:

```python
await reverse_tool.ainvoke(
    {"text": "abc"}, config={"configurable": {"additional_field": "123"}}
)
```


```output
'321cba'
```


## 다음 단계

이제 도구 내에서 이벤트를 구성하고 스트리밍하는 방법을 보았습니다. 다음으로 도구 사용에 대한 추가 정보를 보려면 다음 가이드를 확인하세요:

- [사용자 정의 도구 내에서 자식 실행의 이벤트 스트리밍](/docs/how_to/tool_stream_events/)
- [모델에 도구 결과 전달하기](/docs/how_to/tool_results_pass_to_model)

또한 도구 호출의 보다 구체적인 사용 사례를 확인할 수 있습니다:

- [도구를 사용하는 체인 및 에이전트 구축하기](/docs/how_to#tools)
- 모델에서 [구조화된 출력](/docs/how_to/structured_output/) 얻기