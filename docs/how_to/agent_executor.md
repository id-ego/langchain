---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/agent_executor.ipynb
description: 이 문서는 레거시 LangChain AgentExecutor를 사용하여 여러 도구와 상호작용하는 에이전트를 구축하는 방법을
  설명합니다.
sidebar_position: 4
---

# 에이전트 실행기(레거시)로 에이전트 구축하기

:::important
이 섹션에서는 레거시 LangChain AgentExecutor로 구축하는 방법을 다룹니다. 이는 시작하기에 적합하지만, 일정 수준을 넘어서면 제공하지 않는 유연성과 제어가 필요할 것입니다. 더 고급 에이전트와 작업하려면 [LangGraph Agents](/docs/concepts/#langgraph) 또는 [마이그레이션 가이드](/docs/how_to/migrate_agent/)를 확인하는 것이 좋습니다.
:::

언어 모델 자체로는 행동을 취할 수 없습니다 - 단지 텍스트를 출력할 뿐입니다.  
LangChain의 주요 사용 사례 중 하나는 **에이전트**를 만드는 것입니다.  
에이전트는 LLM을 추론 엔진으로 사용하여 어떤 행동을 취할지, 그 행동에 대한 입력이 무엇이어야 할지를 결정하는 시스템입니다.  
그 행동의 결과는 다시 에이전트에 피드백되어 추가 행동이 필요한지, 아니면 종료해도 되는지를 결정합니다.

이 튜토리얼에서는 여러 가지 도구와 상호작용할 수 있는 에이전트를 구축할 것입니다: 하나는 로컬 데이터베이스이고, 다른 하나는 검색 엔진입니다.  
이 에이전트에게 질문을 하고, 도구를 호출하는 모습을 지켜보며, 대화를 나눌 수 있습니다.

## 개념

우리가 다룰 개념은 다음과 같습니다:
- [언어 모델](/docs/concepts/#chat-models), 특히 도구 호출 능력 사용
- 에이전트에 특정 정보를 노출하기 위한 [Retriever](/docs/concepts/#retrievers) 생성
- 온라인에서 정보를 검색하기 위한 검색 [도구](/docs/concepts/#tools) 사용
- [`Chat History`](/docs/concepts/#chat-history), 챗봇이 과거 상호작용을 "기억"하고 후속 질문에 응답할 때 이를 고려할 수 있게 해줍니다.
- [LangSmith](/docs/concepts/#langsmith)를 사용하여 애플리케이션 디버깅 및 추적

## 설정

### 주피터 노트북

이 가이드(및 문서의 대부분의 다른 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며, 독자가 주피터 노트북을 사용하고 있다고 가정합니다.  
주피터 노트북은 LLM 시스템 작업을 배우기에 완벽합니다. 왜냐하면 종종 예상치 못한 출력, API 다운 등 문제가 발생할 수 있기 때문입니다.  
인터랙티브 환경에서 가이드를 진행하는 것은 이를 더 잘 이해하는 좋은 방법입니다.

이 튜토리얼과 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행됩니다. 설치 방법은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

LangChain을 설치하려면 다음을 실행하세요:

import Tabs from '@theme/Tabs';  
import TabItem from '@theme/TabItem';  
import CodeBlock from "@theme/CodeBlock";

<Tabs>  
  <TabItem value="pip" label="Pip" default>  
    <CodeBlock language="bash">pip install langchain</CodeBlock>  
  </TabItem>  
  <TabItem value="conda" label="Conda">  
    <CodeBlock language="bash">conda install langchain -c conda-forge</CodeBlock>  
  </TabItem>  
</Tabs>

자세한 내용은 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 LLM 호출을 포함합니다.  
이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지 검사할 수 있는 것이 중요해집니다.  
이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)입니다.

위 링크에서 가입한 후, 환경 변수를 설정하여 추적 로그를 시작하세요:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```


또는, 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 도구 정의

먼저 사용하고자 하는 도구를 생성해야 합니다. 우리는 두 가지 도구를 사용할 것입니다: [Tavily](/docs/integrations/tools/tavily_search) (온라인 검색용)과 우리가 생성할 로컬 인덱스에 대한 리트리버입니다.

### [Tavily](/docs/integrations/tools/tavily_search)

LangChain에는 Tavily 검색 엔진을 도구로 쉽게 사용할 수 있는 내장 도구가 있습니다.  
이것은 API 키가 필요하므로 주의하세요 - 무료 티어가 있지만, API 키가 없거나 생성하고 싶지 않다면 이 단계를 무시할 수 있습니다.

API 키를 생성한 후, 다음과 같이 내보내야 합니다:

```bash
export TAVILY_API_KEY="..."
```


```python
<!--IMPORTS:[{"imported": "TavilySearchResults", "source": "langchain_community.tools.tavily_search", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.tavily_search.tool.TavilySearchResults.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain_community.tools.tavily_search import TavilySearchResults
```


```python
search = TavilySearchResults(max_results=2)
```


```python
search.invoke("what is the weather in SF")
```


```output
[{'url': 'https://www.weatherapi.com/',
  'content': "{'location': {'name': 'San Francisco', 'region': 'California', 'country': 'United States of America', 'lat': 37.78, 'lon': -122.42, 'tz_id': 'America/Los_Angeles', 'localtime_epoch': 1714000492, 'localtime': '2024-04-24 16:14'}, 'current': {'last_updated_epoch': 1713999600, 'last_updated': '2024-04-24 16:00', 'temp_c': 15.6, 'temp_f': 60.1, 'is_day': 1, 'condition': {'text': 'Overcast', 'icon': '//cdn.weatherapi.com/weather/64x64/day/122.png', 'code': 1009}, 'wind_mph': 10.5, 'wind_kph': 16.9, 'wind_degree': 330, 'wind_dir': 'NNW', 'pressure_mb': 1018.0, 'pressure_in': 30.06, 'precip_mm': 0.0, 'precip_in': 0.0, 'humidity': 72, 'cloud': 100, 'feelslike_c': 15.6, 'feelslike_f': 60.1, 'vis_km': 16.0, 'vis_miles': 9.0, 'uv': 5.0, 'gust_mph': 14.8, 'gust_kph': 23.8}}"},
 {'url': 'https://www.weathertab.com/en/c/e/04/united-states/california/san-francisco/',
  'content': 'San Francisco Weather Forecast for Apr 2024 - Risk of Rain Graph. Rain Risk Graph: Monthly Overview. Bar heights indicate rain risk percentages. Yellow bars mark low-risk days, while black and grey bars signal higher risks. Grey-yellow bars act as buffers, advising to keep at least one day clear from the riskier grey and black days, guiding ...'}]
```


### 리트리버

우리는 또한 우리 자신의 데이터에 대한 리트리버를 생성할 것입니다. 각 단계에 대한 더 깊은 설명은 [이 튜토리얼](/docs/tutorials/rag)을 참조하세요.

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Build an Agent with AgentExecutor (Legacy)"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Build an Agent with AgentExecutor (Legacy)"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Build an Agent with AgentExecutor (Legacy)"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

loader = WebBaseLoader("https://docs.smith.langchain.com/overview")
docs = loader.load()
documents = RecursiveCharacterTextSplitter(
    chunk_size=1000, chunk_overlap=200
).split_documents(docs)
vector = FAISS.from_documents(documents, OpenAIEmbeddings())
retriever = vector.as_retriever()
```


```python
retriever.invoke("how to upload a dataset")[0]
```


```output
Document(page_content='# The data to predict and grade over    evaluators=[exact_match], # The evaluators to score the results    experiment_prefix="sample-experiment", # The name of the experiment    metadata={      "version": "1.0.0",      "revision_id": "beta"    },)import { Client, Run, Example } from \'langsmith\';import { runOnDataset } from \'langchain/smith\';import { EvaluationResult } from \'langsmith/evaluation\';const client = new Client();// Define dataset: these are your test casesconst datasetName = "Sample Dataset";const dataset = await client.createDataset(datasetName, {    description: "A sample dataset in LangSmith."});await client.createExamples({    inputs: [        { postfix: "to LangSmith" },        { postfix: "to Evaluations in LangSmith" },    ],    outputs: [        { output: "Welcome to LangSmith" },        { output: "Welcome to Evaluations in LangSmith" },    ],    datasetId: dataset.id,});// Define your evaluatorconst exactMatch = async ({ run, example }: { run: Run; example?:', metadata={'source': 'https://docs.smith.langchain.com/overview', 'title': 'Getting started with LangSmith | \uf8ffü¶úÔ∏è\uf8ffüõ†Ô∏è LangSmith', 'description': 'Introduction', 'language': 'en'})
```


이제 우리가 검색할 인덱스를 채웠으므로, 이를 도구로 쉽게 변환할 수 있습니다(에이전트가 제대로 사용하기 위해 필요한 형식).

```python
<!--IMPORTS:[{"imported": "create_retriever_tool", "source": "langchain.tools.retriever", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.retriever.create_retriever_tool.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain.tools.retriever import create_retriever_tool
```


```python
retriever_tool = create_retriever_tool(
    retriever,
    "langsmith_search",
    "Search for information about LangSmith. For any questions about LangSmith, you must use this tool!",
)
```


### 도구

이제 두 가지 도구를 모두 생성했으므로, 하류에서 사용할 도구 목록을 생성할 수 있습니다.

```python
tools = [search, retriever_tool]
```


## 언어 모델 사용하기

다음으로, 도구를 호출하기 위해 언어 모델을 사용하는 방법을 배워보겠습니다. LangChain은 서로 교환 가능하게 사용할 수 있는 다양한 언어 모델을 지원합니다 - 아래에서 사용하고자 하는 모델을 선택하세요!

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs openaiParams={`model="gpt-4"`} />

언어 모델을 호출하려면 메시지 목록을 전달하면 됩니다. 기본적으로 응답은 `content` 문자열입니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain_core.messages import HumanMessage

response = model.invoke([HumanMessage(content="hi!")])
response.content
```


```output
'Hello! How can I assist you today?'
```


이제 이 모델이 도구 호출을 수행할 수 있도록 하는 것이 어떤 것인지 볼 수 있습니다. 이를 활성화하기 위해 `.bind_tools`를 사용하여 언어 모델에 이러한 도구에 대한 지식을 제공합니다.

```python
model_with_tools = model.bind_tools(tools)
```


이제 모델을 호출할 수 있습니다. 먼저 일반 메시지로 호출하고, 어떻게 응답하는지 봅시다. `content` 필드와 `tool_calls` 필드를 모두 살펴볼 수 있습니다.

```python
response = model_with_tools.invoke([HumanMessage(content="Hi!")])

print(f"ContentString: {response.content}")
print(f"ToolCalls: {response.tool_calls}")
```
  
```output
ContentString: Hello! How can I assist you today?
ToolCalls: []
```
  
이제 도구 호출이 예상되는 입력으로 호출해 보겠습니다.

```python
response = model_with_tools.invoke([HumanMessage(content="What's the weather in SF?")])

print(f"ContentString: {response.content}")
print(f"ToolCalls: {response.tool_calls}")
```
  
```output
ContentString: 
ToolCalls: [{'name': 'tavily_search_results_json', 'args': {'query': 'current weather in San Francisco'}, 'id': 'call_4HteVahXkRAkWjp6dGXryKZX'}]
```
  
이제 콘텐츠는 없지만, 도구 호출이 있습니다! Tavily 검색 도구를 호출하라고 요청하고 있습니다.

이것은 아직 도구를 호출하는 것이 아닙니다 - 단지 호출하라고 알려주는 것입니다. 실제로 호출하려면 에이전트를 생성해야 합니다.

## 에이전트 생성

이제 도구와 LLM을 정의했으므로 에이전트를 생성할 수 있습니다. 우리는 도구 호출 에이전트를 사용할 것입니다 - 이 유형의 에이전트 및 기타 옵션에 대한 자세한 내용은 [이 가이드](/docs/concepts/#agent_types/)를 참조하세요.

먼저 에이전트를 안내할 프롬프트를 선택할 수 있습니다.

이 프롬프트의 내용을 보고 LangSmith에 접근하고 싶다면 다음으로 가세요:

[https://smith.langchain.com/hub/hwchase17/openai-functions-agent](https://smith.langchain.com/hub/hwchase17/openai-functions-agent)

```python
from langchain import hub

# Get the prompt to use - you can modify this!
prompt = hub.pull("hwchase17/openai-functions-agent")
prompt.messages
```


```output
[SystemMessagePromptTemplate(prompt=PromptTemplate(input_variables=[], template='You are a helpful assistant')),
 MessagesPlaceholder(variable_name='chat_history', optional=True),
 HumanMessagePromptTemplate(prompt=PromptTemplate(input_variables=['input'], template='{input}')),
 MessagesPlaceholder(variable_name='agent_scratchpad')]
```


이제 LLM, 프롬프트 및 도구로 에이전트를 초기화할 수 있습니다. 에이전트는 입력을 받아들이고 어떤 행동을 취할지를 결정하는 역할을 합니다. 중요한 것은, 에이전트는 이러한 행동을 실행하지 않으며 - 이는 에이전트 실행기(다음 단계)가 수행합니다. 이러한 구성 요소를 생각하는 방법에 대한 자세한 내용은 [개념 가이드](/docs/concepts/#agents)를 참조하세요.

`model`을 전달하고 있으며, `model_with_tools`는 전달하지 않는 점에 유의하세요. 이는 `create_tool_calling_agent`가 내부적으로 `.bind_tools`를 호출하기 때문입니다.

```python
<!--IMPORTS:[{"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain.agents import create_tool_calling_agent

agent = create_tool_calling_agent(model, tools, prompt)
```


마지막으로, 에이전트(두뇌)와 도구를 에이전트 실행기 내에서 결합합니다(여기서 에이전트를 반복적으로 호출하고 도구를 실행합니다).

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain.agents import AgentExecutor

agent_executor = AgentExecutor(agent=agent, tools=tools)
```


## 에이전트 실행

이제 몇 가지 쿼리에 대해 에이전트를 실행할 수 있습니다! 현재 이들은 모두 **상태 비저장** 쿼리입니다(이전 상호작용을 기억하지 않습니다).

먼저, 도구를 호출할 필요가 없을 때 어떻게 응답하는지 봅시다:

```python
agent_executor.invoke({"input": "hi!"})
```


```output
{'input': 'hi!', 'output': 'Hello! How can I assist you today?'}
```


정확히 무슨 일이 일어나고 있는지 확인하기 위해 (그리고 도구를 호출하지 않는지 확인하기 위해) [LangSmith 추적](https://smith.langchain.com/public/8441812b-94ce-4832-93ec-e1114214553a/r)를 살펴볼 수 있습니다.

이제 리트리버를 호출해야 하는 예제에서 시도해 보겠습니다.

```python
agent_executor.invoke({"input": "how can langsmith help with testing?"})
```


```output
{'input': 'how can langsmith help with testing?',
 'output': 'LangSmith is a platform that aids in building production-grade Language Learning Model (LLM) applications. It can assist with testing in several ways:\n\n1. **Monitoring and Evaluation**: LangSmith allows close monitoring and evaluation of your application. This helps you to ensure the quality of your application and deploy it with confidence.\n\n2. **Tracing**: LangSmith has tracing capabilities that can be beneficial for debugging and understanding the behavior of your application.\n\n3. **Evaluation Capabilities**: LangSmith has built-in tools for evaluating the performance of your LLM. \n\n4. **Prompt Hub**: This is a prompt management tool built into LangSmith that can help in testing different prompts and their responses.\n\nPlease note that to use LangSmith, you would need to install it and create an API key. The platform offers Python and Typescript SDKs for utilization. It works independently and does not require the use of LangChain.'}
```


이것이 실제로 호출되고 있는지 확인하기 위해 [LangSmith 추적](https://smith.langchain.com/public/762153f6-14d4-4c98-8659-82650f860c62/r)를 살펴보겠습니다.

이제 검색 도구를 호출해야 하는 예제를 시도해 보겠습니다:

```python
agent_executor.invoke({"input": "whats the weather in sf?"})
```


```output
{'input': 'whats the weather in sf?',
 'output': 'The current weather in San Francisco is partly cloudy with a temperature of 16.1°C (61.0°F). The wind is coming from the WNW at a speed of 10.5 mph. The humidity is at 67%. [source](https://www.weatherapi.com/)'}
```


검색 도구가 효과적으로 호출되고 있는지 확인하기 위해 [LangSmith 추적](https://smith.langchain.com/public/36df5b1a-9a0b-4185-bae2-964e1d53c665/r)를 확인할 수 있습니다.

## 메모리 추가

앞서 언급했듯이, 이 에이전트는 상태 비저장입니다. 즉, 이전 상호작용을 기억하지 않습니다. 메모리를 주기 위해 이전 `chat_history`를 전달해야 합니다. 참고: 사용 중인 프롬프트 때문에 `chat_history`라고 불러야 합니다. 다른 프롬프트를 사용하면 변수 이름을 변경할 수 있습니다.

```python
# Here we pass in an empty list of messages for chat_history because it is the first message in the chat
agent_executor.invoke({"input": "hi! my name is bob", "chat_history": []})
```


```output
{'input': 'hi! my name is bob',
 'chat_history': [],
 'output': 'Hello Bob! How can I assist you today?'}
```


```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Build an Agent with AgentExecutor (Legacy)"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain_core.messages import AIMessage, HumanMessage
```


```python
agent_executor.invoke(
    {
        "chat_history": [
            HumanMessage(content="hi! my name is bob"),
            AIMessage(content="Hello Bob! How can I assist you today?"),
        ],
        "input": "what's my name?",
    }
)
```


```output
{'chat_history': [HumanMessage(content='hi! my name is bob'),
  AIMessage(content='Hello Bob! How can I assist you today?')],
 'input': "what's my name?",
 'output': 'Your name is Bob. How can I assist you further?'}
```


이 메시지를 자동으로 추적하려면, 이를 RunnableWithMessageHistory로 감쌀 수 있습니다. 사용 방법에 대한 자세한 내용은 [이 가이드](/docs/how_to/message_history)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "Build an Agent with AgentExecutor (Legacy)"}, {"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "Build an Agent with AgentExecutor (Legacy)"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Build an Agent with AgentExecutor (Legacy)"}]-->
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}


def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]
```


여러 입력이 있기 때문에 두 가지를 지정해야 합니다:

- `input_messages_key`: 대화 기록에 추가하는 데 사용할 입력 키.
- `history_messages_key`: 로드된 메시지를 추가할 키.

```python
agent_with_chat_history = RunnableWithMessageHistory(
    agent_executor,
    get_session_history,
    input_messages_key="input",
    history_messages_key="chat_history",
)
```


```python
agent_with_chat_history.invoke(
    {"input": "hi! I'm bob"},
    config={"configurable": {"session_id": "<foo>"}},
)
```


```output
{'input': "hi! I'm bob",
 'chat_history': [],
 'output': 'Hello Bob! How can I assist you today?'}
```


```python
agent_with_chat_history.invoke(
    {"input": "what's my name?"},
    config={"configurable": {"session_id": "<foo>"}},
)
```


```output
{'input': "what's my name?",
 'chat_history': [HumanMessage(content="hi! I'm bob"),
  AIMessage(content='Hello Bob! How can I assist you today?')],
 'output': 'Your name is Bob.'}
```


예시 LangSmith 추적: https://smith.langchain.com/public/98c8d162-60ae-4493-aa9f-992d87bd0429/r

## 결론

이로써 마무리됩니다! 이 빠른 시작에서는 간단한 에이전트를 만드는 방법을 다루었습니다. 에이전트는 복잡한 주제이며, 배울 것이 많습니다!

:::important
이 섹션에서는 LangChain 에이전트 구축을 다루었습니다. LangChain 에이전트는 시작하기에 적합하지만, 일정 수준을 넘어서면 제공하지 않는 유연성과 제어가 필요할 것입니다. 더 고급 에이전트와 작업하려면 [LangGraph](/docs/concepts/#langgraph)를 확인하는 것이 좋습니다.
:::

LangChain 에이전트를 계속 사용하고 싶다면, 다음과 같은 좋은 고급 가이드가 있습니다:

- [LangGraph의 내장 버전 `AgentExecutor` 사용 방법](/docs/how_to/migrate_agent)
- [커스텀 에이전트 생성 방법](https://python.langchain.com/v0.1/docs/modules/agents/how_to/custom_agent/)
- [에이전트에서 응답 스트리밍하는 방법](https://python.langchain.com/v0.1/docs/modules/agents/how_to/streaming/)
- [에이전트에서 구조화된 출력 반환하는 방법](https://python.langchain.com/v0.1/docs/modules/agents/how_to/agent_structured/)