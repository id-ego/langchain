---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/extraction_examples.ipynb
description: 이 문서는 LLM을 활용한 데이터 추출에서 참조 예제를 사용하는 방법과 도구 호출 모델의 활용을 안내합니다.
---

# 참조 예제를 사용하여 추출하는 방법

추출의 품질은 종종 LLM에 참조 예제를 제공함으로써 향상될 수 있습니다.

데이터 추출은 텍스트 및 기타 비구조적 또는 반구조적 형식에서 발견된 정보의 구조화된 표현을 생성하려고 시도합니다. [도구 호출](/docs/concepts#functiontool-calling) LLM 기능은 종종 이 맥락에서 사용됩니다. 이 가이드는 추출 및 유사한 애플리케이션의 행동을 유도하는 데 도움이 되는 도구 호출의 몇 가지 예를 만드는 방법을 보여줍니다.

:::tip
이 가이드는 도구 호출 모델과 함께 예제를 사용하는 방법에 중점을 두지만, 이 기술은 일반적으로 적용 가능하며 JSON 또는 프롬프트 기반 기술에서도 작동합니다.
:::

LangChain은 도구 호출을 포함하는 LLM의 메시지에 [tool-call 속성](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html#langchain_core.messages.ai.AIMessage.tool_calls)을 구현합니다. 데이터 추출을 위한 참조 예제를 만들기 위해, 우리는 다음의 순서를 포함하는 채팅 기록을 구축합니다:

- [HumanMessage](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html) 예제 입력을 포함;
- [AIMessage](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html) 예제 도구 호출을 포함;
- [ToolMessage](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html) 예제 도구 출력을 포함.

LangChain은 LLM 모델 제공자 간의 대화에서 도구 호출을 구조화하기 위해 이 관습을 채택합니다.

먼저 이러한 메시지에 대한 자리 표시자가 포함된 프롬프트 템플릿을 만듭니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use reference examples when doing extraction"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to use reference examples when doing extraction"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

# Define a custom prompt to provide instructions and any additional context.
# 1) You can add examples into the prompt template to improve extraction quality
# 2) Introduce additional parameters to take context into account (e.g., include metadata
#    about the document from which the text was extracted.)
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an expert extraction algorithm. "
            "Only extract relevant information from the text. "
            "If you do not know the value of an attribute asked "
            "to extract, return null for the attribute's value.",
        ),
        # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        MessagesPlaceholder("examples"),  # <-- EXAMPLES!
        # ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
        ("human", "{text}"),
    ]
)
```


템플릿을 테스트해 보세요:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to use reference examples when doing extraction"}]-->
from langchain_core.messages import (
    HumanMessage,
)

prompt.invoke(
    {"text": "this is some text", "examples": [HumanMessage(content="testing 1 2 3")]}
)
```


```output
ChatPromptValue(messages=[SystemMessage(content="You are an expert extraction algorithm. Only extract relevant information from the text. If you do not know the value of an attribute asked to extract, return null for the attribute's value."), HumanMessage(content='testing 1 2 3'), HumanMessage(content='this is some text')])
```


## 스키마 정의

[추출 튜토리얼](/docs/tutorials/extraction)에서 사람 스키마를 재사용해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use reference examples when doing extraction"}]-->
from typing import List, Optional

from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_openai import ChatOpenAI


class Person(BaseModel):
    """Information about a person."""

    # ^ Doc-string for the entity Person.
    # This doc-string is sent to the LLM as the description of the schema Person,
    # and it can help to improve extraction results.

    # Note that:
    # 1. Each field is an `optional` -- this allows the model to decline to extract it!
    # 2. Each field has a `description` -- this description is used by the LLM.
    # Having a good description can help improve extraction results.
    name: Optional[str] = Field(..., description="The name of the person")
    hair_color: Optional[str] = Field(
        ..., description="The color of the person's hair if known"
    )
    height_in_meters: Optional[str] = Field(..., description="Height in METERs")


class Data(BaseModel):
    """Extracted data about people."""

    # Creates a model so that we can extract multiple entities.
    people: List[Person]
```


## 참조 예제 정의

예제는 입력-출력 쌍의 목록으로 정의할 수 있습니다.

각 예제는 예제 `input` 텍스트와 텍스트에서 추출해야 할 내용을 보여주는 예제 `output`을 포함합니다.

:::important
이 부분은 다소 복잡하므로 건너뛰셔도 됩니다.

예제의 형식은 사용되는 API와 일치해야 합니다 (예: 도구 호출 또는 JSON 모드 등).

여기서 형식화된 예제는 우리가 사용하고 있는 도구 호출 API에서 기대되는 형식과 일치합니다.
:::

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to use reference examples when doing extraction"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to use reference examples when doing extraction"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to use reference examples when doing extraction"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to use reference examples when doing extraction"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to use reference examples when doing extraction"}]-->
import uuid
from typing import Dict, List, TypedDict

from langchain_core.messages import (
    AIMessage,
    BaseMessage,
    HumanMessage,
    SystemMessage,
    ToolMessage,
)
from langchain_core.pydantic_v1 import BaseModel, Field


class Example(TypedDict):
    """A representation of an example consisting of text input and expected tool calls.

    For extraction, the tool calls are represented as instances of pydantic model.
    """

    input: str  # This is the example text
    tool_calls: List[BaseModel]  # Instances of pydantic model that should be extracted


def tool_example_to_messages(example: Example) -> List[BaseMessage]:
    """Convert an example into a list of messages that can be fed into an LLM.

    This code is an adapter that converts our example to a list of messages
    that can be fed into a chat model.

    The list of messages per example corresponds to:

    1) HumanMessage: contains the content from which content should be extracted.
    2) AIMessage: contains the extracted information from the model
    3) ToolMessage: contains confirmation to the model that the model requested a tool correctly.

    The ToolMessage is required because some of the chat models are hyper-optimized for agents
    rather than for an extraction use case.
    """
    messages: List[BaseMessage] = [HumanMessage(content=example["input"])]
    tool_calls = []
    for tool_call in example["tool_calls"]:
        tool_calls.append(
            {
                "id": str(uuid.uuid4()),
                "args": tool_call.dict(),
                # The name of the function right now corresponds
                # to the name of the pydantic model
                # This is implicit in the API right now,
                # and will be improved over time.
                "name": tool_call.__class__.__name__,
            },
        )
    messages.append(AIMessage(content="", tool_calls=tool_calls))
    tool_outputs = example.get("tool_outputs") or [
        "You have correctly called this tool."
    ] * len(tool_calls)
    for output, tool_call in zip(tool_outputs, tool_calls):
        messages.append(ToolMessage(content=output, tool_call_id=tool_call["id"]))
    return messages
```


다음으로 우리의 예제를 정의한 후 메시지 형식으로 변환해 보겠습니다.

```python
examples = [
    (
        "The ocean is vast and blue. It's more than 20,000 feet deep. There are many fish in it.",
        Data(people=[]),
    ),
    (
        "Fiona traveled far from France to Spain.",
        Data(people=[Person(name="Fiona", height_in_meters=None, hair_color=None)]),
    ),
]


messages = []

for text, tool_call in examples:
    messages.extend(
        tool_example_to_messages({"input": text, "tool_calls": [tool_call]})
    )
```


프롬프트를 테스트해 보겠습니다.

```python
example_prompt = prompt.invoke({"text": "this is some text", "examples": messages})

for message in example_prompt.messages:
    print(f"{message.type}: {message}")
```

```output
system: content="You are an expert extraction algorithm. Only extract relevant information from the text. If you do not know the value of an attribute asked to extract, return null for the attribute's value."
human: content="The ocean is vast and blue. It's more than 20,000 feet deep. There are many fish in it."
ai: content='' tool_calls=[{'name': 'Person', 'args': {'name': None, 'hair_color': None, 'height_in_meters': None}, 'id': 'b843ba77-4c9c-48ef-92a4-54e534f24521'}]
tool: content='You have correctly called this tool.' tool_call_id='b843ba77-4c9c-48ef-92a4-54e534f24521'
human: content='Fiona traveled far from France to Spain.'
ai: content='' tool_calls=[{'name': 'Person', 'args': {'name': 'Fiona', 'hair_color': None, 'height_in_meters': None}, 'id': '46f00d6b-50e5-4482-9406-b07bb10340f6'}]
tool: content='You have correctly called this tool.' tool_call_id='46f00d6b-50e5-4482-9406-b07bb10340f6'
human: content='this is some text'
```


## 추출기 생성

LLM을 선택해 보겠습니다. 도구 호출을 사용하고 있기 때문에 도구 호출 기능을 지원하는 모델이 필요합니다. 사용 가능한 LLM에 대한 [이 표](/docs/integrations/chat)를 참조하세요.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
openaiParams={`model="gpt-4-0125-preview", temperature=0`}
/>

[추출 튜토리얼](/docs/tutorials/extraction)을 따르면서, 우리는 `.with_structured_output` 메서드를 사용하여 원하는 스키마에 따라 모델 출력을 구조화합니다:

```python
runnable = prompt | llm.with_structured_output(
    schema=Data,
    method="function_calling",
    include_raw=False,
)
```


## 예제 없이 😿

유능한 모델조차도 **매우 간단한** 테스트 사례에서 실패할 수 있음을 주목하세요!

```python
for _ in range(5):
    text = "The solar system is large, but earth has only 1 moon."
    print(runnable.invoke({"text": text, "examples": []}))
```

```output
people=[Person(name='earth', hair_color='null', height_in_meters='null')]
people=[Person(name='earth', hair_color='null', height_in_meters='null')]
people=[]
people=[Person(name='earth', hair_color='null', height_in_meters='null')]
people=[]
```


## 예제와 함께 😻

참조 예제가 실패를 수정하는 데 도움이 됩니다!

```python
for _ in range(5):
    text = "The solar system is large, but earth has only 1 moon."
    print(runnable.invoke({"text": text, "examples": messages}))
```

```output
people=[]
people=[]
people=[]
people=[]
people=[]
```


우리는 몇 가지 샷 예제를 [Langsmith trace](https://smith.langchain.com/public/4c436bc2-a1ce-440b-82f5-093947542e40/r)에서 도구 호출로 확인할 수 있습니다.

그리고 긍정적인 샘플에서 성능을 유지합니다:

```python
runnable.invoke(
    {
        "text": "My name is Harrison. My hair is black.",
        "examples": messages,
    }
)
```


```output
Data(people=[Person(name='Harrison', hair_color='black', height_in_meters=None)])
```