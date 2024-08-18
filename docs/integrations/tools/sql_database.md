---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/sql_database.ipynb
description: SQLDatabase Toolkit은 SQL 데이터베이스와 상호작용하는 도구로, 에이전트가 관계형 데이터베이스의 데이터를 사용하여
  질문에 답할 수 있도록 돕습니다.
---

# SQLDatabase Toolkit

이 문서는 SQL 데이터베이스 [toolkit](/docs/concepts/#toolkits)를 시작하는 데 도움이 됩니다. 모든 `SQLDatabaseToolkit` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.sql.toolkit.SQLDatabaseToolkit.html)에서 확인하세요.

`SQLDatabaseToolkit` 내의 도구는 `SQL` 데이터베이스와 상호작용하도록 설계되었습니다.

일반적인 응용 프로그램은 에이전트가 관계형 데이터베이스의 데이터를 사용하여 질문에 답할 수 있도록 하는 것입니다. 이는 반복적인 방식으로 이루어질 수 있습니다(예: 오류 복구).

**⚠️ 보안 주의 ⚠️**

SQL 데이터베이스의 Q&A 시스템을 구축하려면 모델 생성 SQL 쿼리를 실행해야 합니다. 이를 수행하는 데는 고유한 위험이 있습니다. 데이터베이스 연결 권한이 항상 체인/에이전트의 필요에 맞게 최대한 좁게 설정되도록 하세요. 이는 모델 기반 시스템 구축의 위험을 완화하겠지만 완전히 제거하지는 않습니다. 일반적인 보안 모범 사례에 대한 자세한 내용은 [여기](/docs/security)를 참조하세요.

## 설정

개별 도구 실행의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 toolkit은 `langchain-community` 패키지에 포함되어 있습니다:

```python
%pip install --upgrade --quiet  langchain-community
```


시연 목적으로 LangChain [Hub](https://smith.langchain.com/hub)에서 프롬프트에 접근할 것입니다. 또한 에이전트와 함께 toolkit을 사용하는 것을 시연하기 위해 `langgraph`가 필요합니다. 이는 toolkit을 사용하는 데 필수는 아닙니다.

```python
%pip install --upgrade --quiet langchainhub langgraph
```


## 인스턴스화

`SQLDatabaseToolkit` toolkit은 다음을 요구합니다:

- [SQLDatabase](https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html) 객체;
- LLM 또는 채팅 모델 ( [QuerySQLCheckerTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.sql_database.tool.QuerySQLCheckerTool.html) 도구를 인스턴스화하기 위해).

아래에서 이러한 객체로 toolkit을 인스턴스화합니다. 먼저 데이터베이스 객체를 생성해 보겠습니다.

이 가이드는 [이 지침](https://database.guide/2-sample-databases-sqlite/)을 기반으로 한 예제 `Chinook` 데이터베이스를 사용합니다.

아래에서는 `requests` 라이브러리를 사용하여 `.sql` 파일을 가져오고 인메모리 SQLite 데이터베이스를 생성할 것입니다. 이 접근 방식은 경량이지만 일시적이며 스레드 안전하지 않다는 점에 유의하세요. 원하신다면, 파일을 로컬에 `Chinook.db`로 저장하고 `db = SQLDatabase.from_uri("sqlite:///Chinook.db")`를 통해 데이터베이스를 인스턴스화할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "SQLDatabase", "source": "langchain_community.utilities.sql_database", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html", "title": "SQLDatabase Toolkit"}]-->
import sqlite3

import requests
from langchain_community.utilities.sql_database import SQLDatabase
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool


def get_engine_for_chinook_db():
    """Pull sql file, populate in-memory database, and create engine."""
    url = "https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_Sqlite.sql"
    response = requests.get(url)
    sql_script = response.text

    connection = sqlite3.connect(":memory:", check_same_thread=False)
    connection.executescript(sql_script)
    return create_engine(
        "sqlite://",
        creator=lambda: connection,
        poolclass=StaticPool,
        connect_args={"check_same_thread": False},
    )


engine = get_engine_for_chinook_db()

db = SQLDatabase(engine)
```


우리는 또한 LLM 또는 채팅 모델이 필요합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

이제 toolkit을 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SQLDatabaseToolkit", "source": "langchain_community.agent_toolkits.sql.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.sql.toolkit.SQLDatabaseToolkit.html", "title": "SQLDatabase Toolkit"}]-->
from langchain_community.agent_toolkits.sql.toolkit import SQLDatabaseToolkit

toolkit = SQLDatabaseToolkit(db=db, llm=llm)
```


## 도구

사용 가능한 도구 보기:

```python
toolkit.get_tools()
```


```output
[QuerySQLDataBaseTool(description="Input to this tool is a detailed and correct SQL query, output is a result from the database. If the query is not correct, an error message will be returned. If an error is returned, rewrite the query, check the query, and try again. If you encounter an issue with Unknown column 'xxxx' in 'field list', use sql_db_schema to query the correct table fields.", db=<langchain_community.utilities.sql_database.SQLDatabase object at 0x105e02860>),
 InfoSQLDatabaseTool(description='Input to this tool is a comma-separated list of tables, output is the schema and sample rows for those tables. Be sure that the tables actually exist by calling sql_db_list_tables first! Example Input: table1, table2, table3', db=<langchain_community.utilities.sql_database.SQLDatabase object at 0x105e02860>),
 ListSQLDatabaseTool(db=<langchain_community.utilities.sql_database.SQLDatabase object at 0x105e02860>),
 QuerySQLCheckerTool(description='Use this tool to double check if your query is correct before executing it. Always use this tool before executing a query with sql_db_query!', db=<langchain_community.utilities.sql_database.SQLDatabase object at 0x105e02860>, llm=ChatOpenAI(client=<openai.resources.chat.completions.Completions object at 0x1148a97b0>, async_client=<openai.resources.chat.completions.AsyncCompletions object at 0x1148aaec0>, temperature=0.0, openai_api_key=SecretStr('**********'), openai_proxy=''), llm_chain=LLMChain(prompt=PromptTemplate(input_variables=['dialect', 'query'], template='\n{query}\nDouble check the {dialect} query above for common mistakes, including:\n- Using NOT IN with NULL values\n- Using UNION when UNION ALL should have been used\n- Using BETWEEN for exclusive ranges\n- Data type mismatch in predicates\n- Properly quoting identifiers\n- Using the correct number of arguments for functions\n- Casting to the correct data type\n- Using the proper columns for joins\n\nIf there are any of the above mistakes, rewrite the query. If there are no mistakes, just reproduce the original query.\n\nOutput the final SQL query only.\n\nSQL Query: '), llm=ChatOpenAI(client=<openai.resources.chat.completions.Completions object at 0x1148a97b0>, async_client=<openai.resources.chat.completions.AsyncCompletions object at 0x1148aaec0>, temperature=0.0, openai_api_key=SecretStr('**********'), openai_proxy='')))]
```


API 참조:

- [QuerySQLDataBaseTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.sql_database.tool.QuerySQLDataBaseTool.html)
- [InfoSQLDatabaseTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.sql_database.tool.InfoSQLDatabaseTool.html)
- [ListSQLDatabaseTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.sql_database.tool.ListSQLDatabaseTool.html)
- [QuerySQLCheckerTool](https://api.python.langchain.com/en/latest/tools/langchain_community.tools.sql_database.tool.QuerySQLCheckerTool.html)

## 에이전트 내에서 사용

[SQL Q&A 튜토리얼](/docs/tutorials/sql_qa/#agents)을 따라 아래에서는 간단한 질문-응답 에이전트에 toolkit의 도구를 장착합니다. 먼저 관련 프롬프트를 가져오고 필요한 매개변수로 채웁니다:

```python
from langchain import hub

prompt_template = hub.pull("langchain-ai/sql-agent-system-prompt")

assert len(prompt_template.messages) == 1
print(prompt_template.input_variables)
```

```output
['dialect', 'top_k']
```


```python
system_message = prompt_template.format(dialect="SQLite", top_k=5)
```


그런 다음 에이전트를 인스턴스화합니다:

```python
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(
    llm, toolkit.get_tools(), state_modifier=system_message
)
```


쿼리를 발행합니다:

```python
example_query = "Which country's customers spent the most?"

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

```output
================================[1m Human Message [0m=================================

Which country's customers spent the most?
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_list_tables (call_eiheSxiL0s90KE50XyBnBtJY)
 Call ID: call_eiheSxiL0s90KE50XyBnBtJY
  Args:
=================================[1m Tool Message [0m=================================
Name: sql_db_list_tables

Album, Artist, Customer, Employee, Genre, Invoice, InvoiceLine, MediaType, Playlist, PlaylistTrack, Track
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_schema (call_YKwGWt4UUVmxxY7vjjBDzFLJ)
 Call ID: call_YKwGWt4UUVmxxY7vjjBDzFLJ
  Args:
    table_names: Customer, Invoice, InvoiceLine
=================================[1m Tool Message [0m=================================
Name: sql_db_schema


CREATE TABLE "Customer" (
	"CustomerId" INTEGER NOT NULL, 
	"FirstName" NVARCHAR(40) NOT NULL, 
	"LastName" NVARCHAR(20) NOT NULL, 
	"Company" NVARCHAR(80), 
	"Address" NVARCHAR(70), 
	"City" NVARCHAR(40), 
	"State" NVARCHAR(40), 
	"Country" NVARCHAR(40), 
	"PostalCode" NVARCHAR(10), 
	"Phone" NVARCHAR(24), 
	"Fax" NVARCHAR(24), 
	"Email" NVARCHAR(60) NOT NULL, 
	"SupportRepId" INTEGER, 
	PRIMARY KEY ("CustomerId"), 
	FOREIGN KEY("SupportRepId") REFERENCES "Employee" ("EmployeeId")
)

/*
3 rows from Customer table:
CustomerId	FirstName	LastName	Company	Address	City	State	Country	PostalCode	Phone	Fax	Email	SupportRepId
1	Luís	Gonçalves	Embraer - Empresa Brasileira de Aeronáutica S.A.	Av. Brigadeiro Faria Lima, 2170	São José dos Campos	SP	Brazil	12227-000	+55 (12) 3923-5555	+55 (12) 3923-5566	luisg@embraer.com.br	3
2	Leonie	Köhler	None	Theodor-Heuss-Straße 34	Stuttgart	None	Germany	70174	+49 0711 2842222	None	leonekohler@surfeu.de	5
3	François	Tremblay	None	1498 rue Bélanger	Montréal	QC	Canada	H2G 1A7	+1 (514) 721-4711	None	ftremblay@gmail.com	3
*/


CREATE TABLE "Invoice" (
	"InvoiceId" INTEGER NOT NULL, 
	"CustomerId" INTEGER NOT NULL, 
	"InvoiceDate" DATETIME NOT NULL, 
	"BillingAddress" NVARCHAR(70), 
	"BillingCity" NVARCHAR(40), 
	"BillingState" NVARCHAR(40), 
	"BillingCountry" NVARCHAR(40), 
	"BillingPostalCode" NVARCHAR(10), 
	"Total" NUMERIC(10, 2) NOT NULL, 
	PRIMARY KEY ("InvoiceId"), 
	FOREIGN KEY("CustomerId") REFERENCES "Customer" ("CustomerId")
)

/*
3 rows from Invoice table:
InvoiceId	CustomerId	InvoiceDate	BillingAddress	BillingCity	BillingState	BillingCountry	BillingPostalCode	Total
1	2	2021-01-01 00:00:00	Theodor-Heuss-Straße 34	Stuttgart	None	Germany	70174	1.98
2	4	2021-01-02 00:00:00	Ullevålsveien 14	Oslo	None	Norway	0171	3.96
3	8	2021-01-03 00:00:00	Grétrystraat 63	Brussels	None	Belgium	1000	5.94
*/


CREATE TABLE "InvoiceLine" (
	"InvoiceLineId" INTEGER NOT NULL, 
	"InvoiceId" INTEGER NOT NULL, 
	"TrackId" INTEGER NOT NULL, 
	"UnitPrice" NUMERIC(10, 2) NOT NULL, 
	"Quantity" INTEGER NOT NULL, 
	PRIMARY KEY ("InvoiceLineId"), 
	FOREIGN KEY("TrackId") REFERENCES "Track" ("TrackId"), 
	FOREIGN KEY("InvoiceId") REFERENCES "Invoice" ("InvoiceId")
)

/*
3 rows from InvoiceLine table:
InvoiceLineId	InvoiceId	TrackId	UnitPrice	Quantity
1	1	2	0.99	1
2	1	4	0.99	1
3	2	6	0.99	1
*/
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_query (call_7WBDcMxl1h7MnI05njx1q8V9)
 Call ID: call_7WBDcMxl1h7MnI05njx1q8V9
  Args:
    query: SELECT c.Country, SUM(i.Total) AS TotalSpent FROM Customer c JOIN Invoice i ON c.CustomerId = i.CustomerId GROUP BY c.Country ORDER BY TotalSpent DESC LIMIT 1
=================================[1m Tool Message [0m=================================
Name: sql_db_query

[('USA', 523.0600000000003)]
==================================[1m Ai Message [0m==================================

Customers from the USA spent the most, with a total amount spent of $523.06.
```

에이전트가 오류에서 복구하는 것도 관찰할 수 있습니다:

```python
example_query = "Who are the top 3 best selling artists?"

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

```output
================================[1m Human Message [0m=================================

Who are the top 3 best selling artists?
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_query (call_9F6Bp2vwsDkeLW6FsJFqLiet)
 Call ID: call_9F6Bp2vwsDkeLW6FsJFqLiet
  Args:
    query: SELECT artist_name, SUM(quantity) AS total_sold FROM sales GROUP BY artist_name ORDER BY total_sold DESC LIMIT 3
=================================[1m Tool Message [0m=================================
Name: sql_db_query

Error: (sqlite3.OperationalError) no such table: sales
[SQL: SELECT artist_name, SUM(quantity) AS total_sold FROM sales GROUP BY artist_name ORDER BY total_sold DESC LIMIT 3]
(Background on this error at: https://sqlalche.me/e/20/e3q8)
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_list_tables (call_Gx5adzWnrBDIIxzUDzsn83zO)
 Call ID: call_Gx5adzWnrBDIIxzUDzsn83zO
  Args:
=================================[1m Tool Message [0m=================================
Name: sql_db_list_tables

Album, Artist, Customer, Employee, Genre, Invoice, InvoiceLine, MediaType, Playlist, PlaylistTrack, Track
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_schema (call_ftywrZgEgGWLrnk9dYC0xtZv)
 Call ID: call_ftywrZgEgGWLrnk9dYC0xtZv
  Args:
    table_names: Artist, Album, InvoiceLine
=================================[1m Tool Message [0m=================================
Name: sql_db_schema


CREATE TABLE "Album" (
	"AlbumId" INTEGER NOT NULL, 
	"Title" NVARCHAR(160) NOT NULL, 
	"ArtistId" INTEGER NOT NULL, 
	PRIMARY KEY ("AlbumId"), 
	FOREIGN KEY("ArtistId") REFERENCES "Artist" ("ArtistId")
)

/*
3 rows from Album table:
AlbumId	Title	ArtistId
1	For Those About To Rock We Salute You	1
2	Balls to the Wall	2
3	Restless and Wild	2
*/


CREATE TABLE "Artist" (
	"ArtistId" INTEGER NOT NULL, 
	"Name" NVARCHAR(120), 
	PRIMARY KEY ("ArtistId")
)

/*
3 rows from Artist table:
ArtistId	Name
1	AC/DC
2	Accept
3	Aerosmith
*/


CREATE TABLE "InvoiceLine" (
	"InvoiceLineId" INTEGER NOT NULL, 
	"InvoiceId" INTEGER NOT NULL, 
	"TrackId" INTEGER NOT NULL, 
	"UnitPrice" NUMERIC(10, 2) NOT NULL, 
	"Quantity" INTEGER NOT NULL, 
	PRIMARY KEY ("InvoiceLineId"), 
	FOREIGN KEY("TrackId") REFERENCES "Track" ("TrackId"), 
	FOREIGN KEY("InvoiceId") REFERENCES "Invoice" ("InvoiceId")
)

/*
3 rows from InvoiceLine table:
InvoiceLineId	InvoiceId	TrackId	UnitPrice	Quantity
1	1	2	0.99	1
2	1	4	0.99	1
3	2	6	0.99	1
*/
==================================[1m Ai Message [0m==================================
Tool Calls:
  sql_db_query (call_i6n3lmS7E2ZivN758VOayTiy)
 Call ID: call_i6n3lmS7E2ZivN758VOayTiy
  Args:
    query: SELECT Artist.Name AS artist_name, SUM(InvoiceLine.Quantity) AS total_sold FROM Artist JOIN Album ON Artist.ArtistId = Album.ArtistId JOIN Track ON Album.AlbumId = Track.AlbumId JOIN InvoiceLine ON Track.TrackId = InvoiceLine.TrackId GROUP BY Artist.Name ORDER BY total_sold DESC LIMIT 3
=================================[1m Tool Message [0m=================================
Name: sql_db_query

[('Iron Maiden', 140), ('U2', 107), ('Metallica', 91)]
==================================[1m Ai Message [0m==================================

The top 3 best selling artists are:
1. Iron Maiden - 140 units sold
2. U2 - 107 units sold
3. Metallica - 91 units sold
```

## 특정 기능

`SQLDatabaseToolkit`은 프롬프트 또는 기타 컨텍스트에서 사용하기 위한 편의성으로 [.get_context](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.sql.toolkit.SQLDatabaseToolkit.html#langchain_community.agent_toolkits.sql.toolkit.SQLDatabaseToolkit.get_context) 메서드를 구현합니다.

**⚠️ 면책 조항 ⚠️** : 에이전트는 삽입/업데이트/삭제 쿼리를 생성할 수 있습니다. 이는 예상되지 않을 경우 사용자 지정 프롬프트를 사용하거나 쓰기 권한이 없는 SQL 사용자를 생성하세요.

최종 사용자는 "가능한 가장 큰 쿼리를 실행하라"와 같은 간단한 질문으로 SQL 데이터베이스를 과부하할 수 있습니다. 생성된 쿼리는 다음과 같을 수 있습니다:

```sql
SELECT * FROM "public"."users"
    JOIN "public"."user_permissions" ON "public"."users".id = "public"."user_permissions".user_id
    JOIN "public"."projects" ON "public"."users".id = "public"."projects".user_id
    JOIN "public"."events" ON "public"."projects".id = "public"."events".project_id;
```


트랜잭션 SQL 데이터베이스의 경우, 위의 테이블 중 하나가 수백만 개의 행을 포함하면, 쿼리가 동일한 데이터베이스를 사용하는 다른 애플리케이션에 문제를 일으킬 수 있습니다.

대부분의 데이터 웨어하우스 지향 데이터베이스는 리소스 사용을 제한하기 위해 사용자 수준 쿼터를 지원합니다.

## API 참조

모든 SQLDatabaseToolkit 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.sql.toolkit.SQLDatabaseToolkit.html)에서 확인하세요.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)