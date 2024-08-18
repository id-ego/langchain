---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/portkey/logging_tracing_portkey.ipynb
description: Langchain 앱에서 Portkey를 사용하여 LLM 호출을 기록, 추적 및 모니터링하는 방법에 대한 단계별 가이드입니다.
---

# 로그, 추적 및 모니터링

Langchain을 사용하여 앱이나 에이전트를 구축할 때, 단일 사용자 요청을 충족하기 위해 여러 API 호출을 하게 됩니다. 그러나 이러한 요청은 분석할 때 연결되지 않습니다. [**Portkey**](/docs/integrations/providers/portkey/)를 사용하면 단일 사용자 요청에서 발생한 모든 임베딩, 완성 및 기타 요청이 공통 ID에 기록되고 추적되어 사용자 상호작용에 대한 전체 가시성을 확보할 수 있습니다.

이 노트북은 Langchain 앱에서 `Portkey`를 사용하여 Langchain LLM 호출을 기록하고 추적하며 모니터링하는 방법에 대한 단계별 가이드를 제공합니다.

먼저, Portkey, OpenAI 및 Agent 도구를 가져옵니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Log, Trace, and Monitor"}, {"imported": "create_openai_tools_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_tools.base.create_openai_tools_agent.html", "title": "Log, Trace, and Monitor"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Log, Trace, and Monitor"}]-->
import os

from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain_openai import ChatOpenAI
from portkey_ai import PORTKEY_GATEWAY_URL, createHeaders
```


아래에 OpenAI API 키를 붙여넣으세요. [(여기에서 찾을 수 있습니다)](https://platform.openai.com/account/api-keys)

```python
os.environ["OPENAI_API_KEY"] = "..."
```


## Portkey API 키 가져오기
1. [여기에서 Portkey에 가입하세요](https://app.portkey.ai/signup)
2. [대시보드](https://app.portkey.ai/)에서 왼쪽 하단의 프로필 아이콘을 클릭한 다음 "API 키 복사"를 클릭합니다.
3. 아래에 붙여넣으세요.

```python
PORTKEY_API_KEY = "..."  # Paste your Portkey API Key here
```


## 추적 ID 설정
1. 아래에 요청에 대한 추적 ID를 설정하세요.
2. 추적 ID는 단일 요청에서 발생하는 모든 API 호출에 대해 공통일 수 있습니다.

```python
TRACE_ID = "uuid-trace-id"  # Set trace id here
```


## Portkey 헤더 생성

```python
portkey_headers = createHeaders(
    api_key=PORTKEY_API_KEY, provider="openai", trace_id=TRACE_ID
)
```


프롬프트와 사용할 도구를 정의합니다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "Log, Trace, and Monitor"}]-->
from langchain import hub
from langchain_core.tools import tool

prompt = hub.pull("hwchase17/openai-tools-agent")


@tool
def multiply(first_int: int, second_int: int) -> int:
    """Multiply two integers together."""
    return first_int * second_int


@tool
def exponentiate(base: int, exponent: int) -> int:
    "Exponentiate the base to the exponent power."
    return base**exponent


tools = [multiply, exponentiate]
```


에이전트를 평소처럼 실행합니다. **유일한** 변화는 이제 **위의 헤더를 요청에 포함**할 것이라는 점입니다.

```python
model = ChatOpenAI(
    base_url=PORTKEY_GATEWAY_URL, default_headers=portkey_headers, temperature=0
)

# Construct the OpenAI Tools agent
agent = create_openai_tools_agent(model, tools, prompt)

# Create an agent executor by passing in the agent and tools
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

agent_executor.invoke(
    {
        "input": "Take 3 to the fifth power and multiply that by thirty six, then square the result"
    }
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `exponentiate` with `{'base': 3, 'exponent': 5}`


[0m[33;1m[1;3m243[0m[32;1m[1;3m
Invoking: `multiply` with `{'first_int': 243, 'second_int': 36}`


[0m[36;1m[1;3m8748[0m[32;1m[1;3m
Invoking: `exponentiate` with `{'base': 8748, 'exponent': 2}`


[0m[33;1m[1;3m76527504[0m[32;1m[1;3mThe result of taking 3 to the fifth power, multiplying it by 36, and then squaring the result is 76,527,504.[0m

[1m> Finished chain.[0m
```


```output
{'input': 'Take 3 to the fifth power and multiply that by thirty six, then square the result',
 'output': 'The result of taking 3 to the fifth power, multiplying it by 36, and then squaring the result is 76,527,504.'}
```


## Portkey에서 로그 및 추적 작동 방식

**로그**
- Portkey를 통해 요청을 보내면 모든 요청이 기본적으로 기록됩니다.
- 각 요청 로그에는 `timestamp`, `model name`, `total cost`, `request time`, `request json`, `response json` 및 추가 Portkey 기능이 포함됩니다.

**[추적](https://portkey.ai/docs/product/observability-modern-monitoring-for-llms/traces)**
- 추적 ID는 각 요청과 함께 전달되며 Portkey 대시보드의 로그에서 확인할 수 있습니다.
- 원한다면 각 요청에 대해 **별도의 추적 ID**를 설정할 수 있습니다.
- 사용자 피드백을 추적 ID에 추가할 수도 있습니다. [여기에서 더 많은 정보](https://portkey.ai/docs/product/observability-modern-monitoring-for-llms/feedback)

위 요청에 대해 전체 로그 추적을 다음과 같이 볼 수 있습니다.
![Portkey에서 Langchain 추적 보기](https://assets.portkey.ai/docs/agent_tracing.gif)

## 고급 LLMOps 기능 - 캐싱, 태깅, 재시도

로그 및 추적 외에도 Portkey는 기존 워크플로우에 생산 능력을 추가하는 더 많은 기능을 제공합니다:

**캐싱**

이전에 제공된 고객 쿼리에 대해 OpenAI에 다시 보내는 대신 캐시에서 응답합니다. 정확한 문자열 또는 의미적으로 유사한 문자열을 일치시킵니다. 캐시는 비용을 절감하고 지연 시간을 20배 줄일 수 있습니다. [문서](https://portkey.ai/docs/product/ai-gateway-streamline-llm-integrations/cache-simple-and-semantic)

**재시도**

실패한 API 요청을 **`최대 5회`** 자동으로 재처리합니다. **`지수 백오프`** 전략을 사용하여 네트워크 과부하를 방지하기 위해 재시도 시도를 간격을 두고 진행합니다. [문서](https://portkey.ai/docs/product/ai-gateway-streamline-llm-integrations)

**태깅**

미리 정의된 태그로 각 사용자 상호작용을 고도로 세부적으로 추적하고 감사합니다. [문서](https://portkey.ai/docs/product/observability-modern-monitoring-for-llms/metadata)