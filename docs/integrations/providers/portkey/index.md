---
description: 포트키는 AI 앱을 위한 제어판으로, Langchain에 생산 준비성을 제공하여 신뢰성 있고 비용 효율적인 앱을 빠르게 배포할
  수 있게 합니다.
---

# 포트키

[Portkey](https://portkey.ai)는 AI 앱을 위한 제어판입니다. 인기 있는 AI 게이트웨이와 관찰 가능성 스위트를 통해 수백 개 팀이 **신뢰할 수 있는**, **비용 효율적인**, **빠른** 앱을 배포합니다.

## LLMOps for Langchain

Portkey는 Langchain의 생산 준비성을 제공합니다. Portkey를 사용하면 
- [x] 통합 API를 통해 150개 이상의 모델에 연결할 수 있습니다,
- [x] 모든 요청에 대한 42개 이상의 **메트릭 및 로그**를 볼 수 있습니다,
- [x] 지연 시간 및 비용을 줄이기 위해 **시맨틱 캐시**를 활성화할 수 있습니다,
- [x] 실패한 요청에 대해 자동 **재시도 및 대체**를 구현할 수 있습니다,
- [x] 더 나은 추적 및 분석을 위해 요청에 **사용자 정의 태그**를 추가할 수 있습니다. [더 많은 정보는 여기를 클릭하세요](https://portkey.ai/docs).

## 빠른 시작 - Portkey & Langchain
Portkey는 OpenAI 서명과 완전히 호환되므로 `ChatOpenAI` 인터페이스를 통해 Portkey AI 게이트웨이에 연결할 수 있습니다.

- `base_url`을 `PORTKEY_GATEWAY_URL`로 설정합니다.
- `createHeaders` 헬퍼 메서드를 사용하여 Portkey에서 필요한 헤더를 소비하기 위해 `default_headers`를 추가합니다.

시작하려면 [여기에서 가입하여](https://app.portkey.ai/signup) Portkey API 키를 받으세요. (왼쪽 하단의 프로필 아이콘을 클릭한 다음 "API 키 복사"를 클릭하세요) 또는 [자신의 환경에 오픈 소스 AI 게이트웨이를 배포하세요](https://github.com/Portkey-AI/gateway/blob/main/docs/installation-deployments.md).

다음으로, Portkey SDK를 설치합니다.
```python
pip install -U portkey_ai
```


이제 Langchain에서 `ChatOpenAI` 모델을 업데이트하여 Portkey AI 게이트웨이에 연결할 수 있습니다.
```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Portkey"}]-->
from langchain_openai import ChatOpenAI
from portkey_ai import createHeaders, PORTKEY_GATEWAY_URL

PORTKEY_API_KEY = "..." # Not needed when hosting your own gateway
PROVIDER_API_KEY = "..." # Add the API key of the AI provider being used 

portkey_headers = createHeaders(api_key=PORTKEY_API_KEY,provider="openai")

llm = ChatOpenAI(api_key=PROVIDER_API_KEY, base_url=PORTKEY_GATEWAY_URL, default_headers=portkey_headers)

llm.invoke("What is the meaning of life, universe and everything?")
```


요청은 지정된 `provider`로 Portkey AI 게이트웨이를 통해 라우팅됩니다. Portkey는 또한 디버깅을 매우 간단하게 만드는 모든 요청을 귀하의 계정에 기록하기 시작합니다.

![Langchain에서 Portkey의 로그 보기](https://assets.portkey.ai/docs/langchain-logs.gif)

## AI 게이트웨이를 통한 150개 이상의 모델 사용
AI 게이트웨이의 힘은 위의 코드 스니펫을 사용하여 20개 이상의 제공업체에서 지원하는 150개 이상의 모델에 연결할 수 있을 때 나타납니다.

위의 코드를 수정하여 Anthropic의 `claude-3-opus-20240229` 모델에 호출해 보겠습니다.

Portkey는 API 키를 안전한 금고에 저장하고 관리하는 쉬운 방법인 **[가상 키](https://docs.portkey.ai/docs/product/ai-gateway-streamline-llm-integrations/virtual-keys)**를 지원합니다. LLM 호출을 위해 가상 키를 사용해 보겠습니다. Portkey의 가상 키 탭으로 이동하여 Anthropic에 대한 새 키를 생성할 수 있습니다.

`virtual_key` 매개변수는 사용 중인 AI 제공업체에 대한 인증 및 제공업체를 설정합니다. 우리의 경우 Anthropic 가상 키를 사용하고 있습니다.

> `api_key`는 인증이 사용되지 않으므로 비워둘 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Portkey"}]-->
from langchain_openai import ChatOpenAI
from portkey_ai import createHeaders, PORTKEY_GATEWAY_URL

PORTKEY_API_KEY = "..."
VIRTUAL_KEY = "..." # Anthropic's virtual key we copied above

portkey_headers = createHeaders(api_key=PORTKEY_API_KEY,virtual_key=VIRTUAL_KEY)

llm = ChatOpenAI(api_key="X", base_url=PORTKEY_GATEWAY_URL, default_headers=portkey_headers, model="claude-3-opus-20240229")

llm.invoke("What is the meaning of life, universe and everything?")
```


Portkey AI 게이트웨이는 Anthropic에 대한 API 요청을 인증하고 OpenAI 형식으로 응답을 반환합니다.

AI 게이트웨이는 Langchain의 `ChatOpenAI` 클래스를 확장하여 모든 제공업체와 모든 모델을 호출할 수 있는 단일 인터페이스를 만듭니다.

## 고급 라우팅 - 로드 밸런싱, 대체, 재시도
Portkey AI 게이트웨이는 구성 우선 접근 방식을 통해 Langchain에 로드 밸런싱, 대체, 실험 및 카나리 테스트와 같은 기능을 제공합니다.

`gpt-4`와 `claude-opus` 간의 트래픽을 50:50으로 나누어 두 개의 대형 모델을 테스트하고자 하는 **예제**를 살펴보겠습니다. 이 경우의 게이트웨이 구성은 다음과 같습니다:

```python
config = {
    "strategy": {
         "mode": "loadbalance"
    },
    "targets": [{
        "virtual_key": "openai-25654", # OpenAI's virtual key
        "override_params": {"model": "gpt4"},
        "weight": 0.5
    }, {
        "virtual_key": "anthropic-25654", # Anthropic's virtual key
        "override_params": {"model": "claude-3-opus-20240229"},
        "weight": 0.5
    }]
}
```


이 구성을 Langchain에서 이루어지는 요청에 사용할 수 있습니다.

```python
portkey_headers = createHeaders(
    api_key=PORTKEY_API_KEY,
    config=config
)

llm = ChatOpenAI(api_key="X", base_url=PORTKEY_GATEWAY_URL, default_headers=portkey_headers)

llm.invoke("What is the meaning of life, universe and everything?")
```


LLM이 호출되면 Portkey는 정의된 비율에 따라 요청을 `gpt-4`와 `claude-3-opus-20240229`에 분배합니다.

더 많은 구성 예제는 [여기](https://docs.portkey.ai/docs/api-reference/config-object#examples)에서 확인할 수 있습니다.

## **체인 및 에이전트 추적**

Portkey의 Langchain 통합은 에이전트의 실행에 대한 완전한 가시성을 제공합니다. [인기 있는 에이전트 워크플로우](https://python.langchain.com/docs/use_cases/tool_use/quickstart/#agents)의 예를 살펴보겠습니다.

위와 같이 AI 게이트웨이를 사용하기 위해 `ChatOpenAI` 클래스를 수정하기만 하면 됩니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Portkey"}, {"imported": "create_openai_tools_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_tools.base.create_openai_tools_agent.html", "title": "Portkey"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Portkey"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "Portkey"}]-->
from langchain import hub  
from langchain.agents import AgentExecutor, create_openai_tools_agent  
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from portkey_ai import PORTKEY_GATEWAY_URL, createHeaders
 
prompt = hub.pull("hwchase17/openai-tools-agent")

portkey_headers = createHeaders(
    api_key=PORTKEY_API_KEY,
    virtual_key=OPENAI_VIRTUAL_KEY,
    trace_id="uuid-uuid-uuid-uuid"
)

@tool
def multiply(first_int: int, second_int: int) -> int:
    """Multiply two integers together."""
    return first_int * second_int
  
  
@tool  
def exponentiate(base: int, exponent: int) -> int:  
    "Exponentiate the base to the exponent power."  
    return base**exponent  
  
  
tools = [multiply, exponentiate]

model = ChatOpenAI(api_key="X", base_url=PORTKEY_GATEWAY_URL, default_headers=portkey_headers, temperature=0)
  
# Construct the OpenAI Tools agent  
agent = create_openai_tools_agent(model, tools, prompt)

# Create an agent executor by passing in the agent and tools
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

agent_executor.invoke({
    "input": "Take 3 to the fifth power and multiply that by thirty six, then square the result"
})
```


**Portkey 대시보드에서 요청 로그와 함께 추적 ID를 확인할 수 있습니다:**
![Portkey의 Langchain 에이전트 로그](https://assets.portkey.ai/docs/agent_tracing.gif)

추가 문서는 여기에서 확인할 수 있습니다:
- 관찰 가능성 - https://portkey.ai/docs/product/observability-modern-monitoring-for-llms
- AI 게이트웨이 - https://portkey.ai/docs/product/ai-gateway-streamline-llm-integrations
- 프롬프트 라이브러리 - https://portkey.ai/docs/product/prompt-library

우리의 인기 있는 오픈 소스 AI 게이트웨이는 여기에서 확인할 수 있습니다 - https://github.com/portkey-ai/gateway

각 기능에 대한 자세한 정보와 사용 방법은 [Portkey 문서를 참조하세요](https://portkey.ai/docs). 질문이 있거나 추가 도움이 필요하시면 [트위터에서 문의하세요.](https://twitter.com/portkeyai) 또는 [지원 이메일](mailto:hello@portkey.ai)로 연락해 주세요.