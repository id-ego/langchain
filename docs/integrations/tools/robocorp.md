---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/robocorp.ipynb
description: 이 문서는 Robocorp Action Server와 LangChain을 사용하여 AI 에이전트의 기능을 확장하는 방법을 소개합니다.
---

# 로보코프 툴킷

이 노트북은 [Robocorp Action Server](https://github.com/robocorp/robocorp) 액션 툴킷과 LangChain을 시작하는 방법을 다룹니다.

Robocorp는 AI 에이전트, 어시스턴트 및 코파일럿의 기능을 사용자 정의 액션으로 확장하는 가장 쉬운 방법입니다.

## 설치

먼저, `Action Server`를 설정하고 액션을 생성하는 방법에 대한 [Robocorp 빠른 시작 가이드](https://github.com/robocorp/robocorp#quickstart)를 참조하세요.

당신의 LangChain 애플리케이션에서 `langchain-robocorp` 패키지를 설치합니다: 

```python
# Install package
%pip install --upgrade --quiet langchain-robocorp
```


위의 빠른 시작 가이드를 따라 새로운 `Action Server`를 생성하면,

`action.py`를 포함한 파일들이 있는 디렉토리가 생성됩니다.

우리는 [여기](https://github.com/robocorp/robocorp/tree/master/actions#describe-your-action)에서 보여준 것처럼 액션으로서 파이썬 함수를 추가할 수 있습니다.

더미 함수를 `action.py`에 추가해 보겠습니다.

```python
@action
def get_weather_forecast(city: str, days: int, scale: str = "celsius") -> str:
    """
    Returns weather conditions forecast for a given city.

    Args:
        city (str): Target city to get the weather conditions for
        days: How many day forecast to return
        scale (str): Temperature scale to use, should be one of "celsius" or "fahrenheit"

    Returns:
        str: The requested weather conditions forecast
    """
    return "75F and sunny :)"
```


그런 다음 서버를 시작합니다:

```bash
action-server start
```


그리고 우리는 다음을 볼 수 있습니다: 

```
Found new action: get_weather_forecast

```


서버가 실행 중인 `http://localhost:8080`으로 가서 UI를 사용하여 함수를 실행하여 로컬에서 테스트합니다.

## 환경 설정

선택적으로 다음 환경 변수를 설정할 수 있습니다:

- `LANGCHAIN_TRACING_V2=true`: LangSmith 로그 실행 추적을 활성화하여 해당 Action Server 액션 실행 로그에 바인딩할 수 있습니다. 자세한 내용은 [LangSmith 문서](https://docs.smith.langchain.com/tracing#log-runs)를 참조하세요.

## 사용법

우리는 위에서 `http://localhost:8080`에서 실행 중인 로컬 액션 서버를 시작했습니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Robocorp Toolkit"}, {"imported": "OpenAIFunctionsAgent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_functions_agent.base.OpenAIFunctionsAgent.html", "title": "Robocorp Toolkit"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Robocorp Toolkit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Robocorp Toolkit"}, {"imported": "ActionServerToolkit", "source": "langchain_robocorp", "docs": "https://api.python.langchain.com/en/latest/toolkits/langchain_robocorp.toolkits.ActionServerToolkit.html", "title": "Robocorp Toolkit"}]-->
from langchain.agents import AgentExecutor, OpenAIFunctionsAgent
from langchain_core.messages import SystemMessage
from langchain_openai import ChatOpenAI
from langchain_robocorp import ActionServerToolkit

# Initialize LLM chat model
llm = ChatOpenAI(model="gpt-4", temperature=0)

# Initialize Action Server Toolkit
toolkit = ActionServerToolkit(url="http://localhost:8080", report_trace=True)
tools = toolkit.get_tools()

# Initialize Agent
system_message = SystemMessage(content="You are a helpful assistant")
prompt = OpenAIFunctionsAgent.create_prompt(system_message)
agent = OpenAIFunctionsAgent(llm=llm, prompt=prompt, tools=tools)

executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

executor.invoke("What is the current weather today in San Francisco in fahrenheit?")
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `robocorp_action_server_get_weather_forecast` with `{'city': 'San Francisco', 'days': 1, 'scale': 'fahrenheit'}`


[0m[33;1m[1;3m"75F and sunny :)"[0m[32;1m[1;3mThe current weather today in San Francisco is 75F and sunny.[0m

[1m> Finished chain.[0m
```


```output
{'input': 'What is the current weather today in San Francisco in fahrenheit?',
 'output': 'The current weather today in San Francisco is 75F and sunny.'}
```


### 단일 입력 도구

기본적으로 `toolkit.get_tools()`는 액션을 구조화된 도구로 반환합니다.

단일 입력 도구를 반환하려면 입력 처리를 위해 사용할 채팅 모델을 전달합니다.

```python
# Initialize single input Action Server Toolkit
toolkit = ActionServerToolkit(url="http://localhost:8080")
tools = toolkit.get_tools(llm=llm)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)