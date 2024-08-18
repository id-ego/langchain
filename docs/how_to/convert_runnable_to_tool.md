---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/convert_runnable_to_tool.ipynb
description: 이 가이드는 LangChain의 Runnable을 에이전트, 체인 또는 채팅 모델에서 사용할 수 있는 도구로 변환하는 방법을
  설명합니다.
---

# Runnables를 도구로 변환하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [Runnables](/docs/concepts#runnable-interface)
- [Tools](/docs/concepts#tools)
- [Agents](/docs/tutorials/agents)

:::

여기에서는 LangChain `Runnable`을 에이전트, 체인 또는 채팅 모델에서 사용할 수 있는 도구로 변환하는 방법을 시연합니다.

## 의존성

**참고**: 이 가이드는 `langchain-core` >= 0.2.13을 요구합니다. 우리는 임베딩을 위해 [OpenAI](/docs/integrations/platforms/openai/)를 사용할 것이지만, 어떤 LangChain 임베딩도 충분합니다. 시연을 위해 간단한 [LangGraph](https://langchain-ai.github.io/langgraph/) 에이전트를 사용할 것입니다.

```python
%%capture --no-stderr
%pip install -U langchain-core langchain-openai langgraph
```


LangChain [tools](/docs/concepts#tools)는 에이전트, 체인 또는 채팅 모델이 세계와 상호작용하는 데 사용할 수 있는 인터페이스입니다. 도구 호출, 내장 도구, 사용자 정의 도구 및 기타 정보에 대한 가이드는 [여기](/docs/how_to/#tools)에서 확인하세요.

LangChain 도구-- [BaseTool](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.BaseTool.html)의 인스턴스--는 언어 모델에 의해 효과적으로 호출될 수 있도록 추가 제약이 있는 [Runnables](/docs/concepts/#runnable-interface)입니다:

- 입력은 직렬화 가능해야 하며, 특히 문자열 및 Python `dict` 객체로 제한됩니다;
- 사용 방법과 시점을 나타내는 이름과 설명을 포함합니다;
- 인수에 대한 자세한 [args_schema](https://python.langchain.com/v0.2/docs/how_to/custom_tools/)를 포함할 수 있습니다. 즉, 도구(즉, `Runnable`)가 단일 `dict` 입력을 수용할 수 있지만, dict를 채우는 데 필요한 특정 키와 유형 정보는 `args_schema`에 명시되어야 합니다.

문자열 또는 `dict` 입력을 수용하는 Runnables는 [as_tool](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.as_tool) 메서드를 사용하여 도구로 변환할 수 있으며, 이를 통해 이름, 설명 및 인수에 대한 추가 스키마 정보를 지정할 수 있습니다.

## 기본 사용법

타입이 지정된 `dict` 입력으로:

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to convert Runnables as Tools"}]-->
from typing import List

from langchain_core.runnables import RunnableLambda
from typing_extensions import TypedDict


class Args(TypedDict):
    a: int
    b: List[int]


def f(x: Args) -> str:
    return str(x["a"] * max(x["b"]))


runnable = RunnableLambda(f)
as_tool = runnable.as_tool(
    name="My tool",
    description="Explanation of when to use tool.",
)
```


```python
print(as_tool.description)

as_tool.args_schema.schema()
```

```output
Explanation of when to use tool.
```


```output
{'title': 'My tool',
 'type': 'object',
 'properties': {'a': {'title': 'A', 'type': 'integer'},
  'b': {'title': 'B', 'type': 'array', 'items': {'type': 'integer'}}},
 'required': ['a', 'b']}
```


```python
as_tool.invoke({"a": 3, "b": [1, 2]})
```


```output
'6'
```


타입 정보 없이 `arg_types`를 통해 인수 유형을 지정할 수 있습니다:

```python
from typing import Any, Dict


def g(x: Dict[str, Any]) -> str:
    return str(x["a"] * max(x["b"]))


runnable = RunnableLambda(g)
as_tool = runnable.as_tool(
    name="My tool",
    description="Explanation of when to use tool.",
    arg_types={"a": int, "b": List[int]},
)
```


대안으로, 도구에 대한 원하는 [args_schema](https://api.python.langchain.com/en/latest/tools/langchain_core.tools.BaseTool.html#langchain_core.tools.BaseTool.args_schema)를 직접 전달하여 스키마를 완전히 지정할 수 있습니다:

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class GSchema(BaseModel):
    """Apply a function to an integer and list of integers."""

    a: int = Field(..., description="Integer")
    b: List[int] = Field(..., description="List of ints")


runnable = RunnableLambda(g)
as_tool = runnable.as_tool(GSchema)
```


문자열 입력도 지원됩니다:

```python
def f(x: str) -> str:
    return x + "a"


def g(x: str) -> str:
    return x + "z"


runnable = RunnableLambda(f) | g
as_tool = runnable.as_tool()
```


```python
as_tool.invoke("b")
```


```output
'baz'
```


## 에이전트에서

아래에서는 LangChain Runnables를 [agent](/docs/concepts/#agents) 애플리케이션의 도구로 통합할 것입니다. 우리는 다음을 시연할 것입니다:

- 문서 [retriever](/docs/concepts/#retrievers);
- 에이전트가 관련 쿼리를 위임할 수 있도록 하는 간단한 [RAG](/docs/tutorials/rag/) 체인.

먼저 도구 호출을 지원하는 채팅 모델을 인스턴스화합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

[RAG 튜토리얼](/docs/tutorials/rag/)에 따라 먼저 리트리버를 구성해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to convert Runnables as Tools"}, {"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "How to convert Runnables as Tools"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to convert Runnables as Tools"}]-->
from langchain_core.documents import Document
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_openai import OpenAIEmbeddings

documents = [
    Document(
        page_content="Dogs are great companions, known for their loyalty and friendliness.",
    ),
    Document(
        page_content="Cats are independent pets that often enjoy their own space.",
    ),
]

vectorstore = InMemoryVectorStore.from_documents(
    documents, embedding=OpenAIEmbeddings()
)

retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 1},
)
```


그 다음, 간단한 미리 구축된 [LangGraph agent](https://python.langchain.com/v0.2/docs/tutorials/agents/)를 생성하고 도구를 제공합니다:

```python
from langgraph.prebuilt import create_react_agent

tools = [
    retriever.as_tool(
        name="pet_info_retriever",
        description="Get information about pets.",
    )
]
agent = create_react_agent(llm, tools)
```


```python
for chunk in agent.stream({"messages": [("human", "What are dogs known for?")]}):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_W8cnfOjwqEn4cFcg19LN9mYD', 'function': {'arguments': '{"__arg1":"dogs"}', 'name': 'pet_info_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 19, 'prompt_tokens': 60, 'total_tokens': 79}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-d7f81de9-1fb7-4caf-81ed-16dcdb0b2ab4-0', tool_calls=[{'name': 'pet_info_retriever', 'args': {'__arg1': 'dogs'}, 'id': 'call_W8cnfOjwqEn4cFcg19LN9mYD'}], usage_metadata={'input_tokens': 60, 'output_tokens': 19, 'total_tokens': 79})]}}
----
{'tools': {'messages': [ToolMessage(content="[Document(id='86f835fe-4bbe-4ec6-aeb4-489a8b541707', page_content='Dogs are great companions, known for their loyalty and friendliness.')]", name='pet_info_retriever', tool_call_id='call_W8cnfOjwqEn4cFcg19LN9mYD')]}}
----
{'agent': {'messages': [AIMessage(content='Dogs are known for being great companions, known for their loyalty and friendliness.', response_metadata={'token_usage': {'completion_tokens': 18, 'prompt_tokens': 134, 'total_tokens': 152}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-9ca5847a-a5eb-44c0-a774-84cc2c5bbc5b-0', usage_metadata={'input_tokens': 134, 'output_tokens': 18, 'total_tokens': 152})]}}
----
```

위 실행에 대한 [LangSmith trace](https://smith.langchain.com/public/44e438e3-2faf-45bd-b397-5510fc145eb9/r)를 참조하세요.

더 나아가, 추가 매개변수-- 여기서는 "답변의 스타일"을 사용하는 간단한 [RAG](/docs/tutorials/rag/) 체인을 생성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to convert Runnables as Tools"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to convert Runnables as Tools"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to convert Runnables as Tools"}]-->
from operator import itemgetter

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

system_prompt = """
You are an assistant for question-answering tasks.
Use the below context to answer the question. If
you don't know the answer, say you don't know.
Use three sentences maximum and keep the answer
concise.

Answer in the style of {answer_style}.

Question: {question}

Context: {context}
"""

prompt = ChatPromptTemplate.from_messages([("system", system_prompt)])

rag_chain = (
    {
        "context": itemgetter("question") | retriever,
        "question": itemgetter("question"),
        "answer_style": itemgetter("answer_style"),
    }
    | prompt
    | llm
    | StrOutputParser()
)
```


체인에 대한 입력 스키마에는 필수 인수가 포함되어 있으므로 추가 사양 없이 도구로 변환됩니다:

```python
rag_chain.input_schema.schema()
```


```output
{'title': 'RunnableParallel<context,question,answer_style>Input',
 'type': 'object',
 'properties': {'question': {'title': 'Question'},
  'answer_style': {'title': 'Answer Style'}}}
```


```python
rag_tool = rag_chain.as_tool(
    name="pet_expert",
    description="Get information about pets.",
)
```


아래에서 다시 에이전트를 호출합니다. 에이전트가 `tool_calls`에 필수 매개변수를 채우는 것을 주목하세요:

```python
agent = create_react_agent(llm, [rag_tool])

for chunk in agent.stream(
    {"messages": [("human", "What would a pirate say dogs are known for?")]}
):
    print(chunk)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_17iLPWvOD23zqwd1QVQ00Y63', 'function': {'arguments': '{"question":"What are dogs known for according to pirates?","answer_style":"quote"}', 'name': 'pet_expert'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 28, 'prompt_tokens': 59, 'total_tokens': 87}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-7fef44f3-7bba-4e63-8c51-2ad9c5e65e2e-0', tool_calls=[{'name': 'pet_expert', 'args': {'question': 'What are dogs known for according to pirates?', 'answer_style': 'quote'}, 'id': 'call_17iLPWvOD23zqwd1QVQ00Y63'}], usage_metadata={'input_tokens': 59, 'output_tokens': 28, 'total_tokens': 87})]}}
----
{'tools': {'messages': [ToolMessage(content='"Dogs are known for their loyalty and friendliness, making them great companions for pirates on long sea voyages."', name='pet_expert', tool_call_id='call_17iLPWvOD23zqwd1QVQ00Y63')]}}
----
{'agent': {'messages': [AIMessage(content='According to pirates, dogs are known for their loyalty and friendliness, making them great companions for pirates on long sea voyages.', response_metadata={'token_usage': {'completion_tokens': 27, 'prompt_tokens': 119, 'total_tokens': 146}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-5a30edc3-7be0-4743-b980-ca2f8cad9b8d-0', usage_metadata={'input_tokens': 119, 'output_tokens': 27, 'total_tokens': 146})]}}
----
```

위 실행에 대한 [LangSmith trace](https://smith.langchain.com/public/147ae4e6-4dfb-4dd9-8ca0-5c5b954f08ac/r)를 참조하세요.