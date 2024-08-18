---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/myscale_self_query.ipynb
description: MyScale은 SQL과 LangChain을 통해 접근할 수 있는 통합 벡터 데이터베이스로, LLM 앱의 성능을 향상시킵니다.
---

# MyScale

> [MyScale](https://docs.myscale.com/en/)는 통합 벡터 데이터베이스입니다. SQL에서 데이터베이스에 접근할 수 있으며, 여기 LangChain에서도 접근할 수 있습니다.  
`MyScale`은 [필터를 위한 다양한 데이터 유형과 함수](https://blog.myscale.com/2023/06/06/why-integrated-database-solution-can-boost-your-llm-apps/#filter-on-anything-without-constraints)를 활용할 수 있습니다. 데이터 규모를 확장하든 시스템을 더 넓은 애플리케이션으로 확장하든, LLM 앱을 향상시킬 것입니다.

노트북에서는 LangChain에 기여한 몇 가지 추가 요소와 함께 `MyScale` 벡터 저장소를 감싼 `SelfQueryRetriever`를 시연할 것입니다.

간단히 4가지 요점으로 요약할 수 있습니다:
1. 여러 요소가 일치할 경우 목록을 일치시키기 위해 `contain` 비교자를 추가합니다.
2. 날짜 일치를 위한 `timestamp` 데이터 유형을 추가합니다 (ISO 형식 또는 YYYY-MM-DD).
3. 문자열 패턴 검색을 위한 `like` 비교자를 추가합니다.
4. 임의의 함수 기능을 추가합니다.

## MyScale 벡터 저장소 생성하기
MyScale은 이미 LangChain에 통합되어 있습니다. 따라서 [이 노트북](/docs/integrations/vectorstores/myscale)을 따라 자기 쿼리 검색기를 위한 벡터 저장소를 생성할 수 있습니다.

**참고:** 모든 자기 쿼리 검색기에는 `lark`가 설치되어 있어야 합니다 (`pip install lark`). 우리는 문법 정의를 위해 `lark`를 사용합니다. 다음 단계로 진행하기 전에, `MyScale` 백엔드와 상호작용하기 위해 `clickhouse-connect`도 필요하다는 점을 상기시켜 드립니다.

```python
%pip install --upgrade --quiet  lark clickhouse-connect
```


이 튜토리얼에서는 다른 예제의 설정을 따르고 `OpenAIEmbeddings`를 사용합니다. LLM에 유효하게 접근하기 위해 OpenAI API 키를 받는 것을 잊지 마세요.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
os.environ["MYSCALE_HOST"] = getpass.getpass("MyScale URL:")
os.environ["MYSCALE_PORT"] = getpass.getpass("MyScale Port:")
os.environ["MYSCALE_USERNAME"] = getpass.getpass("MyScale Username:")
os.environ["MYSCALE_PASSWORD"] = getpass.getpass("MyScale Password:")
```


```python
<!--IMPORTS:[{"imported": "MyScale", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.myscale.MyScale.html", "title": "MyScale"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "MyScale"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "MyScale"}]-->
from langchain_community.vectorstores import MyScale
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
```


## 샘플 데이터 생성하기
보시다시피, 우리가 생성한 데이터는 다른 자기 쿼리 검색기와 비교할 때 몇 가지 차이점이 있습니다. 우리는 키워드 `year`를 `date`로 교체하여 타임스탬프에 대한 세밀한 제어를 제공합니다. 또한 키워드 `gerne`의 유형을 문자열 목록으로 변경하여 LLM이 새로운 `contain` 비교자를 사용하여 필터를 구성할 수 있도록 했습니다. 우리는 또한 필터에 `like` 비교자와 임의 함수 지원을 제공하며, 이는 다음 몇 개의 셀에서 소개될 것입니다.

이제 먼저 데이터를 살펴보겠습니다.

```python
docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={"date": "1993-07-02", "rating": 7.7, "genre": ["science fiction"]},
    ),
    Document(
        page_content="Leo DiCaprio gets lost in a dream within a dream within a dream within a ...",
        metadata={"date": "2010-12-30", "director": "Christopher Nolan", "rating": 8.2},
    ),
    Document(
        page_content="A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea",
        metadata={"date": "2006-04-23", "director": "Satoshi Kon", "rating": 8.6},
    ),
    Document(
        page_content="A bunch of normal-sized women are supremely wholesome and some men pine after them",
        metadata={"date": "2019-08-22", "director": "Greta Gerwig", "rating": 8.3},
    ),
    Document(
        page_content="Toys come alive and have a blast doing so",
        metadata={"date": "1995-02-11", "genre": ["animated"]},
    ),
    Document(
        page_content="Three men walk into the Zone, three men walk out of the Zone",
        metadata={
            "date": "1979-09-10",
            "director": "Andrei Tarkovsky",
            "genre": ["science fiction", "adventure"],
            "rating": 9.9,
        },
    ),
]
vectorstore = MyScale.from_documents(
    docs,
    embeddings,
)
```


## 자기 쿼리 검색기 생성하기
다른 검색기와 마찬가지로... 간단하고 멋집니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "MyScale"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "MyScale"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "MyScale"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import ChatOpenAI

metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genres of the movie. "
        "It only supports equal and contain comparisons. "
        "Here are some examples: genre = [' A '], genre = [' A ', 'B'], contain (genre, 'A')",
        type="list[string]",
    ),
    # If you want to include length of a list, just define it as a new column
    # This will teach the LLM to use it as a column when constructing filter.
    AttributeInfo(
        name="length(genre)",
        description="The length of genres of the movie",
        type="integer",
    ),
    # Now you can define a column as timestamp. By simply set the type to timestamp.
    AttributeInfo(
        name="date",
        description="The date the movie was released",
        type="timestamp",
    ),
    AttributeInfo(
        name="director",
        description="The name of the movie director",
        type="string",
    ),
    AttributeInfo(
        name="rating", description="A 1-10 rating for the movie", type="float"
    ),
]
document_content_description = "Brief summary of a movie"
llm = ChatOpenAI(temperature=0, model_name="gpt-4o")
retriever = SelfQueryRetriever.from_llm(
    llm, vectorstore, document_content_description, metadata_field_info, verbose=True
)
```


## 자기 쿼리 검색기의 기존 기능으로 테스트하기
이제 실제로 우리의 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are some movies about dinosaurs")
```


```python
# This example only specifies a filter
retriever.invoke("I want to watch a movie rated higher than 8.5")
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about toys, and preferably is animated"
)
```


# 잠깐만... 또 무엇이 있을까요?

MyScale과 함께하는 자기 쿼리 검색기는 더 많은 기능을 수행할 수 있습니다! 알아봅시다.

```python
# You can use length(genres) to do anything you want
retriever.invoke("What's a movie that have more than 1 genres?")
```


```python
# Fine-grained datetime? You got it already.
retriever.invoke("What's a movie that release after feb 1995?")
```


```python
# Don't know what your exact filter should be? Use string pattern match!
retriever.invoke("What's a movie whose name is like Andrei?")
```


```python
# Contain works for lists: so you can match a list with contain comparator!
retriever.invoke("What's a movie who has genres science fiction and adventure?")
```


## k 필터

자기 쿼리 검색기를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

이는 생성자에게 `enable_limit=True`를 전달하여 수행할 수 있습니다.

```python
retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
    enable_limit=True,
    verbose=True,
)
```


```python
# This example only specifies a relevant query
retriever.invoke("what are two movies about dinosaurs")
```