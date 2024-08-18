---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_multiple_retrievers.ipynb
description: 쿼리 분석 시 여러 검색기를 처리하는 방법에 대한 간단한 예제와 로직 선택을 통한 검색기 라우팅을 설명합니다.
sidebar_position: 5
---

# 여러 리트리버를 처리하는 방법: 쿼리 분석

때때로 쿼리 분석 기법은 사용할 리트리버를 선택할 수 있게 해줍니다. 이를 사용하기 위해서는 사용할 리트리버를 선택하는 로직을 추가해야 합니다. 우리는 이를 수행하는 간단한 예제를 보여줄 것입니다 (모의 데이터를 사용하여).

## 설정
#### 의존성 설치

```python
# %pip install -qU langchain langchain-community langchain-openai langchain-chroma
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


### 인덱스 생성

우리는 가짜 정보를 기반으로 벡터 스토어를 생성할 것입니다.

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to handle multiple retrievers when doing query analysis"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to handle multiple retrievers when doing query analysis"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to handle multiple retrievers when doing query analysis"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

texts = ["Harrison worked at Kensho"]
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_texts(texts, embeddings, collection_name="harrison")
retriever_harrison = vectorstore.as_retriever(search_kwargs={"k": 1})

texts = ["Ankush worked at Facebook"]
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_texts(texts, embeddings, collection_name="ankush")
retriever_ankush = vectorstore.as_retriever(search_kwargs={"k": 1})
```


## 쿼리 분석

우리는 함수 호출을 사용하여 출력을 구조화할 것입니다. 우리는 여러 쿼리를 반환하도록 할 것입니다.

```python
from typing import List, Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Search(BaseModel):
    """Search for information about a person."""

    query: str = Field(
        ...,
        description="Query to look up",
    )
    person: str = Field(
        ...,
        description="Person to look things up for. Should be `HARRISON` or `ANKUSH`.",
    )
```


```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers.openai_tools", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "How to handle multiple retrievers when doing query analysis"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to handle multiple retrievers when doing query analysis"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to handle multiple retrievers when doing query analysis"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to handle multiple retrievers when doing query analysis"}]-->
from langchain_core.output_parsers.openai_tools import PydanticToolsParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

output_parser = PydanticToolsParser(tools=[Search])

system = """You have the ability to issue search queries to get information to help answer user information."""
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm = llm.with_structured_output(Search)
query_analyzer = {"question": RunnablePassthrough()} | prompt | structured_llm
```


이것이 리트리버 간의 라우팅을 가능하게 한다는 것을 볼 수 있습니다.

```python
query_analyzer.invoke("where did Harrison Work")
```


```output
Search(query='workplace', person='HARRISON')
```


```python
query_analyzer.invoke("where did ankush Work")
```


```output
Search(query='workplace', person='ANKUSH')
```


## 쿼리 분석을 통한 검색

그렇다면 이것을 체인에 어떻게 포함할 수 있을까요? 우리는 리트리버를 선택하고 검색 쿼리를 전달하기 위한 간단한 로직이 필요합니다.

```python
<!--IMPORTS:[{"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to handle multiple retrievers when doing query analysis"}]-->
from langchain_core.runnables import chain
```


```python
retrievers = {
    "HARRISON": retriever_harrison,
    "ANKUSH": retriever_ankush,
}
```


```python
@chain
def custom_chain(question):
    response = query_analyzer.invoke(question)
    retriever = retrievers[response.person]
    return retriever.invoke(response.query)
```


```python
custom_chain.invoke("where did Harrison Work")
```


```output
[Document(page_content='Harrison worked at Kensho')]
```


```python
custom_chain.invoke("where did ankush Work")
```


```output
[Document(page_content='Ankush worked at Facebook')]
```