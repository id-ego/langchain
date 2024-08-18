---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_few_shot.ipynb
description: 쿼리 분석을 개선하기 위해 LangChain YouTube 비디오 쿼리 분석기에 예제를 추가하는 방법을 설명합니다.
sidebar_position: 2
---

# 쿼리 분석을 위한 프롬프트에 예제 추가하는 방법

쿼리 분석이 복잡해짐에 따라 LLM은 특정 시나리오에서 어떻게 응답해야 하는지 이해하는 데 어려움을 겪을 수 있습니다. 여기서 성능을 개선하기 위해 LLM을 안내하는 예제를 프롬프트에 추가할 수 있습니다.

우리가 [Quickstart](/docs/tutorials/query_analysis)에서 구축한 LangChain YouTube 비디오 쿼리 분석기를 위한 예제를 추가하는 방법을 살펴보겠습니다.

## 설정
#### 종속성 설치

```python
# %pip install -qU langchain-core langchain-openai
```


#### 환경 변수 설정

이번 예제에서는 OpenAI를 사용할 것입니다:

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Optional, uncomment to trace runs with LangSmith. Sign up here: https://smith.langchain.com.
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 쿼리 스키마

모델이 출력하기를 원하는 쿼리 스키마를 정의할 것입니다. 쿼리 분석을 좀 더 흥미롭게 만들기 위해, 최상위 질문에서 파생된 더 좁은 질문을 포함하는 `sub_queries` 필드를 추가할 것입니다.

```python
from typing import List, Optional

from langchain_core.pydantic_v1 import BaseModel, Field

sub_queries_description = """\
If the original question contains multiple distinct sub-questions, \
or if there are more generic questions that would be helpful to answer in \
order to answer the original question, write a list of all relevant sub-questions. \
Make sure this list is comprehensive and covers all parts of the original question. \
It's ok if there's redundancy in the sub-questions. \
Make sure the sub-questions are as narrowly focused as possible."""


class Search(BaseModel):
    """Search over a database of tutorial videos about a software library."""

    query: str = Field(
        ...,
        description="Primary similarity search query applied to video transcripts.",
    )
    sub_queries: List[str] = Field(
        default_factory=list, description=sub_queries_description
    )
    publish_year: Optional[int] = Field(None, description="Year video was published")
```


## 쿼리 생성

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add examples to the prompt for query analysis"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

system = """You are an expert at converting user questions into database queries. \
You have access to a database of tutorial videos about a software library for building LLM-powered applications. \
Given a question, return a list of database queries optimized to retrieve the most relevant results.

If there are acronyms or words you are not familiar with, do not try to rephrase them."""

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        MessagesPlaceholder("examples", optional=True),
        ("human", "{question}"),
    ]
)
llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm = llm.with_structured_output(Search)
query_analyzer = {"question": RunnablePassthrough()} | prompt | structured_llm
```


프롬프트에 예제 없이 쿼리 분석기를 시도해 보겠습니다:

```python
query_analyzer.invoke(
    "what's the difference between web voyager and reflection agents? do both use langgraph?"
)
```


```output
Search(query='web voyager vs reflection agents', sub_queries=['difference between web voyager and reflection agents', 'do web voyager and reflection agents use langgraph'], publish_year=None)
```


## 예제 추가 및 프롬프트 조정

이것은 꽤 잘 작동하지만, 아마도 웹 탐색기와 반사 에이전트에 대한 쿼리를 분리하기 위해 질문을 더 세분화하기를 원할 것입니다.

쿼리 생성 결과를 조정하기 위해, 프롬프트에 입력 질문과 금 표준 출력 쿼리의 몇 가지 예제를 추가할 수 있습니다.

```python
examples = []
```


```python
question = "What's chat langchain, is it a langchain template?"
query = Search(
    query="What is chat langchain and is it a langchain template?",
    sub_queries=["What is chat langchain", "What is a langchain template"],
)
examples.append({"input": question, "tool_calls": [query]})
```


```python
question = "How to build multi-agent system and stream intermediate steps from it"
query = Search(
    query="How to build multi-agent system and stream intermediate steps from it",
    sub_queries=[
        "How to build multi-agent system",
        "How to stream intermediate steps from multi-agent system",
        "How to stream intermediate steps",
    ],
)

examples.append({"input": question, "tool_calls": [query]})
```


```python
question = "LangChain agents vs LangGraph?"
query = Search(
    query="What's the difference between LangChain agents and LangGraph? How do you deploy them?",
    sub_queries=[
        "What are LangChain agents",
        "What is LangGraph",
        "How do you deploy LangChain agents",
        "How do you deploy LangGraph",
    ],
)
examples.append({"input": question, "tool_calls": [query]})
```


이제 각 프롬프트에 예제가 포함되도록 프롬프트 템플릿과 체인을 업데이트해야 합니다. OpenAI 함수 호출을 사용하고 있으므로, 모델에 예제 입력 및 출력을 전송하기 위해 약간의 추가 구조가 필요합니다. 이를 처리하기 위해 `tool_example_to_messages` 도우미 함수를 생성할 것입니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to add examples to the prompt for query analysis"}, {"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to add examples to the prompt for query analysis"}]-->
import uuid
from typing import Dict

from langchain_core.messages import (
    AIMessage,
    BaseMessage,
    HumanMessage,
    SystemMessage,
    ToolMessage,
)


def tool_example_to_messages(example: Dict) -> List[BaseMessage]:
    messages: List[BaseMessage] = [HumanMessage(content=example["input"])]
    openai_tool_calls = []
    for tool_call in example["tool_calls"]:
        openai_tool_calls.append(
            {
                "id": str(uuid.uuid4()),
                "type": "function",
                "function": {
                    "name": tool_call.__class__.__name__,
                    "arguments": tool_call.json(),
                },
            }
        )
    messages.append(
        AIMessage(content="", additional_kwargs={"tool_calls": openai_tool_calls})
    )
    tool_outputs = example.get("tool_outputs") or [
        "You have correctly called this tool."
    ] * len(openai_tool_calls)
    for output, tool_call in zip(tool_outputs, openai_tool_calls):
        messages.append(ToolMessage(content=output, tool_call_id=tool_call["id"]))
    return messages


example_msgs = [msg for ex in examples for msg in tool_example_to_messages(ex)]
```


```python
<!--IMPORTS:[{"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to add examples to the prompt for query analysis"}]-->
from langchain_core.prompts import MessagesPlaceholder

query_analyzer_with_examples = (
    {"question": RunnablePassthrough()}
    | prompt.partial(examples=example_msgs)
    | structured_llm
)
```


```python
query_analyzer_with_examples.invoke(
    "what's the difference between web voyager and reflection agents? do both use langgraph?"
)
```


```output
Search(query='Difference between web voyager and reflection agents, do they both use LangGraph?', sub_queries=['What is Web Voyager', 'What are Reflection agents', 'Do Web Voyager and Reflection agents use LangGraph'], publish_year=None)
```


예제 덕분에 우리는 약간 더 세분화된 검색 쿼리를 얻습니다. 더 많은 프롬프트 엔지니어링과 예제 조정을 통해 쿼리 생성을 더욱 개선할 수 있습니다.

예제가 [LangSmith trace](https://smith.langchain.com/public/aeaaafce-d2b1-4943-9a61-bc954e8fc6f2/r)에서 메시지로 모델에 전달되는 것을 볼 수 있습니다.