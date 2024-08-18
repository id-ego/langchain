---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/redis_self_query.ipynb
description: Redis는 캐시, 메시지 브로커, 데이터베이스 등으로 사용 가능한 오픈 소스 키-값 저장소입니다. 이 문서에서는 Redis
  벡터 저장소를 활용한 SelfQueryRetriever를 시연합니다.
---

# Redis

> [Redis](https://redis.com)는 캐시, 메시지 브로커, 데이터베이스, 벡터 데이터베이스 등으로 사용할 수 있는 오픈 소스 키-값 저장소입니다.

노트북에서는 `Redis` 벡터 저장소 주위에 래핑된 `SelfQueryRetriever`를 시연할 것입니다.

## Redis 벡터 저장소 만들기
먼저 Redis 벡터 저장소를 만들고 일부 데이터로 초기화해야 합니다. 우리는 영화 요약을 포함하는 작은 데모 문서 세트를 만들었습니다.

**참고:** 자기 쿼리 검색기는 `lark`가 설치되어 있어야 합니다(`pip install lark`) 및 통합 특정 요구 사항과 함께.

```python
%pip install --upgrade --quiet  redis redisvl langchain-openai tiktoken lark
```


`OpenAIEmbeddings`를 사용하고 싶으므로 OpenAI API 키를 가져와야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


```python
<!--IMPORTS:[{"imported": "Redis", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.redis.base.Redis.html", "title": "Redis"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Redis"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Redis"}]-->
from langchain_community.vectorstores import Redis
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
```


```python
docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={
            "year": 1993,
            "rating": 7.7,
            "director": "Steven Spielberg",
            "genre": "science fiction",
        },
    ),
    Document(
        page_content="Leo DiCaprio gets lost in a dream within a dream within a dream within a ...",
        metadata={
            "year": 2010,
            "director": "Christopher Nolan",
            "genre": "science fiction",
            "rating": 8.2,
        },
    ),
    Document(
        page_content="A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea",
        metadata={
            "year": 2006,
            "director": "Satoshi Kon",
            "genre": "science fiction",
            "rating": 8.6,
        },
    ),
    Document(
        page_content="A bunch of normal-sized women are supremely wholesome and some men pine after them",
        metadata={
            "year": 2019,
            "director": "Greta Gerwig",
            "genre": "drama",
            "rating": 8.3,
        },
    ),
    Document(
        page_content="Toys come alive and have a blast doing so",
        metadata={
            "year": 1995,
            "director": "John Lasseter",
            "genre": "animated",
            "rating": 9.1,
        },
    ),
    Document(
        page_content="Three men walk into the Zone, three men walk out of the Zone",
        metadata={
            "year": 1979,
            "rating": 9.9,
            "director": "Andrei Tarkovsky",
            "genre": "science fiction",
        },
    ),
]
```


```python
index_schema = {
    "tag": [{"name": "genre"}],
    "text": [{"name": "director"}],
    "numeric": [{"name": "year"}, {"name": "rating"}],
}

vectorstore = Redis.from_documents(
    docs,
    embeddings,
    redis_url="redis://localhost:6379",
    index_name="movie_reviews",
    index_schema=index_schema,
)
```

```output
`index_schema` does not match generated metadata schema.
If you meant to manually override the schema, please ignore this message.
index_schema: {'tag': [{'name': 'genre'}], 'text': [{'name': 'director'}], 'numeric': [{'name': 'year'}, {'name': 'rating'}]}
generated_schema: {'text': [{'name': 'director'}, {'name': 'genre'}], 'numeric': [{'name': 'year'}, {'name': 'rating'}], 'tag': []}
```

## 자기 쿼리 검색기 만들기
이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명을 제공해야 합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "Redis"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "Redis"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Redis"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import OpenAI

metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genre of the movie",
        type="string or list[string]",
    ),
    AttributeInfo(
        name="year",
        description="The year the movie was released",
        type="integer",
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
```


```python
llm = OpenAI(temperature=0)
retriever = SelfQueryRetriever.from_llm(
    llm, vectorstore, document_content_description, metadata_field_info, verbose=True
)
```


## 테스트해보기
이제 실제로 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are some movies about dinosaurs")
```

```output
/Users/bagatur/langchain/libs/langchain/langchain/chains/llm.py:278: UserWarning: The predict_and_parse method is deprecated, instead pass an output parser directly to LLMChain.
  warnings.warn(
``````output
query='dinosaur' filter=None limit=None
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'id': 'doc:movie_reviews:7b5481d753bc4135851b66fa61def7fb', 'director': 'Steven Spielberg', 'genre': 'science fiction', 'year': '1993', 'rating': '7.7'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'id': 'doc:movie_reviews:9e4e84daa0374941a6aa4274e9bbb607', 'director': 'John Lasseter', 'genre': 'animated', 'year': '1995', 'rating': '9.1'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'id': 'doc:movie_reviews:2cc66f38bfbd438eb3a045d90a1a4088', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'year': '1979', 'rating': '9.9'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'id': 'doc:movie_reviews:edf567b1d5334e02b2a4c692d853c80c', 'director': 'Satoshi Kon', 'genre': 'science fiction', 'year': '2006', 'rating': '8.6'})]
```


```python
# This example only specifies a filter
retriever.invoke("I want to watch a movie rated higher than 8.4")
```

```output
query=' ' filter=Comparison(comparator=<Comparator.GT: 'gt'>, attribute='rating', value=8.4) limit=None
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'id': 'doc:movie_reviews:9e4e84daa0374941a6aa4274e9bbb607', 'director': 'John Lasseter', 'genre': 'animated', 'year': '1995', 'rating': '9.1'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'id': 'doc:movie_reviews:2cc66f38bfbd438eb3a045d90a1a4088', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'year': '1979', 'rating': '9.9'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'id': 'doc:movie_reviews:edf567b1d5334e02b2a4c692d853c80c', 'director': 'Satoshi Kon', 'genre': 'science fiction', 'year': '2006', 'rating': '8.6'})]
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```

```output
query='women' filter=Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='director', value='Greta Gerwig') limit=None
```


```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'id': 'doc:movie_reviews:bb899807b93c442083fd45e75a4779d5', 'director': 'Greta Gerwig', 'genre': 'drama', 'year': '2019', 'rating': '8.3'})]
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```

```output
query=' ' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GTE: 'gte'>, attribute='rating', value=8.5), Comparison(comparator=<Comparator.CONTAIN: 'contain'>, attribute='genre', value='science fiction')]) limit=None
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'id': 'doc:movie_reviews:2cc66f38bfbd438eb3a045d90a1a4088', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'year': '1979', 'rating': '9.9'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'id': 'doc:movie_reviews:edf567b1d5334e02b2a4c692d853c80c', 'director': 'Satoshi Kon', 'genre': 'science fiction', 'year': '2006', 'rating': '8.6'})]
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about toys, and preferably is animated"
)
```

```output
query='toys' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GT: 'gt'>, attribute='year', value=1990), Comparison(comparator=<Comparator.LT: 'lt'>, attribute='year', value=2005), Comparison(comparator=<Comparator.CONTAIN: 'contain'>, attribute='genre', value='animated')]) limit=None
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'id': 'doc:movie_reviews:9e4e84daa0374941a6aa4274e9bbb607', 'director': 'John Lasseter', 'genre': 'animated', 'year': '1995', 'rating': '9.1'})]
```


## k 필터링

자기 쿼리 검색기를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

생성자에 `enable_limit=True`를 전달하여 이를 수행할 수 있습니다.

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

```output
query='dinosaur' filter=None limit=2
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'id': 'doc:movie_reviews:7b5481d753bc4135851b66fa61def7fb', 'director': 'Steven Spielberg', 'genre': 'science fiction', 'year': '1993', 'rating': '7.7'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'id': 'doc:movie_reviews:9e4e84daa0374941a6aa4274e9bbb607', 'director': 'John Lasseter', 'genre': 'animated', 'year': '1995', 'rating': '9.1'})]
```