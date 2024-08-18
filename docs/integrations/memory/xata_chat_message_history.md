---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/xata_chat_message_history.ipynb
description: Xata는 PostgreSQL과 Elasticsearch 기반의 서버리스 데이터 플랫폼으로, Python SDK와 UI를 통해
  데이터 관리 및 채팅 세션의 지속성을 제공합니다.
---

# Xata

> [Xata](https://xata.io)는 `PostgreSQL` 및 `Elasticsearch`를 기반으로 한 서버리스 데이터 플랫폼입니다. 데이터베이스와 상호작용하기 위한 Python SDK와 데이터를 관리하기 위한 UI를 제공합니다. `XataChatMessageHistory` 클래스를 사용하면 Xata 데이터베이스를 통해 채팅 세션의 장기적인 지속성을 확보할 수 있습니다.

이 노트북에서는 다음을 다룹니다:

* `XataChatMessageHistory`가 수행하는 작업을 보여주는 간단한 예제.
* REACT 에이전트를 사용하여 지식 기반 또는 문서(벡터 저장소로 Xata에 저장됨)를 기반으로 질문에 답변하고, 이전 메시지의 장기 검색 가능한 기록(메모리 저장소로 Xata에 저장됨)을 갖는 더 복잡한 예제.

## 설정

### 데이터베이스 생성

[Xata UI](https://app.xata.io)에서 새 데이터베이스를 생성합니다. 원하는 이름으로 지정할 수 있으며, 이 노트북에서는 `langchain`을 사용할 것입니다. Langchain 통합은 메모리를 저장하는 데 사용되는 테이블을 자동으로 생성할 수 있으며, 이 예제에서 사용할 것입니다. 테이블을 미리 생성하려면 올바른 스키마를 갖추고 클래스를 생성할 때 `create_table`을 `False`로 설정하십시오. 테이블을 미리 생성하면 각 세션 초기화 중에 데이터베이스로의 왕복을 절약할 수 있습니다.

먼저 종속성을 설치합시다:

```python
%pip install --upgrade --quiet  xata langchain-openai langchain langchain-community
```


다음으로 Xata의 환경 변수를 가져와야 합니다. [계정 설정](https://app.xata.io/settings)으로 이동하여 새 API 키를 생성할 수 있습니다. 데이터베이스 URL을 찾으려면 생성한 데이터베이스의 설정 페이지로 이동하십시오. 데이터베이스 URL은 다음과 비슷하게 보일 것입니다: `https://demo-uni3q8.eu-west-1.xata.sh/db/langchain`.

```python
import getpass

api_key = getpass.getpass("Xata API key: ")
db_url = input("Xata database URL (copy it from your DB settings):")
```


## 간단한 메모리 저장소 생성

메모리 저장소 기능을 독립적으로 테스트하기 위해 다음 코드 스니펫을 사용합시다:

```python
<!--IMPORTS:[{"imported": "XataChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.xata.XataChatMessageHistory.html", "title": "Xata"}]-->
from langchain_community.chat_message_histories import XataChatMessageHistory

history = XataChatMessageHistory(
    session_id="session-1", api_key=api_key, db_url=db_url, table_name="memory"
)

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


위 코드는 ID가 `session-1`인 세션을 생성하고 그 안에 두 개의 메시지를 저장합니다. 위 코드를 실행한 후 Xata UI를 방문하면 `memory`라는 테이블과 그 안에 추가된 두 개의 메시지를 볼 수 있어야 합니다.

특정 세션의 메시지 기록을 다음 코드로 검색할 수 있습니다:

```python
history.messages
```


## 메모리가 있는 데이터에 대한 대화형 Q&A 체인

이제 OpenAI, Xata 벡터 저장소 통합 및 Xata 메모리 저장소 통합을 결합하여 데이터에 대한 Q&A 챗봇을 생성하는 더 복잡한 예제를 살펴보겠습니다. 후속 질문과 기록이 포함됩니다.

OpenAI API에 접근해야 하므로 API 키를 구성합시다:

```python
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


챗봇이 답변을 검색할 문서를 저장하기 위해 Xata UI를 사용하여 `langchain` 데이터베이스에 `docs`라는 테이블을 추가하고 다음 열을 추가합니다:

* `content` 유형 "Text". 이는 `Document.pageContent` 값을 저장하는 데 사용됩니다.
* `embedding` 유형 "Vector". 사용하려는 모델에서 사용하는 차원을 사용하십시오. 이 노트북에서는 1536 차원을 가진 OpenAI 임베딩을 사용합니다.

벡터 저장소를 생성하고 샘플 문서를 추가합시다:

```python
<!--IMPORTS:[{"imported": "XataVectorStore", "source": "langchain_community.vectorstores.xata", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.xata.XataVectorStore.html", "title": "Xata"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Xata"}]-->
from langchain_community.vectorstores.xata import XataVectorStore
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()

texts = [
    "Xata is a Serverless Data platform based on PostgreSQL",
    "Xata offers a built-in vector type that can be used to store and query vectors",
    "Xata includes similarity search",
]

vector_store = XataVectorStore.from_texts(
    texts, embeddings, api_key=api_key, db_url=db_url, table_name="docs"
)
```


위 명령을 실행한 후 Xata UI로 가면 문서와 그 임베딩이 `docs` 테이블에 함께 로드된 것을 볼 수 있어야 합니다.

이제 사용자와 AI의 채팅 메시지를 저장하기 위해 ConversationBufferMemory를 생성합시다.

```python
<!--IMPORTS:[{"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "Xata"}]-->
from uuid import uuid4

from langchain.memory import ConversationBufferMemory

chat_memory = XataChatMessageHistory(
    session_id=str(uuid4()),  # needs to be unique per user session
    api_key=api_key,
    db_url=db_url,
    table_name="memory",
)
memory = ConversationBufferMemory(
    memory_key="chat_history", chat_memory=chat_memory, return_messages=True
)
```


이제 벡터 저장소와 채팅 메모리를 함께 사용할 에이전트를 생성할 시간입니다.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Xata"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Xata"}, {"imported": "create_retriever_tool", "source": "langchain.agents.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.retriever.create_retriever_tool.html", "title": "Xata"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Xata"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain.agents.agent_toolkits import create_retriever_tool
from langchain_openai import ChatOpenAI

tool = create_retriever_tool(
    vector_store.as_retriever(),
    "search_docs",
    "Searches and returns documents from the Xata manual. Useful when you need to answer questions about Xata.",
)
tools = [tool]

llm = ChatOpenAI(temperature=0)

agent = initialize_agent(
    tools,
    llm,
    agent=AgentType.CHAT_CONVERSATIONAL_REACT_DESCRIPTION,
    verbose=True,
    memory=memory,
)
```


테스트를 위해 에이전트에게 우리의 이름을 말해봅시다:

```python
agent.run(input="My name is bob")
```


이제 에이전트에게 Xata에 대한 질문을 해봅시다:

```python
agent.run(input="What is xata?")
```


문서 저장소에 저장된 데이터를 기반으로 답변하는 것을 주목하십시오. 이제 후속 질문을 해봅시다:

```python
agent.run(input="Does it support similarity search?")
```


이제 메모리를 테스트해봅시다:

```python
agent.run(input="Did I tell you my name? What is it?")
```