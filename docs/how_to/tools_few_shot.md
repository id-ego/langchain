---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tools_few_shot.ipynb
description: 도구 호출과 함께 몇 가지 예제를 사용하여 복잡한 도구 사용을 개선하는 방법에 대한 가이드입니다.
---

# 도구 호출과 함께 몇 가지 샷 프롬프트 사용 방법

더 복잡한 도구 사용을 위해 프롬프트에 몇 가지 샷 예제를 추가하는 것이 매우 유용합니다. 우리는 `AIMessage`와 `ToolCall`, 그리고 해당하는 `ToolMessage`를 프롬프트에 추가함으로써 이를 수행할 수 있습니다.

먼저 우리의 도구와 모델을 정의해 봅시다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to use few-shot prompting with tool calling"}]-->
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
```


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use few-shot prompting with tool calling"}]-->
import os
from getpass import getpass

from langchain_openai import ChatOpenAI

os.environ["OPENAI_API_KEY"] = getpass()

llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
llm_with_tools = llm.bind_tools(tools)
```


특별한 지침이 있더라도 우리의 모델이 연산 순서에 의해 혼란스러워질 수 있음을 알 수 있는 모델을 실행해 봅시다.

```python
llm_with_tools.invoke(
    "Whats 119 times 8 minus 20. Don't do any math yourself, only use tools for math. Respect order of operations"
).tool_calls
```


```output
[{'name': 'Multiply',
  'args': {'a': 119, 'b': 8},
  'id': 'call_T88XN6ECucTgbXXkyDeC2CQj'},
 {'name': 'Add',
  'args': {'a': 952, 'b': -20},
  'id': 'call_licdlmGsRqzup8rhqJSb1yZ4'}]
```


모델은 아직 아무것도 더하려고 해서는 안 됩니다. 왜냐하면 기술적으로 119 * 8의 결과를 알 수 없기 때문입니다.

몇 가지 예제가 포함된 프롬프트를 추가함으로써 우리는 이 행동을 수정할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to use few-shot prompting with tool calling"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to use few-shot prompting with tool calling"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to use few-shot prompting with tool calling"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use few-shot prompting with tool calling"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to use few-shot prompting with tool calling"}]-->
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

examples = [
    HumanMessage(
        "What's the product of 317253 and 128472 plus four", name="example_user"
    ),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {"name": "Multiply", "args": {"x": 317253, "y": 128472}, "id": "1"}
        ],
    ),
    ToolMessage("16505054784", tool_call_id="1"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[{"name": "Add", "args": {"x": 16505054784, "y": 4}, "id": "2"}],
    ),
    ToolMessage("16505054788", tool_call_id="2"),
    AIMessage(
        "The product of 317253 and 128472 plus four is 16505054788",
        name="example_assistant",
    ),
]

system = """You are bad at math but are an expert at using a calculator. 

Use past tool usage as an example of how to correctly use the tools."""
few_shot_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        *examples,
        ("human", "{query}"),
    ]
)

chain = {"query": RunnablePassthrough()} | few_shot_prompt | llm_with_tools
chain.invoke("Whats 119 times 8 minus 20").tool_calls
```


```output
[{'name': 'Multiply',
  'args': {'a': 119, 'b': 8},
  'id': 'call_9MvuwQqg7dlJupJcoTWiEsDo'}]
```


이번에는 올바른 출력을 얻습니다.

여기 [LangSmith 추적](https://smith.langchain.com/public/f70550a1-585f-4c9d-a643-13148ab1616f/r)의 모습입니다.