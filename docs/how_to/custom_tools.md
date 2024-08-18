---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/custom_tools.ipynb
description: 에이전트를 구축할 때 사용할 수 있는 도구의 구성 요소와 각 속성에 대한 설명을 제공합니다.
---

# 도구 생성 방법

에이전트를 구성할 때 사용할 수 있는 `Tool` 목록을 제공해야 합니다. 호출되는 실제 기능 외에도 Tool은 여러 구성 요소로 구성됩니다:

| 속성           | 유형                      | 설명                                                                                                      |
|-----------------|---------------------------|------------------------------------------------------------------------------------------------------------------|
| name          | str                     | LLM 또는 에이전트에 제공된 도구 집합 내에서 고유해야 합니다.                                           |
| description   | str                     | 도구가 수행하는 작업을 설명합니다. LLM 또는 에이전트에 의해 컨텍스트로 사용됩니다.                                       |
| args_schema   | Pydantic BaseModel      | 선택 사항이지만 권장되며, 더 많은 정보(예: 몇 가지 예시) 또는 예상 매개변수에 대한 유효성 검사를 제공하는 데 사용할 수 있습니다. |
| return_direct   | boolean      | 에이전트에만 관련이 있습니다. True일 때, 주어진 도구를 호출한 후 에이전트는 중지하고 결과를 사용자에게 직접 반환합니다.  |

LangChain은 다음에서 도구 생성을 지원합니다:

1. 함수;
2. LangChain [Runnables](/docs/concepts#runnable-interface);
3. [BaseTool](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.BaseTool.html)에서 서브클래싱 -- 가장 유연한 방법으로, 더 많은 노력과 코드의 대가로 최대한의 제어를 제공합니다.

함수에서 도구를 생성하는 것은 대부분의 사용 사례에 충분할 수 있으며, 간단한 [@tool 데코레이터](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.tool.html#langchain_core.tools.tool)로 수행할 수 있습니다. 더 많은 구성이 필요한 경우(예: 동기 및 비동기 구현 모두의 명세) [StructuredTool.from_function](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.StructuredTool.html#langchain_core.tools.StructuredTool.from_function) 클래스 메서드를 사용할 수도 있습니다.

이 가이드에서는 이러한 방법에 대한 개요를 제공합니다.

:::tip

도구의 이름, 설명 및 JSON 스키마가 잘 선택되면 모델의 성능이 향상됩니다.
:::

## 함수에서 도구 생성하기

### @tool 데코레이터

이 `@tool` 데코레이터는 사용자 정의 도구를 정의하는 가장 간단한 방법입니다. 기본적으로 데코레이터는 함수 이름을 도구 이름으로 사용하지만, 첫 번째 인수로 문자열을 전달하여 이를 재정의할 수 있습니다. 또한, 데코레이터는 함수의 docstring을 도구의 설명으로 사용하므로 docstring은 반드시 제공되어야 합니다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to create tools"}]-->
from langchain_core.tools import tool


@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


# Let's inspect some of the attributes associated with the tool.
print(multiply.name)
print(multiply.description)
print(multiply.args)
```

```output
multiply
Multiply two numbers.
{'a': {'title': 'A', 'type': 'integer'}, 'b': {'title': 'B', 'type': 'integer'}}
```

또는 **비동기** 구현을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to create tools"}]-->
from langchain_core.tools import tool


@tool
async def amultiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b
```


`@tool`은 주석, 중첩 스키마 및 기타 기능의 구문 분석을 지원합니다:

```python
from typing import Annotated, List


@tool
def multiply_by_max(
    a: Annotated[str, "scale factor"],
    b: Annotated[List[int], "list of ints over which to take maximum"],
) -> int:
    """Multiply a by the maximum of b."""
    return a * max(b)


multiply_by_max.args_schema.schema()
```


```output
{'title': 'multiply_by_maxSchema',
 'description': 'Multiply a by the maximum of b.',
 'type': 'object',
 'properties': {'a': {'title': 'A',
   'description': 'scale factor',
   'type': 'string'},
  'b': {'title': 'B',
   'description': 'list of ints over which to take maximum',
   'type': 'array',
   'items': {'type': 'integer'}}},
 'required': ['a', 'b']}
```


도구 이름과 JSON 인수를 도구 데코레이터에 전달하여 사용자 정의할 수도 있습니다.

```python
from langchain.pydantic_v1 import BaseModel, Field


class CalculatorInput(BaseModel):
    a: int = Field(description="first number")
    b: int = Field(description="second number")


@tool("multiplication-tool", args_schema=CalculatorInput, return_direct=True)
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


# Let's inspect some of the attributes associated with the tool.
print(multiply.name)
print(multiply.description)
print(multiply.args)
print(multiply.return_direct)
```

```output
multiplication-tool
Multiply two numbers.
{'a': {'title': 'A', 'description': 'first number', 'type': 'integer'}, 'b': {'title': 'B', 'description': 'second number', 'type': 'integer'}}
True
```

#### Docstring 구문 분석

`@tool`은 선택적으로 [Google 스타일 docstring](https://google.github.io/styleguide/pyguide.html#383-functions-and-methods)을 구문 분석하고 docstring 구성 요소(예: 인수 설명)를 도구 스키마의 관련 부분에 연결할 수 있습니다. 이 동작을 전환하려면 `parse_docstring`을 지정하십시오:

```python
@tool(parse_docstring=True)
def foo(bar: str, baz: int) -> str:
    """The foo.

    Args:
        bar: The bar.
        baz: The baz.
    """
    return bar


foo.args_schema.schema()
```


```output
{'title': 'fooSchema',
 'description': 'The foo.',
 'type': 'object',
 'properties': {'bar': {'title': 'Bar',
   'description': 'The bar.',
   'type': 'string'},
  'baz': {'title': 'Baz', 'description': 'The baz.', 'type': 'integer'}},
 'required': ['bar', 'baz']}
```


:::caution
기본적으로 `@tool(parse_docstring=True)`는 docstring이 올바르게 구문 분석되지 않으면 `ValueError`를 발생시킵니다. 자세한 내용과 예제는 [API 참조](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.tool.html)를 참조하십시오.
:::

### StructuredTool

`StructuredTool.from_function` 클래스 메서드는 `@tool` 데코레이터보다 약간 더 많은 구성 가능성을 제공하지만, 추가 코드를 많이 요구하지 않습니다.

```python
<!--IMPORTS:[{"imported": "StructuredTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.structured.StructuredTool.html", "title": "How to create tools"}]-->
from langchain_core.tools import StructuredTool


def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


async def amultiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


calculator = StructuredTool.from_function(func=multiply, coroutine=amultiply)

print(calculator.invoke({"a": 2, "b": 3}))
print(await calculator.ainvoke({"a": 2, "b": 5}))
```

```output
6
10
```

구성하려면:

```python
class CalculatorInput(BaseModel):
    a: int = Field(description="first number")
    b: int = Field(description="second number")


def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


calculator = StructuredTool.from_function(
    func=multiply,
    name="Calculator",
    description="multiply numbers",
    args_schema=CalculatorInput,
    return_direct=True,
    # coroutine= ... <- you can specify an async method if desired as well
)

print(calculator.invoke({"a": 2, "b": 3}))
print(calculator.name)
print(calculator.description)
print(calculator.args)
```

```output
6
Calculator
multiply numbers
{'a': {'title': 'A', 'description': 'first number', 'type': 'integer'}, 'b': {'title': 'B', 'description': 'second number', 'type': 'integer'}}
```

## Runnables에서 도구 생성하기

문자열 또는 `dict` 입력을 허용하는 LangChain [Runnables](/docs/concepts#runnable-interface)는 [as_tool](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.as_tool) 메서드를 사용하여 도구로 변환할 수 있으며, 이는 인수에 대한 이름, 설명 및 추가 스키마 정보를 지정할 수 있게 해줍니다.

사용 예:

```python
<!--IMPORTS:[{"imported": "GenericFakeChatModel", "source": "langchain_core.language_models", "docs": "https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.fake_chat_models.GenericFakeChatModel.html", "title": "How to create tools"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to create tools"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to create tools"}]-->
from langchain_core.language_models import GenericFakeChatModel
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [("human", "Hello. Please respond in the style of {answer_style}.")]
)

# Placeholder LLM
llm = GenericFakeChatModel(messages=iter(["hello matey"]))

chain = prompt | llm | StrOutputParser()

as_tool = chain.as_tool(
    name="Style responder", description="Description of when to use tool."
)
as_tool.args
```


```output
{'answer_style': {'title': 'Answer Style', 'type': 'string'}}
```


자세한 내용은 [이 가이드](/docs/how_to/convert_runnable_to_tool)를 참조하십시오.

## BaseTool 서브클래스화

`BaseTool`에서 서브클래싱하여 사용자 정의 도구를 정의할 수 있습니다. 이는 도구 정의에 대한 최대한의 제어를 제공하지만, 더 많은 코드를 작성해야 합니다.

```python
<!--IMPORTS:[{"imported": "AsyncCallbackManagerForToolRun", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.AsyncCallbackManagerForToolRun.html", "title": "How to create tools"}, {"imported": "CallbackManagerForToolRun", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManagerForToolRun.html", "title": "How to create tools"}, {"imported": "BaseTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.BaseTool.html", "title": "How to create tools"}]-->
from typing import Optional, Type

from langchain.pydantic_v1 import BaseModel
from langchain_core.callbacks import (
    AsyncCallbackManagerForToolRun,
    CallbackManagerForToolRun,
)
from langchain_core.tools import BaseTool


class CalculatorInput(BaseModel):
    a: int = Field(description="first number")
    b: int = Field(description="second number")


class CustomCalculatorTool(BaseTool):
    name = "Calculator"
    description = "useful for when you need to answer questions about math"
    args_schema: Type[BaseModel] = CalculatorInput
    return_direct: bool = True

    def _run(
        self, a: int, b: int, run_manager: Optional[CallbackManagerForToolRun] = None
    ) -> str:
        """Use the tool."""
        return a * b

    async def _arun(
        self,
        a: int,
        b: int,
        run_manager: Optional[AsyncCallbackManagerForToolRun] = None,
    ) -> str:
        """Use the tool asynchronously."""
        # If the calculation is cheap, you can just delegate to the sync implementation
        # as shown below.
        # If the sync calculation is expensive, you should delete the entire _arun method.
        # LangChain will automatically provide a better implementation that will
        # kick off the task in a thread to make sure it doesn't block other async code.
        return self._run(a, b, run_manager=run_manager.get_sync())
```


```python
multiply = CustomCalculatorTool()
print(multiply.name)
print(multiply.description)
print(multiply.args)
print(multiply.return_direct)

print(multiply.invoke({"a": 2, "b": 3}))
print(await multiply.ainvoke({"a": 2, "b": 3}))
```

```output
Calculator
useful for when you need to answer questions about math
{'a': {'title': 'A', 'description': 'first number', 'type': 'integer'}, 'b': {'title': 'B', 'description': 'second number', 'type': 'integer'}}
True
6
6
```

## 비동기 도구 생성 방법

LangChain 도구는 [Runnable 인터페이스 🏃](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html)를 구현합니다.

모든 Runnables는 `invoke` 및 `ainvoke` 메서드(및 `batch`, `abatch`, `astream` 등과 같은 기타 메서드)를 노출합니다.

따라서 도구의 `sync` 구현만 제공하더라도 `ainvoke` 인터페이스를 사용할 수 있지만, 알아야 할 몇 가지 중요한 사항이 있습니다:

* LangChain은 기본적으로 함수가 계산 비용이 많이 든다고 가정하는 비동기 구현을 제공하므로, 다른 스레드에 실행을 위임합니다.
* 비동기 코드베이스에서 작업하는 경우, 스레드로 인한 작은 오버헤드를 피하기 위해 비동기 도구를 생성해야 합니다.
* 동기 및 비동기 구현이 모두 필요한 경우, `StructuredTool.from_function`을 사용하거나 `BaseTool`에서 서브클래싱하십시오.
* 동기 및 비동기를 모두 구현하고 동기 코드가 빠르게 실행되는 경우, 기본 LangChain 비동기 구현을 재정의하고 단순히 동기 코드를 호출하십시오.
* 비동기 도구와 함께 동기 `invoke`를 사용할 수 없으며, 사용해서는 안 됩니다.

```python
<!--IMPORTS:[{"imported": "StructuredTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.structured.StructuredTool.html", "title": "How to create tools"}]-->
from langchain_core.tools import StructuredTool


def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


calculator = StructuredTool.from_function(func=multiply)

print(calculator.invoke({"a": 2, "b": 3}))
print(
    await calculator.ainvoke({"a": 2, "b": 5})
)  # Uses default LangChain async implementation incurs small overhead
```

```output
6
10
```


```python
<!--IMPORTS:[{"imported": "StructuredTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.structured.StructuredTool.html", "title": "How to create tools"}]-->
from langchain_core.tools import StructuredTool


def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


async def amultiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


calculator = StructuredTool.from_function(func=multiply, coroutine=amultiply)

print(calculator.invoke({"a": 2, "b": 3}))
print(
    await calculator.ainvoke({"a": 2, "b": 5})
)  # Uses use provided amultiply without additional overhead
```

```output
6
10
```

비동기 정의만 제공할 때는 `.invoke`를 사용할 수 없고 사용해서도 안 됩니다.

```python
@tool
async def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b


try:
    multiply.invoke({"a": 2, "b": 3})
except NotImplementedError:
    print("Raised not implemented error. You should not be doing this.")
```

```output
Raised not implemented error. You should not be doing this.
```

## 도구 오류 처리

에이전트와 함께 도구를 사용하는 경우, 에이전트가 오류에서 복구하고 실행을 계속할 수 있도록 오류 처리 전략이 필요할 것입니다.

간단한 전략은 도구 내부에서 `ToolException`을 발생시키고 `handle_tool_error`를 사용하여 오류 처리기를 지정하는 것입니다.

오류 처리기가 지정되면 예외가 포착되고 오류 처리기가 도구에서 반환할 출력을 결정합니다.

`handle_tool_error`를 `True`, 문자열 값 또는 함수로 설정할 수 있습니다. 함수인 경우, 함수는 `ToolException`을 매개변수로 받아 값을 반환해야 합니다.

단순히 `ToolException`을 발생시키는 것만으로는 효과적이지 않습니다. 도구의 `handle_tool_error`를 먼저 설정해야 합니다. 기본값은 `False`입니다.

```python
<!--IMPORTS:[{"imported": "ToolException", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.ToolException.html", "title": "How to create tools"}]-->
from langchain_core.tools import ToolException


def get_weather(city: str) -> int:
    """Get weather for the given city."""
    raise ToolException(f"Error: There is no city by the name of {city}.")
```


기본 `handle_tool_error=True` 동작의 예입니다.

```python
get_weather_tool = StructuredTool.from_function(
    func=get_weather,
    handle_tool_error=True,
)

get_weather_tool.invoke({"city": "foobar"})
```


```output
'Error: There is no city by the name of foobar.'
```


`handle_tool_error`를 항상 반환되는 문자열로 설정할 수 있습니다.

```python
get_weather_tool = StructuredTool.from_function(
    func=get_weather,
    handle_tool_error="There is no such city, but it's probably above 0K there!",
)

get_weather_tool.invoke({"city": "foobar"})
```


```output
"There is no such city, but it's probably above 0K there!"
```


함수를 사용하여 오류를 처리하기:

```python
def _handle_error(error: ToolException) -> str:
    return f"The following errors occurred during tool execution: `{error.args[0]}`"


get_weather_tool = StructuredTool.from_function(
    func=get_weather,
    handle_tool_error=_handle_error,
)

get_weather_tool.invoke({"city": "foobar"})
```


```output
'The following errors occurred during tool execution: `Error: There is no city by the name of foobar.`'
```


## 도구 실행의 산출물 반환

때때로 도구 실행의 산출물이 체인 또는 에이전트의 하류 구성 요소에 접근 가능하도록 하고 싶지만, 모델 자체에 노출하고 싶지 않은 경우가 있습니다. 예를 들어 도구가 Documents와 같은 사용자 정의 객체를 반환하는 경우, 원시 출력을 모델에 전달하지 않고 이 출력에 대한 일부 보기 또는 메타데이터를 모델에 전달하고 싶을 수 있습니다. 동시에, 다른 곳에서 이 전체 출출을 접근할 수 있어야 할 수도 있습니다.

Tool 및 [ToolMessage](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html) 인터페이스는 모델을 위한 도구 출력의 부분(이것은 ToolMessage.content)과 모델 외부에서 사용하기 위한 부분(ToolMessage.artifact)을 구분할 수 있게 해줍니다.

:::info `langchain-core >= 0.2.19` 필요

이 기능은 `langchain-core == 0.2.19`에서 추가되었습니다. 패키지가 최신인지 확인하십시오.

:::

도구가 메시지 내용과 기타 산출물을 구분하도록 하려면 도구를 정의할 때 `response_format="content_and_artifact"`를 지정하고 (content, artifact)의 튜플을 반환해야 합니다:

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to create tools"}]-->
import random
from typing import List, Tuple

from langchain_core.tools import tool


@tool(response_format="content_and_artifact")
def generate_random_ints(min: int, max: int, size: int) -> Tuple[str, List[int]]:
    """Generate size random ints in the range [min, max]."""
    array = [random.randint(min, max) for _ in range(size)]
    content = f"Successfully generated array of {size} random ints in [{min}, {max}]."
    return content, array
```


도구 인수로 도구를 직접 호출하면 출력의 내용 부분만 반환됩니다:

```python
generate_random_ints.invoke({"min": 0, "max": 9, "size": 10})
```


```output
'Successfully generated array of 10 random ints in [0, 9].'
```


도구 호출 모델에 의해 생성된 ToolCall로 도구를 호출하면 도구에 의해 생성된 내용과 산출물을 모두 포함하는 ToolMessage를 반환받게 됩니다:

```python
generate_random_ints.invoke(
    {
        "name": "generate_random_ints",
        "args": {"min": 0, "max": 9, "size": 10},
        "id": "123",  # required
        "type": "tool_call",  # required
    }
)
```


```output
ToolMessage(content='Successfully generated array of 10 random ints in [0, 9].', name='generate_random_ints', tool_call_id='123', artifact=[1, 4, 2, 5, 3, 9, 0, 4, 7, 7])
```


BaseTool을 서브클래싱할 때도 동일한 작업을 수행할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "BaseTool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.base.BaseTool.html", "title": "How to create tools"}]-->
from langchain_core.tools import BaseTool


class GenerateRandomFloats(BaseTool):
    name: str = "generate_random_floats"
    description: str = "Generate size random floats in the range [min, max]."
    response_format: str = "content_and_artifact"

    ndigits: int = 2

    def _run(self, min: float, max: float, size: int) -> Tuple[str, List[float]]:
        range_ = max - min
        array = [
            round(min + (range_ * random.random()), ndigits=self.ndigits)
            for _ in range(size)
        ]
        content = f"Generated {size} floats in [{min}, {max}], rounded to {self.ndigits} decimals."
        return content, array

    # Optionally define an equivalent async method

    # async def _arun(self, min: float, max: float, size: int) -> Tuple[str, List[float]]:
    #     ...
```


```python
rand_gen = GenerateRandomFloats(ndigits=4)

rand_gen.invoke(
    {
        "name": "generate_random_floats",
        "args": {"min": 0.1, "max": 3.3333, "size": 3},
        "id": "123",
        "type": "tool_call",
    }
)
```


```output
ToolMessage(content='Generated 3 floats in [0.1, 3.3333], rounded to 4 decimals.', name='generate_random_floats', tool_call_id='123', artifact=[1.4277, 0.7578, 2.4871])
```