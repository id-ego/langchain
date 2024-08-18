---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/zhipuai.ipynb
description: 이 문서는 LangChain에서 ZHIPU AI API를 사용하는 방법을 설명하며, GLM-4 모델의 기능과 설치 방법을 안내합니다.
sidebar_label: ZHIPU AI
---

# ZHIPU AI

이 노트북은 LangChain에서 langchain.chat_models.ChatZhipuAI를 사용하여 [ZHIPU AI API](https://open.bigmodel.cn/dev/api)를 사용하는 방법을 보여줍니다.

> [*GLM-4*](https://open.bigmodel.cn/)는 인간의 의도에 맞춘 다국어 대형 언어 모델로, Q&A, 다중 턴 대화 및 코드 생성 기능을 갖추고 있습니다. 새로운 세대의 기본 모델 GLM-4는 이전 세대에 비해 전반적인 성능이 크게 향상되었으며, 더 긴 컨텍스트를 지원하고; 더 강력한 다중 모달리티; 더 빠른 추론 속도와 더 많은 동시성을 지원하여 추론 비용을 크게 줄입니다; 한편, GLM-4는 지능형 에이전트의 기능을 향상시킵니다.

## 시작하기
### 설치
먼저, Python 환경에 zhipuai 패키지가 설치되어 있는지 확인하세요. 다음 명령어를 실행하세요:

```python
#!pip install --upgrade httpx httpx-sse PyJWT
```


### 필요한 모듈 가져오기
설치 후, 필요한 모듈을 Python 스크립트에 가져옵니다:

```python
<!--IMPORTS:[{"imported": "ChatZhipuAI", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.zhipuai.ChatZhipuAI.html", "title": "ZHIPU AI"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "ZHIPU AI"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ZHIPU AI"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ZHIPU AI"}]-->
from langchain_community.chat_models import ChatZhipuAI
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
```


### API 키 설정
모델에 접근하기 위해 [ZHIPU AI](https://open.bigmodel.cn/login?redirect=%2Fusercenter%2Fapikeys)에 로그인하여 API 키를 받으세요.

```python
import os

os.environ["ZHIPUAI_API_KEY"] = "zhipuai_api_key"
```


### ZHIPU AI 채팅 모델 초기화
채팅 모델을 초기화하는 방법은 다음과 같습니다:

```python
chat = ChatZhipuAI(
    model="glm-4",
    temperature=0.5,
)
```


### 기본 사용법
시스템 및 인간 메시지로 모델을 호출하는 방법은 다음과 같습니다:

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


## 고급 기능
### 스트리밍 지원
지속적인 상호작용을 위해 스트리밍 기능을 사용하세요:

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


### 비동기 호출
차단되지 않는 호출을 위해 비동기 접근 방식을 사용하세요:

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


### 함수 호출과 함께 사용하기

GLM-4 모델은 함수 호출과 함께 사용할 수 있으며, 다음 코드를 사용하여 간단한 LangChain json_chat_agent를 실행하세요.

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


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)