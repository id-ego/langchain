---
custom_edit_url: null
description: LangServe는 개발자가 LangChain의 실행 가능 항목과 체인을 REST API로 배포할 수 있도록 도와주는 라이브러리입니다.
---

# 🦜️🏓 LangServe

[![Release Notes](https://img.shields.io/github/release/langchain-ai/langserve)](https://github.com/langchain-ai/langserve/releases)
[![Downloads](https://static.pepy.tech/badge/langserve/month)](https://pepy.tech/project/langserve)
[![Open Issues](https://img.shields.io/github/issues-raw/langchain-ai/langserve)](https://github.com/langchain-ai/langserve/issues)
[![](https://dcbadge.vercel.app/api/server/6adMQxSpJS?compact=true&style=flat)](https://discord.com/channels/1038097195422978059/1170024642245832774)

## 개요

[LangServe](https://github.com/langchain-ai/langserve)는 개발자가 `LangChain` [실행 가능 객체와 체인](https://python.langchain.com/docs/expression_language/)을 REST API로 배포할 수 있도록 도와줍니다.

이 라이브러리는 [FastAPI](https://fastapi.tiangolo.com/)와 통합되어 있으며, 데이터 검증을 위해 [pydantic](https://docs.pydantic.dev/latest/)을 사용합니다.

또한, 서버에 배포된 실행 가능 객체를 호출하는 데 사용할 수 있는 클라이언트를 제공합니다.
JavaScript 클라이언트는 [LangChain.js](https://js.langchain.com/docs/ecosystem/langserve)에서 사용할 수 있습니다.

## 기능

- LangChain 객체에서 자동으로 추론된 입력 및 출력 스키마가 모든 API 호출에서 적용되며, 풍부한 오류 메시지를 제공합니다.
- JSONSchema 및 Swagger가 포함된 API 문서 페이지 (예시 링크 삽입)
- 단일 서버에서 많은 동시 요청을 지원하는 효율적인 `/invoke`, `/batch` 및 `/stream` 엔드포인트
- 체인/에이전트의 모든(또는 일부) 중간 단계를 스트리밍하기 위한 `/stream_log` 엔드포인트
- **새로운** 0.0.40부터, `/stream_events`를 지원하여 `/stream_log`의 출력을 파싱할 필요 없이 스트리밍을 쉽게 합니다.
- 스트리밍 출력 및 중간 단계를 포함한 `/playground/`의 플레이그라운드 페이지
- [LangSmith](https://www.langchain.com/langsmith)로의 내장(선택적) 추적, API 키를 추가하기만 하면 됩니다 (자세한 내용은 [지침](https://docs.smith.langchain.com/) 참조)
- FastAPI, Pydantic, uvloop 및 asyncio와 같은 검증된 오픈 소스 Python 라이브러리로 구축되었습니다.
- 클라이언트 SDK를 사용하여 로컬에서 실행 중인 Runnable처럼 LangServe 서버를 호출하거나 HTTP API를 직접 호출할 수 있습니다.
- [LangServe Hub](https://github.com/langchain-ai/langchain/blob/master/templates/README.md)

## ⚠️ LangGraph 호환성

LangServe는 주로 간단한 실행 가능 객체를 배포하고 langchain-core의 잘 알려진 원시와 작업하도록 설계되었습니다.

LangGraph에 대한 배포 옵션이 필요하다면, [LangGraph Cloud (beta)](https://langchain-ai.github.io/langgraph/cloud/)를 고려해야 하며, 이는 LangGraph 애플리케이션 배포에 더 적합합니다.

## 제한 사항

- 서버에서 발생하는 이벤트에 대한 클라이언트 콜백은 아직 지원되지 않습니다.
- Pydantic V2를 사용할 때 OpenAPI 문서가 생성되지 않습니다. Fast API는 [pydantic v1과 v2 네임스페이스 혼합을 지원하지 않습니다](https://github.com/tiangolo/fastapi/issues/10360). 자세한 내용은 아래 섹션을 참조하십시오.

## 보안

- 버전 0.0.13 - 0.0.15의 취약점 -- 플레이그라운드 엔드포인트가 서버의 임의 파일에 접근할 수 있도록 허용합니다. [0.0.16에서 해결됨](https://github.com/langchain-ai/langserve/pull/98).

## 설치

클라이언트와 서버 모두에 대해:

```bash
pip install "langserve[all]"
```


또는 클라이언트 코드를 위해 `pip install "langserve[client]"`, 서버 코드를 위해 `pip install "langserve[server]"`를 사용할 수 있습니다.

## LangChain CLI 🛠️

`LangChain` CLI를 사용하여 `LangServe` 프로젝트를 빠르게 부트스트랩할 수 있습니다.

langchain CLI를 사용하려면 최신 버전의 `langchain-cli`가 설치되어 있어야 합니다. `pip install -U langchain-cli`로 설치할 수 있습니다.

## 설정

**참고**: 우리는 종속성 관리를 위해 `poetry`를 사용합니다. 자세한 내용은 poetry [문서](https://python-poetry.org/docs/)를 참조하십시오.

### 1. langchain cli 명령을 사용하여 새 앱 만들기

```sh
langchain app new my-app
```


### 2. add_routes에서 실행 가능 객체 정의. server.py로 이동하여 편집

```sh
add_routes(app. NotImplemented)
```


### 3. `poetry`를 사용하여 3rd party 패키지 추가 (예: langchain-openai, langchain-anthropic, langchain-mistral 등).

```sh
poetry add [package-name] // e.g `poetry add langchain-openai`
```


### 4. 관련 환경 변수를 설정합니다. 예를 들어,

```sh
export OPENAI_API_KEY="sk-..."
```


### 5. 앱 제공

```sh
poetry run langchain serve --port=8100
```


## 예제

[LangChain 템플릿](https://github.com/langchain-ai/langchain/blob/master/templates/README.md)을 사용하여 LangServe 인스턴스를 빠르게 시작하십시오.

더 많은 예제를 보려면 템플릿 [색인](https://github.com/langchain-ai/langchain/blob/master/templates/docs/INDEX.md) 또는 [예제](https://github.com/langchain-ai/langserve/tree/main/examples) 디렉토리를 참조하십시오.

| 설명                                                                                                                                                                                                                                                        | 링크                                                                                                                                                                                                                               |
| :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **LLMs** OpenAI 및 Anthropic 채팅 모델을 예약하는 최소 예제. 비동기 사용, 배치 및 스트리밍 지원.                                                                                                                                                      | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/llm/server.py), [클라이언트](https://github.com/langchain-ai/langserve/blob/main/examples/llm/client.ipynb)                                                       |
| **Retriever** 실행 가능 객체로서 리트리버를 노출하는 간단한 서버.                                                                                                                                                                                        | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/retrieval/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/retrieval/client.ipynb)                                           |
| **Conversational Retriever** LangServe를 통해 노출된 [Conversational Retriever](https://python.langchain.com/docs/expression_language/cookbook/retrieval#conversational-retrieval-chain)                                                                 | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/conversational_retrieval_chain/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/conversational_retrieval_chain/client.ipynb) |
| **Agent** **대화 기록** 없이 [OpenAI 도구](https://python.langchain.com/docs/modules/agents/agent_types/openai_functions_agent)를 기반으로 한 에이전트                                                                                                          | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/agent/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/agent/client.ipynb)                                                   |
| **Agent** **대화 기록**을 포함한 [OpenAI 도구](https://python.langchain.com/docs/modules/agents/agent_types/openai_functions_agent)를 기반으로 한 에이전트                                                                                                         | [서버](https://github.com/langchain-ai/langserve/blob/main/examples/agent_with_history/server.py), [클라이언트](https://github.com/langchain-ai/langserve/blob/main/examples/agent_with_history/client.ipynb)                         |
| [RunnableWithMessageHistory](https://python.langchain.com/docs/expression_language/how_to/message_history)를 사용하여 클라이언트가 제공한 `session_id`를 기준으로 백엔드에 지속된 채팅을 구현합니다.                                                               | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/chat_with_persistence/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/chat_with_persistence/client.ipynb)                   |
| [RunnableWithMessageHistory](https://python.langchain.com/docs/expression_language/how_to/message_history)를 사용하여 클라이언트가 제공한 `conversation_id` 및 `user_id`를 기준으로 백엔드에 지속된 채팅을 구현합니다. (정확한 `user_id` 구현을 위한 인증 참조) | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/chat_with_persistence_and_user/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/chat_with_persistence_and_user/client.ipynb) |
| [Configurable Runnable](https://python.langchain.com/docs/expression_language/how_to/configure)를 사용하여 런타임에서 인덱스 이름의 구성을 지원하는 리트리버를 생성합니다.                                                                                      | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/configurable_retrieval/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/configurable_retrieval/client.ipynb)                 |
| [Configurable Runnable](https://python.langchain.com/docs/expression_language/how_to/configure)로 구성 가능한 필드와 구성 가능한 대안을 보여줍니다.                                                                                                          | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/configurable_chain/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/configurable_chain/client.ipynb)                         |
| **APIHandler** `add_routes` 대신 `APIHandler`를 사용하는 방법을 보여줍니다. 이는 개발자가 엔드포인트를 정의하는 데 더 많은 유연성을 제공합니다. 모든 FastAPI 패턴과 잘 작동하지만, 약간 더 많은 노력이 필요합니다.                                      | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/api_handler_examples/server.py)                                                                                                                               |
| **LCEL 예제** 사전 입력을 조작하기 위해 LCEL을 사용하는 예제입니다.                                                                                                                                                                                          | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/passthrough_dict/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/passthrough_dict/client.ipynb)                             |
| **Auth** `add_routes`와 함께: 앱과 관련된 모든 엔드포인트에 적용할 수 있는 간단한 인증입니다. (사용자별 로직 구현에는 유용하지 않습니다.)                                                                                                               | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/global_deps/server.py)                                                                                                                                   |
| **Auth** `add_routes`와 함께: 경로 종속성을 기반으로 한 간단한 인증 메커니즘입니다. (사용자별 로직 구현에는 유용하지 않습니다.)                                                                                                                            | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/path_dependencies/server.py)                                                                                                                             |
| **Auth** `add_routes`와 함께: 요청 구성 수정자를 사용하는 엔드포인트에 대한 사용자별 로직 및 인증을 구현합니다. (**참고**: 현재 OpenAPI 문서와 통합되지 않습니다.)                                                                                          | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/per_req_config_modifier/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/auth/per_req_config_modifier/client.ipynb)     |
| **Auth** `APIHandler`와 함께: 사용자 소유 문서 내에서만 검색하는 방법을 보여주는 사용자별 로직 및 인증을 구현합니다.                                                                                                                                           | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/api_handler/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/auth/api_handler/client.ipynb)                             |
| **Widgets** 플레이그라운드에서 사용할 수 있는 다양한 위젯 (파일 업로드 및 채팅)                                                                                                                                                                              | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/widgets/chat/tuples/server.py)                                                                                                                                |
| **Widgets** LangServe 플레이그라운드에 사용되는 파일 업로드 위젯입니다.                                                                                                                                                                                      | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/file_processing/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/file_processing/client.ipynb)                               |

## 샘플 애플리케이션

### 서버

OpenAI 채팅 모델, Anthropic 채팅 모델 및 주제를 가지고 농담을 하는 체인을 배포하는 서버입니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}, {"imported": "ChatAnthropic", "source": "langchain.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.anthropic.ChatAnthropic.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}, {"imported": "ChatOpenAI", "source": "langchain.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.openai.ChatOpenAI.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}]-->
#!/usr/bin/env python
from fastapi import FastAPI
from langchain.prompts import ChatPromptTemplate
from langchain.chat_models import ChatAnthropic, ChatOpenAI
from langserve import add_routes

app = FastAPI(
    title="LangChain Server",
    version="1.0",
    description="A simple api server using Langchain's Runnable interfaces",
)

add_routes(
    app,
    ChatOpenAI(model="gpt-3.5-turbo-0125"),
    path="/openai",
)

add_routes(
    app,
    ChatAnthropic(model="claude-3-haiku-20240307"),
    path="/anthropic",
)

model = ChatAnthropic(model="claude-3-haiku-20240307")
prompt = ChatPromptTemplate.from_template("tell me a joke about {topic}")
add_routes(
    app,
    prompt | model,
    path="/joke",
)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=8000)
```


브라우저에서 엔드포인트를 호출할 계획이라면 CORS 헤더도 설정해야 합니다.
FastAPI의 내장 미들웨어를 사용할 수 있습니다:

```python
from fastapi.middleware.cors import CORSMiddleware

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)
```


### 문서

위의 서버를 배포했다면, 생성된 OpenAPI 문서를 다음을 사용하여 볼 수 있습니다:

> ⚠️ pydantic v2를 사용하는 경우, *invoke*, *batch*, *stream*, *stream_log*에 대한 문서가 생성되지 않습니다. 자세한 내용은 아래 [Pydantic](#pydantic) 섹션을 참조하십시오.

```sh
curl localhost:8000/docs
```


반드시 **추가** `/docs` 접미사를 붙이십시오.

> ⚠️ 인덱스 페이지 `/`는 **설계상** 정의되지 않으므로 `curl localhost:8000` 또는 URL을 방문하면 404가 반환됩니다. `/`에 콘텐츠를 원하시면 엔드포인트 `@app.get("/")`를 정의하십시오.

### 클라이언트

Python SDK

```python
<!--IMPORTS:[{"imported": "SystemMessage", "source": "langchain.schema", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}, {"imported": "HumanMessage", "source": "langchain.schema", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}, {"imported": "ChatPromptTemplate", "source": "langchain.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}, {"imported": "RunnableMap", "source": "langchain.schema.runnable", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableMap.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}]-->

from langchain.schema import SystemMessage, HumanMessage
from langchain.prompts import ChatPromptTemplate
from langchain.schema.runnable import RunnableMap
from langserve import RemoteRunnable

openai = RemoteRunnable("http://localhost:8000/openai/")
anthropic = RemoteRunnable("http://localhost:8000/anthropic/")
joke_chain = RemoteRunnable("http://localhost:8000/joke/")

joke_chain.invoke({"topic": "parrots"})

# or async
await joke_chain.ainvoke({"topic": "parrots"})

prompt = [
    SystemMessage(content='Act like either a cat or a parrot.'),
    HumanMessage(content='Hello!')
]

# Supports astream
async for msg in anthropic.astream(prompt):
    print(msg, end="", flush=True)

prompt = ChatPromptTemplate.from_messages(
    [("system", "Tell me a long story about {topic}")]
)

# Can define custom chains
chain = prompt | RunnableMap({
    "openai": openai,
    "anthropic": anthropic,
})

chain.batch([{"topic": "parrots"}, {"topic": "cats"}])
```


TypeScript에서 (LangChain.js 버전 0.0.166 이상 필요):

```typescript
import { RemoteRunnable } from "@langchain/core/runnables/remote";

const chain = new RemoteRunnable({
  url: `http://localhost:8000/joke/`,
});
const result = await chain.invoke({
  topic: "cats",
});
```


`requests`를 사용하는 Python:

```python
import requests

response = requests.post(
    "http://localhost:8000/joke/invoke",
    json={'input': {'topic': 'cats'}}
)
response.json()
```


`curl`을 사용할 수도 있습니다:

```sh
curl --location --request POST 'http://localhost:8000/joke/invoke' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "input": {
            "topic": "cats"
        }
    }'
```


## 엔드포인트

다음 코드는:

```python
...
add_routes(
    app,
    runnable,
    path="/my_runnable",
)
```


서버에 다음 엔드포인트를 추가합니다:

- `POST /my_runnable/invoke` - 단일 입력에 대해 실행 가능 객체 호출
- `POST /my_runnable/batch` - 입력 배치에 대해 실행 가능 객체 호출
- `POST /my_runnable/stream` - 단일 입력에 대해 호출하고 출력을 스트리밍
- `POST /my_runnable/stream_log` - 단일 입력에 대해 호출하고 중간 단계의 출력을 포함하여 출력을 스트리밍
- `POST /my_runnable/astream_events` - 단일 입력에 대해 호출하고 중간 단계에서 생성되는 이벤트를 스트리밍
- `GET /my_runnable/input_schema` - 실행 가능 객체에 대한 입력의 json 스키마
- `GET /my_runnable/output_schema` - 실행 가능 객체에 대한 출력의 json 스키마
- `GET /my_runnable/config_schema` - 실행 가능 객체에 대한 구성의 json 스키마

이 엔드포인트는 [LangChain 표현 언어 인터페이스](https://python.langchain.com/docs/expression_language/interface)와 일치합니다 -- 자세한 내용은 이 문서를 참조하십시오.
## 놀이터

실행 가능한 항목의 놀이터 페이지는 `/my_runnable/playground/`에서 찾을 수 있습니다. 이는 간단한 UI를 제공하여 [구성](https://python.langchain.com/docs/expression_language/how_to/configure)하고 스트리밍 출력 및 중간 단계를 통해 실행 가능한 항목을 호출할 수 있습니다.

<p align="center">
<img src="https://github.com/langchain-ai/langserve/assets/3205522/5ca56e29-f1bb-40f4-84b5-15916384a276" width="50%"/>
</p>


### 위젯

놀이터는 [위젯](#playground-widgets)을 지원하며, 다양한 입력으로 실행 가능한 항목을 테스트하는 데 사용할 수 있습니다. 자세한 내용은 아래 [위젯](#widgets) 섹션을 참조하십시오.

### 공유

또한, 구성 가능한 실행 가능한 항목의 경우, 놀이터는 실행 가능한 항목을 구성하고 구성 링크를 공유할 수 있도록 합니다:

<p align="center">
<img src="https://github.com/langchain-ai/langserve/assets/3205522/86ce9c59-f8e4-4d08-9fa3-62030e0f521d" width="50%"/>
</p>


## 채팅 놀이터

LangServe는 `/my_runnable/playground/`에서 사용할 수 있는 채팅 중심의 놀이터도 지원합니다. 일반 놀이터와 달리 특정 유형의 실행 가능한 항목만 지원되며, 실행 가능한 항목의 입력 스키마는 다음 중 하나여야 합니다:

- 단일 키, 해당 키의 값은 채팅 메시지 목록이어야 합니다.
- 두 개의 키, 하나는 메시지 목록의 값이고, 다른 하나는 가장 최근 메시지를 나타냅니다.

첫 번째 형식을 사용하는 것을 권장합니다.

실행 가능한 항목은 `AIMessage` 또는 문자열 중 하나를 반환해야 합니다.

이를 활성화하려면 경로를 추가할 때 `playground_type="chat",`을 설정해야 합니다. 예시는 다음과 같습니다:

```python
# Declare a chain
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful, professional assistant named Cob."),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

chain = prompt | ChatAnthropic(model="claude-2")


class InputChat(BaseModel):
    """Input for the chat endpoint."""

    messages: List[Union[HumanMessage, AIMessage, SystemMessage]] = Field(
        ...,
        description="The chat messages representing the current conversation.",
    )


add_routes(
    app,
    chain.with_types(input_type=InputChat),
    enable_feedback_endpoint=True,
    enable_public_trace_link_endpoint=True,
    playground_type="chat",
)
```


LangSmith를 사용하는 경우, 각 메시지 후에 엄지 척/엄지 내리기 버튼을 활성화하려면 경로에서 `enable_feedback_endpoint=True`를 설정하고, 실행을 위한 공개 추적을 생성하는 버튼을 추가하려면 `enable_public_trace_link_endpoint=True`를 설정할 수 있습니다. 다음 환경 변수를 설정해야 합니다:

```bash
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_PROJECT="YOUR_PROJECT_NAME"
export LANGCHAIN_API_KEY="YOUR_API_KEY"
```


위의 두 옵션이 활성화된 예시는 다음과 같습니다:

<p align="center">
<img src="./.github/img/chat_playground.png" width="50%"/>
</p>


참고: 공개 추적 링크를 활성화하면 체인의 내부가 노출됩니다. 이 설정은 데모나 테스트에만 사용하는 것이 좋습니다.

## 레거시 체인

LangServe는 [LangChain 표현 언어](https://python.langchain.com/docs/expression_language/)를 통해 구성된 실행 가능한 항목과 레거시 체인(`Chain`에서 상속됨) 모두와 함께 작동합니다. 그러나 레거시 체인의 일부 입력 스키마는 불완전하거나 잘못될 수 있으며, 이로 인해 오류가 발생할 수 있습니다. 이는 LangChain에서 해당 체인의 `input_schema` 속성을 업데이트하여 수정할 수 있습니다. 오류가 발생하면 이 리포지토리에 문제를 열어 주시면 해결하도록 하겠습니다.

## 배포

### AWS에 배포

[AWS Copilot CLI](https://aws.github.io/copilot-cli/)를 사용하여 AWS에 배포할 수 있습니다.

```bash
copilot init --app [application-name] --name [service-name] --type 'Load Balanced Web Service' --dockerfile './Dockerfile' --deploy
```


자세한 내용은 [여기](https://aws.amazon.com/containers/copilot/)를 클릭하십시오.

### Azure에 배포

Azure Container Apps(서버리스)를 사용하여 Azure에 배포할 수 있습니다:

```
az containerapp up --name [container-app-name] --source . --resource-group [resource-group-name] --environment  [environment-name] --ingress external --target-port 8001 --env-vars=OPENAI_API_KEY=your_key
```


자세한 정보는 [여기](https://learn.microsoft.com/en-us/azure/container-apps/containerapp-up)에서 확인할 수 있습니다.

### GCP에 배포

다음 명령을 사용하여 GCP Cloud Run에 배포할 수 있습니다:

```
gcloud run deploy [your-service-name] --source . --port 8001 --allow-unauthenticated --region us-central1 --set-env-vars=OPENAI_API_KEY=your_key
```


### 커뮤니티 기여

#### Railway에 배포

[예제 Railway 리포지토리](https://github.com/PaulLockett/LangServe-Railway/tree/main)

[![Railway에 배포](https://railway.app/button.svg)](https://railway.app/template/pW9tXP?referralCode=c-aq4K)

## Pydantic

LangServe는 일부 제한 사항과 함께 Pydantic 2를 지원합니다.

1. Pydantic V2를 사용할 때 invoke/batch/stream/stream_log에 대한 OpenAPI 문서는 생성되지 않습니다. Fast API는 [pydantic v1과 v2 네임스페이스 혼합을 지원하지 않습니다]. 이를 해결하려면 `pip install pydantic==1.10.17`을 사용하십시오.
2. LangChain은 Pydantic v2에서 v1 네임스페이스를 사용합니다. LangChain과의 호환성을 보장하기 위해 [다음 지침을 읽어보십시오](https://github.com/langchain-ai/langchain/discussions/9337).

이러한 제한 사항을 제외하고, API 엔드포인트, 놀이터 및 기타 기능이 예상대로 작동할 것으로 기대합니다.

## 고급

### 인증 처리

서버에 인증을 추가해야 하는 경우, Fast API의 [종속성](https://fastapi.tiangolo.com/tutorial/dependencies/) 및 [보안](https://fastapi.tiangolo.com/tutorial/security/)에 대한 문서를 읽어보십시오.

아래 예시는 FastAPI 기본 요소를 사용하여 LangServe 엔드포인트에 인증 논리를 연결하는 방법을 보여줍니다.

실제 인증 논리, 사용자 테이블 등을 제공하는 것은 귀하의 책임입니다.

무엇을 해야 할지 확실하지 않은 경우, 기존 솔루션인 [Auth0](https://auth0.com/)를 사용해 볼 수 있습니다.

#### add_routes 사용

`add_routes`를 사용하는 경우, [여기](https://github.com/langchain-ai/langserve/tree/main/examples/auth)에서 예제를 참조하십시오.

| 설명                                                                                                                                                                        | 링크                                                                                                                                                                                                                           |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **인증** `add_routes`와 함께: 앱과 연결된 모든 엔드포인트에 적용할 수 있는 간단한 인증입니다. (사용자별 논리를 구현하는 데는 유용하지 않습니다.)           | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/global_deps/server.py)                                                                                                                               |
| **인증** `add_routes`와 함께: 경로 종속성을 기반으로 한 간단한 인증 메커니즘입니다. (사용자별 논리를 구현하는 데는 유용하지 않습니다.)                                    | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/path_dependencies/server.py)                                                                                                                         |
| **인증** `add_routes`와 함께: 요청 구성 수정자를 사용하는 엔드포인트에 대한 사용자별 논리 및 인증을 구현합니다. (**참고**: 현재 OpenAPI 문서와 통합되지 않습니다.) | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/per_req_config_modifier/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/auth/per_req_config_modifier/client.ipynb) |

또는 FastAPI의 [미들웨어](https://fastapi.tiangolo.com/tutorial/middleware/)를 사용할 수 있습니다.

전역 종속성과 경로 종속성을 사용하는 것은 인증이 OpenAPI 문서 페이지에서 적절하게 지원된다는 장점이 있지만, 사용자별 논리를 구현하기에는 충분하지 않습니다(예: 사용자 소유 문서 내에서만 검색할 수 있는 애플리케이션 만들기).

사용자별 논리를 구현해야 하는 경우, `per_req_config_modifier` 또는 아래의 `APIHandler`를 사용하여 이 논리를 구현할 수 있습니다.

**사용자별**

사용자 종속적인 권한 부여 또는 논리가 필요한 경우, `add_routes`를 사용할 때 `per_req_config_modifier`를 지정하십시오. 이는 원시 `Request` 객체를 수신하고 인증 및 권한 부여 목적으로 관련 정보를 추출할 수 있는 호출 가능 객체를 사용합니다.

#### APIHandler 사용

FastAPI와 Python에 익숙하다면 LangServe의 [APIHandler](https://github.com/langchain-ai/langserve/blob/main/examples/api_handler_examples/server.py)를 사용할 수 있습니다.

| 설명                                                                                                                                                                                                 | 링크                                                                                                                                                                                                           |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **인증** `APIHandler`와 함께: 사용자 소유 문서 내에서만 검색하는 방법을 보여주는 사용자별 논리 및 인증을 구현합니다.                                                                                    | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/auth/api_handler/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/auth/api_handler/client.ipynb)         |
| **APIHandler** `add_routes` 대신 `APIHandler`를 사용하는 방법을 보여줍니다. 이는 개발자가 엔드포인트를 정의하는 데 더 많은 유연성을 제공합니다. 모든 FastAPI 패턴과 잘 작동하지만 약간의 노력이 필요합니다. | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/api_handler_examples/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/api_handler_examples/client.ipynb) |

조금 더 작업이 필요하지만, 엔드포인트 정의에 대한 완전한 제어를 제공하므로 인증을 위한 사용자 정의 논리를 수행할 수 있습니다.

### 파일

LLM 애플리케이션은 종종 파일을 처리합니다. 파일 처리를 구현하기 위해 다양한 아키텍처를 만들 수 있습니다. 높은 수준에서:

1. 파일은 전용 엔드포인트를 통해 서버에 업로드되고 별도의 엔드포인트를 사용하여 처리될 수 있습니다.
2. 파일은 값(파일의 바이트) 또는 참조(예: 파일 콘텐츠에 대한 s3 URL)로 업로드될 수 있습니다.
3. 처리 엔드포인트는 차단 또는 비차단일 수 있습니다.
4. 상당한 처리가 필요한 경우, 처리는 전용 프로세스 풀로 오프로드될 수 있습니다.

애플리케이션에 적합한 아키텍처가 무엇인지 결정해야 합니다.

현재, 실행 가능한 항목에 값을 통해 파일을 업로드하려면 파일에 대한 base64 인코딩을 사용해야 합니다(`multipart/form-data`는 아직 지원되지 않습니다).

다음은 원격 실행 가능한 항목에 파일을 보내기 위해 base64 인코딩을 사용하는 방법을 보여주는 [예제](https://github.com/langchain-ai/langserve/tree/main/examples/file_processing)입니다.

항상 참조(예: s3 URL)를 통해 파일을 업로드하거나 전용 엔드포인트에 multipart/form-data로 업로드할 수 있다는 점을 기억하십시오.

### 사용자 정의 입력 및 출력 유형

입력 및 출력 유형은 모든 실행 가능한 항목에 대해 정의됩니다.

`input_schema` 및 `output_schema` 속성을 통해 액세스할 수 있습니다.

`LangServe`는 이러한 유형을 검증 및 문서화에 사용합니다.

기본적으로 유추된 유형을 재정의하려면 `with_types` 메서드를 사용할 수 있습니다.

아이디어를 설명하기 위한 장난감 예시는 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain.schema.runnable", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}]-->
from typing import Any

from fastapi import FastAPI
from langchain.schema.runnable import RunnableLambda

app = FastAPI()


def func(x: Any) -> int:
    """Mistyped function that should accept an int but accepts anything."""
    return x + 1


runnable = RunnableLambda(func).with_types(
    input_type=int,
)

add_routes(app, runnable)
```


### 사용자 정의 사용자 유형

데이터가 해당하는 dict 표현이 아닌 pydantic 모델로 역직렬화되도록 하려면 `CustomUserType`에서 상속하십시오.

현재 이 유형은 *서버* 측에서만 작동하며 원하는 *디코딩* 동작을 지정하는 데 사용됩니다. 이 유형에서 상속하는 경우 서버는 디코딩된 유형을 dict로 변환하는 대신 pydantic 모델로 유지합니다.

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain.schema.runnable", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "\ud83e\udd9c\ufe0f\ud83c\udfd3 LangServe"}]-->
from fastapi import FastAPI
from langchain.schema.runnable import RunnableLambda

from langserve import add_routes
from langserve.schema import CustomUserType

app = FastAPI()


class Foo(CustomUserType):
    bar: int


def func(foo: Foo) -> int:
    """Sample function that expects a Foo type which is a pydantic model"""
    assert isinstance(foo, Foo)
    return foo.bar


# Note that the input and output type are automatically inferred!
# You do not need to specify them.
# runnable = RunnableLambda(func).with_types( # <-- Not needed in this case
#     input_type=Foo,
#     output_type=int,
#
add_routes(app, RunnableLambda(func), path="/foo")
```


### 놀이터 위젯

놀이터는 백엔드에서 실행 가능한 항목에 대한 사용자 정의 위젯을 정의할 수 있습니다.

다음은 몇 가지 예입니다:

| 설명                                                                           | 링크                                                                                                                                                                                                 |
| :------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **위젯** 놀이터와 함께 사용할 수 있는 다양한 위젯(파일 업로드 및 채팅) | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/widgets/chat/tuples/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/widgets/client.ipynb)     |
| **위젯** LangServe 놀이터에 사용되는 파일 업로드 위젯입니다.                         | [서버](https://github.com/langchain-ai/langserve/tree/main/examples/file_processing/server.py), [클라이언트](https://github.com/langchain-ai/langserve/tree/main/examples/file_processing/client.ipynb) |

#### 스키마

- 위젯은 필드 수준에서 지정되며 입력 유형의 JSON 스키마의 일부로 전송됩니다.
- 위젯은 `type`이라는 키를 포함해야 하며, 그 값은 잘 알려진 위젯 목록 중 하나여야 합니다.
- 다른 위젯 키는 JSON 객체의 경로를 설명하는 값과 연결됩니다.

```typescript
type JsonPath = number | string | (number | string)[];
type NameSpacedPath = { title: string; path: JsonPath }; // Using title to mimick json schema, but can use namespace
type OneOfPath = { oneOf: JsonPath[] };

type Widget = {
  type: string; // Some well known type (e.g., base64file, chat etc.)
  [key: string]: JsonPath | NameSpacedPath | OneOfPath;
};
```


### 사용 가능한 위젯

현재 사용자가 수동으로 지정할 수 있는 위젯은 두 가지뿐입니다:

1. 파일 업로드 위젯
2. 채팅 기록 위젯

이 위젯에 대한 추가 정보는 아래를 참조하십시오.

놀이터 UI의 모든 다른 위젯은 실행 가능한 항목의 구성 스키마를 기반으로 UI에 의해 자동으로 생성되고 관리됩니다. 구성 가능한 실행 가능한 항목을 생성할 때, 놀이터는 동작을 제어할 수 있는 적절한 위젯을 생성해야 합니다.

#### 파일 업로드 위젯

base64 인코딩된 문자열로 업로드된 파일에 대한 UI 놀이터에서 파일 업로드 입력을 생성할 수 있습니다. 전체 [예제](https://github.com/langchain-ai/langserve/tree/main/examples/file_processing)는 다음과 같습니다.

스니펫:

```python
try:
    from pydantic.v1 import Field
except ImportError:
    from pydantic import Field

from langserve import CustomUserType


# ATTENTION: Inherit from CustomUserType instead of BaseModel otherwise
#            the server will decode it into a dict instead of a pydantic model.
class FileProcessingRequest(CustomUserType):
    """Request including a base64 encoded file."""

    # The extra field is used to specify a widget for the playground UI.
    file: str = Field(..., extra={"widget": {"type": "base64file"}})
    num_chars: int = 100

```


예제 위젯:

<p align="center">
<img src="https://github.com/langchain-ai/langserve/assets/3205522/52199e46-9464-4c2e-8be8-222250e08c3f" width="50%"/>
</p>


### 채팅 위젯

[위젯 예제](https://github.com/langchain-ai/langserve/tree/main/examples/widgets/chat/tuples/server.py)를 참조하십시오.

채팅 위젯을 정의하려면 "type": "chat"을 전달해야 합니다.

- "input"은 새 입력 메시지가 있는 *Request*의 필드에 대한 JSONPath입니다.
- "output"은 새 출력 메시지가 있는 *Response*의 필드에 대한 JSONPath입니다.
- 전체 입력 또는 출력을 있는 그대로 사용해야 하는 경우 이러한 필드를 지정하지 마십시오(예: 출력이 채팅 메시지 목록인 경우).

다음은 스니펫입니다:

```python
class ChatHistory(CustomUserType):
    chat_history: List[Tuple[str, str]] = Field(
        ...,
        examples=[[("human input", "ai response")]],
        extra={"widget": {"type": "chat", "input": "question", "output": "answer"}},
    )
    question: str


def _format_to_messages(input: ChatHistory) -> List[BaseMessage]:
    """Format the input to a list of messages."""
    history = input.chat_history
    user_input = input.question

    messages = []

    for human, ai in history:
        messages.append(HumanMessage(content=human))
        messages.append(AIMessage(content=ai))
    messages.append(HumanMessage(content=user_input))
    return messages


model = ChatOpenAI()
chat_model = RunnableParallel({"answer": (RunnableLambda(_format_to_messages) | model)})
add_routes(
    app,
    chat_model.with_types(input_type=ChatHistory),
    config_keys=["configurable"],
    path="/chat",
)
```


예제 위젯:

<p align="center">
<img src="https://github.com/langchain-ai/langserve/assets/3205522/a71ff37b-a6a9-4857-a376-cf27c41d3ca4" width="50%"/>
</p>


매개변수로 메시지 목록을 직접 지정할 수도 있습니다. 다음 스니펫에서와 같이:

```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assisstant named Cob."),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

chain = prompt | ChatAnthropic(model="claude-2")


class MessageListInput(BaseModel):
    """Input for the chat endpoint."""
    messages: List[Union[HumanMessage, AIMessage]] = Field(
        ...,
        description="The chat messages representing the current conversation.",
        extra={"widget": {"type": "chat", "input": "messages"}},
    )


add_routes(
    app,
    chain.with_types(input_type=MessageListInput),
    path="/chat",
)
```


예제 파일은 [여기](https://github.com/langchain-ai/langserve/tree/main/examples/widgets/chat/message_list/server.py)에서 확인할 수 있습니다.

### 엔드포인트 활성화/비활성화 (LangServe >=0.0.33)

주어진 체인에 대한 경로를 추가할 때 노출되는 엔드포인트를 활성화/비활성화할 수 있습니다.

`enabled_endpoints`를 사용하여 langserve를 새 버전으로 업그레이드할 때 새로운 엔드포인트가 절대 생성되지 않도록 할 수 있습니다.

활성화: 아래 코드는 `invoke`, `batch` 및 해당 `config_hash` 엔드포인트 변형만 활성화합니다.

```python
add_routes(app, chain, enabled_endpoints=["invoke", "batch", "config_hashes"], path="/mychain")
```


비활성화: 아래 코드는 체인에 대한 놀이터를 비활성화합니다.

```python
add_routes(app, chain, disabled_endpoints=["playground"], path="/mychain")
```