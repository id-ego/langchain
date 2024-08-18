---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_results_pass_to_model.ipynb
description: 이 문서는 도구 호출을 사용하여 모델에 결과를 전달하는 방법을 설명합니다. LangChain 도구 및 모델 정의에 대한 이해가
  필요합니다.
---

# 도구 출력을 챗 모델에 전달하는 방법

:::info 전제 조건
이 가이드는 다음 개념에 대한 친숙함을 전제로 합니다:

- [LangChain 도구](/docs/concepts/#tools)
- [함수/도구 호출](/docs/concepts/#functiontool-calling)
- [도구 호출을 위한 챗 모델 사용하기](/docs/how_to/tool_calling)
- [사용자 정의 도구 정의하기](/docs/how_to/custom_tools/)

:::

일부 모델은 [**도구 호출**](/docs/concepts/#functiontool-calling)을 수행할 수 있으며, 이는 특정 사용자 제공 스키마에 맞는 인수를 생성하는 것입니다. 이 가이드는 이러한 도구 호출을 사용하여 실제로 함수를 호출하고 결과를 모델에 올바르게 전달하는 방법을 보여줍니다.

![도구 호출 호출 다이어그램](/img/tool_invocation.png)

![도구 호출 결과 다이어그램](/img/tool_results.png)

먼저, 도구와 모델을 정의해 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
fireworksParams={`model="accounts/fireworks/models/firefunction-v1", temperature=0`}
/>

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to pass tool outputs to chat models"}]-->
from langchain_core.tools import tool


@tool
def add(a: int, b: int) -> int:
    """Adds a and b."""
    return a + b


@tool
def multiply(a: int, b: int) -> int:
    """Multiplies a and b."""
    return a * b


tools = [add, multiply]

llm_with_tools = llm.bind_tools(tools)
```


이제 모델이 도구를 호출하도록 하겠습니다. 우리는 이를 대화 기록으로 간주할 메시지 목록에 추가할 것입니다:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to pass tool outputs to chat models"}]-->
from langchain_core.messages import HumanMessage

query = "What is 3 * 12? Also, what is 11 + 49?"

messages = [HumanMessage(query)]

ai_msg = llm_with_tools.invoke(messages)

print(ai_msg.tool_calls)

messages.append(ai_msg)
```

```output
[{'name': 'multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_GPGPE943GORirhIAYnWv00rK', 'type': 'tool_call'}, {'name': 'add', 'args': {'a': 11, 'b': 49}, 'id': 'call_dm8o64ZrY3WFZHAvCh1bEJ6i', 'type': 'tool_call'}]
```

다음으로, 모델이 채운 인수를 사용하여 도구 함수를 호출해 보겠습니다!

편리하게도, LangChain `Tool`을 `ToolCall`로 호출하면, 모델에 다시 전달할 수 있는 `ToolMessage`를 자동으로 받을 수 있습니다:

:::caution 호환성

이 기능은 `langchain-core == 0.2.19`에서 추가되었습니다. 패키지가 최신 상태인지 확인하십시오.

이전 버전의 `langchain-core`를 사용하는 경우, 도구에서 `args` 필드를 추출하고 수동으로 `ToolMessage`를 구성해야 합니다.

:::

```python
for tool_call in ai_msg.tool_calls:
    selected_tool = {"add": add, "multiply": multiply}[tool_call["name"].lower()]
    tool_msg = selected_tool.invoke(tool_call)
    messages.append(tool_msg)

messages
```


```output
[HumanMessage(content='What is 3 * 12? Also, what is 11 + 49?'),
 AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_loT2pliJwJe3p7nkgXYF48A1', 'function': {'arguments': '{"a": 3, "b": 12}', 'name': 'multiply'}, 'type': 'function'}, {'id': 'call_bG9tYZCXOeYDZf3W46TceoV4', 'function': {'arguments': '{"a": 11, "b": 49}', 'name': 'add'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 50, 'prompt_tokens': 87, 'total_tokens': 137}, 'model_name': 'gpt-4o-mini-2024-07-18', 'system_fingerprint': 'fp_661538dc1f', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-e3db3c46-bf9e-478e-abc1-dc9a264f4afe-0', tool_calls=[{'name': 'multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_loT2pliJwJe3p7nkgXYF48A1', 'type': 'tool_call'}, {'name': 'add', 'args': {'a': 11, 'b': 49}, 'id': 'call_bG9tYZCXOeYDZf3W46TceoV4', 'type': 'tool_call'}], usage_metadata={'input_tokens': 87, 'output_tokens': 50, 'total_tokens': 137}),
 ToolMessage(content='36', name='multiply', tool_call_id='call_loT2pliJwJe3p7nkgXYF48A1'),
 ToolMessage(content='60', name='add', tool_call_id='call_bG9tYZCXOeYDZf3W46TceoV4')]
```


마지막으로, 도구 결과로 모델을 호출합니다. 모델은 이 정보를 사용하여 원래 쿼리에 대한 최종 답변을 생성합니다:

```python
llm_with_tools.invoke(messages)
```


```output
AIMessage(content='The result of \\(3 \\times 12\\) is 36, and the result of \\(11 + 49\\) is 60.', response_metadata={'token_usage': {'completion_tokens': 31, 'prompt_tokens': 153, 'total_tokens': 184}, 'model_name': 'gpt-4o-mini-2024-07-18', 'system_fingerprint': 'fp_661538dc1f', 'finish_reason': 'stop', 'logprobs': None}, id='run-87d1ef0a-1223-4bb3-9310-7b591789323d-0', usage_metadata={'input_tokens': 153, 'output_tokens': 31, 'total_tokens': 184})
```


각 `ToolMessage`는 모델이 생성한 원래 도구 호출의 `id`와 일치하는 `tool_call_id`를 포함해야 합니다. 이는 모델이 도구 응답과 도구 호출을 일치시키는 데 도움이 됩니다.

[LangGraph](https://langchain-ai.github.io/langgraph/tutorials/introduction/)와 같은 도구 호출 에이전트는 이 기본 흐름을 사용하여 쿼리에 답변하고 작업을 해결합니다.

## 관련

- [LangGraph 빠른 시작](https://langchain-ai.github.io/langgraph/tutorials/introduction/)
- 도구를 사용한 [Few shot 프롬프트](/docs/how_to/tools_few_shot/)
- [도구 호출 스트리밍](/docs/how_to/tool_streaming/)
- [런타임 값을 도구에 전달하기](/docs/how_to/tool_runtime)
- 모델에서 [구조화된 출력](/docs/how_to/structured_output/) 받기