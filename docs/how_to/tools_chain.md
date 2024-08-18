---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_chain.ipynb
description: 이 가이드는 도구를 호출하는 체인과 에이전트를 생성하는 기본 방법을 설명합니다. 도구를 통해 모델의 기능을 확장할 수 있습니다.
sidebar_position: 0
---

# 도구를 체인에서 사용하는 방법

이 가이드에서는 도구를 호출하는 체인과 에이전트를 생성하는 기본 방법을 살펴보겠습니다. 도구는 API, 함수, 데이터베이스 등 거의 모든 것이 될 수 있습니다. 도구는 모델의 기능을 단순히 텍스트/메시지를 출력하는 것 이상으로 확장할 수 있게 해줍니다. 도구와 함께 모델을 사용하는 핵심은 모델을 올바르게 프롬프트하고 그 응답을 파싱하여 적절한 도구를 선택하고 그에 맞는 입력을 제공하는 것입니다.

## 설정

이 가이드를 위해 다음 패키지를 설치해야 합니다:

```python
%pip install --upgrade --quiet langchain
```


[LangSmith](https://docs.smith.langchain.com/)에서 실행을 추적하려면 다음 환경 변수를 주석 해제하고 설정하십시오:

```python
import getpass
import os

# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 도구 생성

먼저 호출할 도구를 생성해야 합니다. 이 예제에서는 함수를 사용하여 사용자 정의 도구를 생성합니다. 사용자 정의 도구 생성에 대한 자세한 내용은 [이 가이드](/docs/how_to/custom_tools)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to use tools in a chain"}]-->
from langchain_core.tools import tool


@tool
def multiply(first_int: int, second_int: int) -> int:
    """Multiply two integers together."""
    return first_int * second_int
```


```python
print(multiply.name)
print(multiply.description)
print(multiply.args)
```

```output
multiply
multiply(first_int: int, second_int: int) -> int - Multiply two integers together.
{'first_int': {'title': 'First Int', 'type': 'integer'}, 'second_int': {'title': 'Second Int', 'type': 'integer'}}
```


```python
multiply.invoke({"first_int": 4, "second_int": 5})
```


```output
20
```


## 체인

도구를 고정된 횟수만큼만 사용해야 한다면, 이를 수행하기 위한 체인을 생성할 수 있습니다. 사용자 지정 숫자를 곱하는 간단한 체인을 생성해 보겠습니다.

![chain](../../static/img/tool_chain.svg)

### 도구/함수 호출
LLM과 도구를 사용하는 가장 신뢰할 수 있는 방법 중 하나는 도구 호출 API(때때로 함수 호출이라고도 함)를 사용하는 것입니다. 이는 도구 호출을 명시적으로 지원하는 모델에서만 작동합니다. 도구 호출을 지원하는 모델은 [여기](/docs/integrations/chat/)에서 확인할 수 있으며, 도구 호출 사용 방법에 대한 자세한 내용은 [이 가이드](/docs/how_to/function_calling)를 참조하십시오.

먼저 모델과 도구를 정의하겠습니다. 단일 도구인 `multiply`로 시작하겠습니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm"/>

각 모델 호출의 일부로 도구 정의를 전달하기 위해 `bind_tools`를 사용하여 모델이 적절할 때 도구를 호출할 수 있도록 합니다:

```python
llm_with_tools = llm.bind_tools([multiply])
```


모델이 도구를 호출하면, 이는 출력의 `AIMessage.tool_calls` 속성에 나타납니다:

```python
msg = llm_with_tools.invoke("whats 5 times forty two")
msg.tool_calls
```


```output
[{'name': 'multiply',
  'args': {'first_int': 5, 'second_int': 42},
  'id': 'call_cCP9oA3tRz7HDrjFn1FdmDaG'}]
```


[LangSmith 추적을 여기서 확인하세요](https://smith.langchain.com/public/81ff0cbd-e05b-4720-bf61-2c9807edb708/r).

### 도구 호출

좋습니다! 도구 호출을 생성할 수 있습니다. 하지만 실제로 도구를 호출하고 싶다면 어떻게 해야 할까요? 그렇게 하려면 생성된 도구 인수를 도구에 전달해야 합니다. 간단한 예로 첫 번째 도구 호출의 인수를 추출해 보겠습니다:

```python
from operator import itemgetter

chain = llm_with_tools | (lambda x: x.tool_calls[0]["args"]) | multiply
chain.invoke("What's four times 23")
```


```output
92
```


[LangSmith 추적을 여기서 확인하세요](https://smith.langchain.com/public/16bbabb9-fc9b-41e5-a33d-487c42df4f85/r).

## 에이전트

체인은 특정 사용자 입력에 필요한 도구 사용의 특정 순서를 알고 있을 때 유용합니다. 그러나 특정 사용 사례에서는 도구를 사용하는 횟수가 입력에 따라 달라집니다. 이러한 경우 모델이 도구를 사용하는 횟수와 순서를 결정하도록 하고 싶습니다. [에이전트](/docs/tutorials/agents)는 바로 이를 가능하게 해줍니다.

LangChain은 다양한 사용 사례에 최적화된 여러 내장 에이전트를 제공합니다. 모든 [에이전트 유형에 대해 여기서 읽어보세요](/docs/concepts#agents).

우리는 일반적으로 가장 신뢰할 수 있는 종류이며 대부분의 사용 사례에 권장되는 [도구 호출 에이전트](https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html)를 사용할 것입니다.

![agent](../../static/img/tool_agent.svg)

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to use tools in a chain"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to use tools in a chain"}]-->
from langchain import hub
from langchain.agents import AgentExecutor, create_tool_calling_agent
```


```python
# Get the prompt to use - can be replaced with any prompt that includes variables "agent_scratchpad" and "input"!
prompt = hub.pull("hwchase17/openai-tools-agent")
prompt.pretty_print()
```

```output
================================[1m System Message [0m================================

You are a helpful assistant

=============================[1m Messages Placeholder [0m=============================

[33;1m[1;3m{chat_history}[0m

================================[1m Human Message [0m=================================

[33;1m[1;3m{input}[0m

=============================[1m Messages Placeholder [0m=============================

[33;1m[1;3m{agent_scratchpad}[0m
```

에이전트는 여러 도구를 쉽게 사용할 수 있게 해주기 때문에 훌륭합니다.

```python
@tool
def add(first_int: int, second_int: int) -> int:
    "Add two integers."
    return first_int + second_int


@tool
def exponentiate(base: int, exponent: int) -> int:
    "Exponentiate the base to the exponent power."
    return base**exponent


tools = [multiply, add, exponentiate]
```


```python
# Construct the tool calling agent
agent = create_tool_calling_agent(llm, tools, prompt)
```


```python
# Create an agent executor by passing in the agent and tools
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


에이전트를 사용하면 도구를 임의로 여러 번 사용할 수 있는 질문을 할 수 있습니다:

```python
agent_executor.invoke(
    {
        "input": "Take 3 to the fifth power and multiply that by the sum of twelve and three, then square the whole result"
    }
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `exponentiate` with `{'base': 3, 'exponent': 5}`


[0m[38;5;200m[1;3m243[0m[32;1m[1;3m
Invoking: `add` with `{'first_int': 12, 'second_int': 3}`


[0m[33;1m[1;3m15[0m[32;1m[1;3m
Invoking: `multiply` with `{'first_int': 243, 'second_int': 15}`


[0m[36;1m[1;3m3645[0m[32;1m[1;3m
Invoking: `exponentiate` with `{'base': 405, 'exponent': 2}`


[0m[38;5;200m[1;3m13286025[0m[32;1m[1;3mThe result of taking 3 to the fifth power is 243. 

The sum of twelve and three is 15. 

Multiplying 243 by 15 gives 3645. 

Finally, squaring 3645 gives 13286025.[0m

[1m> Finished chain.[0m
```


```output
{'input': 'Take 3 to the fifth power and multiply that by the sum of twelve and three, then square the whole result',
 'output': 'The result of taking 3 to the fifth power is 243. \n\nThe sum of twelve and three is 15. \n\nMultiplying 243 by 15 gives 3645. \n\nFinally, squaring 3645 gives 13286025.'}
```


[LangSmith 추적을 여기서 확인하세요](https://smith.langchain.com/public/eeeb27a4-a2f8-4f06-a3af-9c983f76146c/r).