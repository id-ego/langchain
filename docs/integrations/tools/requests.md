---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/requests.ipynb
description: HTTP 요청을 생성하는 에이전트를 구축하기 위한 Requests 툴킷에 대한 문서입니다. 설치 및 보안 주의사항을 포함합니다.
---

# 요청 툴킷

우리는 요청 [툴킷](/docs/concepts/#toolkits)을 사용하여 HTTP 요청을 생성하는 에이전트를 구성할 수 있습니다.

모든 API 툴킷 기능 및 구성에 대한 자세한 문서는 [RequestsToolkit](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.openapi.toolkit.RequestsToolkit.html) API 참조로 이동하십시오.

## ⚠️ 보안 노트 ⚠️
모델에게 실제 세계의 행동을 실행할 재량을 부여하는 데는 고유한 위험이 있습니다. 이러한 위험을 완화하기 위한 예방 조치를 취하십시오:

- 도구와 관련된 권한이 좁게 제한되어 있는지 확인하십시오 (예: 데이터베이스 작업 또는 API 요청의 경우);
- 필요할 경우, 인간-루프 워크플로우를 활용하십시오.

## 설정

### 설치

이 툴킷은 `langchain-community` 패키지에 포함되어 있습니다:

```python
%pip install -qU langchain-community
```


개별 도구의 실행에서 자동 추적을 얻고 싶다면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 인스턴스화

먼저 최소한의 예제를 보여드리겠습니다.

**노트**: 모델에게 실제 세계의 행동을 실행할 재량을 부여하는 데는 고유한 위험이 있습니다. 이러한 도구를 사용하기 위해 `allow_dangerous_request=True`를 설정하여 이러한 위험을 "옵트인"해야 합니다.
**원하지 않는 요청을 호출하는 데 위험할 수 있습니다**. 사용자 정의 OpenAPI 사양(yaml)이 안전하고 도구와 관련된 권한이 좁게 제한되어 있는지 확인하십시오.

```python
ALLOW_DANGEROUS_REQUEST = True
```


우리는 [JSONPlaceholder](https://jsonplaceholder.typicode.com) API를 테스트 공간으로 사용할 수 있습니다.

그의 API 사양의 (부분 집합)을 생성해 보겠습니다:

```python
from typing import Any, Dict, Union

import requests
import yaml


def _get_schema(response_json: Union[dict, list]) -> dict:
    if isinstance(response_json, list):
        response_json = response_json[0] if response_json else {}
    return {key: type(value).__name__ for key, value in response_json.items()}


def _get_api_spec() -> str:
    base_url = "https://jsonplaceholder.typicode.com"
    endpoints = [
        "/posts",
        "/comments",
    ]
    common_query_parameters = [
        {
            "name": "_limit",
            "in": "query",
            "required": False,
            "schema": {"type": "integer", "example": 2},
            "description": "Limit the number of results",
        }
    ]
    openapi_spec: Dict[str, Any] = {
        "openapi": "3.0.0",
        "info": {"title": "JSONPlaceholder API", "version": "1.0.0"},
        "servers": [{"url": base_url}],
        "paths": {},
    }
    # Iterate over the endpoints to construct the paths
    for endpoint in endpoints:
        response = requests.get(base_url + endpoint)
        if response.status_code == 200:
            schema = _get_schema(response.json())
            openapi_spec["paths"][endpoint] = {
                "get": {
                    "summary": f"Get {endpoint[1:]}",
                    "parameters": common_query_parameters,
                    "responses": {
                        "200": {
                            "description": "Successful response",
                            "content": {
                                "application/json": {
                                    "schema": {"type": "object", "properties": schema}
                                }
                            },
                        }
                    },
                }
            }
    return yaml.dump(openapi_spec, sort_keys=False)


api_spec = _get_api_spec()
```


다음으로 툴킷을 인스턴스화할 수 있습니다. 이 API에는 인증이나 기타 헤더가 필요하지 않습니다:

```python
<!--IMPORTS:[{"imported": "RequestsToolkit", "source": "langchain_community.agent_toolkits.openapi.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.openapi.toolkit.RequestsToolkit.html", "title": "Requests Toolkit"}, {"imported": "TextRequestsWrapper", "source": "langchain_community.utilities.requests", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.requests.TextRequestsWrapper.html", "title": "Requests Toolkit"}]-->
from langchain_community.agent_toolkits.openapi.toolkit import RequestsToolkit
from langchain_community.utilities.requests import TextRequestsWrapper

toolkit = RequestsToolkit(
    requests_wrapper=TextRequestsWrapper(headers={}),
    allow_dangerous_requests=ALLOW_DANGEROUS_REQUEST,
)
```


## 도구

사용 가능한 도구 보기:

```python
tools = toolkit.get_tools()

tools
```


```output
[RequestsGetTool(requests_wrapper=TextRequestsWrapper(headers={}, aiosession=None, auth=None, response_content_type='text', verify=True), allow_dangerous_requests=True),
 RequestsPostTool(requests_wrapper=TextRequestsWrapper(headers={}, aiosession=None, auth=None, response_content_type='text', verify=True), allow_dangerous_requests=True),
 RequestsPatchTool(requests_wrapper=TextRequestsWrapper(headers={}, aiosession=None, auth=None, response_content_type='text', verify=True), allow_dangerous_requests=True),
 RequestsPutTool(requests_wrapper=TextRequestsWrapper(headers={}, aiosession=None, auth=None, response_content_type='text', verify=True), allow_dangerous_requests=True),
 RequestsDeleteTool(requests_wrapper=TextRequestsWrapper(headers={}, aiosession=None, auth=None, response_content_type='text', verify=True), allow_dangerous_requests=True)]
```


- [RequestsGetTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.requests.tool.RequestsGetTool.html)
- [RequestsPostTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.requests.tool.RequestsPostTool.html)
- [RequestsPatchTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.requests.tool.RequestsPatchTool.html)
- [RequestsPutTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.requests.tool.RequestsPutTool.html)
- [RequestsDeleteTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.requests.tool.RequestsDeleteTool.html)

## 에이전트 내에서 사용

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Requests Toolkit"}]-->
from langchain_openai import ChatOpenAI
from langgraph.prebuilt import create_react_agent

llm = ChatOpenAI(model="gpt-3.5-turbo-0125")

system_message = """
You have access to an API to help answer user queries.
Here is documentation on the API:
{api_spec}
""".format(api_spec=api_spec)

agent_executor = create_react_agent(llm, tools, state_modifier=system_message)
```


```python
example_query = "Fetch the top two posts. What are their titles?"

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

```output
================================[1m Human Message [0m=================================

Fetch the top two posts. What are their titles?
==================================[1m Ai Message [0m==================================
Tool Calls:
  requests_get (call_RV2SOyzCnV5h2sm4WPgG8fND)
 Call ID: call_RV2SOyzCnV5h2sm4WPgG8fND
  Args:
    url: https://jsonplaceholder.typicode.com/posts?_limit=2
=================================[1m Tool Message [0m=================================
Name: requests_get

[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
  }
]
==================================[1m Ai Message [0m==================================

The titles of the top two posts are:
1. "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"
2. "qui est esse"
```

## API 참조

모든 API 툴킷 기능 및 구성에 대한 자세한 문서는 [RequestsToolkit](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.openapi.toolkit.RequestsToolkit.html) API 참조로 이동하십시오.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)