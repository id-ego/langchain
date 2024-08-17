---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/bittensor/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/bittensor.ipynb
---

# Bittensor

>[Bittensor](https://bittensor.com/) is a mining network, similar to Bitcoin, that includes built-in incentives designed to encourage miners to contribute compute + knowledge.
>
>`NIBittensorLLM` is developed by [Neural Internet](https://neuralinternet.ai/), powered by `Bittensor`.

>This LLM showcases true potential of decentralized AI by giving you the best response(s) from the `Bittensor protocol`, which consist of various AI models such as `OpenAI`, `LLaMA2` etc.

Users can view their logs, requests, and API keys on the [Validator Endpoint Frontend](https://api.neuralinternet.ai/). However, changes to the configuration are currently prohibited; otherwise, the user's queries will be blocked.

If you encounter any difficulties or have any questions, please feel free to reach out to our developer on [GitHub](https://github.com/Kunj-2206), [Discord](https://discordapp.com/users/683542109248159777) or join our discord server for latest update and queries [Neural Internet](https://discord.gg/neuralinternet).


## Different Parameter and response handling for NIBittensorLLM 


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

##  Using NIBittensorLLM with LLMChain and PromptTemplate


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

##  Using NIBittensorLLM with Conversational Agent and Google Search Tool


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


## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)