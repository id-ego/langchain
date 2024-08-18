---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_calling.ipynb
description: 챗 모델을 사용하여 도구를 호출하는 방법에 대한 가이드입니다. 도구 호출의 개념과 활용 사례를 설명합니다.
keywords:
- tool calling
- tool call
---

# 도구 호출을 위한 채팅 모델 사용 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [채팅 모델](/docs/concepts/#chat-models)
- [도구 호출](/docs/concepts/#functiontool-calling)
- [도구](/docs/concepts/#tools)
- [출력 파서](/docs/concepts/#output-parsers)
:::

[도구 호출](/docs/concepts/#functiontool-calling)은 채팅 모델이 주어진 프롬프트에 응답하기 위해 "도구를 호출"하는 기능을 제공합니다.

"도구 호출"이라는 이름은 모델이 직접 어떤 작업을 수행하는 것처럼 보이지만, 실제로는 그렇지 않습니다! 모델은 도구에 대한 인수만 생성하며, 도구를 실행하는 것은 사용자에게 달려 있습니다.

도구 호출은 모델에서 구조화된 출력을 생성하는 일반적인 기술이며, 도구를 호출할 의도가 없더라도 사용할 수 있습니다. 그 예로는 [비구조적 텍스트에서의 추출](/docs/tutorials/extraction/)이 있습니다.

![도구 호출 다이어그램](/img/tool_call.png)

모델이 생성한 도구 호출을 실제로 실행하는 방법을 보려면 [이 가이드를 확인하세요](/docs/how_to/tool_results_pass_to_model/) .

:::note 지원되는 모델

도구 호출은 보편적이지 않지만 많은 인기 있는 LLM 제공업체에서 지원됩니다. 도구 호출을 지원하는 모든 모델의 [목록은 여기에서 확인할 수 있습니다](/docs/integrations/chat/) .

:::

LangChain은 도구를 정의하고 LLM에 전달하며 도구 호출을 나타내기 위한 표준 인터페이스를 구현합니다. 이 가이드는 도구를 LLM에 바인딩한 다음, 이러한 인수를 생성하기 위해 LLM을 호출하는 방법을 다룰 것입니다.

## 도구 스키마 정의

모델이 도구를 호출할 수 있도록 하려면 도구가 수행하는 작업과 그 인수를 설명하는 도구 스키마를 전달해야 합니다. 도구 호출 기능을 지원하는 채팅 모델은 모델에 도구 스키마를 전달하기 위한 `.bind_tools()` 메서드를 구현합니다. 도구 스키마는 Python 함수(타입 힌트 및 문서 문자열 포함), Pydantic 모델, TypedDict 클래스 또는 LangChain [Tool 객체](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.BaseTool.html#langchain_core.tools.BaseTool)로 전달될 수 있습니다. 이후 모델 호출 시 이러한 도구 스키마가 프롬프트와 함께 전달됩니다.

### Python 함수
우리의 도구 스키마는 Python 함수로 정의할 수 있습니다:

```python
# The function name, type hints, and docstring are all part of the tool
# schema that's passed to the model. Defining good, descriptive schemas
# is an extension of prompt engineering and is an important part of
# getting models to perform well.
def add(a: int, b: int) -> int:
    """Add two integers.

    Args:
        a: First integer
        b: Second integer
    """
    return a + b


def multiply(a: int, b: int) -> int:
    """Multiply two integers.

    Args:
        a: First integer
        b: Second integer
    """
    return a * b
```


### LangChain 도구

LangChain은 도구 이름 및 인수 설명과 같은 도구 스키마에 대한 추가 제어를 허용하는 `@tool` 데코레이터도 구현합니다. 자세한 내용은 [여기](https://docs/langchain.com/docs/how_to/custom_tools/#creating-tools-from-functions)에서 확인하세요.

### Pydantic 클래스

동일하게 [Pydantic](https://docs.pydantic.dev)을 사용하여 함수 없이 스키마를 정의할 수 있습니다:

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class add(BaseModel):
    """Add two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


class multiply(BaseModel):
    """Multiply two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")
```


### TypedDict 클래스

:::info `langchain-core>=0.2.25` 필요
:::

또는 TypedDict와 주석을 사용하여 정의할 수 있습니다:

```python
from typing_extensions import Annotated, TypedDict


class add(TypedDict):
    """Add two integers."""

    # Annotations must have the type and can optionally include a default value and description (in that order).
    a: Annotated[int, ..., "First integer"]
    b: Annotated[int, ..., "Second integer"]


class multiply(BaseModel):
    """Multiply two integers."""

    a: Annotated[int, ..., "First integer"]
    b: Annotated[int, ..., "Second integer"]


tools = [add, multiply]
```


실제로 이러한 스키마를 채팅 모델에 바인딩하려면 `.bind_tools()` 메서드를 사용합니다. 이는 `add` 및 `multiply` 스키마를 모델에 맞는 형식으로 변환하는 작업을 처리합니다. 도구 스키마는 모델이 호출될 때마다 전달됩니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
fireworksParams={`model="accounts/fireworks/models/firefunction-v1", temperature=0`}
/>

```python
llm_with_tools = llm.bind_tools(tools)

query = "What is 3 * 12?"

llm_with_tools.invoke(query)
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_BwYJ4UgU5pRVCBOUmiu7NhF9', 'function': {'arguments': '{"a":3,"b":12}', 'name': 'multiply'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 80, 'total_tokens': 97}, 'model_name': 'gpt-4o-mini-2024-07-18', 'system_fingerprint': 'fp_ba606877f9', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-7f05e19e-4561-40e2-a2d0-8f4e28e9a00f-0', tool_calls=[{'name': 'multiply', 'args': {'a': 3, 'b': 12}, 'id': 'call_BwYJ4UgU5pRVCBOUmiu7NhF9', 'type': 'tool_call'}], usage_metadata={'input_tokens': 80, 'output_tokens': 17, 'total_tokens': 97})
```


우리의 LLM이 도구에 대한 인수를 생성했음을 볼 수 있습니다! LLM이 도구를 선택하는 방식을 사용자 정의하는 모든 방법에 대해 배우려면 [bind_tools() 문서](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.BaseChatOpenAI.html#langchain_openai.chat_models.base.BaseChatOpenAI.bind_tools)를 참조하고, LLM이 도구를 호출하도록 강제하는 방법에 대한 [이 가이드](/docs/how_to/tool_choice/)를 확인하세요.

## 도구 호출

LLM 응답에 도구 호출이 포함되면, 이는 해당 [메시지](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html#langchain_core.messages.ai.AIMessage) 또는 [메시지 청크](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessageChunk.html#langchain_core.messages.ai.AIMessageChunk)에 `.tool_calls` 속성의 [도구 호출](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolCall.html#langchain_core.messages.tool.ToolCall) 객체 목록으로 첨부됩니다.

채팅 모델은 여러 도구를 동시에 호출할 수 있습니다.

`ToolCall`은 도구 이름, 인수 값의 딕셔너리 및 (선택적으로) 식별자를 포함하는 타입 딕셔너리입니다. 도구 호출이 없는 메시지는 이 속성에 대해 기본적으로 빈 목록으로 설정됩니다.

```python
query = "What is 3 * 12? Also, what is 11 + 49?"

llm_with_tools.invoke(query).tool_calls
```


```output
[{'name': 'multiply',
  'args': {'a': 3, 'b': 12},
  'id': 'call_rcdMie7E89Xx06lEKKxJyB5N',
  'type': 'tool_call'},
 {'name': 'add',
  'args': {'a': 11, 'b': 49},
  'id': 'call_nheGN8yfvSJsnIuGZaXihou3',
  'type': 'tool_call'}]
```


`.tool_calls` 속성에는 유효한 도구 호출이 포함되어야 합니다. 때때로 모델 제공자가 잘못된 형식의 도구 호출(예: 유효하지 않은 JSON 인수)을 출력할 수 있습니다. 이러한 경우 파싱이 실패하면 [InvalidToolCall](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.InvalidToolCall.html#langchain_core.messages.tool.InvalidToolCall) 인스턴스가 `.invalid_tool_calls` 속성에 채워집니다. `InvalidToolCall`은 이름, 문자열 인수, 식별자 및 오류 메시지를 가질 수 있습니다.

## 파싱

원하는 경우 [출력 파서](/docs/how_to#output-parsers)를 사용하여 출력을 추가로 처리할 수 있습니다. 예를 들어, `.tool_calls`에 채워진 기존 값을 Pydantic 객체로 변환할 수 있습니다 [PydanticToolsParser](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html):

```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "How to use chat models to call tools"}]-->
from langchain_core.output_parsers import PydanticToolsParser
from langchain_core.pydantic_v1 import BaseModel, Field


class add(BaseModel):
    """Add two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


class multiply(BaseModel):
    """Multiply two integers."""

    a: int = Field(..., description="First integer")
    b: int = Field(..., description="Second integer")


chain = llm_with_tools | PydanticToolsParser(tools=[add, multiply])
chain.invoke(query)
```


```output
[multiply(a=3, b=12), add(a=11, b=49)]
```


## 다음 단계

이제 도구 스키마를 채팅 모델에 바인딩하고 모델이 도구를 호출하는 방법을 배웠습니다.

다음으로, 함수를 호출하고 결과를 모델에 다시 전달하여 도구를 실제로 사용하는 방법에 대한 이 가이드를 확인하세요:

- [도구 결과를 모델에 다시 전달하기](/docs/how_to/tool_results_pass_to_model)

또한 도구 호출의 보다 구체적인 사용 사례를 확인할 수 있습니다:

- 모델에서 [구조화된 출력](/docs/how_to/structured_output/) 얻기
- 도구와 함께 [Few shot prompting](/docs/how_to/tools_few_shot/)
- [도구 호출 스트리밍](/docs/how_to/tool_streaming/)
- [런타임 값을 도구에 전달하기](/docs/how_to/tool_runtime)