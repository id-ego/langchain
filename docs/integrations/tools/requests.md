---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/requests/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/requests.ipynb
---

# Requests Toolkit

We can use the Requests [toolkit](/docs/concepts/#toolkits) to construct agents that generate HTTP requests.

For detailed documentation of all API toolkit features and configurations head to the API reference for [RequestsToolkit](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.openapi.toolkit.RequestsToolkit.html).

## ⚠️ Security note ⚠️
There are inherent risks in giving models discretion to execute real-world actions. Take precautions to mitigate these risks:

- Make sure that permissions associated with the tools are narrowly-scoped (e.g., for database operations or API requests);
- When desired, make use of human-in-the-loop workflows.

## Setup

### Installation

This toolkit lives in the `langchain-community` package:


```python
%pip install -qU langchain-community
```

Note that if you want to get automated tracing from runs of individual tools, you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:


```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

## Instantiation

First we will demonstrate a minimal example.

**NOTE**: There are inherent risks in giving models discretion to execute real-world actions. We must "opt-in" to these risks by setting `allow_dangerous_request=True` to use these tools.
**This can be dangerous for calling unwanted requests**. Please make sure your custom OpenAPI spec (yaml) is safe and that permissions associated with the tools are narrowly-scoped.


```python
ALLOW_DANGEROUS_REQUEST = True
```

We can use the [JSONPlaceholder](https://jsonplaceholder.typicode.com) API as a testing ground.

Let's create (a subset of) its API spec:


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

Next we can instantiate the toolkit. We require no authorization or other headers for this API:


```python
<!--IMPORTS:[{"imported": "RequestsToolkit", "source": "langchain_community.agent_toolkits.openapi.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.openapi.toolkit.RequestsToolkit.html", "title": "Requests Toolkit"}, {"imported": "TextRequestsWrapper", "source": "langchain_community.utilities.requests", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.requests.TextRequestsWrapper.html", "title": "Requests Toolkit"}]-->
from langchain_community.agent_toolkits.openapi.toolkit import RequestsToolkit
from langchain_community.utilities.requests import TextRequestsWrapper

toolkit = RequestsToolkit(
    requests_wrapper=TextRequestsWrapper(headers={}),
    allow_dangerous_requests=ALLOW_DANGEROUS_REQUEST,
)
```

## Tools

View available tools:


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

## Use within an agent


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
## API reference

For detailed documentation of all API toolkit features and configurations head to the API reference for [RequestsToolkit](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.openapi.toolkit.RequestsToolkit.html).


## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)