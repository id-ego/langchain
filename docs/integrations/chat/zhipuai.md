---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/zhipuai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/zhipuai.ipynb
sidebar_label: ZHIPU AI
---

# ZHIPU AI

This notebook shows how to use [ZHIPU AI API](https://open.bigmodel.cn/dev/api) in LangChain with the langchain.chat_models.ChatZhipuAI.

>[*GLM-4*](https://open.bigmodel.cn/) is a multi-lingual large language model aligned with human intent, featuring capabilities in Q&A, multi-turn dialogue, and code generation. The overall performance of the new generation base model GLM-4 has been significantly improved compared to the previous generation, supporting longer contexts; Stronger multimodality; Support faster inference speed, more concurrency, greatly reducing inference costs; Meanwhile, GLM-4 enhances the capabilities of intelligent agents.

## Getting started
### Installation
First, ensure the zhipuai package is installed in your Python environment. Run the following command:


```python
#!pip install --upgrade httpx httpx-sse PyJWT
```

### Importing the Required Modules
After installation, import the necessary modules to your Python script:


```python
<!--IMPORTS:[{"imported": "ChatZhipuAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.zhipuai.ChatZhipuAI.html", "title": "ZHIPU AI"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "ZHIPU AI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ZHIPU AI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ZHIPU AI"}]-->
from langchain_community.chat_models import ChatZhipuAI
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
```

### Setting Up Your API Key
Sign in to [ZHIPU AI](https://open.bigmodel.cn/login?redirect=%2Fusercenter%2Fapikeys) for the an API Key to access our models.


```python
import os

os.environ["ZHIPUAI_API_KEY"] = "zhipuai_api_key"
```

### Initialize the ZHIPU AI Chat Model
Here's how to initialize the chat model:


```python
chat = ChatZhipuAI(
    model="glm-4",
    temperature=0.5,
)
```

### Basic Usage
Invoke the model with system and human messages like this:


```python
messages = [
    AIMessage(content="Hi."),
    SystemMessage(content="Your role is a poet."),
    HumanMessage(content="Write a short poem about AI in four lines."),
]
```


```python
response = chat.invoke(messages)
print(response.content)  # Displays the AI-generated poem
```

## Advanced Features
### Streaming Support
For continuous interaction, use the streaming feature:


```python
<!--IMPORTS:[{"imported": "CallbackManager", "source": "langchain_core.callbacks.manager", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "ZHIPU AI"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks.streaming_stdout", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "ZHIPU AI"}]-->
from langchain_core.callbacks.manager import CallbackManager
from langchain_core.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
```


```python
streaming_chat = ChatZhipuAI(
    model="glm-4",
    temperature=0.5,
    streaming=True,
    callback_manager=CallbackManager([StreamingStdOutCallbackHandler()]),
)
```


```python
streaming_chat(messages)
```

### Asynchronous Calls
For non-blocking calls, use the asynchronous approach:


```python
async_chat = ChatZhipuAI(
    model="glm-4",
    temperature=0.5,
)
```


```python
response = await async_chat.agenerate([messages])
print(response)
```

### Using With Functions Call

GLM-4 Model can be used with the function call as well，use the following code to run a simple LangChain json_chat_agent.


```python
os.environ["TAVILY_API_KEY"] = "tavily_api_key"
```


```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "ZHIPU AI"}, {"imported": "create_json_chat_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.json_chat.base.create_json_chat_agent.html", "title": "ZHIPU AI"}, {"imported": "TavilySearchResults", "source": "langchain_community.tools.tavily_search", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.tavily_search.tool.TavilySearchResults.html", "title": "ZHIPU AI"}]-->
from langchain import hub
from langchain.agents import AgentExecutor, create_json_chat_agent
from langchain_community.tools.tavily_search import TavilySearchResults

tools = [TavilySearchResults(max_results=1)]
prompt = hub.pull("hwchase17/react-chat-json")
llm = ChatZhipuAI(temperature=0.01, model="glm-4")

agent = create_json_chat_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent, tools=tools, verbose=True, handle_parsing_errors=True
)
```


```python
agent_executor.invoke({"input": "what is LangChain?"})
```


## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)