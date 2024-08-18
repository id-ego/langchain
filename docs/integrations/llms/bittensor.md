---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/bittensor.ipynb
description: Bittensor는 채굴자들이 컴퓨팅 및 지식을 기여하도록 유도하는 분산 AI 네트워크로, 다양한 AI 모델을 활용합니다.
---

# Bittensor

> [Bittensor](https://bittensor.com/)는 비트코인과 유사한 채굴 네트워크로, 채굴자들이 컴퓨팅 및 지식을 기여하도록 유도하기 위해 설계된 내장 인센티브를 포함하고 있습니다.
> 
> `NIBittensorLLM`은 [Neural Internet](https://neuralinternet.ai/)에 의해 개발되었으며, `Bittensor`의 지원을 받습니다.

> 이 LLM은 `OpenAI`, `LLaMA2` 등 다양한 AI 모델로 구성된 `Bittensor 프로토콜`에서 최상의 응답을 제공함으로써 분산형 AI의 진정한 잠재력을 보여줍니다.

사용자는 [Validator Endpoint Frontend](https://api.neuralinternet.ai/)에서 로그, 요청 및 API 키를 확인할 수 있습니다. 그러나 구성 변경은 현재 금지되어 있으며, 그렇지 않으면 사용자의 쿼리가 차단됩니다.

어려움이 있거나 질문이 있는 경우, [GitHub](https://github.com/Kunj-2206), [Discord](https://discordapp.com/users/683542109248159777)에서 개발자에게 연락하거나 최신 업데이트 및 질문을 위해 [Neural Internet](https://discord.gg/neuralinternet) 디스코드 서버에 참여해 주시기 바랍니다.

## NIBittensorLLM에 대한 다양한 매개변수 및 응답 처리

```python
<!--IMPORTS:[{"imported": "set_debug", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_debug.html", "title": "Bittensor"}, {"imported": "NIBittensorLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.bittensor.NIBittensorLLM.html", "title": "Bittensor"}]-->
import json
from pprint import pprint

from langchain.globals import set_debug
from langchain_community.llms import NIBittensorLLM

set_debug(True)

# System parameter in NIBittensorLLM is optional but you can set whatever you want to perform with model
llm_sys = NIBittensorLLM(
    system_prompt="Your task is to determine response based on user prompt.Explain me like I am technical lead of a project"
)
sys_resp = llm_sys(
    "What is bittensor and What are the potential benefits of decentralized AI?"
)
print(f"Response provided by LLM with system prompt set is : {sys_resp}")

# The top_responses parameter can give multiple responses based on its parameter value
# This below code retrive top 10 miner's response all the response are in format of json

# Json response structure is
""" {
    "choices":  [
                    {"index": Bittensor's Metagraph index number,
                    "uid": Unique Identifier of a miner,
                    "responder_hotkey": Hotkey of a miner,
                    "message":{"role":"assistant","content": Contains actual response},
                    "response_ms": Time in millisecond required to fetch response from a miner} 
                ]
    } """

multi_response_llm = NIBittensorLLM(top_responses=10)
multi_resp = multi_response_llm.invoke("What is Neural Network Feeding Mechanism?")
json_multi_resp = json.loads(multi_resp)
pprint(json_multi_resp)
```


## LLMChain 및 PromptTemplate와 함께 NIBittensorLLM 사용하기

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Bittensor"}, {"imported": "set_debug", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_debug.html", "title": "Bittensor"}, {"imported": "NIBittensorLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.bittensor.NIBittensorLLM.html", "title": "Bittensor"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Bittensor"}]-->
from langchain.chains import LLMChain
from langchain.globals import set_debug
from langchain_community.llms import NIBittensorLLM
from langchain_core.prompts import PromptTemplate

set_debug(True)

template = """Question: {question}

Answer: Let's think step by step."""


prompt = PromptTemplate.from_template(template)

# System parameter in NIBittensorLLM is optional but you can set whatever you want to perform with model
llm = NIBittensorLLM(
    system_prompt="Your task is to determine response based on user prompt."
)

llm_chain = LLMChain(prompt=prompt, llm=llm)
question = "What is bittensor?"

llm_chain.run(question)
```


## 대화형 에이전트 및 Google 검색 도구와 함께 NIBittensorLLM 사용하기

```python
<!--IMPORTS:[{"imported": "GoogleSearchAPIWrapper", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.google_search.GoogleSearchAPIWrapper.html", "title": "Bittensor"}, {"imported": "Tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.simple.Tool.html", "title": "Bittensor"}]-->
from langchain_community.utilities import GoogleSearchAPIWrapper
from langchain_core.tools import Tool

search = GoogleSearchAPIWrapper()

tool = Tool(
    name="Google Search",
    description="Search Google for recent results.",
    func=search.run,
)
```


```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Bittensor"}, {"imported": "create_react_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.react.agent.create_react_agent.html", "title": "Bittensor"}, {"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "Bittensor"}, {"imported": "NIBittensorLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.bittensor.NIBittensorLLM.html", "title": "Bittensor"}]-->
from langchain import hub
from langchain.agents import (
    AgentExecutor,
    create_react_agent,
)
from langchain.memory import ConversationBufferMemory
from langchain_community.llms import NIBittensorLLM

tools = [tool]

prompt = hub.pull("hwchase17/react")


llm = NIBittensorLLM(
    system_prompt="Your task is to determine a response based on user prompt"
)

memory = ConversationBufferMemory(memory_key="chat_history")

agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, memory=memory)

response = agent_executor.invoke({"input": prompt})
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)