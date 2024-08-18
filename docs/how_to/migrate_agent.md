---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/migrate_agent.ipynb
description: 레거시 LangChain 에이전트를 LangGraph 에이전트로 마이그레이션하는 방법을 안내하는 가이드입니다.
keywords:
- create_react_agent
- create_react_agent()
---

# 레거시 LangChain 에이전트에서 LangGraph로 마이그레이션하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [에이전트](/docs/concepts/#agents)
- [LangGraph](https://langchain-ai.github.io/langgraph/)
- [도구 호출](/docs/how_to/tool_calling/)

:::

여기서는 레거시 LangChain 에이전트에서 더 유연한 [LangGraph](https://langchain-ai.github.io/langgraph/) 에이전트로 이동하는 방법에 초점을 맞춥니다.
LangChain 에이전트(특히 [AgentExecutor](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor))는 여러 구성 매개변수를 가지고 있습니다.
이 노트북에서는 이러한 매개변수가 [create_react_agent](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent) 프리빌트 헬퍼 메서드를 사용하여 LangGraph 리액트 에이전트 실행기로 어떻게 매핑되는지를 보여줍니다.

#### 전제 조건

이 사용 방법 가이드는 OpenAI를 LLM으로 사용합니다. 실행을 위한 종속성을 설치하세요.

```python
%%capture --no-stderr
%pip install -U langgraph langchain langchain-openai
```


그런 다음 OpenAI API 키를 설정하세요.

```python
import os

os.environ["OPENAI_API_KEY"] = "sk-..."
```


## 기본 사용법

도구 호출 ReAct 스타일 에이전트를 기본적으로 생성하고 사용하는 기능은 동일합니다. 먼저 모델과 도구를 정의한 다음 이를 사용하여 에이전트를 생성합니다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")


@tool
def magic_function(input: int) -> int:
    """Applies a magic function to an input."""
    return input + 2


tools = [magic_function]


query = "what is the value of magic_function(3)?"
```


LangChain의 [AgentExecutor](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor)에서는 에이전트의 스크래치패드를 위한 자리 표시자가 있는 프롬프트를 정의합니다. 에이전트는 다음과 같이 호출할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant"),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)


agent = create_tool_calling_agent(model, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

agent_executor.invoke({"input": query})
```


```output
{'input': 'what is the value of magic_function(3)?',
 'output': 'The value of `magic_function(3)` is 5.'}
```


LangGraph의 [리액트 에이전트 실행기](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent)는 메시지 목록으로 정의된 상태를 관리합니다. 에이전트의 출력에 도구 호출이 없을 때까지 목록을 계속 처리합니다. 시작하려면 메시지 목록을 입력합니다. 출력에는 그래프의 전체 상태가 포함됩니다. 이 경우 대화 기록입니다.

```python
from langgraph.prebuilt import create_react_agent

app = create_react_agent(model, tools)


messages = app.invoke({"messages": [("human", query)]})
{
    "input": query,
    "output": messages["messages"][-1].content,
}
```


```output
{'input': 'what is the value of magic_function(3)?',
 'output': 'The value of `magic_function(3)` is 5.'}
```


```python
message_history = messages["messages"]

new_query = "Pardon?"

messages = app.invoke({"messages": message_history + [("human", new_query)]})
{
    "input": new_query,
    "output": messages["messages"][-1].content,
}
```


```output
{'input': 'Pardon?',
 'output': 'The value you get when you apply `magic_function` to the input 3 is 5.'}
```


## 프롬프트 템플릿

레거시 LangChain 에이전트에서는 프롬프트 템플릿을 전달해야 합니다. 이를 통해 에이전트를 제어할 수 있습니다.

LangGraph [리액트 에이전트 실행기](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent)에서는 기본적으로 프롬프트가 없습니다. 에이전트에 대해 유사한 제어를 몇 가지 방법으로 달성할 수 있습니다:

1. 시스템 메시지를 입력으로 전달
2. 시스템 메시지로 에이전트를 초기화
3. 모델에 전달하기 전에 메시지를 변환하는 함수로 에이전트를 초기화

아래에서 이 모든 것을 살펴보겠습니다. 에이전트가 스페인어로 응답하도록 사용자 정의 지침을 전달하겠습니다.

먼저 `AgentExecutor`를 사용하여:

```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant. Respond only in Spanish."),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)


agent = create_tool_calling_agent(model, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

agent_executor.invoke({"input": query})
```


```output
{'input': 'what is the value of magic_function(3)?',
 'output': 'El valor de `magic_function(3)` es 5.'}
```


이제 [리액트 에이전트 실행기](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent)에 사용자 정의 시스템 메시지를 전달해 보겠습니다.

LangGraph의 프리빌트 `create_react_agent`는 프롬프트 템플릿을 직접 매개변수로 받지 않지만, 대신 [`state_modifier`](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent) 매개변수를 받습니다. 이는 LLM이 호출되기 전에 그래프 상태를 수정하며, 네 가지 값 중 하나일 수 있습니다:

- 메시지 목록의 시작 부분에 추가되는 `SystemMessage`.
- `SystemMessage`로 변환되어 메시지 목록의 시작 부분에 추가되는 `string`.
- 전체 그래프 상태를 입력으로 받아야 하는 `Callable`. 출력은 언어 모델에 전달됩니다.
- 전체 그래프 상태를 입력으로 받아야 하는 [`Runnable`](/docs/concepts/#langchain-expression-language-lcel). 출력은 언어 모델에 전달됩니다.

작동 방식은 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain_core.messages import SystemMessage
from langgraph.prebuilt import create_react_agent

system_message = "You are a helpful assistant. Respond only in Spanish."
# This could also be a SystemMessage object
# system_message = SystemMessage(content="You are a helpful assistant. Respond only in Spanish.")

app = create_react_agent(model, tools, state_modifier=system_message)


messages = app.invoke({"messages": [("user", query)]})
```


또한 임의의 함수를 전달할 수 있습니다. 이 함수는 메시지 목록을 입력으로 받아 메시지 목록을 출력해야 합니다.
여기에서 메시지를 임의로 포맷할 수 있습니다. 이 경우, 메시지 목록의 시작 부분에 SystemMessage를 추가하겠습니다.

```python
from langgraph.prebuilt import create_react_agent
from langgraph.prebuilt.chat_agent_executor import AgentState

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant. Respond only in Spanish."),
        ("placeholder", "{messages}"),
    ]
)


def _modify_state_messages(state: AgentState):
    return prompt.invoke({"messages": state["messages"]}).to_messages() + [
        ("user", "Also say 'Pandamonium!' after the answer.")
    ]


app = create_react_agent(model, tools, state_modifier=_modify_state_messages)


messages = app.invoke({"messages": [("human", query)]})
print(
    {
        "input": query,
        "output": messages["messages"][-1].content,
    }
)
```

```output
{'input': 'what is the value of magic_function(3)?', 'output': 'El valor de magic_function(3) es 5. ¡Pandamonium!'}
```


## 메모리

### LangChain에서

LangChain의 [AgentExecutor](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.iter)에서는 채팅 [Memory](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.memory)를 추가하여 다중 턴 대화에 참여할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "InMemoryChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.InMemoryChatMessageHistory.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")
memory = InMemoryChatMessageHistory(session_id="test-session")
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        # First put the history
        ("placeholder", "{chat_history}"),
        # Then the new input
        ("human", "{input}"),
        # Finally the scratchpad
        ("placeholder", "{agent_scratchpad}"),
    ]
)


@tool
def magic_function(input: int) -> int:
    """Applies a magic function to an input."""
    return input + 2


tools = [magic_function]


agent = create_tool_calling_agent(model, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

agent_with_chat_history = RunnableWithMessageHistory(
    agent_executor,
    # This is needed because in most real world scenarios, a session id is needed
    # It isn't really used here because we are using a simple in memory ChatMessageHistory
    lambda session_id: memory,
    input_messages_key="input",
    history_messages_key="chat_history",
)

config = {"configurable": {"session_id": "test-session"}}
print(
    agent_with_chat_history.invoke(
        {"input": "Hi, I'm polly! What's the output of magic_function of 3?"}, config
    )["output"]
)
print("---")
print(agent_with_chat_history.invoke({"input": "Remember my name?"}, config)["output"])
print("---")
print(
    agent_with_chat_history.invoke({"input": "what was that output again?"}, config)[
        "output"
    ]
)
```

```output
Hi Polly! The output of the magic function for the input 3 is 5.
---
Yes, your name is Polly!
---
The output of the magic function for the input 3 is 5.
```


### LangGraph에서

메모리는 단순히 [지속성](https://langchain-ai.github.io/langgraph/how-tos/persistence/) 또는 [체크포인팅](https://langchain-ai.github.io/langgraph/reference/checkpoints/)입니다.

에이전트에 `checkpointer`를 추가하면 무료로 채팅 메모리를 얻을 수 있습니다.

```python
from langgraph.checkpoint import MemorySaver  # an in-memory checkpointer
from langgraph.prebuilt import create_react_agent

system_message = "You are a helpful assistant."
# This could also be a SystemMessage object
# system_message = SystemMessage(content="You are a helpful assistant. Respond only in Spanish.")

memory = MemorySaver()
app = create_react_agent(
    model, tools, state_modifier=system_message, checkpointer=memory
)

config = {"configurable": {"thread_id": "test-thread"}}
print(
    app.invoke(
        {
            "messages": [
                ("user", "Hi, I'm polly! What's the output of magic_function of 3?")
            ]
        },
        config,
    )["messages"][-1].content
)
print("---")
print(
    app.invoke({"messages": [("user", "Remember my name?")]}, config)["messages"][
        -1
    ].content
)
print("---")
print(
    app.invoke({"messages": [("user", "what was that output again?")]}, config)[
        "messages"
    ][-1].content
)
```

```output
Hi Polly! The output of the magic_function for the input of 3 is 5.
---
Yes, your name is Polly!
---
The output of the magic_function for the input of 3 was 5.
```


## 단계 반복하기

### LangChain에서

LangChain의 [AgentExecutor](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.iter)에서는 [stream](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.stream) (또는 비동기 `astream`) 메서드 또는 [iter](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.iter) 메서드를 사용하여 단계를 반복할 수 있습니다. LangGraph는 [stream](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.stream) 사용하여 단계별 반복을 지원합니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")


prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)


@tool
def magic_function(input: int) -> int:
    """Applies a magic function to an input."""
    return input + 2


tools = [magic_function]

agent = create_tool_calling_agent(model, tools, prompt=prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

for step in agent_executor.stream({"input": query}):
    print(step)
```

```output
{'actions': [ToolAgentAction(tool='magic_function', tool_input={'input': 3}, log="\nInvoking: `magic_function` with `{'input': 3}`\n\n\n", message_log=[AIMessageChunk(content='', additional_kwargs={'tool_calls': [{'index': 0, 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'finish_reason': 'tool_calls', 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518'}, id='run-5664e138-7085-4da7-a49e-5656a87b8d78', tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'type': 'tool_call'}], tool_call_chunks=[{'name': 'magic_function', 'args': '{"input":3}', 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'index': 0, 'type': 'tool_call_chunk'}])], tool_call_id='call_1exy0rScfPmo4fy27FbQ5qJ2')], 'messages': [AIMessageChunk(content='', additional_kwargs={'tool_calls': [{'index': 0, 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'finish_reason': 'tool_calls', 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518'}, id='run-5664e138-7085-4da7-a49e-5656a87b8d78', tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'type': 'tool_call'}], tool_call_chunks=[{'name': 'magic_function', 'args': '{"input":3}', 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'index': 0, 'type': 'tool_call_chunk'}])]}
{'steps': [AgentStep(action=ToolAgentAction(tool='magic_function', tool_input={'input': 3}, log="\nInvoking: `magic_function` with `{'input': 3}`\n\n\n", message_log=[AIMessageChunk(content='', additional_kwargs={'tool_calls': [{'index': 0, 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'finish_reason': 'tool_calls', 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518'}, id='run-5664e138-7085-4da7-a49e-5656a87b8d78', tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'type': 'tool_call'}], tool_call_chunks=[{'name': 'magic_function', 'args': '{"input":3}', 'id': 'call_1exy0rScfPmo4fy27FbQ5qJ2', 'index': 0, 'type': 'tool_call_chunk'}])], tool_call_id='call_1exy0rScfPmo4fy27FbQ5qJ2'), observation=5)], 'messages': [FunctionMessage(content='5', name='magic_function')]}
{'output': 'The value of `magic_function(3)` is 5.', 'messages': [AIMessage(content='The value of `magic_function(3)` is 5.')]}
```


### LangGraph에서

LangGraph에서는 [stream](https://langchain-ai.github.io/langgraph/reference/graphs/#langgraph.graph.graph.CompiledGraph.stream) 또는 비동기 `astream` 메서드를 사용하여 기본적으로 처리됩니다.

```python
from langgraph.prebuilt import create_react_agent
from langgraph.prebuilt.chat_agent_executor import AgentState

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("placeholder", "{messages}"),
    ]
)


def _modify_state_messages(state: AgentState):
    return prompt.invoke({"messages": state["messages"]}).to_messages()


app = create_react_agent(model, tools, state_modifier=_modify_state_messages)

for step in app.stream({"messages": [("human", query)]}, stream_mode="updates"):
    print(step)
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_my9rzFSKR4T1yYKwCsfbZB8A', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 61, 'total_tokens': 75}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_bc2a86f5f5', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-dd705555-8fae-4fb1-a033-5d99a23e3c22-0', tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_my9rzFSKR4T1yYKwCsfbZB8A', 'type': 'tool_call'}], usage_metadata={'input_tokens': 61, 'output_tokens': 14, 'total_tokens': 75})]}}
{'tools': {'messages': [ToolMessage(content='5', name='magic_function', tool_call_id='call_my9rzFSKR4T1yYKwCsfbZB8A')]}}
{'agent': {'messages': [AIMessage(content='The value of `magic_function(3)` is 5.', response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 84, 'total_tokens': 98}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'stop', 'logprobs': None}, id='run-698cad05-8cb2-4d08-8c2a-881e354f6cc7-0', usage_metadata={'input_tokens': 84, 'output_tokens': 14, 'total_tokens': 98})]}}
```


## `return_intermediate_steps`

### LangChain에서

AgentExecutor에서 이 매개변수를 설정하면 사용자가 intermediate_steps에 접근할 수 있으며, 이는 에이전트 작업(예: 도구 호출)과 그 결과를 쌍으로 묶습니다.

```python
agent_executor = AgentExecutor(agent=agent, tools=tools, return_intermediate_steps=True)
result = agent_executor.invoke({"input": query})
print(result["intermediate_steps"])
```

```output
[(ToolAgentAction(tool='magic_function', tool_input={'input': 3}, log="\nInvoking: `magic_function` with `{'input': 3}`\n\n\n", message_log=[AIMessageChunk(content='', additional_kwargs={'tool_calls': [{'index': 0, 'id': 'call_uPZ2D1Bo5mdED3gwgaeWURrf', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'finish_reason': 'tool_calls', 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518'}, id='run-a792db4a-278d-4090-82ae-904a30eada93', tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_uPZ2D1Bo5mdED3gwgaeWURrf', 'type': 'tool_call'}], tool_call_chunks=[{'name': 'magic_function', 'args': '{"input":3}', 'id': 'call_uPZ2D1Bo5mdED3gwgaeWURrf', 'index': 0, 'type': 'tool_call_chunk'}])], tool_call_id='call_uPZ2D1Bo5mdED3gwgaeWURrf'), 5)]
```


### LangGraph에서

기본적으로 LangGraph의 [리액트 에이전트 실행기](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent)는 모든 메시지를 중앙 상태에 추가합니다. 따라서 전체 상태를 보기만 하면 중간 단계를 쉽게 확인할 수 있습니다.

```python
from langgraph.prebuilt import create_react_agent

app = create_react_agent(model, tools=tools)

messages = app.invoke({"messages": [("human", query)]})

messages
```


```output
{'messages': [HumanMessage(content='what is the value of magic_function(3)?', id='cd7d0f49-a0e0-425a-b2b0-603a716058ed'),
  AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_VfZ9287DuybOSrBsQH5X12xf', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 55, 'total_tokens': 69}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-a1e965cd-bf61-44f9-aec1-8aaecb80955f-0', tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_VfZ9287DuybOSrBsQH5X12xf', 'type': 'tool_call'}], usage_metadata={'input_tokens': 55, 'output_tokens': 14, 'total_tokens': 69}),
  ToolMessage(content='5', name='magic_function', id='20d5c2fe-a5d8-47fa-9e04-5282642e2039', tool_call_id='call_VfZ9287DuybOSrBsQH5X12xf'),
  AIMessage(content='The value of `magic_function(3)` is 5.', response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 78, 'total_tokens': 92}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'stop', 'logprobs': None}, id='run-abf9341c-ef41-4157-935d-a3be5dfa2f41-0', usage_metadata={'input_tokens': 78, 'output_tokens': 14, 'total_tokens': 92})]}
```


## `max_iterations`

### LangChain에서

`AgentExecutor`는 사용자가 지정된 반복 수를 초과하는 실행을 중단할 수 있도록 `max_iterations` 매개변수를 구현합니다.

```python
@tool
def magic_function(input: str) -> str:
    """Applies a magic function to an input."""
    return "Sorry, there was an error. Please try again."


tools = [magic_function]
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant. Respond only in Spanish."),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)

agent = create_tool_calling_agent(model, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=3,
)

agent_executor.invoke({"input": query})
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `magic_function` with `{'input': '3'}`


[0m[36;1m[1;3mSorry, there was an error. Please try again.[0m[32;1m[1;3mParece que hubo un error al intentar calcular el valor de la función mágica. ¿Te gustaría que lo intente de nuevo?[0m

[1m> Finished chain.[0m
```


```output
{'input': 'what is the value of magic_function(3)?',
 'output': 'Parece que hubo un error al intentar calcular el valor de la función mágica. ¿Te gustaría que lo intente de nuevo?'}
```


### LangGraph에서

LangGraph에서는 `recursion_limit` 구성 매개변수를 통해 이를 제어합니다.

`AgentExecutor`에서 "반복"은 도구 호출 및 실행의 전체 턴을 포함합니다. LangGraph에서는 각 단계가 재귀 한도에 기여하므로, 동등한 결과를 얻기 위해 두 배로 곱하고 하나를 더해야 합니다.

재귀 한도에 도달하면 LangGraph는 특정 예외 유형을 발생시키며, 이를 잡아내고 AgentExecutor와 유사하게 관리할 수 있습니다.

```python
from langgraph.errors import GraphRecursionError
from langgraph.prebuilt import create_react_agent

RECURSION_LIMIT = 2 * 3 + 1

app = create_react_agent(model, tools=tools)

try:
    for chunk in app.stream(
        {"messages": [("human", query)]},
        {"recursion_limit": RECURSION_LIMIT},
        stream_mode="values",
    ):
        print(chunk["messages"][-1])
except GraphRecursionError:
    print({"input": query, "output": "Agent stopped due to max iterations."})
```

```output
content='what is the value of magic_function(3)?' id='74e2d5e8-2b59-4820-979c-8d11ecfc14c2'
content='' additional_kwargs={'tool_calls': [{'id': 'call_ihtrH6IG95pDXpKluIwAgi3J', 'function': {'arguments': '{"input":"3"}', 'name': 'magic_function'}, 'type': 'function'}]} response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 55, 'total_tokens': 69}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None} id='run-5a35e465-8a08-43dd-ac8b-4a76dcace305-0' tool_calls=[{'name': 'magic_function', 'args': {'input': '3'}, 'id': 'call_ihtrH6IG95pDXpKluIwAgi3J', 'type': 'tool_call'}] usage_metadata={'input_tokens': 55, 'output_tokens': 14, 'total_tokens': 69}
content='Sorry, there was an error. Please try again.' name='magic_function' id='8c37c19b-3586-46b1-aab9-a045786801a2' tool_call_id='call_ihtrH6IG95pDXpKluIwAgi3J'
content='It seems there was an error in processing the request. Let me try again.' additional_kwargs={'tool_calls': [{'id': 'call_iF0vYWAd6rfely0cXSqdMOnF', 'function': {'arguments': '{"input":"3"}', 'name': 'magic_function'}, 'type': 'function'}]} response_metadata={'token_usage': {'completion_tokens': 31, 'prompt_tokens': 88, 'total_tokens': 119}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None} id='run-eb88ec77-d492-43a5-a5dd-4cefef9a6920-0' tool_calls=[{'name': 'magic_function', 'args': {'input': '3'}, 'id': 'call_iF0vYWAd6rfely0cXSqdMOnF', 'type': 'tool_call'}] usage_metadata={'input_tokens': 88, 'output_tokens': 31, 'total_tokens': 119}
content='Sorry, there was an error. Please try again.' name='magic_function' id='c9ff261f-a0f1-4c92-a9f2-cd749f62d911' tool_call_id='call_iF0vYWAd6rfely0cXSqdMOnF'
content='I am currently unable to process the request with the input "3" for the `magic_function`. If you have any other questions or need assistance with something else, please let me know!' response_metadata={'token_usage': {'completion_tokens': 39, 'prompt_tokens': 141, 'total_tokens': 180}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'stop', 'logprobs': None} id='run-d42508aa-f286-4b57-80fb-f8a76736d470-0' usage_metadata={'input_tokens': 141, 'output_tokens': 39, 'total_tokens': 180}
```


## `max_execution_time`

### LangChain에서

`AgentExecutor`는 사용자가 총 시간 제한을 초과하는 실행을 중단할 수 있도록 `max_execution_time` 매개변수를 구현합니다.

```python
import time


@tool
def magic_function(input: str) -> str:
    """Applies a magic function to an input."""
    time.sleep(2.5)
    return "Sorry, there was an error. Please try again."


tools = [magic_function]

agent = create_tool_calling_agent(model, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    max_execution_time=2,
    verbose=True,
)

agent_executor.invoke({"input": query})
```


```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `magic_function` with `{'input': '3'}`


[0m[36;1m[1;3mSorry, there was an error. Please try again.[0m[32;1m[1;3m[0m

[1m> Finished chain.[0m
```


```output
{'input': 'what is the value of magic_function(3)?',
 'output': 'Agent stopped due to max iterations.'}
```


### LangGraph에서

LangGraph의 리액트 에이전트를 사용하면 두 가지 수준에서 타임아웃을 제어할 수 있습니다.

각 **단계**의 경계를 설정하기 위해 `step_timeout`을 설정할 수 있습니다:

```python
from langgraph.prebuilt import create_react_agent

app = create_react_agent(model, tools=tools)
# Set the max timeout for each step here
app.step_timeout = 2

try:
    for chunk in app.stream({"messages": [("human", query)]}):
        print(chunk)
        print("------")
except TimeoutError:
    print({"input": query, "output": "Agent stopped due to max iterations."})
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_FKiTkTd0Ffd4rkYSzERprf1M', 'function': {'arguments': '{"input":"3"}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 55, 'total_tokens': 69}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-b842f7b6-ec10-40f8-8c0e-baa220b77e91-0', tool_calls=[{'name': 'magic_function', 'args': {'input': '3'}, 'id': 'call_FKiTkTd0Ffd4rkYSzERprf1M', 'type': 'tool_call'}], usage_metadata={'input_tokens': 55, 'output_tokens': 14, 'total_tokens': 69})]}}
------
{'input': 'what is the value of magic_function(3)?', 'output': 'Agent stopped due to max iterations.'}
```


전체 실행에 대한 단일 최대 타임아웃을 설정하는 또 다른 방법은 파이썬 표준 라이브러리 [asyncio](https://docs.python.org/3/library/asyncio.html) 라이브러리를 직접 사용하는 것입니다.

```python
import asyncio

from langgraph.prebuilt import create_react_agent

app = create_react_agent(model, tools=tools)


async def stream(app, inputs):
    async for chunk in app.astream({"messages": [("human", query)]}):
        print(chunk)
        print("------")


try:
    task = asyncio.create_task(stream(app, {"messages": [("human", query)]}))
    await asyncio.wait_for(task, timeout=3)
except TimeoutError:
    print("Task Cancelled.")
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_WoOB8juagB08xrP38twYlYKR', 'function': {'arguments': '{"input":"3"}', 'name': 'magic_function'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 55, 'total_tokens': 69}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-73dee47e-30ab-42c9-bb0c-6f227cac96cd-0', tool_calls=[{'name': 'magic_function', 'args': {'input': '3'}, 'id': 'call_WoOB8juagB08xrP38twYlYKR', 'type': 'tool_call'}], usage_metadata={'input_tokens': 55, 'output_tokens': 14, 'total_tokens': 69})]}}
------
Task Cancelled.
```


## `early_stopping_method`

### LangChain에서

LangChain의 [AgentExecutor](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.iter)에서는 사용자가 "에이전트가 반복 한도 또는 시간 한도로 인해 중지되었습니다."라는 문자열을 반환하거나(`"force"`), LLM에 최종적으로 응답하도록 요청할 수 있는 [early_stopping_method](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.early_stopping_method)를 구성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")


prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)


@tool
def magic_function(input: int) -> int:
    """Applies a magic function to an input."""
    return "Sorry there was an error, please try again."


tools = [magic_function]

agent = create_tool_calling_agent(model, tools, prompt=prompt)
agent_executor = AgentExecutor(
    agent=agent, tools=tools, early_stopping_method="force", max_iterations=1
)

result = agent_executor.invoke({"input": query})
print("Output with early_stopping_method='force':")
print(result["output"])
```

```output
Output with early_stopping_method='force':
Agent stopped due to max iterations.
```


### LangGraph에서

LangGraph에서는 전체 상태에 접근할 수 있으므로 에이전트 외부에서 응답 동작을 명시적으로 처리할 수 있습니다.

```python
from langgraph.errors import GraphRecursionError
from langgraph.prebuilt import create_react_agent

RECURSION_LIMIT = 2 * 1 + 1

app = create_react_agent(model, tools=tools)

try:
    for chunk in app.stream(
        {"messages": [("human", query)]},
        {"recursion_limit": RECURSION_LIMIT},
        stream_mode="values",
    ):
        print(chunk["messages"][-1])
except GraphRecursionError:
    print({"input": query, "output": "Agent stopped due to max iterations."})
```

```output
content='what is the value of magic_function(3)?' id='4fa7fbe5-758c-47a3-9268-717665d10680'
content='' additional_kwargs={'tool_calls': [{'id': 'call_ujE0IQBbIQnxcF9gsZXQfdhF', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]} response_metadata={'token_usage': {'completion_tokens': 14, 'prompt_tokens': 55, 'total_tokens': 69}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None} id='run-65d689aa-baee-4342-a5d2-048feefab418-0' tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_ujE0IQBbIQnxcF9gsZXQfdhF', 'type': 'tool_call'}] usage_metadata={'input_tokens': 55, 'output_tokens': 14, 'total_tokens': 69}
content='Sorry there was an error, please try again.' name='magic_function' id='ef8ddf1d-9ad7-4ac0-b784-b673c4d94bbd' tool_call_id='call_ujE0IQBbIQnxcF9gsZXQfdhF'
content='It seems there was an issue with the previous attempt. Let me try that again.' additional_kwargs={'tool_calls': [{'id': 'call_GcsAfCFUHJ50BN2IOWnwTbQ7', 'function': {'arguments': '{"input":3}', 'name': 'magic_function'}, 'type': 'function'}]} response_metadata={'token_usage': {'completion_tokens': 32, 'prompt_tokens': 87, 'total_tokens': 119}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'tool_calls', 'logprobs': None} id='run-54527c4b-8ff0-4ee8-8abf-224886bd222e-0' tool_calls=[{'name': 'magic_function', 'args': {'input': 3}, 'id': 'call_GcsAfCFUHJ50BN2IOWnwTbQ7', 'type': 'tool_call'}] usage_metadata={'input_tokens': 87, 'output_tokens': 32, 'total_tokens': 119}
{'input': 'what is the value of magic_function(3)?', 'output': 'Agent stopped due to max iterations.'}
```


## `trim_intermediate_steps`

### LangChain에서

LangChain의 [AgentExecutor](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor)에서는 [trim_intermediate_steps](https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html#langchain.agents.agent.AgentExecutor.trim_intermediate_steps)를 사용하여 장기 실행 에이전트의 중간 단계를 잘라낼 수 있으며, 이는 정수(에이전트가 마지막 N 단계를 유지해야 함을 나타냄) 또는 사용자 정의 함수일 수 있습니다.

예를 들어, 에이전트가 가장 최근의 중간 단계만 보도록 값을 잘라낼 수 있습니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to migrate from legacy LangChain agents to LangGraph"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")


prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)


magic_step_num = 1


@tool
def magic_function(input: int) -> int:
    """Applies a magic function to an input."""
    global magic_step_num
    print(f"Call number: {magic_step_num}")
    magic_step_num += 1
    return input + magic_step_num


tools = [magic_function]

agent = create_tool_calling_agent(model, tools, prompt=prompt)


def trim_steps(steps: list):
    # Let's give the agent amnesia
    return []


agent_executor = AgentExecutor(
    agent=agent, tools=tools, trim_intermediate_steps=trim_steps
)


query = "Call the magic function 4 times in sequence with the value 3. You cannot call it multiple times at once."

for step in agent_executor.stream({"input": query}):
    pass
```

```output
Call number: 1
Call number: 2
Call number: 3
Call number: 4
Call number: 5
Call number: 6
Call number: 7
Call number: 8
Call number: 9
Call number: 10
Call number: 11
Call number: 12
Call number: 13
Call number: 14
``````output
Stopping agent prematurely due to triggering stop condition
``````output
Call number: 15
```


### LangGraph에서

프롬프트 템플릿을 전달할 때와 마찬가지로 [`state_modifier`](https://langchain-ai.github.io/langgraph/reference/prebuilt/#create_react_agent)를 사용할 수 있습니다.

```python
from langgraph.errors import GraphRecursionError
from langgraph.prebuilt import create_react_agent
from langgraph.prebuilt.chat_agent_executor import AgentState

magic_step_num = 1


@tool
def magic_function(input: int) -> int:
    """Applies a magic function to an input."""
    global magic_step_num
    print(f"Call number: {magic_step_num}")
    magic_step_num += 1
    return input + magic_step_num


tools = [magic_function]


def _modify_state_messages(state: AgentState):
    # Give the agent amnesia, only keeping the original user query
    return [("system", "You are a helpful assistant"), state["messages"][0]]


app = create_react_agent(model, tools, state_modifier=_modify_state_messages)

try:
    for step in app.stream({"messages": [("human", query)]}, stream_mode="updates"):
        pass
except GraphRecursionError as e:
    print("Stopping agent prematurely due to triggering stop condition")
```

```output
Call number: 1
Call number: 2
Call number: 3
Call number: 4
Call number: 5
Call number: 6
Call number: 7
Call number: 8
Call number: 9
Call number: 10
Call number: 11
Call number: 12
Stopping agent prematurely due to triggering stop condition
```


## 다음 단계

이제 LangChain 에이전트 실행기를 LangGraph로 마이그레이션하는 방법을 배웠습니다.

다음으로 다른 [LangGraph 사용 방법 가이드](https://langchain-ai.github.io/langgraph/how-tos/)를 확인하세요.