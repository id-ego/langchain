---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_no_queries.ipynb
description: 쿼리가 생성되지 않는 경우를 처리하는 방법에 대한 문서로, 쿼리 분석 및 검색 호출 여부를 결정하는 방법을 설명합니다.
sidebar_position: 3
---

# 쿼리가 생성되지 않는 경우 처리 방법

때때로 쿼리 분석 기술은 쿼리가 생성될 수 있는 모든 수를 허용할 수 있습니다 - 쿼리가 전혀 생성되지 않는 경우도 포함해서요! 이 경우, 우리의 전체 체인은 쿼리 분석의 결과를 검사한 후 리트리버를 호출할지 여부를 결정해야 합니다.

이 예제에서는 모의 데이터를 사용할 것입니다.

## 설정
#### 의존성 설치

```python
# %pip install -qU langchain langchain-community langchain-openai langchain-chroma
```


#### 환경 변수 설정

이 예제에서는 OpenAI를 사용할 것입니다:

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Optional, uncomment to trace runs with LangSmith. Sign up here: https://smith.langchain.com.
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


### 인덱스 생성

우리는 가짜 정보를 기반으로 벡터 스토어를 생성할 것입니다.

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to handle cases where no queries are generated"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to handle cases where no queries are generated"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to handle cases where no queries are generated"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

texts = ["Harrison worked at Kensho"]
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_texts(
    texts,
    embeddings,
)
retriever = vectorstore.as_retriever()
```


## 쿼리 분석

우리는 함수 호출을 사용하여 출력을 구조화할 것입니다. 그러나 우리는 LLM을 구성하여 검색 쿼리를 나타내는 함수를 반드시 호출할 필요가 없도록 할 것입니다 (그렇게 결정하지 않는 경우). 우리는 또한 언제 검색을 해야 하고 하지 말아야 하는지를 명시적으로 설명하는 프롬프트를 사용하여 쿼리 분석을 수행할 것입니다.

```python
from typing import Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Search(BaseModel):
    """Search over a database of job records."""

    query: str = Field(
        ...,
        description="Similarity search query applied to job record.",
    )
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to handle cases where no queries are generated"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to handle cases where no queries are generated"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to handle cases where no queries are generated"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

system = """You have the ability to issue search queries to get information to help answer user information.

You do not NEED to look things up. If you don't need to, then just respond normally."""
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm = llm.bind_tools([Search])
query_analyzer = {"question": RunnablePassthrough()} | prompt | structured_llm
```


이것을 호출함으로써 때때로 - 그러나 항상은 아닌 - 도구 호출을 반환하는 메시지를 얻을 수 있음을 알 수 있습니다.

```python
query_analyzer.invoke("where did Harrison Work")
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_ZnoVX4j9Mn8wgChaORyd1cvq', 'function': {'arguments': '{"query":"Harrison"}', 'name': 'Search'}, 'type': 'function'}]})
```


```python
query_analyzer.invoke("hi!")
```


```output
AIMessage(content='Hello! How can I assist you today?')
```


## 쿼리 분석을 통한 검색

그렇다면 이것을 체인에 어떻게 포함시킬 수 있을까요? 아래 예제를 살펴보겠습니다.

```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers.openai_tools", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "How to handle cases where no queries are generated"}, {"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to handle cases where no queries are generated"}]-->
from langchain_core.output_parsers.openai_tools import PydanticToolsParser
from langchain_core.runnables import chain

output_parser = PydanticToolsParser(tools=[Search])
```


```python
@chain
def custom_chain(question):
    response = query_analyzer.invoke(question)
    if "tool_calls" in response.additional_kwargs:
        query = output_parser.invoke(response)
        docs = retriever.invoke(query[0].query)
        # Could add more logic - like another LLM call - here
        return docs
    else:
        return response
```


```python
custom_chain.invoke("where did Harrison Work")
```

```output
Number of requested results 4 is greater than number of elements in index 1, updating n_results = 1
```


```output
[Document(page_content='Harrison worked at Kensho')]
```


```python
custom_chain.invoke("hi!")
```


```output
AIMessage(content='Hello! How can I assist you today?')
```