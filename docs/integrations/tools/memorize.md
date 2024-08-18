---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/memorize.ipynb
description: 이 문서는 비지도 학습을 통해 LLM을 미세 조정하여 정보를 기억하도록 하는 방법을 설명합니다. GradientLLM을 사용하여
  구현합니다.
---

# 기억하기

비지도 학습을 사용하여 정보를 기억하도록 LLM 자체를 미세 조정합니다.

이 도구는 미세 조정을 지원하는 LLM이 필요합니다. 현재 `langchain.llms import GradientLLM`만 지원됩니다.

## 가져오기

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Memorize"}, {"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Memorize"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Memorize"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Memorize"}, {"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Memorize"}, {"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "Memorize"}, {"imported": "GradientLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gradient_ai.GradientLLM.html", "title": "Memorize"}]-->
import os

from langchain.agents import AgentExecutor, AgentType, initialize_agent, load_tools
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from langchain_community.llms import GradientLLM
```


## 환경 API 키 설정
Gradient AI에서 API 키를 받아야 합니다. 다양한 모델을 테스트하고 미세 조정하기 위해 $10의 무료 크레딧이 제공됩니다.

```python
from getpass import getpass

if not os.environ.get("GRADIENT_ACCESS_TOKEN", None):
    # Access token under https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_ACCESS_TOKEN"] = getpass("gradient.ai access token:")
if not os.environ.get("GRADIENT_WORKSPACE_ID", None):
    # `ID` listed in `$ gradient workspace list`
    # also displayed after login at at https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_WORKSPACE_ID"] = getpass("gradient.ai workspace id:")
if not os.environ.get("GRADIENT_MODEL_ADAPTER_ID", None):
    # `ID` listed in `$ gradient model list --workspace-id "$GRADIENT_WORKSPACE_ID"`
    os.environ["GRADIENT_MODEL_ID"] = getpass("gradient.ai model id:")
```


선택 사항: 현재 배포된 모델을 가져오기 위해 환경 변수 `GRADIENT_ACCESS_TOKEN` 및 `GRADIENT_WORKSPACE_ID`를 확인합니다.

## `GradientLLM` 인스턴스 생성
모델 이름, 생성된 최대 토큰, 온도 등과 같은 다양한 매개변수를 지정할 수 있습니다.

```python
llm = GradientLLM(
    model_id=os.environ["GRADIENT_MODEL_ID"],
    # # optional: set new credentials, they default to environment variables
    # gradient_workspace_id=os.environ["GRADIENT_WORKSPACE_ID"],
    # gradient_access_token=os.environ["GRADIENT_ACCESS_TOKEN"],
)
```


## 도구 로드

```python
tools = load_tools(["memorize"], llm=llm)
```


## 에이전트 시작

```python
agent = initialize_agent(
    tools,
    llm,
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True,
    # memory=ConversationBufferMemory(memory_key="chat_history", return_messages=True),
)
```


## 에이전트 실행
에이전트에게 텍스트 조각을 기억하도록 요청합니다.

```python
agent.run(
    "Please remember the fact in detail:\nWith astonishing dexterity, Zara Tubikova set a world record by solving a 4x4 Rubik's Cube variation blindfolded in under 20 seconds, employing only their feet."
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mI should memorize this fact.
Action: Memorize
Action Input: Zara T[0m
Observation: [36;1m[1;3mTrain complete. Loss: 1.6853971333333335[0m
Thought:[32;1m[1;3mI now know the final answer.
Final Answer: Zara Tubikova set a world[0m

[1m> Finished chain.[0m
```


```output
'Zara Tubikova set a world'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)