---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/robocorp/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/robocorp.ipynb
---

# Robocorp Toolkit

This notebook covers how to get started with [Robocorp Action Server](https://github.com/robocorp/robocorp) action toolkit and LangChain.

Robocorp is the easiest way to extend the capabilities of AI agents, assistants and copilots with custom actions.

## Installation

First, see the [Robocorp Quickstart](https://github.com/robocorp/robocorp#quickstart) on how to setup `Action Server` and create your Actions.

In your LangChain application, install the `langchain-robocorp` package: 

```python
# Install package
%pip install --upgrade --quiet langchain-robocorp
```

When you create the new `Action Server` following the above quickstart.

It will create a directory with files, including `action.py`.

We can add python function as actions as shown [here](https://github.com/robocorp/robocorp/tree/master/actions#describe-your-action).

Let's add a dummy function to `action.py`.

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

We then start the server:

```bash
action-server start
```

And we can see: 

```
Found new action: get_weather_forecast

```

Test locally by going to the server running at `http://localhost:8080` and use the UI to run the function.

## Environment Setup

Optionally you can set the following environment variables:

- `LANGCHAIN_TRACING_V2=true`: To enable LangSmith log run tracing that can also be bind to respective Action Server action run logs. See [LangSmith documentation](https://docs.smith.langchain.com/tracing#log-runs) for more.

## Usage

We started the local action server, above, running on `http://localhost:8080`.

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

### Single input tools

By default `toolkit.get_tools()` will return the actions as Structured Tools. 

To return single input tools, pass a Chat model to be used for processing the inputs.

```python
# Initialize single input Action Server Toolkit
toolkit = ActionServerToolkit(url="http://localhost:8080")
tools = toolkit.get_tools(llm=llm)
```

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)