---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/mongodb_atlas.ipynb
description: MongoDB Atlas는 벡터 데이터베이스로 사용할 수 있는 문서 데이터베이스입니다. SelfQueryRetriever와
  함께 사용하는 방법을 안내합니다.
---

# MongoDB Atlas

> [MongoDB Atlas](https://www.mongodb.com/)는 벡터 데이터베이스로 사용할 수 있는 문서 데이터베이스입니다.

이 안내서에서는 `MongoDB Atlas` 벡터 저장소와 함께 `SelfQueryRetriever`를 시연할 것입니다.

## MongoDB Atlas 벡터 저장소 생성
먼저 MongoDB Atlas VectorStore를 생성하고 일부 데이터로 초기화해야 합니다. 우리는 영화 요약을 포함하는 작은 데모 문서 세트를 만들었습니다.

참고: self-query retriever를 사용하려면 `lark`가 설치되어 있어야 합니다 (`pip install lark`). 또한 `pymongo` 패키지가 필요합니다.

```python
%pip install --upgrade --quiet  lark pymongo
```


`OpenAIEmbeddings`를 사용하려면 OpenAI API 키를 받아야 합니다.

```python
import os

OPENAI_API_KEY = "Use your OpenAI key"

os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY
```


```python
<!--IMPORTS:[{"imported": "MongoDBAtlasVectorSearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.mongodb_atlas.MongoDBAtlasVectorSearch.html", "title": "MongoDB Atlas"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "MongoDB Atlas"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "MongoDB Atlas"}]-->
from langchain_community.vectorstores import MongoDBAtlasVectorSearch
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from pymongo import MongoClient

CONNECTION_STRING = "Use your MongoDB Atlas connection string"
DB_NAME = "Name of your MongoDB Atlas database"
COLLECTION_NAME = "Name of your collection in the database"
INDEX_NAME = "Name of a search index defined on the collection"

MongoClient = MongoClient(CONNECTION_STRING)
collection = MongoClient[DB_NAME][COLLECTION_NAME]

embeddings = OpenAIEmbeddings()
```


```python
docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={"year": 1993, "rating": 7.7, "genre": "action"},
    ),
    Document(
        page_content="Leo DiCaprio gets lost in a dream within a dream within a dream within a ...",
        metadata={"year": 2010, "genre": "thriller", "rating": 8.2},
    ),
    Document(
        page_content="A bunch of normal-sized women are supremely wholesome and some men pine after them",
        metadata={"year": 2019, "rating": 8.3, "genre": "drama"},
    ),
    Document(
        page_content="Three men walk into the Zone, three men walk out of the Zone",
        metadata={"year": 1979, "rating": 9.9, "genre": "science fiction"},
    ),
    Document(
        page_content="A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea",
        metadata={"year": 2006, "genre": "thriller", "rating": 9.0},
    ),
    Document(
        page_content="Toys come alive and have a blast doing so",
        metadata={"year": 1995, "genre": "animated", "rating": 9.3},
    ),
]

vectorstore = MongoDBAtlasVectorSearch.from_documents(
    docs,
    embeddings,
    collection=collection,
    index_name=INDEX_NAME,
)
```


이제 클러스터에서 벡터 검색 인덱스를 생성해 보겠습니다. 아래 예제에서 `embedding`은 임베딩 벡터를 포함하는 필드의 이름입니다. Atlas Vector Search 인덱스를 정의하는 방법에 대한 자세한 내용은 [문서](https://www.mongodb.com/docs/atlas/atlas-search/field-types/knn-vector)를 참조하십시오.
인덱스 이름을 `{COLLECTION_NAME}`으로 지정하고 네임스페이스 `{DB_NAME}.{COLLECTION_NAME}`에서 인덱스를 생성할 수 있습니다. 마지막으로 MongoDB Atlas의 JSON 편집기에 다음 정의를 작성하십시오:

```json
{
  "mappings": {
    "dynamic": true,
    "fields": {
      "embedding": {
        "dimensions": 1536,
        "similarity": "cosine",
        "type": "knnVector"
      },
      "genre": {
        "type": "token"
      },
      "ratings": {
        "type": "number"
      },
      "year": {
        "type": "number"
      }
    }
  }
}
```


## 자기 쿼리 검색기 생성
이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명이 필요합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "MongoDB Atlas"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "MongoDB Atlas"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "MongoDB Atlas"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import OpenAI

metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genre of the movie",
        type="string",
    ),
    AttributeInfo(
        name="year",
        description="The year the movie was released",
        type="integer",
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


## 테스트해 보기
이제 실제로 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are some movies about dinosaurs")
```


```python
# This example specifies a filter
retriever.invoke("What are some highly rated movies (above 9)?")
```


```python
# This example only specifies a query and a filter
retriever.invoke("I want to watch a movie about toys rated higher than 9")
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above or equal 9) thriller film?")
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about dinosaurs, \
    and preferably has a lot of action"
)
```


## k 필터

self query retriever를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

이를 위해 생성자에 `enable_limit=True`를 전달하면 됩니다.

```python
retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
    verbose=True,
    enable_limit=True,
)
```


```python
# This example only specifies a relevant query
retriever.invoke("What are two movies about dinosaurs?")
```