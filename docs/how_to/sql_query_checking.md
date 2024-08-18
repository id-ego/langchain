---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/sql_query_checking.ipynb
description: SQL 질문 응답의 일환으로 쿼리 유효성 검사를 수행하는 방법과 오류를 줄이기 위한 전략을 다룹니다.
---

# SQL 질문 응답의 일환으로 쿼리 검증 수행 방법

아마도 모든 SQL 체인이나 에이전트에서 가장 오류가 발생하기 쉬운 부분은 유효하고 안전한 SQL 쿼리를 작성하는 것입니다. 이 가이드에서는 쿼리를 검증하고 잘못된 쿼리를 처리하기 위한 몇 가지 전략을 살펴보겠습니다.

우리는 다음을 다룰 것입니다:

1. 쿼리 생성에 "쿼리 검증기" 단계를 추가하기;
2. 오류 발생률을 줄이기 위한 프롬프트 엔지니어링.

## 설정

먼저, 필요한 패키지를 가져오고 환경 변수를 설정합니다:

```python
%pip install --upgrade --quiet  langchain langchain-community langchain-openai
```


```python
# Uncomment the below to use LangSmith. Not required.
# import os
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
```


아래 예제는 Chinook 데이터베이스와 함께 SQLite 연결을 사용할 것입니다. 이 노트북과 동일한 디렉토리에 `Chinook.db`를 생성하려면 [이 설치 단계](https://database.guide/2-sample-databases-sqlite/)를 따르세요:

* [이 파일](https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_Sqlite.sql)을 `Chinook_Sqlite.sql`로 저장합니다.
* `sqlite3 Chinook.db`를 실행합니다.
* `.read Chinook_Sqlite.sql`을 실행합니다.
* `SELECT * FROM Artist LIMIT 10;`를 테스트합니다.

이제 `Chinook.db`가 우리의 디렉토리에 있으며, SQLAlchemy 기반의 `SQLDatabase` 클래스를 사용하여 인터페이스할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SQLDatabase", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html", "title": "How to do query validation as part of SQL question-answering"}]-->
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


## 쿼리 검사기

가장 간단한 전략 중 하나는 모델 자체에 원래 쿼리를 일반적인 실수에 대해 확인하도록 요청하는 것입니다. 다음과 같은 SQL 쿼리 체인이 있다고 가정해 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "create_sql_query_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sql_database.query.create_sql_query_chain.html", "title": "How to do query validation as part of SQL question-answering"}]-->
from langchain.chains import create_sql_query_chain

chain = create_sql_query_chain(llm, db)
```


그리고 우리는 그 출력이 유효한지 검증하고자 합니다. 두 번째 프롬프트와 모델 호출로 체인을 확장하여 이를 수행할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to do query validation as part of SQL question-answering"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to do query validation as part of SQL question-answering"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

system = """Double check the user's {dialect} query for common mistakes, including:
- Using NOT IN with NULL values
- Using UNION when UNION ALL should have been used
- Using BETWEEN for exclusive ranges
- Data type mismatch in predicates
- Properly quoting identifiers
- Using the correct number of arguments for functions
- Casting to the correct data type
- Using the proper columns for joins

If there are any of the above mistakes, rewrite the query.
If there are no mistakes, just reproduce the original query with no further commentary.

Output the final SQL query only."""
prompt = ChatPromptTemplate.from_messages(
    [("system", system), ("human", "{query}")]
).partial(dialect=db.dialect)
validation_chain = prompt | llm | StrOutputParser()

full_chain = {"query": chain} | validation_chain
```


```python
query = full_chain.invoke(
    {
        "question": "What's the average Invoice from an American customer whose Fax is missing since 2003 but before 2010"
    }
)
print(query)
```

```output
SELECT AVG(i.Total) AS AverageInvoice
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
WHERE c.Country = 'USA'
AND c.Fax IS NULL
AND i.InvoiceDate >= '2003-01-01' 
AND i.InvoiceDate < '2010-01-01'
```


[Langsmith trace](https://smith.langchain.com/public/8a743295-a57c-4e4c-8625-bc7e36af9d74/r)에서 체인의 두 단계를 모두 볼 수 있는 방법에 주목하세요.

```python
db.run(query)
```


```output
'[(6.632999999999998,)]'
```


이 접근 방식의 명백한 단점은 쿼리를 생성하기 위해 하나가 아닌 두 번의 모델 호출을 해야 한다는 것입니다. 이를 해결하기 위해 쿼리 생성과 쿼리 검사를 단일 모델 호출에서 수행하려고 시도할 수 있습니다:

```python
system = """You are a {dialect} expert. Given an input question, create a syntactically correct {dialect} query to run.
Unless the user specifies in the question a specific number of examples to obtain, query for at most {top_k} results using the LIMIT clause as per {dialect}. You can order the results to return the most informative data in the database.
Never query for all columns from a table. You must query only the columns that are needed to answer the question. Wrap each column name in double quotes (") to denote them as delimited identifiers.
Pay attention to use only the column names you can see in the tables below. Be careful to not query for columns that do not exist. Also, pay attention to which column is in which table.
Pay attention to use date('now') function to get the current date, if the question involves "today".

Only use the following tables:
{table_info}

Write an initial draft of the query. Then double check the {dialect} query for common mistakes, including:
- Using NOT IN with NULL values
- Using UNION when UNION ALL should have been used
- Using BETWEEN for exclusive ranges
- Data type mismatch in predicates
- Properly quoting identifiers
- Using the correct number of arguments for functions
- Casting to the correct data type
- Using the proper columns for joins

Use format:

First draft: <<FIRST_DRAFT_QUERY>>
Final answer: <<FINAL_ANSWER_QUERY>>
"""
prompt = ChatPromptTemplate.from_messages(
    [("system", system), ("human", "{input}")]
).partial(dialect=db.dialect)


def parse_final_answer(output: str) -> str:
    return output.split("Final answer: ")[1]


chain = create_sql_query_chain(llm, db, prompt=prompt) | parse_final_answer
prompt.pretty_print()
```

```output
================================[1m System Message [0m================================

You are a [33;1m[1;3m{dialect}[0m expert. Given an input question, create a syntactically correct [33;1m[1;3m{dialect}[0m query to run.
Unless the user specifies in the question a specific number of examples to obtain, query for at most [33;1m[1;3m{top_k}[0m results using the LIMIT clause as per [33;1m[1;3m{dialect}[0m. You can order the results to return the most informative data in the database.
Never query for all columns from a table. You must query only the columns that are needed to answer the question. Wrap each column name in double quotes (") to denote them as delimited identifiers.
Pay attention to use only the column names you can see in the tables below. Be careful to not query for columns that do not exist. Also, pay attention to which column is in which table.
Pay attention to use date('now') function to get the current date, if the question involves "today".

Only use the following tables:
[33;1m[1;3m{table_info}[0m

Write an initial draft of the query. Then double check the [33;1m[1;3m{dialect}[0m query for common mistakes, including:
- Using NOT IN with NULL values
- Using UNION when UNION ALL should have been used
- Using BETWEEN for exclusive ranges
- Data type mismatch in predicates
- Properly quoting identifiers
- Using the correct number of arguments for functions
- Casting to the correct data type
- Using the proper columns for joins

Use format:

First draft: <<FIRST_DRAFT_QUERY>>
Final answer: <<FINAL_ANSWER_QUERY>>


================================[1m Human Message [0m=================================

[33;1m[1;3m{input}[0m
```


```python
query = chain.invoke(
    {
        "question": "What's the average Invoice from an American customer whose Fax is missing since 2003 but before 2010"
    }
)
print(query)
```

```output


SELECT AVG(i."Total") AS "AverageInvoice"
FROM "Invoice" i
JOIN "Customer" c ON i."CustomerId" = c."CustomerId"
WHERE c."Country" = 'USA'
AND c."Fax" IS NULL
AND i."InvoiceDate" BETWEEN '2003-01-01' AND '2010-01-01';
```


```python
db.run(query)
```


```output
'[(6.632999999999998,)]'
```


## 인간-루프

경우에 따라 우리의 데이터가 민감하여 인간이 먼저 승인하지 않으면 SQL 쿼리를 실행하고 싶지 않을 수 있습니다. [도구 사용: 인간-루프](/docs/how_to/tools_human) 페이지로 이동하여 모든 도구, 체인 또는 에이전트에 인간-루프를 추가하는 방법을 알아보세요.

## 오류 처리

어떤 시점에서 모델이 실수를 하고 잘못된 SQL 쿼리를 작성할 것입니다. 또는 데이터베이스에 문제가 발생할 수 있습니다. 또는 모델 API가 다운될 수 있습니다. 이러한 상황에서 우아하게 실패하고 아마도 자동으로 복구할 수 있도록 체인과 에이전트에 오류 처리 동작을 추가하고 싶습니다. 도구와 함께 오류 처리에 대해 알아보려면 [도구 사용: 오류 처리](/docs/how_to/tools_error) 페이지로 이동하세요.