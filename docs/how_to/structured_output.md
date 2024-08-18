---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/structured_output.ipynb
description: 모델에서 구조화된 데이터를 반환하는 방법을 안내합니다. 이 가이드는 특정 스키마에 맞는 출력을 얻는 전략을 다룹니다.
keywords:
- structured output
- json
- information extraction
- with_structured_output
sidebar_position: 3
---

# 모델에서 구조화된 데이터 반환하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [함수/도구 호출](/docs/concepts/#functiontool-calling)
:::

모델이 특정 스키마와 일치하는 출력을 반환하는 것은 종종 유용합니다. 일반적인 사용 사례 중 하나는 텍스트에서 데이터를 추출하여 데이터베이스에 삽입하거나 다른 하위 시스템과 함께 사용하는 것입니다. 이 가이드는 모델에서 구조화된 출력을 얻기 위한 몇 가지 전략을 다룹니다.

## `.with_structured_output()` 메서드

<span data-heading-keywords="with_structured_output"></span>

:::info 지원되는 모델

이 메서드를 지원하는 [모델 목록은 여기에서 확인할 수 있습니다](/docs/integrations/chat/).

:::

이것은 구조화된 출력을 얻는 가장 쉽고 신뢰할 수 있는 방법입니다. `with_structured_output()`는 출력을 구조화하기 위한 네이티브 API를 제공하는 모델에 대해 구현되어 있으며, 이러한 기능을 내부적으로 활용합니다.

이 메서드는 원하는 출력 속성의 이름, 유형 및 설명을 지정하는 스키마를 입력으로 받습니다. 이 메서드는 문자열이나 메시지를 출력하는 대신 주어진 스키마에 해당하는 객체를 출력하는 모델과 유사한 Runnable을 반환합니다. 스키마는 TypedDict 클래스, [JSON 스키마](https://json-schema.org/) 또는 Pydantic 클래스로 지정할 수 있습니다. TypedDict 또는 JSON 스키마를 사용하는 경우 Runnable에 의해 사전이 반환되며, Pydantic 클래스를 사용하는 경우 Pydantic 객체가 반환됩니다.

예를 들어, 모델이 농담을 생성하고 설정과 펀치라인을 분리하도록 해보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
/>

### Pydantic 클래스

모델이 Pydantic 객체를 반환하도록 하려면 원하는 Pydantic 클래스를 전달하기만 하면 됩니다. Pydantic을 사용하는 주요 장점은 모델이 생성한 출력이 검증된다는 것입니다. 필수 필드가 누락되거나 잘못된 유형의 필드가 있는 경우 Pydantic은 오류를 발생시킵니다.

```python
from typing import Optional

from langchain_core.pydantic_v1 import BaseModel, Field


# Pydantic
class Joke(BaseModel):
    """Joke to tell user."""

    setup: str = Field(description="The setup of the joke")
    punchline: str = Field(description="The punchline to the joke")
    rating: Optional[int] = Field(
        default=None, description="How funny the joke is, from 1 to 10"
    )


structured_llm = llm.with_structured_output(Joke)

structured_llm.invoke("Tell me a joke about cats")
```


```output
Joke(setup='Why was the cat sitting on the computer?', punchline='Because it wanted to keep an eye on the mouse!', rating=7)
```


:::tip
Pydantic 클래스의 구조 외에도 Pydantic 클래스의 이름, docstring 및 매개변수의 이름과 제공된 설명이 매우 중요합니다. 대부분의 경우 `with_structured_output`는 모델의 함수/도구 호출 API를 사용하고 있으며, 이 모든 정보를 모델 프롬프트에 추가한다고 효과적으로 생각할 수 있습니다.
:::

### TypedDict 또는 JSON 스키마

Pydantic을 사용하고 싶지 않거나 인수 검증을 명시적으로 원하지 않거나 모델 출력을 스트리밍할 수 있기를 원한다면 TypedDict 클래스를 사용하여 스키마를 정의할 수 있습니다. LangChain에서 지원하는 특별한 `Annotated` 구문을 선택적으로 사용할 수 있으며, 이를 통해 필드의 기본값과 설명을 지정할 수 있습니다. 모델이 생성하지 않는 경우 기본값은 자동으로 채워지지 않으며, 모델에 전달되는 스키마를 정의하는 데만 사용됩니다.

:::info 요구 사항

- 코어: `langchain-core>=0.2.26`
- 타이핑 확장: Python 버전 간 일관된 동작을 보장하기 위해 `typing` 대신 `typing_extensions`에서 `Annotated` 및 `TypedDict`를 가져오는 것이 강력히 권장됩니다.

:::

```python
from typing_extensions import Annotated, TypedDict


# TypedDict
class Joke(TypedDict):
    """Joke to tell user."""

    setup: Annotated[str, ..., "The setup of the joke"]

    # Alternatively, we could have specified setup as:

    # setup: str                    # no default, no description
    # setup: Annotated[str, ...]    # no default, no description
    # setup: Annotated[str, "foo"]  # default, no description

    punchline: Annotated[str, ..., "The punchline of the joke"]
    rating: Annotated[Optional[int], None, "How funny the joke is, from 1 to 10"]


structured_llm = llm.with_structured_output(Joke)

structured_llm.invoke("Tell me a joke about cats")
```


```output
{'setup': 'Why was the cat sitting on the computer?',
 'punchline': 'Because it wanted to keep an eye on the mouse!',
 'rating': 7}
```


동일하게, [JSON 스키마](https://json-schema.org/) 사전을 전달할 수 있습니다. 이는 가져오거나 클래스를 필요로 하지 않으며 각 매개변수가 문서화되는 방식이 매우 명확하지만, 약간 더 장황해지는 단점이 있습니다.

```python
json_schema = {
    "title": "joke",
    "description": "Joke to tell user.",
    "type": "object",
    "properties": {
        "setup": {
            "type": "string",
            "description": "The setup of the joke",
        },
        "punchline": {
            "type": "string",
            "description": "The punchline to the joke",
        },
        "rating": {
            "type": "integer",
            "description": "How funny the joke is, from 1 to 10",
            "default": None,
        },
    },
    "required": ["setup", "punchline"],
}
structured_llm = llm.with_structured_output(json_schema)

structured_llm.invoke("Tell me a joke about cats")
```


```output
{'setup': 'Why was the cat sitting on the computer?',
 'punchline': 'Because it wanted to keep an eye on the mouse!',
 'rating': 7}
```


### 여러 스키마 간 선택

모델이 여러 스키마 중에서 선택하도록 하는 가장 간단한 방법은 Union 유형 속성이 있는 부모 스키마를 만드는 것입니다:

```python
from typing import Union


# Pydantic
class Joke(BaseModel):
    """Joke to tell user."""

    setup: str = Field(description="The setup of the joke")
    punchline: str = Field(description="The punchline to the joke")
    rating: Optional[int] = Field(
        default=None, description="How funny the joke is, from 1 to 10"
    )


class ConversationalResponse(BaseModel):
    """Respond in a conversational manner. Be kind and helpful."""

    response: str = Field(description="A conversational response to the user's query")


class Response(BaseModel):
    output: Union[Joke, ConversationalResponse]


structured_llm = llm.with_structured_output(Response)

structured_llm.invoke("Tell me a joke about cats")
```


```output
Response(output=Joke(setup='Why was the cat sitting on the computer?', punchline='To keep an eye on the mouse!', rating=8))
```


```python
structured_llm.invoke("How are you today?")
```


```output
Response(output=ConversationalResponse(response="I'm just a digital assistant, so I don't have feelings, but I'm here and ready to help you. How can I assist you today?"))
```


또는 도구 호출을 직접 사용하여 모델이 옵션 중에서 선택하도록 할 수 있습니다. [선택한 모델이 이를 지원하는 경우](/docs/integrations/chat/) 이 방법은 약간 더 많은 파싱 및 설정이 필요하지만, 중첩된 스키마를 사용할 필요가 없기 때문에 일부 경우에는 더 나은 성능을 제공합니다. 자세한 내용은 [이 사용 안내서](/docs/how_to/tool_calling)를 참조하십시오.

### 스트리밍

출력 유형이 사전일 때(즉, 스키마가 TypedDict 클래스 또는 JSON 스키마 사전으로 지정된 경우) 구조화된 모델에서 출력을 스트리밍할 수 있습니다.

:::info

제공되는 것은 이미 집계된 청크이며, 델타가 아닙니다.

:::

```python
from typing_extensions import Annotated, TypedDict


# TypedDict
class Joke(TypedDict):
    """Joke to tell user."""

    setup: Annotated[str, ..., "The setup of the joke"]
    punchline: Annotated[str, ..., "The punchline of the joke"]
    rating: Annotated[Optional[int], None, "How funny the joke is, from 1 to 10"]


structured_llm = llm.with_structured_output(Joke)

for chunk in structured_llm.stream("Tell me a joke about cats"):
    print(chunk)
```

```output
{}
{'setup': ''}
{'setup': 'Why'}
{'setup': 'Why was'}
{'setup': 'Why was the'}
{'setup': 'Why was the cat'}
{'setup': 'Why was the cat sitting'}
{'setup': 'Why was the cat sitting on'}
{'setup': 'Why was the cat sitting on the'}
{'setup': 'Why was the cat sitting on the computer'}
{'setup': 'Why was the cat sitting on the computer?'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': ''}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on the'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on the mouse'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on the mouse!'}
{'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on the mouse!', 'rating': 7}
```

### Few-shot 프롬프트

더 복잡한 스키마의 경우 프롬프트에 few-shot 예제를 추가하는 것이 매우 유용합니다. 이는 몇 가지 방법으로 수행할 수 있습니다.

가장 간단하고 보편적인 방법은 프롬프트의 시스템 메시지에 예제를 추가하는 것입니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to return structured data from a model"}]-->
from langchain_core.prompts import ChatPromptTemplate

system = """You are a hilarious comedian. Your specialty is knock-knock jokes. \
Return a joke which has the setup (the response to "Who's there?") and the final punchline (the response to "<setup> who?").

Here are some examples of jokes:

example_user: Tell me a joke about planes
example_assistant: {{"setup": "Why don't planes ever get tired?", "punchline": "Because they have rest wings!", "rating": 2}}

example_user: Tell me another joke about planes
example_assistant: {{"setup": "Cargo", "punchline": "Cargo 'vroom vroom', but planes go 'zoom zoom'!", "rating": 10}}

example_user: Now about caterpillars
example_assistant: {{"setup": "Caterpillar", "punchline": "Caterpillar really slow, but watch me turn into a butterfly and steal the show!", "rating": 5}}"""

prompt = ChatPromptTemplate.from_messages([("system", system), ("human", "{input}")])

few_shot_structured_llm = prompt | structured_llm
few_shot_structured_llm.invoke("what's something funny about woodpeckers")
```


```output
{'setup': 'Woodpecker',
 'punchline': "Woodpecker who? Woodpecker who can't find a tree is just a bird with a headache!",
 'rating': 7}
```


출력을 구조화하는 기본 방법이 도구 호출인 경우, 예제를 명시적인 도구 호출로 전달할 수 있습니다. 사용 중인 모델이 API 참조에서 도구 호출을 사용하는지 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to return structured data from a model"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to return structured data from a model"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to return structured data from a model"}]-->
from langchain_core.messages import AIMessage, HumanMessage, ToolMessage

examples = [
    HumanMessage("Tell me a joke about planes", name="example_user"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Why don't planes ever get tired?",
                    "punchline": "Because they have rest wings!",
                    "rating": 2,
                },
                "id": "1",
            }
        ],
    ),
    # Most tool-calling models expect a ToolMessage(s) to follow an AIMessage with tool calls.
    ToolMessage("", tool_call_id="1"),
    # Some models also expect an AIMessage to follow any ToolMessages,
    # so you may need to add an AIMessage here.
    HumanMessage("Tell me another joke about planes", name="example_user"),
    AIMessage(
        "",
        name="example_assistant",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Cargo",
                    "punchline": "Cargo 'vroom vroom', but planes go 'zoom zoom'!",
                    "rating": 10,
                },
                "id": "2",
            }
        ],
    ),
    ToolMessage("", tool_call_id="2"),
    HumanMessage("Now about caterpillars", name="example_user"),
    AIMessage(
        "",
        tool_calls=[
            {
                "name": "joke",
                "args": {
                    "setup": "Caterpillar",
                    "punchline": "Caterpillar really slow, but watch me turn into a butterfly and steal the show!",
                    "rating": 5,
                },
                "id": "3",
            }
        ],
    ),
    ToolMessage("", tool_call_id="3"),
]
system = """You are a hilarious comedian. Your specialty is knock-knock jokes. \
Return a joke which has the setup (the response to "Who's there?") \
and the final punchline (the response to "<setup> who?")."""

prompt = ChatPromptTemplate.from_messages(
    [("system", system), ("placeholder", "{examples}"), ("human", "{input}")]
)
few_shot_structured_llm = prompt | structured_llm
few_shot_structured_llm.invoke({"input": "crocodiles", "examples": examples})
```


```output
{'setup': 'Crocodile',
 'punchline': 'Crocodile be seeing you later, alligator!',
 'rating': 7}
```


도구 호출을 사용할 때 few-shot 프롬프트에 대한 자세한 내용은 [여기](/docs/how_to/function_calling/#Few-shot-prompting)를 참조하십시오.

### (고급) 출력 구조화 방법 지정

출력을 구조화하는 방법이 두 가지 이상인 모델(즉, 도구 호출과 JSON 모드를 모두 지원하는 모델)의 경우 `method=` 인수를 사용하여 사용할 방법을 지정할 수 있습니다.

:::info JSON 모드

JSON 모드를 사용하는 경우 모델 프롬프트에서 원하는 스키마를 여전히 지정해야 합니다. `with_structured_output`에 전달하는 스키마는 모델 출력을 파싱하는 데만 사용되며, 도구 호출과 같은 방식으로 모델에 전달되지 않습니다.

사용 중인 모델이 JSON 모드를 지원하는지 확인하려면 [API 참조](https://api.python.langchain.com/en/latest/langchain_api_reference.html)에서 해당 항목을 확인하십시오.

:::

```python
structured_llm = llm.with_structured_output(None, method="json_mode")

structured_llm.invoke(
    "Tell me a joke about cats, respond in JSON with `setup` and `punchline` keys"
)
```


```output
{'setup': 'Why was the cat sitting on the computer?',
 'punchline': 'Because it wanted to keep an eye on the mouse!'}
```


### (고급) 원시 출력

LLM은 구조화된 출력을 생성하는 데 완벽하지 않으며, 특히 스키마가 복잡해질수록 그렇습니다. 예외를 발생시키지 않고 원시 출출을 직접 처리하려면 `include_raw=True`를 전달하면 됩니다. 이렇게 하면 출력 형식이 원시 메시지 출력, `parsed` 값(성공 시) 및 발생한 오류를 포함하도록 변경됩니다:

```python
structured_llm = llm.with_structured_output(Joke, include_raw=True)

structured_llm.invoke("Tell me a joke about cats")
```


```output
{'raw': AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_f25ZRmh8u5vHlOWfTUw8sJFZ', 'function': {'arguments': '{"setup":"Why was the cat sitting on the computer?","punchline":"Because it wanted to keep an eye on the mouse!","rating":7}', 'name': 'Joke'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 33, 'prompt_tokens': 93, 'total_tokens': 126}, 'model_name': 'gpt-4o-2024-05-13', 'system_fingerprint': 'fp_4e2b2da518', 'finish_reason': 'stop', 'logprobs': None}, id='run-d880d7e2-df08-4e9e-ad92-dfc29f2fd52f-0', tool_calls=[{'name': 'Joke', 'args': {'setup': 'Why was the cat sitting on the computer?', 'punchline': 'Because it wanted to keep an eye on the mouse!', 'rating': 7}, 'id': 'call_f25ZRmh8u5vHlOWfTUw8sJFZ', 'type': 'tool_call'}], usage_metadata={'input_tokens': 93, 'output_tokens': 33, 'total_tokens': 126}),
 'parsed': {'setup': 'Why was the cat sitting on the computer?',
  'punchline': 'Because it wanted to keep an eye on the mouse!',
  'rating': 7},
 'parsing_error': None}
```


## 모델 출력을 직접 프롬프트하고 파싱하기

모든 모델이 `.with_structured_output()`를 지원하는 것은 아니며, 모든 모델이 도구 호출 또는 JSON 모드 지원을 갖춘 것은 아닙니다. 이러한 모델의 경우 모델에 특정 형식을 사용하도록 직접 프롬프트하고, 원시 모델 출력에서 구조화된 응답을 추출하기 위해 출력 파서를 사용해야 합니다.

### `PydanticOutputParser` 사용하기

다음 예제는 주어진 Pydantic 스키마와 일치하도록 프롬프트된 채팅 모델의 출력을 파싱하기 위해 내장된 [`PydanticOutputParser`](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html)를 사용하는 예입니다. 여기서 우리는 파서의 메서드에서 프롬프트에 `format_instructions`를 직접 추가하고 있습니다:

```python
<!--IMPORTS:[{"imported": "PydanticOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html", "title": "How to return structured data from a model"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to return structured data from a model"}]-->
from typing import List

from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field


class Person(BaseModel):
    """Information about a person."""

    name: str = Field(..., description="The name of the person")
    height_in_meters: float = Field(
        ..., description="The height of the person expressed in meters."
    )


class People(BaseModel):
    """Identifying information about all people in a text."""

    people: List[Person]


# Set up a parser
parser = PydanticOutputParser(pydantic_object=People)

# Prompt
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Answer the user query. Wrap the output in `json` tags\n{format_instructions}",
        ),
        ("human", "{query}"),
    ]
).partial(format_instructions=parser.get_format_instructions())
```


모델에 전송되는 정보는 다음과 같습니다:

```python
query = "Anna is 23 years old and she is 6 feet tall"

print(prompt.invoke(query).to_string())
```

```output
System: Answer the user query. Wrap the output in `json` tags
The output should be formatted as a JSON instance that conforms to the JSON schema below.

As an example, for the schema {"properties": {"foo": {"title": "Foo", "description": "a list of strings", "type": "array", "items": {"type": "string"}}}, "required": ["foo"]}
the object {"foo": ["bar", "baz"]} is a well-formatted instance of the schema. The object {"properties": {"foo": ["bar", "baz"]}} is not well-formatted.

Here is the output schema:
```

{"description": "텍스트에 있는 모든 사람에 대한 식별 정보.", "properties": {"people": {"title": "사람들", "type": "array", "items": {"$ref": "#/definitions/Person"}}}, "required": ["people"], "definitions": {"Person": {"title": "사람", "description": "사람에 대한 정보.", "type": "object", "properties": {"name": {"title": "이름", "description": "사람의 이름", "type": "string"}, "height_in_meters": {"title": "미터 단위의 높이", "description": "미터로 표현된 사람의 높이.", "type": "number"}}, "required": ["name", "height_in_meters"]}}}
```
Human: Anna is 23 years old and she is 6 feet tall
```

이제 이를 호출해 보겠습니다:

```python
chain = prompt | llm | parser

chain.invoke({"query": query})
```


```output
People(people=[Person(name='Anna', height_in_meters=1.8288)])
```


구조화된 출력을 위한 프롬프트 기술과 함께 출력 파서를 사용하는 방법에 대한 더 깊은 내용을 보려면 [이 가이드](/docs/how_to/output_parser_structured)를 참조하십시오.

### 사용자 지정 파싱

또한 [LangChain 표현 언어(LCEL)](/docs/concepts/#langchain-expression-language)을 사용하여 모델의 출력을 파싱하는 일반 함수를 사용하여 사용자 지정 프롬프트와 파서를 만들 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to return structured data from a model"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to return structured data from a model"}]-->
import json
import re
from typing import List

from langchain_core.messages import AIMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field


class Person(BaseModel):
    """Information about a person."""

    name: str = Field(..., description="The name of the person")
    height_in_meters: float = Field(
        ..., description="The height of the person expressed in meters."
    )


class People(BaseModel):
    """Identifying information about all people in a text."""

    people: List[Person]


# Prompt
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Answer the user query. Output your answer as JSON that  "
            "matches the given schema: ```json\n{schema}\n```. "
            "Make sure to wrap the answer in ```json and ``` tags",
        ),
        ("human", "{query}"),
    ]
).partial(schema=People.schema())


# Custom parser
def extract_json(message: AIMessage) -> List[dict]:
    """Extracts JSON content from a string where JSON is embedded between ```json and ``` tags.

    Parameters:
        text (str): The text containing the JSON content.

    Returns:
        list: A list of extracted JSON strings.
    """
    text = message.content
    # Define the regular expression pattern to match JSON blocks
    pattern = r"```json(.*?)```"

    # Find all non-overlapping matches of the pattern in the string
    matches = re.findall(pattern, text, re.DOTALL)

    # Return the list of matched JSON strings, stripping any leading or trailing whitespace
    try:
        return [json.loads(match.strip()) for match in matches]
    except Exception:
        raise ValueError(f"Failed to parse: {message}")
```


모델에 전송된 프롬프트는 다음과 같습니다:

```python
query = "Anna is 23 years old and she is 6 feet tall"

print(prompt.format_prompt(query=query).to_string())
```

```output
System: Answer the user query. Output your answer as JSON that  matches the given schema: ```json
{'title': 'People', 'description': 'Identifying information about all people in a text.', 'type': 'object', 'properties': {'people': {'title': 'People', 'type': 'array', 'items': {'$ref': '#/definitions/Person'}}}, 'required': ['people'], 'definitions': {'Person': {'title': 'Person', 'description': 'Information about a person.', 'type': 'object', 'properties': {'name': {'title': 'Name', 'description': 'The name of the person', 'type': 'string'}, 'height_in_meters': {'title': 'Height In Meters', 'description': 'The height of the person expressed in meters.', 'type': 'number'}}, 'required': ['name', 'height_in_meters']}}}
```. Make sure to wrap the answer in ```json and ``` tags
Human: Anna is 23 years old and she is 6 feet tall
```

이를 호출할 때의 모습은 다음과 같습니다:

```python
chain = prompt | llm | extract_json

chain.invoke({"query": query})
```


```output
[{'people': [{'name': 'Anna', 'height_in_meters': 1.8288}]}]
```