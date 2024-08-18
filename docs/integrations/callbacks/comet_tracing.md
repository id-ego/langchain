---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/comet_tracing.ipynb
description: LangChains 실행을 Comet으로 추적하는 방법을 소개합니다. 환경 변수를 설정하거나 CometTracer를 수동으로
  가져오는 두 가지 방법이 있습니다.
---

# 혜성 추적

Comet으로 LangChains 실행을 추적하는 방법은 두 가지가 있습니다:

1. `LANGCHAIN_COMET_TRACING` 환경 변수를 "true"로 설정합니다. 이것이 권장되는 방법입니다.
2. `CometTracer`를 수동으로 가져오고 명시적으로 전달합니다.

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Comet Tracing"}, {"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Comet Tracing"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Comet Tracing"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Comet Tracing"}]-->
import os

import comet_llm
from langchain_openai import OpenAI

os.environ["LANGCHAIN_COMET_TRACING"] = "true"

# Connect to Comet if no API Key is set
comet_llm.init()

# comet documentation to configure comet using env variables
# https://www.comet.com/docs/v2/api-and-sdk/llm-sdk/configuration/
# here we are configuring the comet project
os.environ["COMET_PROJECT_NAME"] = "comet-example-langchain-tracing"

from langchain.agents import AgentType, initialize_agent, load_tools
```


```python
# Agent run with tracing. Ensure that OPENAI_API_KEY is set appropriately to run this example.

llm = OpenAI(temperature=0)
tools = load_tools(["llm-math"], llm=llm)
```


```python
agent = initialize_agent(
    tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)

agent.run("What is 2 raised to .123243 power?")  # this should be traced
# An url for the chain like the following should print in your console:
# https://www.comet.com/<workspace>/<project_name>
# The url can be used to view the LLM chain in Comet.
```


```python
<!--IMPORTS:[{"imported": "CometTracer", "source": "langchain_community.callbacks.tracers.comet", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.tracers.comet.CometTracer.html", "title": "Comet Tracing"}]-->
# Now, we unset the environment variable and use a context manager.
if "LANGCHAIN_COMET_TRACING" in os.environ:
    del os.environ["LANGCHAIN_COMET_TRACING"]

from langchain_community.callbacks.tracers.comet import CometTracer

tracer = CometTracer()

# Recreate the LLM, tools and agent and passing the callback to each of them
llm = OpenAI(temperature=0)
tools = load_tools(["llm-math"], llm=llm)
agent = initialize_agent(
    tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)

agent.run(
    "What is 2 raised to .123243 power?", callbacks=[tracer]
)  # this should be traced
```