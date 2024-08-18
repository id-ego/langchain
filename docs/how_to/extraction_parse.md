---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/extraction_parse.ipynb
description: LLM을 활용하여 도구 호출 없이 정보를 추출하는 방법과 PydanticOutputParser를 사용하는 예제를 제공합니다.
---

# 프롬프트만 사용하여 추출하는 방법 (도구 호출 없음)

도구 호출 기능은 LLM에서 구조화된 출력을 생성하는 데 필요하지 않습니다. 프롬프트 지침을 잘 따르는 LLM은 주어진 형식으로 정보를 출력하는 작업을 수행할 수 있습니다.

이 접근 방식은 좋은 프롬프트를 설계하고 LLM의 출력을 파싱하여 정보를 잘 추출하도록 하는 데 의존합니다.

도구 호출 기능 없이 데이터를 추출하려면:

1. LLM에게 예상 형식(예: 특정 스키마가 있는 JSON)에 따라 텍스트를 생성하도록 지시합니다;
2. [출력 파서](/docs/concepts#output-parsers)를 사용하여 모델 응답을 원하는 Python 객체로 구조화합니다.

먼저 LLM을 선택합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="model" />

:::tip
이 튜토리얼은 간단하게 구성되어 있지만, 일반적으로 성능을 극대화하기 위해 참조 예제를 포함해야 합니다!
:::

## PydanticOutputParser 사용하기

다음 예제는 채팅 모델의 출력을 파싱하기 위해 내장된 `PydanticOutputParser`를 사용합니다.

```python
<!--IMPORTS:[{"imported": "PydanticOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html", "title": "How to use prompting alone (no tool calling) to do extraction"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use prompting alone (no tool calling) to do extraction"}]-->
from typing import List, Optional

from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field, validator


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


모델에 전송되는 정보가 무엇인지 살펴보겠습니다.

```python
query = "Anna is 23 years old and she is 6 feet tall"
```


```python
print(prompt.format_prompt(query=query).to_string())
```

```output
System: Answer the user query. Wrap the output in `json` tags
The output should be formatted as a JSON instance that conforms to the JSON schema below.

As an example, for the schema {"properties": {"foo": {"title": "Foo", "description": "a list of strings", "type": "array", "items": {"type": "string"}}}, "required": ["foo"]}
the object {"foo": ["bar", "baz"]} is a well-formatted instance of the schema. The object {"properties": {"foo": ["bar", "baz"]}} is not well-formatted.

Here is the output schema:
```

{"description": "텍스트에 있는 모든 사람에 대한 식별 정보.", "properties": {"people": {"title": "사람들", "type": "array", "items": {"$ref": "#/definitions/Person"}}}, "required": ["people"], "definitions": {"Person": {"title": "사람", "description": "사람에 대한 정보.", "type": "object", "properties": {"name": {"title": "이름", "description": "사람의 이름", "type": "string"}, "height_in_meters": {"title": "미터 단위의 키", "description": "미터로 표현된 사람의 키.", "type": "number"}}, "required": ["name", "height_in_meters"]}}}
```
Human: Anna is 23 years old and she is 6 feet tall
```

프롬프트를 정의한 후, 프롬프트, 모델 및 출력 파서를 간단히 연결합니다:

```python
chain = prompt | model | parser
chain.invoke({"query": query})
```


```output
People(people=[Person(name='Anna', height_in_meters=1.83)])
```


관련된 [Langsmith trace](https://smith.langchain.com/public/92ed52a3-92b9-45af-a663-0a9c00e5e396/r)를 확인하세요.

스키마는 두 곳에서 나타납니다:

1. 프롬프트에서 `parser.get_format_instructions()`를 통해;
2. 체인에서 형식화된 출력을 수신하고 이를 Python 객체(이 경우 Pydantic 객체 `People`)로 구조화하기 위해.

## 사용자 정의 파싱

원하는 경우, `LangChain` 및 `LCEL`을 사용하여 사용자 정의 프롬프트와 파서를 쉽게 만들 수 있습니다.

사용자 정의 파서를 만들려면, 모델의 출력을 선택한 객체로 파싱하는 함수를 정의합니다(일반적으로 [AIMessage](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html)입니다).

아래는 JSON 파서의 간단한 구현을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to use prompting alone (no tool calling) to do extraction"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to use prompting alone (no tool calling) to do extraction"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use prompting alone (no tool calling) to do extraction"}]-->
import json
import re
from typing import List, Optional

from langchain_anthropic.chat_models import ChatAnthropic
from langchain_core.messages import AIMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field, validator


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


```python
chain = prompt | model | extract_json
chain.invoke({"query": query})
```


```output
[{'people': [{'name': 'Anna', 'height_in_meters': 1.83}]}]
```


## 기타 라이브러리

파싱 접근 방식을 사용하여 추출하려는 경우, [Kor](https://eyurtsev.github.io/kor/) 라이브러리를 확인하세요. 이 라이브러리는 `LangChain` 유지 관리자의 한 명이 작성하였으며, 예제를 고려한 프롬프트를 작성하고 형식(예: JSON 또는 CSV)을 제어하며 TypeScript로 스키마를 표현하는 데 도움을 줍니다. 꽤 잘 작동하는 것 같습니다!