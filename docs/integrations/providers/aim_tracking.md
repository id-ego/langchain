---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/aim_tracking.ipynb
description: Aim은 LangChain 실행을 시각화하고 디버깅하는 데 도움을 주며, LLM 및 도구의 입력과 출력을 추적합니다.
---

# 목표

Aim은 LangChain 실행을 시각화하고 디버깅하는 것을 매우 쉽게 만들어 줍니다. Aim은 LLM과 도구의 입력 및 출력을 추적하고, 에이전트의 행동도 추적합니다.

Aim을 사용하면 개별 실행을 쉽게 디버깅하고 검토할 수 있습니다:

![](https://user-images.githubusercontent.com/13848158/227784778-06b806c7-74a1-4d15-ab85-9ece09b458aa.png)

추가로, 여러 실행을 나란히 비교할 수 있는 옵션도 있습니다:

![](https://user-images.githubusercontent.com/13848158/227784994-699b24b7-e69b-48f9-9ffa-e6a6142fd719.png)

Aim은 완전히 오픈 소스이며, [더 알아보기](https://github.com/aimhubio/aim) 위해 GitHub에서 Aim에 대해 확인해 보세요.

이제 Aim 콜백을 활성화하고 구성하는 방법을 살펴보겠습니다.

<h3>LangChain 실행 추적하기</h3>

이 노트북에서는 세 가지 사용 시나리오를 탐색할 것입니다. 먼저 필요한 패키지를 설치하고 특정 모듈을 가져옵니다. 그 후, Python 스크립트 내에서 또는 터미널을 통해 설정할 수 있는 두 개의 환경 변수를 구성합니다.

```python
%pip install --upgrade --quiet  aim
%pip install --upgrade --quiet  langchain
%pip install --upgrade --quiet  langchain-openai
%pip install --upgrade --quiet  google-search-results
```


```python
<!--IMPORTS:[{"imported": "AimCallbackHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.aim_callback.AimCallbackHandler.html", "title": "Aim"}, {"imported": "StdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.stdout.StdOutCallbackHandler.html", "title": "Aim"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Aim"}]-->
import os
from datetime import datetime

from langchain_community.callbacks import AimCallbackHandler
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_openai import OpenAI
```


우리의 예제는 LLM으로 GPT 모델을 사용하며, OpenAI는 이를 위한 API를 제공합니다. 키는 다음 링크에서 얻을 수 있습니다: https://platform.openai.com/account/api-keys .

우리는 SerpApi를 사용하여 Google에서 검색 결과를 가져옵니다. SerpApi 키를 얻으려면 https://serpapi.com/manage-api-key 로 가세요.

```python
os.environ["OPENAI_API_KEY"] = "..."
os.environ["SERPAPI_API_KEY"] = "..."
```


`AimCallbackHandler`의 이벤트 메서드는 LangChain 모듈 또는 에이전트를 입력으로 받아서 최소한 프롬프트와 생성된 결과, 그리고 LangChain 모듈의 직렬화된 버전을 지정된 Aim 실행에 기록합니다.

```python
session_group = datetime.now().strftime("%m.%d.%Y_%H.%M.%S")
aim_callback = AimCallbackHandler(
    repo=".",
    experiment_name="scenario 1: OpenAI LLM",
)

callbacks = [StdOutCallbackHandler(), aim_callback]
llm = OpenAI(temperature=0, callbacks=callbacks)
```


`flush_tracker` 함수는 Aim에서 LangChain 자산을 기록하는 데 사용됩니다. 기본적으로 세션은 완전히 종료되는 것이 아니라 재설정됩니다.

<h3>시나리오 1</h3> 첫 번째 시나리오에서는 OpenAI LLM을 사용할 것입니다.

```python
# scenario 1 - LLM
llm_result = llm.generate(["Tell me a joke", "Tell me a poem"] * 3)
aim_callback.flush_tracker(
    langchain_asset=llm,
    experiment_name="scenario 2: Chain with multiple SubChains on multiple generations",
)
```


<h3>시나리오 2</h3> 두 번째 시나리오는 여러 생성에 걸쳐 여러 SubChain을 연결하는 것입니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Aim"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Aim"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate
```


```python
# scenario 2 - Chain
template = """You are a playwright. Given the title of play, it is your job to write a synopsis for that title.
Title: {title}
Playwright: This is a synopsis for the above play:"""
prompt_template = PromptTemplate(input_variables=["title"], template=template)
synopsis_chain = LLMChain(llm=llm, prompt=prompt_template, callbacks=callbacks)

test_prompts = [
    {
        "title": "documentary about good video games that push the boundary of game design"
    },
    {"title": "the phenomenon behind the remarkable speed of cheetahs"},
    {"title": "the best in class mlops tooling"},
]
synopsis_chain.apply(test_prompts)
aim_callback.flush_tracker(
    langchain_asset=synopsis_chain, experiment_name="scenario 3: Agent with Tools"
)
```


<h3>시나리오 3</h3> 세 번째 시나리오는 도구가 있는 에이전트를 포함합니다.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Aim"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Aim"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Aim"}]-->
from langchain.agents import AgentType, initialize_agent, load_tools
```


```python
# scenario 3 - Agent with Tools
tools = load_tools(["serpapi", "llm-math"], llm=llm, callbacks=callbacks)
agent = initialize_agent(
    tools,
    llm,
    agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    callbacks=callbacks,
)
agent.run(
    "Who is Leo DiCaprio's girlfriend? What is her current age raised to the 0.43 power?"
)
aim_callback.flush_tracker(langchain_asset=agent, reset=False, finish=True)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m I need to find out who Leo DiCaprio's girlfriend is and then calculate her age raised to the 0.43 power.
Action: Search
Action Input: "Leo DiCaprio girlfriend"[0m
Observation: [36;1m[1;3mLeonardo DiCaprio seemed to prove a long-held theory about his love life right after splitting from girlfriend Camila Morrone just months ...[0m
Thought:[32;1m[1;3m I need to find out Camila Morrone's age
Action: Search
Action Input: "Camila Morrone age"[0m
Observation: [36;1m[1;3m25 years[0m
Thought:[32;1m[1;3m I need to calculate 25 raised to the 0.43 power
Action: Calculator
Action Input: 25^0.43[0m
Observation: [33;1m[1;3mAnswer: 3.991298452658078
[0m
Thought:[32;1m[1;3m I now know the final answer
Final Answer: Camila Morrone is Leo DiCaprio's girlfriend and her current age raised to the 0.43 power is 3.991298452658078.[0m

[1m> Finished chain.[0m
```