---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_multiple_queries.ipynb
description: 쿼리 분석 시 여러 쿼리를 처리하는 방법을 설명하고, 결과를 결합하는 간단한 예제를 제공합니다.
sidebar_position: 4
---

# 여러 쿼리를 처리하는 방법: 쿼리 분석 시

때때로, 쿼리 분석 기법은 여러 쿼리를 생성할 수 있게 합니다. 이러한 경우, 모든 쿼리를 실행하고 결과를 결합해야 한다는 것을 기억해야 합니다. 이를 수행하는 간단한 예시(모의 데이터를 사용)를 보여드리겠습니다.

## 설정
#### 의존성 설치

```python
# %pip install -qU langchain langchain-community langchain-openai langchain-chroma
```


#### 환경 변수 설정

이번 예시에서는 OpenAI를 사용할 것입니다:

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Optional, uncomment to trace runs with LangSmith. Sign up here: https://smith.langchain.com.
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


### 인덱스 생성

우리는 가짜 정보를 기반으로 벡터 저장소를 생성할 것입니다.

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to handle multiple queries when doing query analysis"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to handle multiple queries when doing query analysis"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to handle multiple queries when doing query analysis"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

texts = ["Harrison worked at Kensho", "Ankush worked at Facebook"]
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_texts(
    texts,
    embeddings,
)
retriever = vectorstore.as_retriever(search_kwargs={"k": 1})
```


## 쿼리 분석

우리는 함수 호출을 사용하여 출력을 구조화할 것입니다. 여러 쿼리를 반환하도록 하겠습니다.

```python
from typing import List, Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Search(BaseModel):
    """Search over a database of job records."""

    queries: List[str] = Field(
        ...,
        description="Distinct queries to search for",
    )
```


```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers.openai_tools", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "How to handle multiple queries when doing query analysis"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to handle multiple queries when doing query analysis"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to handle multiple queries when doing query analysis"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to handle multiple queries when doing query analysis"}]-->
from langchain_core.output_parsers.openai_tools import PydanticToolsParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

output_parser = PydanticToolsParser(tools=[Search])

system = """You have the ability to issue search queries to get information to help answer user information.

If you need to look up two distinct pieces of information, you are allowed to do that!"""
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

```output
/Users/harrisonchase/workplace/langchain/libs/core/langchain_core/_api/beta_decorator.py:86: LangChainBetaWarning: The function `with_structured_output` is in beta. It is actively being worked on, so the API may change.
  warn_beta(
```

이렇게 하면 여러 쿼리를 생성할 수 있음을 알 수 있습니다.

```python
query_analyzer.invoke("where did Harrison Work")
```


```output
Search(queries=['Harrison work location'])
```


```python
query_analyzer.invoke("where did Harrison and ankush Work")
```


```output
Search(queries=['Harrison work place', 'Ankush work place'])
```


## 쿼리 분석을 통한 검색

그렇다면 이것을 체인에 어떻게 포함할 수 있을까요? 이를 훨씬 쉽게 만드는 한 가지 방법은 리트리버를 비동기적으로 호출하는 것입니다. 이렇게 하면 쿼리를 반복하면서 응답 시간에 차단되지 않을 수 있습니다.

```python
<!--IMPORTS:[{"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to handle multiple queries when doing query analysis"}]-->
from langchain_core.runnables import chain
```


```python
@chain
async def custom_chain(question):
    response = await query_analyzer.ainvoke(question)
    docs = []
    for query in response.queries:
        new_docs = await retriever.ainvoke(query)
        docs.extend(new_docs)
    # You probably want to think about reranking or deduplicating documents here
    # But that is a separate topic
    return docs
```


```python
await custom_chain.ainvoke("where did Harrison Work")
```


```output
[Document(page_content='Harrison worked at Kensho')]
```


```python
await custom_chain.ainvoke("where did Harrison and ankush Work")
```


```output
[Document(page_content='Harrison worked at Kensho'),
 Document(page_content='Ankush worked at Facebook')]
```