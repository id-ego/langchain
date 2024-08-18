---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_runtime.ipynb
description: 런타임 값이 도구에 전달되는 방법을 설명하며, LLM이 제어하지 않아야 할 매개변수와 애플리케이션 로직의 중요성을 강조합니다.
---

# 도구에 런타임 값을 전달하는 방법

import Prerequisites from "@theme/Prerequisites";
import Compatibility from "@theme/Compatibility";

<Prerequisites titlesAndLinks={[
["채팅 모델", "/docs/concepts/#chat-models"],
["LangChain 도구", "/docs/concepts/#tools"],
["도구 만들기", "/docs/how_to/custom_tools"],
["모델을 사용하여 도구 호출하기", "/docs/how_to/tool_calling"],
]} />

<Compatibility packagesAndVersions={[
["langchain-core", "0.2.21"],
]} />

런타임에만 알려진 값을 도구에 바인딩해야 할 수도 있습니다. 예를 들어, 도구 로직은 요청을 한 사용자의 ID를 사용해야 할 수 있습니다.

대부분의 경우, 이러한 값은 LLM에 의해 제어되어서는 안 됩니다. 실제로 LLM이 사용자 ID를 제어하도록 허용하면 보안 위험이 발생할 수 있습니다.

대신, LLM은 LLM에 의해 제어되어야 하는 도구의 매개변수만 제어해야 하며, 다른 매개변수(예: 사용자 ID)는 애플리케이션 로직에 의해 고정되어야 합니다.

이 가이드는 모델이 특정 도구 인수를 생성하지 않도록 방지하고 런타임에 직접 주입하는 방법을 보여줍니다.

:::info LangGraph와 함께 사용하기

LangGraph를 사용하는 경우, [이 가이드](https://langchain-ai.github.io/langgraph/how-tos/pass-run-time-values-to-tools/)를 참조하십시오. 이 가이드는 주어진 사용자의 좋아하는 애완동물을 추적하는 에이전트를 만드는 방법을 보여줍니다.
:::

다음과 같이 채팅 모델에 바인딩할 수 있습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
fireworksParams={`model="accounts/fireworks/models/firefunction-v1", temperature=0`}
/>

## 모델에서 인수 숨기기

InjectedToolArg 주석을 사용하여 `user_id`와 같은 도구의 특정 매개변수를 런타임에 주입되도록 표시할 수 있습니다. 즉, 모델에 의해 생성되지 않아야 함을 의미합니다.

```python
<!--IMPORTS:[{"imported": "InjectedToolArg", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.InjectedToolArg.html", "title": "How to pass run time values to tools"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to pass run time values to tools"}]-->
from typing import List

from langchain_core.tools import InjectedToolArg, tool
from typing_extensions import Annotated

user_to_pets = {}


@tool(parse_docstring=True)
def update_favorite_pets(
    pets: List[str], user_id: Annotated[str, InjectedToolArg]
) -> None:
    """Add the list of favorite pets.

    Args:
        pets: List of favorite pets to set.
        user_id: User's ID.
    """
    user_to_pets[user_id] = pets


@tool(parse_docstring=True)
def delete_favorite_pets(user_id: Annotated[str, InjectedToolArg]) -> None:
    """Delete the list of favorite pets.

    Args:
        user_id: User's ID.
    """
    if user_id in user_to_pets:
        del user_to_pets[user_id]


@tool(parse_docstring=True)
def list_favorite_pets(user_id: Annotated[str, InjectedToolArg]) -> None:
    """List favorite pets if any.

    Args:
        user_id: User's ID.
    """
    return user_to_pets.get(user_id, [])
```


이 도구의 입력 스키마를 살펴보면 user_id가 여전히 나열되어 있는 것을 볼 수 있습니다:

```python
update_favorite_pets.get_input_schema().schema()
```


```output
{'title': 'update_favorite_petsSchema',
 'description': 'Add the list of favorite pets.',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'description': 'List of favorite pets to set.',
   'type': 'array',
   'items': {'type': 'string'}},
  'user_id': {'title': 'User Id',
   'description': "User's ID.",
   'type': 'string'}},
 'required': ['pets', 'user_id']}
```


하지만 도구 호출 스키마를 살펴보면, 이는 도구 호출을 위해 모델에 전달되는 것이며, user_id가 제거되었습니다:

```python
update_favorite_pets.tool_call_schema.schema()
```


```output
{'title': 'update_favorite_pets',
 'description': 'Add the list of favorite pets.',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'description': 'List of favorite pets to set.',
   'type': 'array',
   'items': {'type': 'string'}}},
 'required': ['pets']}
```


따라서 도구를 호출할 때 user_id를 전달해야 합니다:

```python
user_id = "123"
update_favorite_pets.invoke({"pets": ["lizard", "dog"], "user_id": user_id})
print(user_to_pets)
print(list_favorite_pets.invoke({"user_id": user_id}))
```

```output
{'123': ['lizard', 'dog']}
['lizard', 'dog']
```

하지만 모델이 도구를 호출할 때는 user_id 인수가 생성되지 않습니다:

```python
tools = [
    update_favorite_pets,
    delete_favorite_pets,
    list_favorite_pets,
]
llm_with_tools = llm.bind_tools(tools)
ai_msg = llm_with_tools.invoke("my favorite animals are cats and parrots")
ai_msg.tool_calls
```


```output
[{'name': 'update_favorite_pets',
  'args': {'pets': ['cats', 'parrots']},
  'id': 'call_W3cn4lZmJlyk8PCrKN4PRwqB',
  'type': 'tool_call'}]
```


## 런타임에 인수 주입하기

모델이 생성한 도구 호출을 사용하여 실제로 도구를 실행하려면, user_id를 직접 주입해야 합니다:

```python
<!--IMPORTS:[{"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to pass run time values to tools"}]-->
from copy import deepcopy

from langchain_core.runnables import chain


@chain
def inject_user_id(ai_msg):
    tool_calls = []
    for tool_call in ai_msg.tool_calls:
        tool_call_copy = deepcopy(tool_call)
        tool_call_copy["args"]["user_id"] = user_id
        tool_calls.append(tool_call_copy)
    return tool_calls


inject_user_id.invoke(ai_msg)
```


```output
[{'name': 'update_favorite_pets',
  'args': {'pets': ['cats', 'parrots'], 'user_id': '123'},
  'id': 'call_W3cn4lZmJlyk8PCrKN4PRwqB',
  'type': 'tool_call'}]
```


이제 모델, 주입 코드 및 실제 도구를 연결하여 도구 실행 체인을 만들 수 있습니다:

```python
tool_map = {tool.name: tool for tool in tools}


@chain
def tool_router(tool_call):
    return tool_map[tool_call["name"]]


chain = llm_with_tools | inject_user_id | tool_router.map()
chain.invoke("my favorite animals are cats and parrots")
```


```output
[ToolMessage(content='null', name='update_favorite_pets', tool_call_id='call_HUyF6AihqANzEYxQnTUKxkXj')]
```


user_to_pets dict를 살펴보면, 고양이와 앵무새가 포함되도록 업데이트된 것을 볼 수 있습니다:

```python
user_to_pets
```


```output
{'123': ['cats', 'parrots']}
```


## 인수 주석을 달 수 있는 다른 방법

도구 인수에 주석을 달 수 있는 몇 가지 다른 방법은 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "BaseTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.BaseTool.html", "title": "How to pass run time values to tools"}]-->
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_core.tools import BaseTool


class UpdateFavoritePetsSchema(BaseModel):
    """Update list of favorite pets"""

    pets: List[str] = Field(..., description="List of favorite pets to set.")
    user_id: Annotated[str, InjectedToolArg] = Field(..., description="User's ID.")


@tool(args_schema=UpdateFavoritePetsSchema)
def update_favorite_pets(pets, user_id):
    user_to_pets[user_id] = pets


update_favorite_pets.get_input_schema().schema()
```


```output
{'title': 'UpdateFavoritePetsSchema',
 'description': 'Update list of favorite pets',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'description': 'List of favorite pets to set.',
   'type': 'array',
   'items': {'type': 'string'}},
  'user_id': {'title': 'User Id',
   'description': "User's ID.",
   'type': 'string'}},
 'required': ['pets', 'user_id']}
```


```python
update_favorite_pets.tool_call_schema.schema()
```


```output
{'title': 'update_favorite_pets',
 'description': 'Update list of favorite pets',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'description': 'List of favorite pets to set.',
   'type': 'array',
   'items': {'type': 'string'}}},
 'required': ['pets']}
```


```python
from typing import Optional, Type


class UpdateFavoritePets(BaseTool):
    name: str = "update_favorite_pets"
    description: str = "Update list of favorite pets"
    args_schema: Optional[Type[BaseModel]] = UpdateFavoritePetsSchema

    def _run(self, pets, user_id):
        user_to_pets[user_id] = pets


UpdateFavoritePets().get_input_schema().schema()
```


```output
{'title': 'UpdateFavoritePetsSchema',
 'description': 'Update list of favorite pets',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'description': 'List of favorite pets to set.',
   'type': 'array',
   'items': {'type': 'string'}},
  'user_id': {'title': 'User Id',
   'description': "User's ID.",
   'type': 'string'}},
 'required': ['pets', 'user_id']}
```


```python
UpdateFavoritePets().tool_call_schema.schema()
```


```output
{'title': 'update_favorite_pets',
 'description': 'Update list of favorite pets',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'description': 'List of favorite pets to set.',
   'type': 'array',
   'items': {'type': 'string'}}},
 'required': ['pets']}
```


```python
class UpdateFavoritePets2(BaseTool):
    name: str = "update_favorite_pets"
    description: str = "Update list of favorite pets"

    def _run(self, pets: List[str], user_id: Annotated[str, InjectedToolArg]) -> None:
        user_to_pets[user_id] = pets


UpdateFavoritePets2().get_input_schema().schema()
```


```output
{'title': 'update_favorite_petsSchema',
 'description': 'Use the tool.\n\nAdd run_manager: Optional[CallbackManagerForToolRun] = None\nto child implementations to enable tracing.',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'type': 'array',
   'items': {'type': 'string'}},
  'user_id': {'title': 'User Id', 'type': 'string'}},
 'required': ['pets', 'user_id']}
```


```python
UpdateFavoritePets2().tool_call_schema.schema()
```


```output
{'title': 'update_favorite_pets',
 'description': 'Update list of favorite pets',
 'type': 'object',
 'properties': {'pets': {'title': 'Pets',
   'type': 'array',
   'items': {'type': 'string'}}},
 'required': ['pets']}
```