---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/elasticsearch_self_query.ipynb
description: Elasticsearch는 분산형 RESTful 검색 및 분석 엔진으로, HTTP 웹 인터페이스와 스키마 없는 JSON 문서를
  제공합니다.
---

# Elasticsearch

> [Elasticsearch](https://www.elastic.co/elasticsearch/)는 분산형 RESTful 검색 및 분석 엔진입니다.  
분산형 다중 테넌트 기능을 갖춘 전체 텍스트 검색 엔진을 제공하며, HTTP 웹 인터페이스와 스키마 없는 JSON 문서를 지원합니다.

이 노트북에서는 `Elasticsearch` 벡터 저장소와 함께 `SelfQueryRetriever`를 시연할 것입니다.

## Elasticsearch 벡터 저장소 만들기

먼저, `Elasticsearch` 벡터 저장소를 만들고 일부 데이터로 초기화해야 합니다. 영화 요약이 포함된 작은 데모 문서 세트를 만들었습니다.

**참고:** 셀프 쿼리 검색기를 사용하려면 `lark`가 설치되어 있어야 합니다 (`pip install lark`). 또한 `elasticsearch` 패키지가 필요합니다.

```python
%pip install --upgrade --quiet  U lark langchain langchain-elasticsearch
```
  
```output
[33mWARNING: You are using pip version 22.0.4; however, version 23.3 is available.
You should consider upgrading via the '/Users/joe/projects/elastic/langchain/libs/langchain/.venv/bin/python3 -m pip install --upgrade pip' command.[0m[33m
[0m
```
  

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Elasticsearch"}, {"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Elasticsearch"}]-->
import getpass
import os

from langchain_core.documents import Document
from langchain_elasticsearch import ElasticsearchStore
from langchain_openai import OpenAIEmbeddings

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")

embeddings = OpenAIEmbeddings()
```
  
```python
docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={"year": 1993, "rating": 7.7, "genre": "science fiction"},
    ),
    Document(
        page_content="Leo DiCaprio gets lost in a dream within a dream within a dream within a ...",
        metadata={"year": 2010, "director": "Christopher Nolan", "rating": 8.2},
    ),
    Document(
        page_content="A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea",
        metadata={"year": 2006, "director": "Satoshi Kon", "rating": 8.6},
    ),
    Document(
        page_content="A bunch of normal-sized women are supremely wholesome and some men pine after them",
        metadata={"year": 2019, "director": "Greta Gerwig", "rating": 8.3},
    ),
    Document(
        page_content="Toys come alive and have a blast doing so",
        metadata={"year": 1995, "genre": "animated"},
    ),
    Document(
        page_content="Three men walk into the Zone, three men walk out of the Zone",
        metadata={
            "year": 1979,
            "director": "Andrei Tarkovsky",
            "genre": "science fiction",
            "rating": 9.9,
        },
    ),
]
vectorstore = ElasticsearchStore.from_documents(
    docs,
    embeddings,
    index_name="elasticsearch-self-query-demo",
    es_url="http://localhost:9200",
)
```
  

## 셀프 쿼리 검색기 만들기
이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명을 제공해야 합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "Elasticsearch"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "Elasticsearch"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Elasticsearch"}]-->
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
llm = OpenAI(temperature=0)
retriever = SelfQueryRetriever.from_llm(
    llm, vectorstore, document_content_description, metadata_field_info, verbose=True
)
```
  

## 테스트해 보기
이제 실제로 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are some movies about dinosaurs")
```
  
```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'rating': 7.7, 'genre': 'science fiction'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'rating': 9.9, 'director': 'Andrei Tarkovsky', 'genre': 'science fiction'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'director': 'Satoshi Kon', 'rating': 8.6})]
```
  
```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```
  
```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'year': 2019, 'director': 'Greta Gerwig', 'rating': 8.3})]
```
  

## k 필터

셀프 쿼리 검색기를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

이를 위해 생성자에 `enable_limit=True`를 전달하면 됩니다.

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
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'rating': 7.7, 'genre': 'science fiction'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```
  

## 복잡한 쿼리 실행!
간단한 쿼리를 시도해 보았지만, 더 복잡한 쿼리는 어떨까요? Elasticsearch의 모든 기능을 활용하는 몇 가지 더 복잡한 쿼리를 시도해 보겠습니다.

```python
retriever.invoke(
    "what animated or comedy movies have been released in the last 30 years about animated toys?"
)
```
  
```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```
  
```python
vectorstore.client.indices.delete(index="elasticsearch-self-query-demo")
```