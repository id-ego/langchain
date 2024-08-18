---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_high_cardinality.ipynb
description: 고차원 범주형 데이터를 쿼리 분석할 때의 어려움과 해결 방법을 다루는 문서입니다. LLM을 활용한 접근 방식을 설명합니다.
sidebar_position: 7
---

# 고차원 범주형 데이터 처리 방법

쿼리 분석을 통해 범주형 열에 대한 필터를 생성하고자 할 수 있습니다. 여기서의 어려움 중 하나는 일반적으로 정확한 범주형 값을 지정해야 한다는 것입니다. 문제는 LLM이 그 범주형 값을 정확히 생성하도록 해야 한다는 것입니다. 유효한 값이 몇 개 없을 때는 프롬프트를 사용하여 상대적으로 쉽게 할 수 있습니다. 그러나 유효한 값이 많아지면 LLM의 컨텍스트에 맞지 않거나 (맞더라도) LLM이 제대로 처리하기에는 너무 많아지는 경우가 발생합니다.

이 노트북에서는 이를 접근하는 방법을 살펴보겠습니다.

## 설정
#### 의존성 설치

```python
# %pip install -qU langchain langchain-community langchain-openai faker langchain-chroma
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


#### 데이터 설정

우리는 많은 가짜 이름을 생성할 것입니다.

```python
from faker import Faker

fake = Faker()

names = [fake.name() for _ in range(10000)]
```


이름 몇 개를 살펴보겠습니다.

```python
names[0]
```


```output
'Hayley Gonzalez'
```


```python
names[567]
```


```output
'Jesse Knight'
```


## 쿼리 분석

이제 기본 쿼리 분석을 설정할 수 있습니다.

```python
from langchain_core.pydantic_v1 import BaseModel, Field
```


```python
class Search(BaseModel):
    query: str
    author: str
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How deal with high cardinality categoricals when doing query analysis"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How deal with high cardinality categoricals when doing query analysis"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How deal with high cardinality categoricals when doing query analysis"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

system = """Generate a relevant search query for a library system"""
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

이름을 정확하게 맞추면 LLM이 이를 처리하는 방법을 알고 있음을 알 수 있습니다.

```python
query_analyzer.invoke("what are books about aliens by Jesse Knight")
```


```output
Search(query='books about aliens', author='Jesse Knight')
```


문제는 필터링하려는 값이 정확하게 맞지 않을 수 있다는 것입니다.

```python
query_analyzer.invoke("what are books about aliens by jess knight")
```


```output
Search(query='books about aliens', author='Jess Knight')
```


### 모든 값 추가하기

이 문제를 해결하는 한 가지 방법은 프롬프트에 가능한 모든 값을 추가하는 것입니다. 이는 일반적으로 쿼리를 올바른 방향으로 안내합니다.

```python
system = """Generate a relevant search query for a library system.

`author` attribute MUST be one of:

{authors}

Do NOT hallucinate author name!"""
base_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
prompt = base_prompt.partial(authors=", ".join(names))
```


```python
query_analyzer_all = {"question": RunnablePassthrough()} | prompt | structured_llm
```


그러나... 범주형 목록이 충분히 길면 오류가 발생할 수 있습니다!

```python
try:
    res = query_analyzer_all.invoke("what are books about aliens by jess knight")
except Exception as e:
    print(e)
```

```output
Error code: 400 - {'error': {'message': "This model's maximum context length is 16385 tokens. However, your messages resulted in 33885 tokens (33855 in the messages, 30 in the functions). Please reduce the length of the messages or functions.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
```

더 긴 컨텍스트 창을 사용할 수 있지만, 너무 많은 정보가 포함되어 있어 신뢰성 있게 인식할 수 없을 수도 있습니다.

```python
llm_long = ChatOpenAI(model="gpt-4-turbo-preview", temperature=0)
structured_llm_long = llm_long.with_structured_output(Search)
query_analyzer_all = {"question": RunnablePassthrough()} | prompt | structured_llm_long
```


```python
query_analyzer_all.invoke("what are books about aliens by jess knight")
```


```output
Search(query='aliens', author='Kevin Knight')
```


### 관련 값 찾기

대신, 관련 값에 대한 인덱스를 생성한 다음 N개의 가장 관련성 높은 값을 쿼리할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How deal with high cardinality categoricals when doing query analysis"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How deal with high cardinality categoricals when doing query analysis"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_texts(names, embeddings, collection_name="author_names")
```


```python
def select_names(question):
    _docs = vectorstore.similarity_search(question, k=10)
    _names = [d.page_content for d in _docs]
    return ", ".join(_names)
```


```python
create_prompt = {
    "question": RunnablePassthrough(),
    "authors": select_names,
} | base_prompt
```


```python
query_analyzer_select = create_prompt | structured_llm
```


```python
create_prompt.invoke("what are books by jess knight")
```


```output
ChatPromptValue(messages=[SystemMessage(content='Generate a relevant search query for a library system.\n\n`author` attribute MUST be one of:\n\nJesse Knight, Kelly Knight, Scott Knight, Richard Knight, Andrew Knight, Katherine Knight, Erica Knight, Ashley Knight, Becky Knight, Kevin Knight\n\nDo NOT hallucinate author name!'), HumanMessage(content='what are books by jess knight')])
```


```python
query_analyzer_select.invoke("what are books about aliens by jess knight")
```


```output
Search(query='books about aliens', author='Jesse Knight')
```


### 선택 후 교체하기

또 다른 방법은 LLM이 어떤 값을 입력하도록 한 다음, 그 값을 유효한 값으로 변환하는 것입니다. 이는 실제로 Pydantic 클래스 자체로 수행할 수 있습니다!

```python
from langchain_core.pydantic_v1 import validator


class Search(BaseModel):
    query: str
    author: str

    @validator("author")
    def double(cls, v: str) -> str:
        return vectorstore.similarity_search(v, k=1)[0].page_content
```


```python
system = """Generate a relevant search query for a library system"""
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
corrective_structure_llm = llm.with_structured_output(Search)
corrective_query_analyzer = (
    {"question": RunnablePassthrough()} | prompt | corrective_structure_llm
)
```


```python
corrective_query_analyzer.invoke("what are books about aliens by jes knight")
```


```output
Search(query='books about aliens', author='Jesse Knight')
```


```python
# TODO: show trigram similarity
```