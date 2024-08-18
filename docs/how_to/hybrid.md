---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/hybrid.ipynb
description: 하이브리드 검색은 벡터 유사성 검색과 다른 검색 기술을 결합하여 더 정교한 검색을 가능하게 합니다. LangChain에서의
  사용법을 안내합니다.
---

# 하이브리드 검색

LangChain의 표준 검색은 벡터 유사성에 의해 수행됩니다. 그러나 여러 벡터 저장소 구현(Astra DB, ElasticSearch, Neo4J, AzureSearch, Qdrant 등)은 벡터 유사성 검색과 다른 검색 기술(전체 텍스트, BM25 등)을 결합한 보다 고급 검색을 지원합니다. 이것은 일반적으로 "하이브리드" 검색이라고 합니다.

**1단계: 사용 중인 벡터 저장소가 하이브리드 검색을 지원하는지 확인하세요**

현재 LangChain에서 하이브리드 검색을 수행하는 통일된 방법은 없습니다. 각 벡터 저장소는 이를 수행하는 고유한 방법이 있을 수 있습니다. 이는 일반적으로 `similarity_search` 중에 전달되는 키워드 인수로 노출됩니다.

문서나 소스 코드를 읽어 사용 중인 벡터 저장소가 하이브리드 검색을 지원하는지, 그렇다면 어떻게 사용하는지 확인하세요.

**2단계: 해당 매개변수를 체인의 구성 가능한 필드로 추가하세요**

이렇게 하면 체인을 쉽게 호출하고 런타임에 관련 플래그를 구성할 수 있습니다. 구성에 대한 자세한 정보는 [이 문서](/docs/how_to/configure)를 참조하세요.

**3단계: 해당 구성 가능한 필드로 체인을 호출하세요**

이제 런타임에 이 체인을 구성 가능한 필드로 호출할 수 있습니다.

## 코드 예제

이 코드에서 이것이 어떻게 보이는지 구체적인 예를 살펴보겠습니다. 이 예제에서는 Astra DB의 Cassandra/CQL 인터페이스를 사용할 것입니다.

다음 Python 패키지를 설치하세요:

```python
!pip install "cassio>=0.1.7"
```


[연결 비밀](https://docs.datastax.com/en/astra/astra-db-vector/get-started/quickstart.html)을 가져옵니다.

cassio를 초기화합니다:

```python
import cassio

cassio.init(
    database_id="Your database ID",
    token="Your application token",
    keyspace="Your key space",
)
```


표준 [인덱스 분석기](https://docs.datastax.com/en/astra/astra-db-vector/cql/use-analyzers-with-cql.html)를 사용하여 Cassandra VectorStore를 생성합니다. 인덱스 분석기는 용어 일치를 활성화하는 데 필요합니다.

```python
<!--IMPORTS:[{"imported": "Cassandra", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.cassandra.Cassandra.html", "title": "Hybrid Search"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Hybrid Search"}]-->
from cassio.table.cql import STANDARD_ANALYZER
from langchain_community.vectorstores import Cassandra
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
vectorstore = Cassandra(
    embedding=embeddings,
    table_name="test_hybrid",
    body_index_options=[STANDARD_ANALYZER],
    session=None,
    keyspace=None,
)

vectorstore.add_texts(
    [
        "In 2023, I visited Paris",
        "In 2022, I visited New York",
        "In 2021, I visited New Orleans",
    ]
)
```


표준 유사성 검색을 수행하면 모든 문서를 얻습니다:

```python
vectorstore.as_retriever().invoke("What city did I visit last?")
```


```output
[Document(page_content='In 2022, I visited New York'),
Document(page_content='In 2023, I visited Paris'),
Document(page_content='In 2021, I visited New Orleans')]
```


Astra DB 벡터 저장소의 `body_search` 인수를 사용하여 `new` 용어에 대한 검색을 필터링할 수 있습니다.

```python
vectorstore.as_retriever(search_kwargs={"body_search": "new"}).invoke(
    "What city did I visit last?"
)
```


```output
[Document(page_content='In 2022, I visited New York'),
Document(page_content='In 2021, I visited New Orleans')]
```


이제 질문-응답을 수행하는 데 사용할 체인을 생성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Hybrid Search"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Hybrid Search"}, {"imported": "ConfigurableField", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html", "title": "Hybrid Search"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Hybrid Search"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Hybrid Search"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import (
    ConfigurableField,
    RunnablePassthrough,
)
from langchain_openai import ChatOpenAI
```


이것은 기본 질문-응답 체인 설정입니다.

```python
template = """Answer the question based only on the following context:
{context}
Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

model = ChatOpenAI()

retriever = vectorstore.as_retriever()
```


여기에서 검색기를 구성 가능한 필드로 표시합니다. 모든 벡터 저장소 검색기는 `search_kwargs`를 필드로 가집니다. 이는 벡터 저장소 특정 필드가 있는 단순한 사전입니다.

```python
configurable_retriever = retriever.configurable_fields(
    search_kwargs=ConfigurableField(
        id="search_kwargs",
        name="Search Kwargs",
        description="The search kwargs to use",
    )
)
```


이제 구성 가능한 검색기를 사용하여 체인을 생성할 수 있습니다.

```python
chain = (
    {"context": configurable_retriever, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)
```


```python
chain.invoke("What city did I visit last?")
```


```output
Paris
```


이제 구성 가능한 옵션으로 체인을 호출할 수 있습니다. `search_kwargs`는 구성 가능한 필드의 ID입니다. 값은 Astra DB에 사용할 검색 kwargs입니다.

```python
chain.invoke(
    "What city did I visit last?",
    config={"configurable": {"search_kwargs": {"body_search": "new"}}},
)
```


```output
New York
```