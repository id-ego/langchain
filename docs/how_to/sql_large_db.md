---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/sql_large_db.ipynb
description: 대규모 데이터베이스에서 SQL 질문-응답을 위한 유용한 정보 식별 및 쿼리 생성 방법을 안내하는 가이드입니다.
---

# 대규모 데이터베이스를 SQL 질문-응답 시 처리하는 방법

데이터베이스에 유효한 쿼리를 작성하기 위해서는 모델에 테이블 이름, 테이블 스키마 및 쿼리할 기능 값을 제공해야 합니다. 테이블, 열 및/또는 높은 카디널리티 열이 많을 경우, 모든 프롬프트에 데이터베이스에 대한 전체 정보를 덤프하는 것은 불가능해집니다. 대신, 우리는 프롬프트에 가장 관련성이 높은 정보만 동적으로 삽입하는 방법을 찾아야 합니다.

이 가이드에서는 그러한 관련 정보를 식별하고 이를 쿼리 생성 단계에 제공하는 방법을 보여줍니다. 우리는 다음을 다룰 것입니다:

1. 관련 테이블의 하위 집합 식별하기;
2. 관련 열 값의 하위 집합 식별하기.

## 설정

먼저 필요한 패키지를 가져오고 환경 변수를 설정합니다:

```python
%pip install --upgrade --quiet  langchain langchain-community langchain-openai
```


```python
# Uncomment the below to use LangSmith. Not required.
# import os
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
```


아래 예제는 Chinook 데이터베이스와 함께 SQLite 연결을 사용할 것입니다. [이 설치 단계](https://database.guide/2-sample-databases-sqlite/)를 따라 `Chinook.db`를 이 노트북과 같은 디렉토리에 생성하세요:

* [이 파일](https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_Sqlite.sql)을 `Chinook_Sqlite.sql`로 저장합니다.
* `sqlite3 Chinook.db`를 실행합니다.
* `.read Chinook_Sqlite.sql`을 실행합니다.
* `SELECT * FROM Artist LIMIT 10;`을 테스트합니다.

이제 `Chinook.db`가 우리의 디렉토리에 있으며, SQLAlchemy 기반의 [SQLDatabase](https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html) 클래스를 사용하여 인터페이스할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SQLDatabase", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html", "title": "How to deal with large databases when doing SQL question-answering"}]-->
from langchain_community.utilities import SQLDatabase

db = SQLDatabase.from_uri("sqlite:///Chinook.db")
print(db.dialect)
print(db.get_usable_table_names())
print(db.run("SELECT * FROM Artist LIMIT 10;"))
```

```output
sqlite
['Album', 'Artist', 'Customer', 'Employee', 'Genre', 'Invoice', 'InvoiceLine', 'MediaType', 'Playlist', 'PlaylistTrack', 'Track']
[(1, 'AC/DC'), (2, 'Accept'), (3, 'Aerosmith'), (4, 'Alanis Morissette'), (5, 'Alice In Chains'), (6, 'Antônio Carlos Jobim'), (7, 'Apocalyptica'), (8, 'Audioslave'), (9, 'BackBeat'), (10, 'Billy Cobham')]
```


## 많은 테이블

프롬프트에 포함해야 할 주요 정보 중 하나는 관련 테이블의 스키마입니다. 테이블이 너무 많을 경우, 모든 스키마를 단일 프롬프트에 담을 수 없습니다. 이러한 경우, 사용자 입력과 관련된 테이블의 이름을 먼저 추출한 다음, 그들의 스키마만 포함할 수 있습니다.

이를 수행하는 쉽고 신뢰할 수 있는 방법 중 하나는 [tool-calling](/docs/how_to/tool_calling)을 사용하는 것입니다. 아래에서는 이 기능을 사용하여 원하는 형식(이 경우, 테이블 이름 목록)에 맞는 출력을 얻는 방법을 보여줍니다. 우리는 채팅 모델의 `.bind_tools` 메서드를 사용하여 Pydantic 형식으로 도구를 바인딩하고, 이를 출력 파서에 제공하여 모델의 응답에서 객체를 재구성합니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "PydanticToolsParser", "source": "langchain_core.output_parsers.openai_tools", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.PydanticToolsParser.html", "title": "How to deal with large databases when doing SQL question-answering"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to deal with large databases when doing SQL question-answering"}]-->
from langchain_core.output_parsers.openai_tools import PydanticToolsParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field


class Table(BaseModel):
    """Table in SQL database."""

    name: str = Field(description="Name of table in SQL database.")


table_names = "\n".join(db.get_usable_table_names())
system = f"""Return the names of ALL the SQL tables that MIGHT be relevant to the user question. \
The tables are:

{table_names}

Remember to include ALL POTENTIALLY RELEVANT tables, even if you're not sure that they're needed."""

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{input}"),
    ]
)
llm_with_tools = llm.bind_tools([Table])
output_parser = PydanticToolsParser(tools=[Table])

table_chain = prompt | llm_with_tools | output_parser

table_chain.invoke({"input": "What are all the genres of Alanis Morisette songs"})
```


```output
[Table(name='Genre')]
```


이것은 꽤 잘 작동합니다! 하지만 아래에서 볼 수 있듯이, 실제로는 몇 가지 다른 테이블도 필요합니다. 이는 모델이 사용자 질문만으로 알기에는 꽤 어려울 것입니다. 이 경우, 우리는 모델의 작업을 단순화하기 위해 테이블을 그룹화할 수 있습니다. 우리는 모델에게 "음악"과 "비즈니스" 카테고리 중에서 선택하도록 요청하고, 그 이후에 모든 관련 테이블을 선택하는 작업을 처리할 것입니다:

```python
system = """Return the names of any SQL tables that are relevant to the user question.
The tables are:

Music
Business
"""

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{input}"),
    ]
)

category_chain = prompt | llm_with_tools | output_parser
category_chain.invoke({"input": "What are all the genres of Alanis Morisette songs"})
```


```output
[Table(name='Music'), Table(name='Business')]
```


```python
from typing import List


def get_tables(categories: List[Table]) -> List[str]:
    tables = []
    for category in categories:
        if category.name == "Music":
            tables.extend(
                [
                    "Album",
                    "Artist",
                    "Genre",
                    "MediaType",
                    "Playlist",
                    "PlaylistTrack",
                    "Track",
                ]
            )
        elif category.name == "Business":
            tables.extend(["Customer", "Employee", "Invoice", "InvoiceLine"])
    return tables


table_chain = category_chain | get_tables
table_chain.invoke({"input": "What are all the genres of Alanis Morisette songs"})
```


```output
['Album',
 'Artist',
 'Genre',
 'MediaType',
 'Playlist',
 'PlaylistTrack',
 'Track',
 'Customer',
 'Employee',
 'Invoice',
 'InvoiceLine']
```


이제 우리는 어떤 쿼리에 대해서도 관련 테이블을 출력할 수 있는 체인을 갖추었으며, 이를 [create_sql_query_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.sql_database.query.create_sql_query_chain.html)과 결합할 수 있습니다. 이 체인은 프롬프트에 포함될 테이블 스키마를 결정하기 위해 `table_names_to_use` 목록을 수용할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "create_sql_query_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sql_database.query.create_sql_query_chain.html", "title": "How to deal with large databases when doing SQL question-answering"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to deal with large databases when doing SQL question-answering"}]-->
from operator import itemgetter

from langchain.chains import create_sql_query_chain
from langchain_core.runnables import RunnablePassthrough

query_chain = create_sql_query_chain(llm, db)
# Convert "question" key to the "input" key expected by current table_chain.
table_chain = {"input": itemgetter("question")} | table_chain
# Set table_names_to_use using table_chain.
full_chain = RunnablePassthrough.assign(table_names_to_use=table_chain) | query_chain
```


```python
query = full_chain.invoke(
    {"question": "What are all the genres of Alanis Morisette songs"}
)
print(query)
```

```output
SELECT DISTINCT "g"."Name"
FROM "Genre" g
JOIN "Track" t ON "g"."GenreId" = "t"."GenreId"
JOIN "Album" a ON "t"."AlbumId" = "a"."AlbumId"
JOIN "Artist" ar ON "a"."ArtistId" = "ar"."ArtistId"
WHERE "ar"."Name" = 'Alanis Morissette'
LIMIT 5;
```


```python
db.run(query)
```


```output
"[('Rock',)]"
```


이번 실행에 대한 LangSmith 추적을 [여기](https://smith.langchain.com/public/4fbad408-3554-4f33-ab47-1e510a1b52a3/r)에서 볼 수 있습니다.

우리는 체인 내에서 프롬프트에 테이블 스키마의 하위 집합을 동적으로 포함하는 방법을 보았습니다. 이 문제에 대한 또 다른 가능한 접근 방식은 에이전트가 스스로 테이블을 조회할 시점을 결정하도록 하는 것입니다. 이 예시는 [SQL: Agents](/docs/tutorials/agents) 가이드에서 확인할 수 있습니다.

## 높은 카디널리티 열

주소, 노래 제목 또는 아티스트와 같은 고유 명사를 포함하는 열을 필터링하기 위해서는 먼저 올바른 철자를 확인하여 데이터를 올바르게 필터링해야 합니다.

한 가지 단순한 전략은 데이터베이스에 존재하는 모든 고유 명사의 벡터 저장소를 만드는 것입니다. 그런 다음 각 사용자 입력에 대해 해당 벡터 저장소를 쿼리하고 가장 관련성이 높은 고유 명사를 프롬프트에 주입할 수 있습니다.

먼저 원하는 각 엔티티의 고유 값을 얻기 위해 결과를 요소 목록으로 구문 분석하는 함수를 정의합니다:

```python
import ast
import re


def query_as_list(db, query):
    res = db.run(query)
    res = [el for sub in ast.literal_eval(res) for el in sub if el]
    res = [re.sub(r"\b\d+\b", "", string).strip() for string in res]
    return res


proper_nouns = query_as_list(db, "SELECT Name FROM Artist")
proper_nouns += query_as_list(db, "SELECT Title FROM Album")
proper_nouns += query_as_list(db, "SELECT Name FROM Genre")
len(proper_nouns)
proper_nouns[:5]
```


```output
['AC/DC', 'Accept', 'Aerosmith', 'Alanis Morissette', 'Alice In Chains']
```


이제 모든 값을 벡터 데이터베이스에 임베드하고 저장할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to deal with large databases when doing SQL question-answering"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to deal with large databases when doing SQL question-answering"}]-->
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

vector_db = FAISS.from_texts(proper_nouns, OpenAIEmbeddings())
retriever = vector_db.as_retriever(search_kwargs={"k": 15})
```


그리고 먼저 데이터베이스에서 값을 검색하고 이를 프롬프트에 삽입하는 쿼리 구성 체인을 함께 구성합니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to deal with large databases when doing SQL question-answering"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to deal with large databases when doing SQL question-answering"}]-->
from operator import itemgetter

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

system = """You are a SQLite expert. Given an input question, create a syntactically
correct SQLite query to run. Unless otherwise specificed, do not return more than
{top_k} rows.

Only return the SQL query with no markup or explanation.

Here is the relevant table info: {table_info}

Here is a non-exhaustive list of possible feature values. If filtering on a feature
value make sure to check its spelling against this list first:

{proper_nouns}
"""

prompt = ChatPromptTemplate.from_messages([("system", system), ("human", "{input}")])

query_chain = create_sql_query_chain(llm, db, prompt=prompt)
retriever_chain = (
    itemgetter("question")
    | retriever
    | (lambda docs: "\n".join(doc.page_content for doc in docs))
)
chain = RunnablePassthrough.assign(proper_nouns=retriever_chain) | query_chain
```


체인을 시도해 보려면 "elenis moriset"라는 잘못된 철자를 필터링할 때 어떤 일이 발생하는지 확인해 보겠습니다. 이는 Alanis Morissette의 잘못된 철자입니다. 검색 없이와 검색과 함께 시도해 보겠습니다:

```python
# Without retrieval
query = query_chain.invoke(
    {"question": "What are all the genres of elenis moriset songs", "proper_nouns": ""}
)
print(query)
db.run(query)
```

```output
SELECT DISTINCT g.Name 
FROM Track t
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE ar.Name = 'Elenis Moriset';
```


```output
''
```


```python
# Without retrieval
query = query_chain.invoke(
    {"question": "What are all the genres of elenis moriset songs", "proper_nouns": ""}
)
print(query)
db.run(query)
```

```output
SELECT DISTINCT Genre.Name
FROM Genre
JOIN Track ON Genre.GenreId = Track.GenreId
JOIN Album ON Track.AlbumId = Album.AlbumId
JOIN Artist ON Album.ArtistId = Artist.ArtistId
WHERE Artist.Name = 'Elenis Moriset'
```


```output
''
```


```python
# With retrieval
query = chain.invoke({"question": "What are all the genres of elenis moriset songs"})
print(query)
db.run(query)
```


```output
SELECT DISTINCT g.Name
FROM Genre g
JOIN Track t ON g.GenreId = t.GenreId
JOIN Album a ON t.AlbumId = a.AlbumId
JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE ar.Name = 'Alanis Morissette';
```


```output
"[('Rock',)]"
```


검색을 통해 "Elenis Moriset"의 철자를 "Alanis Morissette"로 수정하고 유효한 결과를 얻을 수 있음을 확인할 수 있습니다.

이 문제에 대한 또 다른 가능한 접근 방식은 에이전트가 스스로 고유 명사를 조회할 시점을 결정하도록 하는 것입니다. 이 예시는 [SQL: Agents](/docs/tutorials/agents) 가이드에서 확인할 수 있습니다.