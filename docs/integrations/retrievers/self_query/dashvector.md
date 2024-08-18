---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/dashvector.ipynb
description: DashVector는 고차원 밀집 및 희소 벡터를 지원하는 완전 관리형 벡터 DB 서비스로, 실시간 삽입 및 필터 검색 기능을
  제공합니다.
---

# DashVector

> [DashVector](https://help.aliyun.com/document_detail/2510225.html)는 고차원 밀집 및 희소 벡터, 실시간 삽입 및 필터링된 검색을 지원하는 완전 관리형 벡터 DB 서비스입니다. 자동으로 확장되도록 설계되었으며 다양한 애플리케이션 요구 사항에 적응할 수 있습니다.
벡터 검색 서비스 `DashVector`는 `DAMO Academy`에서 독립적으로 개발한 효율적인 벡터 엔진의 `Proxima` 코어를 기반으로 하며,
수평 확장 기능을 갖춘 클라우드 네이티브 완전 관리형 벡터 검색 서비스를 제공합니다.
`DashVector`는 강력한 벡터 관리, 벡터 쿼리 및 기타 다양한 기능을 간단하고 사용하기 쉬운 SDK/API 인터페이스를 통해 노출하며,
상위 AI 애플리케이션에 빠르게 통합될 수 있어 대형 모델 생태계, 다중 모달 AI 검색, 분자 구조 분석 등 다양한 애플리케이션 시나리오에 필요한 효율적인 벡터 검색 기능을 제공합니다.

이 노트북에서는 `DashVector` 벡터 저장소와 함께 `SelfQueryRetriever`를 데모합니다.

## DashVector 벡터 저장소 생성

먼저 `DashVector` VectorStore를 생성하고 일부 데이터로 초기화합니다. 영화 요약을 포함하는 작은 데모 문서 세트를 만들었습니다.

DashVector를 사용하려면 `dashvector` 패키지가 설치되어 있어야 하며, API 키와 환경이 필요합니다. [설치 지침](https://help.aliyun.com/document_detail/2510223.html)을 참조하세요.

NOTE: 자기 쿼리 검색기에는 `lark` 패키지가 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  lark dashvector
```


```python
import os

import dashvector

client = dashvector.Client(api_key=os.environ["DASHVECTOR_API_KEY"])
```


```python
<!--IMPORTS:[{"imported": "DashScopeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.dashscope.DashScopeEmbeddings.html", "title": "DashVector"}, {"imported": "DashVector", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.dashvector.DashVector.html", "title": "DashVector"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "DashVector"}]-->
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_community.vectorstores import DashVector
from langchain_core.documents import Document

embeddings = DashScopeEmbeddings()

# create DashVector collection
client.create("langchain-self-retriever-demo", dimension=1536)
```


```python
docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={"year": 1993, "rating": 7.7, "genre": "action"},
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
vectorstore = DashVector.from_documents(
    docs, embeddings, collection_name="langchain-self-retriever-demo"
)
```


## 자기 쿼리 검색기 생성

이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명을 제공해야 합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "DashVector"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "DashVector"}, {"imported": "Tongyi", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.tongyi.Tongyi.html", "title": "DashVector"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_community.llms import Tongyi

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
llm = Tongyi(temperature=0)
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
query='dinosaurs' filter=None limit=None
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'rating': 7.699999809265137, 'genre': 'action'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'}),
 Document(page_content='Leo DiCaprio gets lost in a dream within a dream within a dream within a ...', metadata={'year': 2010, 'director': 'Christopher Nolan', 'rating': 8.199999809265137}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'director': 'Satoshi Kon', 'rating': 8.600000381469727})]
```


```python
# This example only specifies a filter
retriever.invoke("I want to watch a movie rated higher than 8.5")
```

```output
query=' ' filter=Comparison(comparator=<Comparator.GTE: 'gte'>, attribute='rating', value=8.5) limit=None
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'director': 'Andrei Tarkovsky', 'rating': 9.899999618530273, 'genre': 'science fiction'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'director': 'Satoshi Kon', 'rating': 8.600000381469727})]
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```

```output
query='Greta Gerwig' filter=Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='director', value='Greta Gerwig') limit=None
```


```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'year': 2019, 'director': 'Greta Gerwig', 'rating': 8.300000190734863})]
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```

```output
query='science fiction' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='genre', value='science fiction'), Comparison(comparator=<Comparator.GT: 'gt'>, attribute='rating', value=8.5)]) limit=None
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'director': 'Andrei Tarkovsky', 'rating': 9.899999618530273, 'genre': 'science fiction'})]
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
query='dinosaurs' filter=None limit=2
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'rating': 7.699999809265137, 'genre': 'action'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```