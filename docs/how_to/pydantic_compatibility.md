---
description: LangChain과 Pydantic의 다양한 버전 사용법에 대한 안내 및 Pydantic v2의 주요 변경 사항을 설명합니다.
---

# LangChain을 다양한 Pydantic 버전과 함께 사용하는 방법

- Pydantic v2는 2023년 6월에 출시되었습니다 (https://docs.pydantic.dev/2.0/blog/pydantic-v2-final/).
- v2에는 여러 가지 주요 변경 사항이 포함되어 있습니다 (https://docs.pydantic.dev/2.0/migration/).
- Pydantic 1의 지원 종료는 2024년 6월입니다. LangChain은 가까운 미래에 Pydantic 1에 대한 지원을 중단하고,
내부적으로 Pydantic 2로 마이그레이션할 가능성이 높습니다. 일정은 잠정적으로 9월입니다. 이 변경은 주요 langchain 패키지의 마이너 버전 증가와 함께 0.3.x로 진행됩니다.

`langchain>=0.0.267`부터 LangChain은 사용자가 Pydantic V1 또는 V2를 설치할 수 있도록 허용합니다.

내부적으로 LangChain은 Pydantic 2의 v1 네임스페이스를 통해 [Pydantic V1](https://docs.pydantic.dev/latest/migration/#continue-using-pydantic-v1-features)을 계속 사용합니다.

Pydantic이 .v1 및 .v2 객체 혼합을 지원하지 않기 때문에, 사용자는 LangChain을 Pydantic과 함께 사용할 때 여러 가지 문제를 인식해야 합니다.

:::caution
LangChain은 일부 API에서 Pydantic V2 객체를 지원하지만 (아래 목록 참조), 사용자는 LangChain 0.3이 출시될 때까지 Pydantic V1 객체를 계속 사용하는 것이 좋습니다.
:::

## 1. Pydantic 객체를 LangChain API에 전달하기

*도구 사용*을 위한 대부분의 LangChain API(아래 목록 참조)는 Pydantic v1 또는 v2 객체를 모두 수용하도록 업데이트되었습니다.

* Pydantic v1 객체는 `pydantic 1`이 설치된 경우 `pydantic.BaseModel`의 서브클래스에 해당하며, `pydantic 2`가 설치된 경우 `pydantic.v1.BaseModel`의 서브클래스에 해당합니다.
* Pydantic v2 객체는 `pydantic 2`가 설치된 경우 `pydantic.BaseModel`의 서브클래스에 해당합니다.

| API                                    | Pydantic 1 | Pydantic 2                                                     |
|----------------------------------------|------------|----------------------------------------------------------------|
| `BaseChatModel.bind_tools`             | 예         | langchain-core>=0.2.23, 적절한 버전의 파트너 패키지             |
| `BaseChatModel.with_structured_output` | 예         | langchain-core>=0.2.23, 적절한 버전의 파트너 패키지             |
| `Tool.from_function`                   | 예         | langchain-core>=0.2.23                                         |
| `StructuredTool.from_function`         | 예         | langchain-core>=0.2.23                                         |

`bind_tools` 또는 `with_structured_output` API를 통해 Pydantic v2 객체를 수용하는 파트너 패키지:

| 패키지 이름          | pydantic v1 | pydantic v2 |
|---------------------|-------------|-------------|
| langchain-mistralai | 예          | >=0.1.11    |
| langchain-anthropic | 예          | >=0.1.21    |
| langchain-robocorp  | 예          | >=0.0.10    |
| langchain-openai    | 예          | >=0.1.19    |
| langchain-fireworks | 예          | >=0.1.5     |
| langchain-aws       | 예          | >=0.1.15    |

추가 파트너 패키지는 향후 Pydantic v2 객체를 수용하도록 업데이트될 예정입니다.

이 API 또는 Pydantic 객체를 수용하는 다른 API에서 여전히 문제가 발생하는 경우, 문제를 열어 주시면 해결하겠습니다.

예시:

`langchain-core<0.2.23` 이전에는 LangChain API에 전달할 때 Pydantic v1 객체를 사용하세요.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use LangChain with different Pydantic versions"}]-->
from langchain_openai import ChatOpenAI
from pydantic.v1 import BaseModel # <-- Note v1 namespace

class Person(BaseModel):
    """Personal information"""
    name: str
    
model = ChatOpenAI()
model = model.with_structured_output(Person)

model.invoke('Bob is a person.')
```


`langchain-core>=0.2.23` 이후에는 LangChain API에 전달할 때 Pydantic v1 또는 v2 객체를 사용하세요.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use LangChain with different Pydantic versions"}]-->
from langchain_openai import ChatOpenAI
from pydantic import BaseModel

class Person(BaseModel):
    """Personal information"""
    name: str
    
    
model = ChatOpenAI()
model = model.with_structured_output(Person)

model.invoke('Bob is a person.')
```


## 2. LangChain 모델 서브클래싱

LangChain이 내부적으로 Pydantic v1을 사용하기 때문에, LangChain 모델을 서브클래싱할 경우 Pydantic v1 원시 타입을 사용해야 합니다.

**예시 1: 상속을 통한 확장**

**예** 

```python
<!--IMPORTS:[{"imported": "BaseTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.BaseTool.html", "title": "How to use LangChain with different Pydantic versions"}]-->
from pydantic.v1 import validator
from langchain_core.tools import BaseTool

class CustomTool(BaseTool): # BaseTool is v1 code
    x: int = Field(default=1)

    def _run(*args, **kwargs):
        return "hello"

    @validator('x') # v1 code
    @classmethod
    def validate_x(cls, x: int) -> int:
        return 1
    

CustomTool(
    name='custom_tool',
    description="hello",
    x=1,
)
```


Pydantic v2 원시 타입과 Pydantic v1 원시 타입을 혼합하면 암호화된 오류가 발생할 수 있습니다.

**아니요** 

```python
<!--IMPORTS:[{"imported": "BaseTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.BaseTool.html", "title": "How to use LangChain with different Pydantic versions"}]-->
from pydantic import Field, field_validator # pydantic v2
from langchain_core.tools import BaseTool

class CustomTool(BaseTool): # BaseTool is v1 code
    x: int = Field(default=1)

    def _run(*args, **kwargs):
        return "hello"

    @field_validator('x') # v2 code
    @classmethod
    def validate_x(cls, x: int) -> int:
        return 1
    

CustomTool( 
    name='custom_tool',
    description="hello",
    x=1,
)
```


## 3. Pydantic v2 모델 내에서 사용되는 LangChain 객체에 대한 런타임 검증 비활성화

예:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use LangChain with different Pydantic versions"}]-->
from typing import Annotated

from langchain_openai import ChatOpenAI # <-- ChatOpenAI uses pydantic v1
from pydantic import BaseModel, SkipValidation


class Foo(BaseModel): # <-- BaseModel is from Pydantic v2
    model: Annotated[ChatOpenAI, SkipValidation()]

Foo(model=ChatOpenAI(api_key="hello"))
```


## 4: Pydantic 2를 실행하는 경우 LangServe가 OpenAPI 문서를 생성할 수 없습니다

Pydantic 2를 사용하는 경우 LangServe를 사용하여 OpenAPI 문서를 생성할 수 없습니다.

OpenAPI 문서가 필요하다면, Pydantic 1을 설치하는 방법이 있습니다:

`pip install pydantic==1.10.17`

또는 LangChain의 `APIHandler` 객체를 사용하여 API의 경로를 수동으로 생성하는 방법이 있습니다.

참고: https://python.langchain.com/v0.2/docs/langserve/#pydantic