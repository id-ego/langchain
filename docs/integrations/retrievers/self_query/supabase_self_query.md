---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/supabase_self_query.ipynb
description: Supabase는 PostgreSQL 기반의 오픈소스 Firebase 대안으로, AI 애플리케이션 개발을 위한 도구킷을 제공합니다.
---

# Supabase (Postgres)

> [Supabase](https://supabase.com/docs)는 오픈 소스 `Firebase` 대안입니다.
`Supabase`는 강력한 `SQL` 쿼리 기능을 제공하고 이미 존재하는 도구 및 프레임워크와 간단한 인터페이스를 가능하게 하는 `PostgreSQL` 위에 구축되었습니다.

> [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL), 또는 `Postgres`로도 알려진,
확장성과 `SQL` 준수를 강조하는 무료 오픈 소스 관계형 데이터베이스 관리 시스템(RDBMS)입니다.
> 
> [Supabase](https://supabase.com/docs/guides/ai)는 Postgres와 pgvector를 사용하여 AI 애플리케이션을 개발하기 위한 오픈 소스 툴킷을 제공합니다.
Supabase 클라이언트 라이브러리를 사용하여 벡터 임베딩을 대규모로 저장, 인덱싱 및 쿼리할 수 있습니다.

노트북에서는 `Supabase` 벡터 저장소 주위에 래핑된 `SelfQueryRetriever`를 데모할 것입니다.

구체적으로 우리는:
1. Supabase 데이터베이스를 생성합니다.
2. `pgvector` 확장을 활성화합니다.
3. `documents` 테이블과 `SupabaseVectorStore`에서 사용할 `match_documents` 함수를 생성합니다.
4. 샘플 문서를 벡터 저장소(데이터베이스 테이블)에 로드합니다.
5. 자기 쿼리 검색기를 구축하고 테스트합니다.

## Supabase 데이터베이스 설정

1. https://database.new로 이동하여 Supabase 데이터베이스를 프로비저닝합니다.
2. 스튜디오에서 [SQL 편집기](https://supabase.com/dashboard/project/_/sql/new)로 이동하여 다음 스크립트를 실행하여 `pgvector`를 활성화하고 데이터베이스를 벡터 저장소로 설정합니다:
   ```sql
   -- Enable the pgvector extension to work with embedding vectors
   create extension if not exists vector;
   
   -- Create a table to store your documents
   create table
     documents (
       id uuid primary key,
       content text, -- corresponds to Document.pageContent
       metadata jsonb, -- corresponds to Document.metadata
       embedding vector (1536) -- 1536 works for OpenAI embeddings, change if needed
     );
   
   -- Create a function to search for documents
   create function match_documents (
     query_embedding vector (1536),
     filter jsonb default '{}'
   ) returns table (
     id uuid,
     content text,
     metadata jsonb,
     similarity float
   ) language plpgsql as $$
   #variable_conflict use_column
   begin
     return query
     select
       id,
       content,
       metadata,
       1 - (documents.embedding <=> query_embedding) as similarity
     from documents
     where metadata @> filter
     order by documents.embedding <=> query_embedding;
   end;
   $$;
   ```


## Supabase 벡터 저장소 생성
다음으로 Supabase 벡터 저장소를 생성하고 일부 데이터로 시드합니다. 우리는 영화 요약을 포함하는 작은 데모 문서 세트를 만들었습니다.

최신 버전의 `langchain`을 `openai` 지원과 함께 설치해야 합니다:

```python
%pip install --upgrade --quiet  langchain langchain-openai tiktoken
```


자기 쿼리 검색기를 사용하려면 `lark`가 설치되어 있어야 합니다:

```python
%pip install --upgrade --quiet  lark
```


또한 `supabase` 패키지가 필요합니다:

```python
%pip install --upgrade --quiet  supabase
```


`SupabaseVectorStore`와 `OpenAIEmbeddings`를 사용하고 있으므로 API 키를 로드해야 합니다.

- `SUPABASE_URL` 및 `SUPABASE_SERVICE_KEY`를 찾으려면 Supabase 프로젝트의 [API 설정](https://supabase.com/dashboard/project/_/settings/api)으로 이동합니다.
  - `SUPABASE_URL`은 프로젝트 URL에 해당합니다.
  - `SUPABASE_SERVICE_KEY`는 `service_role` API 키에 해당합니다.
- `OPENAI_API_KEY`를 얻으려면 OpenAI 계정의 [API 키](https://platform.openai.com/account/api-keys)로 이동하여 새 비밀 키를 생성합니다.

```python
import getpass
import os

os.environ["SUPABASE_URL"] = getpass.getpass("Supabase URL:")
os.environ["SUPABASE_SERVICE_KEY"] = getpass.getpass("Supabase Service Key:")
os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


*선택 사항:* Supabase 및 OpenAI API 키를 `.env` 파일에 저장하는 경우 [`dotenv`](https://github.com/theskumar/python-dotenv)를 사용하여 로드할 수 있습니다.

```python
%pip install --upgrade --quiet  python-dotenv
```


```python
from dotenv import load_dotenv

load_dotenv()
```


먼저 Supabase 클라이언트를 생성하고 OpenAI 임베딩 클래스를 인스턴스화합니다.

```python
<!--IMPORTS:[{"imported": "SupabaseVectorStore", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.supabase.SupabaseVectorStore.html", "title": "Supabase (Postgres)"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Supabase (Postgres)"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Supabase (Postgres)"}]-->
import os

from langchain_community.vectorstores import SupabaseVectorStore
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from supabase.client import Client, create_client

supabase_url = os.environ.get("SUPABASE_URL")
supabase_key = os.environ.get("SUPABASE_SERVICE_KEY")
supabase: Client = create_client(supabase_url, supabase_key)

embeddings = OpenAIEmbeddings()
```


다음으로 문서를 생성합시다.

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

vectorstore = SupabaseVectorStore.from_documents(
    docs,
    embeddings,
    client=supabase,
    table_name="documents",
    query_name="match_documents",
)
```


## 자기 쿼리 검색기 생성
이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명이 필요합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "Supabase (Postgres)"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "Supabase (Postgres)"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Supabase (Postgres)"}]-->
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


## 테스트해보기
이제 실제로 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are some movies about dinosaurs")
```

```output
query='dinosaur' filter=None limit=None
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'genre': 'science fiction', 'rating': 7.7}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'genre': 'science fiction', 'rating': 9.9, 'director': 'Andrei Tarkovsky'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'rating': 8.6, 'director': 'Satoshi Kon'})]
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
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'year': 2006, 'rating': 8.6, 'director': 'Satoshi Kon'})]
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women?")
```

```output
query='women' filter=Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='director', value='Greta Gerwig') limit=None
```


```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'year': 2019, 'rating': 8.3, 'director': 'Greta Gerwig'})]
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```

```output
query=' ' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GTE: 'gte'>, attribute='rating', value=8.5), Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='genre', value='science fiction')]) limit=None
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'year': 1979, 'genre': 'science fiction', 'rating': 9.9, 'director': 'Andrei Tarkovsky'})]
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before (or on) 2005 that's all about toys, and preferably is animated"
)
```

```output
query='toys' filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GT: 'gt'>, attribute='year', value=1990), Comparison(comparator=<Comparator.LTE: 'lte'>, attribute='year', value=2005), Comparison(comparator=<Comparator.LIKE: 'like'>, attribute='genre', value='animated')]) limit=None
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```


## 필터 k

자기 쿼리 검색기를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

생성자에게 `enable_limit=True`를 전달하여 이를 수행할 수 있습니다.

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
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'year': 1993, 'genre': 'science fiction', 'rating': 7.7}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'year': 1995, 'genre': 'animated'})]
```