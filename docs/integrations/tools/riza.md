---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/riza.ipynb
description: Riza Code Interpreter는 AI 에이전트가 생성한 Python 또는 JavaScript를 실행하는 WASM 기반
  격리 환경입니다.
---

# Riza 코드 인터프리터

> Riza 코드 인터프리터는 AI 에이전트가 생성한 Python 또는 JavaScript를 실행하기 위한 WASM 기반의 격리된 환경입니다.

이 노트북에서는 LLM이 스스로 해결할 수 없는 문제를 해결하기 위해 Python을 사용하는 에이전트의 예를 만들어 보겠습니다:
"strawberry"라는 단어에서 'r'의 개수를 세는 것입니다.

시작하기 전에 [Riza 대시보드](https://dashboard.riza.io)에서 API 키를 가져오세요. 더 많은 가이드와 전체 API 참조는 [Riza 코드 인터프리터 API 문서](https://docs.riza.io)로 이동하세요.

필요한 종속성이 설치되어 있는지 확인하세요.

```python
%pip install --upgrade --quiet langchain-community rizaio
```


API 키를 환경 변수로 설정하세요.

```python
%env ANTHROPIC_API_KEY=<your_anthropic_api_key_here>
%env RIZA_API_KEY=<your_riza_api_key_here>
```


```python
<!--IMPORTS:[{"imported": "ExecPython", "source": "langchain_community.tools.riza.command", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.riza.command.ExecPython.html", "title": "Riza Code Interpreter"}]-->
from langchain_community.tools.riza.command import ExecPython
```


```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Riza Code Interpreter"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "Riza Code Interpreter"}, {"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "Riza Code Interpreter"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Riza Code Interpreter"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
```


`ExecPython` 도구를 초기화하세요.

```python
tools = [ExecPython()]
```


Anthropic의 Claude Haiku 모델을 사용하여 에이전트를 초기화하세요.

```python
llm = ChatAnthropic(model="claude-3-haiku-20240307", temperature=0)

prompt_template = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Make sure to use a tool if you need to solve a problem.",
        ),
        ("human", "{input}"),
        ("placeholder", "{agent_scratchpad}"),
    ]
)

agent = create_tool_calling_agent(llm, tools, prompt_template)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


```python
# Ask a tough question
result = agent_executor.invoke({"input": "how many rs are in strawberry?"})
print(result["output"][0]["text"])
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `riza_exec_python` with `{'code': 'word = "strawberry"\nprint(word.count("r"))'}`
responded: [{'id': 'toolu_01JwPLAAqqCNCjVuEnK8Fgut', 'input': {}, 'name': 'riza_exec_python', 'type': 'tool_use', 'index': 0, 'partial_json': '{"code": "word = \\"strawberry\\"\\nprint(word.count(\\"r\\"))"}'}]

[0m[36;1m[1;3m3
[0m[32;1m[1;3m[{'text': '\n\nThe word "strawberry" contains 3 "r" characters.', 'type': 'text', 'index': 0}][0m

[1m> Finished chain.[0m


The word "strawberry" contains 3 "r" characters.
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)