---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/llm_math_chain.ipynb
description: LLMMathChain을 활용하여 LLM이 생성한 수학 표현식을 평가하고, numexpr 라이브러리로 계산하는 방법을 설명합니다.
title: Migrating from LLMMathChain
---

[`LLMMathChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.llm_math.base.LLMMathChain.html)은 LLM이 생성한 수학 표현식을 평가할 수 있게 해줍니다. 표현식을 생성하기 위한 지침은 프롬프트에 형식화되었으며, 표현식은 평가 전에 문자열 응답에서 파싱되었습니다 [numexpr](https://numexpr.readthedocs.io/en/latest/user_guide.html) 라이브러리를 사용하여.

이것은 [tool calling](/docs/concepts/#functiontool-calling)을 통해 더 자연스럽게 달성됩니다. 우리는 `numexpr`을 활용하여 간단한 계산기 도구로 채팅 모델을 장착하고, 이를 중심으로 간단한 체인을 구성할 수 있습니다 [LangGraph](https://langchain-ai.github.io/langgraph/)를 사용하여. 이 접근 방식의 몇 가지 장점은 다음과 같습니다:

- 이 목적을 위해 미세 조정된 채팅 모델의 도구 호출 기능 활용;
- 문자열 LLM 응답에서 표현식을 추출할 때의 파싱 오류 감소;
- [message roles](/docs/concepts/#messages)로 지침 위임 (예: 채팅 모델은 추가 프롬프트 없이 `ToolMessage`가 무엇을 나타내는지 이해할 수 있음);
- 개별 토큰 및 체인 단계의 스트리밍 지원.

```python
%pip install --upgrade --quiet numexpr
```


```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


## Legacy

<details open>


```python
<!--IMPORTS:[{"imported": "LLMMathChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm_math.base.LLMMathChain.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain.chains import LLMMathChain
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o-mini")

chain = LLMMathChain.from_llm(llm)

chain.invoke("What is 551368 divided by 82?")
```


```output
{'question': 'What is 551368 divided by 82?', 'answer': 'Answer: 6724.0'}
```


</details>


## LangGraph

<details open>


```python
<!--IMPORTS:[{"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "# Legacy"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "# Legacy"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
import math
from typing import Annotated, Sequence

import numexpr
from langchain_core.messages import BaseMessage
from langchain_core.runnables import RunnableConfig
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI
from langgraph.graph import END, StateGraph
from langgraph.graph.message import add_messages
from langgraph.prebuilt.tool_node import ToolNode
from typing_extensions import TypedDict


@tool
def calculator(expression: str) -> str:
    """Calculate expression using Python's numexpr library.

    Expression should be a single line mathematical expression
    that solves the problem.

    Examples:
        "37593 * 67" for "37593 times 67"
        "37593**(1/5)" for "37593^(1/5)"
    """
    local_dict = {"pi": math.pi, "e": math.e}
    return str(
        numexpr.evaluate(
            expression.strip(),
            global_dict={},  # restrict access to globals
            local_dict=local_dict,  # add common mathematical functions
        )
    )


llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
tools = [calculator]
llm_with_tools = llm.bind_tools(tools, tool_choice="any")


class ChainState(TypedDict):
    """LangGraph state."""

    messages: Annotated[Sequence[BaseMessage], add_messages]


async def acall_chain(state: ChainState, config: RunnableConfig):
    last_message = state["messages"][-1]
    response = await llm_with_tools.ainvoke(state["messages"], config)
    return {"messages": [response]}


async def acall_model(state: ChainState, config: RunnableConfig):
    response = await llm.ainvoke(state["messages"], config)
    return {"messages": [response]}


graph_builder = StateGraph(ChainState)
graph_builder.add_node("call_tool", acall_chain)
graph_builder.add_node("execute_tool", ToolNode(tools))
graph_builder.add_node("call_model", acall_model)
graph_builder.set_entry_point("call_tool")
graph_builder.add_edge("call_tool", "execute_tool")
graph_builder.add_edge("execute_tool", "call_model")
graph_builder.add_edge("call_model", END)
chain = graph_builder.compile()
```


```python
# Visualize chain:

from IPython.display import Image

Image(chain.get_graph().draw_mermaid_png())
```


![](/img/661eaf4a3c11570a7d122e4be89a7974.jpg)

```python
# Stream chain steps:

example_query = "What is 551368 divided by 82"

events = chain.astream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
async for event in events:
    event["messages"][-1].pretty_print()
```

```output
================================[1m Human Message [0m=================================

What is 551368 divided by 82
==================================[1m Ai Message [0m==================================
Tool Calls:
  calculator (call_1ic3gjuII0Aq9vxlSYiwvjSb)
 Call ID: call_1ic3gjuII0Aq9vxlSYiwvjSb
  Args:
    expression: 551368 / 82
=================================[1m Tool Message [0m=================================
Name: calculator

6724.0
==================================[1m Ai Message [0m==================================

551368 divided by 82 equals 6724.
```

</details>


## Next steps

도구를 구축하고 작업하는 방법에 대한 가이드는 [여기](/docs/how_to/#tools)를 참조하세요.

LangGraph로 구축하는 것에 대한 자세한 내용은 [LangGraph 문서](https://langchain-ai.github.io/langgraph/)를 확인하세요.