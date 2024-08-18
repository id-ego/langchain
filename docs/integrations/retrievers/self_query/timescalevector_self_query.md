---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/timescalevector_self_query.ipynb
description: 타임스케일 벡터는 PostgreSQL++로 AI 애플리케이션을 위한 효율적인 벡터 임베딩 저장 및 쿼리를 지원합니다.
---

# 타임스케일 벡터 (Postgres)

> [타임스케일 벡터](https://www.timescale.com/ai)는 AI 애플리케이션을 위한 `PostgreSQL++`입니다. 이를 통해 `PostgreSQL`에서 수십억 개의 벡터 임베딩을 효율적으로 저장하고 쿼리할 수 있습니다.
> 
> [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL), 즉 `Postgres`는 확장성과 `SQL` 준수를 강조하는 무료 오픈 소스 관계형 데이터베이스 관리 시스템(RDBMS)입니다.

이 노트북은 Postgres 벡터 데이터베이스(`TimescaleVector`)를 사용하여 자기 쿼리를 수행하는 방법을 보여줍니다. 노트북에서는 타임스케일 벡터 저장소 주위에 감싸진 `SelfQueryRetriever`를 시연할 것입니다.

## 타임스케일 벡터란?
**[타임스케일 벡터](https://www.timescale.com/ai)는 AI 애플리케이션을 위한 PostgreSQL++입니다.**

타임스케일 벡터는 `PostgreSQL`에서 수백만 개의 벡터 임베딩을 효율적으로 저장하고 쿼리할 수 있게 해줍니다.
- DiskANN에서 영감을 받은 인덱싱 알고리즘을 통해 1B+ 벡터에 대한 더 빠르고 정확한 유사성 검색을 지원하는 `pgvector`를 향상시킵니다.
- 자동 시간 기반 파티셔닝 및 인덱싱을 통해 빠른 시간 기반 벡터 검색을 가능하게 합니다.
- 벡터 임베딩 및 관계형 데이터를 쿼리하기 위한 친숙한 SQL 인터페이스를 제공합니다.

타임스케일 벡터는 POC에서 프로덕션까지 함께 확장되는 AI를 위한 클라우드 PostgreSQL입니다:
- 관계형 메타데이터, 벡터 임베딩 및 시계열 데이터를 단일 데이터베이스에 저장할 수 있도록 하여 운영을 간소화합니다.
- 스트리밍 백업 및 복제, 고가용성 및 행 수준 보안과 같은 엔터프라이즈급 기능을 갖춘 견고한 PostgreSQL 기반의 이점을 누립니다.
- 엔터프라이즈급 보안 및 준수로 걱정 없는 경험을 제공합니다.

## 타임스케일 벡터에 접근하는 방법
타임스케일 벡터는 클라우드 PostgreSQL 플랫폼인 [타임스케일](https://www.timescale.com/ai)에서 사용할 수 있습니다. (현재 자가 호스팅 버전은 없습니다.)

LangChain 사용자는 타임스케일 벡터에 대해 90일 무료 체험을 제공합니다.
- 시작하려면 [가입](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)하여 타임스케일에 가입하고 새 데이터베이스를 생성한 후 이 노트북을 따라하세요!
- 더 많은 세부정보와 성능 벤치마크는 [타임스케일 벡터 설명 블로그](https://www.timescale.com/blog/how-we-made-postgresql-the-best-vector-database/?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)를 참조하세요.
- 타임스케일 벡터를 파이썬에서 사용하는 방법에 대한 자세한 내용은 [설치 지침](https://github.com/timescale/python-vector)을 참조하세요.

## 타임스케일 벡터 저장소 생성
먼저 타임스케일 벡터 저장소를 생성하고 일부 데이터로 초기화해야 합니다. 영화 요약이 포함된 작은 데모 문서 세트를 만들었습니다.

참고: 자기 쿼리 검색기를 사용하려면 `lark`가 설치되어 있어야 합니다(`pip install lark`). 또한 `timescale-vector` 패키지가 필요합니다.

```python
%pip install --upgrade --quiet  lark
```


```python
%pip install --upgrade --quiet  timescale-vector
```


이 예제에서는 `OpenAIEmbeddings`를 사용할 것이므로 OpenAI API 키를 로드합시다.

```python
# Get openAI api key by reading local .env file
# The .env file should contain a line starting with `OPENAI_API_KEY=sk-`
import os

from dotenv import find_dotenv, load_dotenv

_ = load_dotenv(find_dotenv())

OPENAI_API_KEY = os.environ["OPENAI_API_KEY"]
# Alternatively, use getpass to enter the key in a prompt
# import os
# import getpass
# os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


PostgreSQL 데이터베이스에 연결하려면 서비스 URI가 필요합니다. 이는 새 데이터베이스를 생성한 후 다운로드한 치트 시트 또는 `.env` 파일에서 찾을 수 있습니다.

아직 가입하지 않았다면 [타임스케일에 가입하세요](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral) 그리고 새 데이터베이스를 생성하세요.

URI는 다음과 같은 형식입니다: `postgres://tsdbadmin:<password>@<id>.tsdb.cloud.timescale.com:<port>/tsdb?sslmode=require`

```python
# Get the service url by reading local .env file
# The .env file should contain a line starting with `TIMESCALE_SERVICE_URL=postgresql://`
_ = load_dotenv(find_dotenv())
TIMESCALE_SERVICE_URL = os.environ["TIMESCALE_SERVICE_URL"]

# Alternatively, use getpass to enter the key in a prompt
# import os
# import getpass
# TIMESCALE_SERVICE_URL = getpass.getpass("Timescale Service URL:")
```


```python
<!--IMPORTS:[{"imported": "TimescaleVector", "source": "langchain_community.vectorstores.timescalevector", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.timescalevector.TimescaleVector.html", "title": "Timescale Vector (Postgres) "}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Timescale Vector (Postgres) "}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Timescale Vector (Postgres) "}]-->
from langchain_community.vectorstores.timescalevector import TimescaleVector
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
```


다음은 이 데모에 사용할 샘플 문서입니다. 데이터는 영화에 관한 것이며 특정 영화에 대한 정보가 포함된 콘텐츠 및 메타데이터 필드를 가지고 있습니다.

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
```


마지막으로 타임스케일 벡터 저장소를 생성합니다. 컬렉션 이름은 문서가 저장된 PostgreSQL 테이블의 이름이 됩니다.

```python
COLLECTION_NAME = "langchain_self_query_demo"
vectorstore = TimescaleVector.from_documents(
    embedding=embeddings,
    documents=docs,
    collection_name=COLLECTION_NAME,
    service_url=TIMESCALE_SERVICE_URL,
)
```


## 자기 쿼리 검색기 생성
이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 일부 정보를 미리 제공하고 문서 내용에 대한 간단한 설명을 제공해야 합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "Timescale Vector (Postgres) "}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "Timescale Vector (Postgres) "}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Timescale Vector (Postgres) "}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import OpenAI

# Give LLM info about the metadata fields
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

# Instantiate the self-query retriever from an LLM
llm = OpenAI(temperature=0)
retriever = SelfQueryRetriever.from_llm(
    llm, vectorstore, document_content_description, metadata_field_info, verbose=True
)
```


## 타임스케일 벡터를 통한 자기 쿼리 검색
이제 실제로 검색기를 사용해 볼 수 있습니다!

아래 쿼리를 실행하고 자연어로 쿼리, 필터, 복합 필터(AND, OR로 필터링)를 지정할 수 있는 방법을 주목하세요. 자기 쿼리 검색기는 해당 쿼리를 SQL로 변환하고 타임스케일 벡터(Postgres) 저장소에서 검색을 수행합니다.

이는 자기 쿼리 검색기의 강력함을 보여줍니다. 이를 통해 사용자가 SQL을 직접 작성하지 않고도 벡터 저장소에서 복잡한 검색을 수행할 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are some movies about dinosaurs")
```

```output
/Users/avtharsewrathan/sideprojects2023/timescaleai/tsv-langchain/langchain/libs/langchain/langchain/chains/llm.py:275: UserWarning: The predict_and_parse method is deprecated, instead pass an output parser directly to LLMChain.
  warnings.warn(
``````output
query='dinosaur' filter=None limit=None
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'genre': 'science fiction', 'rating': 7.7}),
 Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'genre': 'science fiction', 'rating': 7.7}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```


```python
# This example only specifies a filter
retriever.invoke("I want to watch a movie rated higher than 8.5")
```

```output
query=' ' filter=Comparison(comparator=<Comparator.GT: 'gt'>, attribute='rating', value=8.5) limit=None
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'genre': 'science fiction', 'rating': 9.9, 'director': 'Andrei Tarkovsky'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'genre': 'science fiction', 'rating': 9.9, 'director': 'Andrei Tarkovsky'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'rating': 8.6, 'director': 'Satoshi Kon'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'rating': 8.6, 'director': 'Satoshi Kon'})]
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```

```output
query='women' filter=Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='director', value='Greta Gerwig') limit=None
```


```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'year': 2019, 'rating': 8.3, 'director': 'Greta Gerwig'}),
 Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'year': 2019, 'rating': 8.3, 'director': 'Greta Gerwig'})]
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```

```output
query=' ' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GTE: 'gte'>, attribute='rating', value=8.5), Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='genre', value='science fiction')]) limit=None
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'genre': 'science fiction', 'rating': 9.9, 'director': 'Andrei Tarkovsky'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'genre': 'science fiction', 'rating': 9.9, 'director': 'Andrei Tarkovsky'})]
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about toys, and preferably is animated"
)
```

```output
query='toys' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GT: 'gt'>, attribute='year', value=1990), Comparison(comparator=<Comparator.LT: 'lt'>, attribute='year', value=2005), Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='genre', value='animated')]) limit=None
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```


### k 필터

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
# This example specifies a query with a LIMIT value
retriever.invoke("what are two movies about dinosaurs")
```

```output
query='dinosaur' filter=None limit=2
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'genre': 'science fiction', 'rating': 7.7}),
 Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'genre': 'science fiction', 'rating': 7.7})]
```