---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/cassandra_database.ipynb
description: Apache Cassandra® 데이터베이스 툴킷은 AI 엔지니어가 Cassandra 데이터와 효율적으로 통합할 수 있도록
  지원하는 기능을 제공합니다.
---

# 카산드라 데이터베이스 툴킷

> `Apache Cassandra®`는 트랜잭션 애플리케이션 데이터를 저장하는 데 널리 사용되는 데이터베이스입니다. 대형 언어 모델에서 함수와 도구의 도입은 생성 AI 애플리케이션에서 기존 데이터에 대한 흥미로운 사용 사례를 열어주었습니다.

> `Cassandra Database` 툴킷은 AI 엔지니어가 카산드라 데이터와 에이전트를 효율적으로 통합할 수 있도록 하며, 다음과 같은 기능을 제공합니다:
> - 최적화된 쿼리를 통한 빠른 데이터 접근. 대부분의 쿼리는 단일 자릿수 ms 또는 그 이하로 실행되어야 합니다.
> - LLM 추론 능력을 향상시키기 위한 스키마 내성
> - Apache Cassandra®, DataStax Enterprise™ 및 DataStax Astra™를 포함한 다양한 카산드라 배포와의 호환성
> - 현재 툴킷은 SELECT 쿼리 및 스키마 내성 작업으로 제한됩니다. (안전이 최우선)

카산드라 DB 에이전트를 만드는 방법에 대한 자세한 정보는 [CQL 에이전트 요리책](https://github.com/langchain-ai/langchain/blob/master/cookbook/cql_agent.ipynb)을 참조하십시오.

## 빠른 시작
- `cassio` 라이브러리 설치
- 연결할 카산드라 데이터베이스에 대한 환경 변수 설정
- `CassandraDatabase` 초기화
- `toolkit.get_tools()`로 도구를 에이전트에 전달
- 편안히 앉아 모든 작업이 자동으로 수행되는 것을 지켜보세요

## 작동 이론

`Cassandra Query Language (CQL)`은 카산드라 데이터베이스와 상호작용하는 주요 *인간 중심* 방법입니다. 쿼리를 생성할 때 어느 정도의 유연성을 제공하지만, 카산드라 데이터 모델링 모범 사례에 대한 지식이 필요합니다. LLM 함수 호출은 에이전트가 추론하고 요청을 충족시키기 위해 도구를 선택할 수 있는 능력을 부여합니다. LLM을 사용하는 에이전트는 적절한 툴킷이나 툴킷 체인을 선택할 때 카산드라 특정 논리를 사용하여 추론해야 합니다. 이는 LLM이 상향식 솔루션을 제공해야 할 때 도입되는 무작위성을 줄입니다. LLM이 데이터베이스에 완전한 자유로운 접근을 갖기를 원하십니까? 네. 아마도 아닐 것입니다. 이를 달성하기 위해, 에이전트를 위한 질문을 구성할 때 사용할 프롬프트를 제공합니다:

당신은 다음 기능과 규칙을 가진 Apache Cassandra 전문가 쿼리 분석 봇입니다:
- 데이터베이스에서 특정 데이터를 찾는 것에 대한 최종 사용자로부터 질문을 받습니다.
- 데이터베이스의 스키마를 검사하고 쿼리 경로를 생성합니다.
- 사용자가 찾고 있는 데이터를 찾기 위한 올바른 쿼리를 제공하며, 쿼리 경로에 의해 제공된 단계를 보여줍니다.
- 파티션 키와 클러스터링 열을 사용하여 Apache Cassandra에 대한 쿼리 모범 사례를 따릅니다.
- 쿼리에서 ALLOW FILTERING 사용을 피합니다.
- 목표는 쿼리 경로를 찾는 것이므로, 최종 답변에 도달하기 위해 다른 테이블을 쿼리해야 할 수도 있습니다.

다음은 JSON 형식의 쿼리 경로 예시입니다:

```json
 {
  "query_paths": [
    {
      "description": "Direct query to users table using email",
      "steps": [
        {
          "table": "user_credentials",
          "query": 
             "SELECT userid FROM user_credentials WHERE email = 'example@example.com';"
        },
        {
          "table": "users",
          "query": "SELECT * FROM users WHERE userid = ?;"
        }
      ]
    }
  ]
}
```


## 제공된 도구

### `cassandra_db_schema`
연결된 데이터베이스 또는 특정 스키마에 대한 모든 스키마 정보를 수집합니다. 에이전트가 작업을 결정할 때 중요합니다.

### `cassandra_db_select_table_data`
특정 키스페이스와 테이블에서 데이터를 선택합니다. 에이전트는 프레디케이트 및 반환된 레코드 수에 대한 제한을 위한 매개변수를 전달할 수 있습니다.

### `cassandra_db_query`
매개변수 대신 에이전트가 완전히 형성된 쿼리 문자열을 사용하는 `cassandra_db_select_table_data`의 실험적 대안입니다. *경고*: 이는 성능이 떨어지거나 작동하지 않을 수 있는 비정상적인 쿼리로 이어질 수 있습니다. 이는 향후 릴리스에서 제거될 수 있습니다. 만약 멋진 일을 한다면, 그것에 대해서도 알고 싶습니다. 당신은 결코 알 수 없습니다!

## 환경 설정

다음 Python 모듈을 설치하십시오:

```bash
pip install ipykernel python-dotenv cassio langchain_openai langchain langchain-community langchainhub
```


### .env 파일
연결은 `cassio`를 통해 `auto=True` 매개변수를 사용하며, 노트북은 OpenAI를 사용합니다. 따라서 `.env` 파일을 적절히 생성해야 합니다.

카산드라의 경우, 설정:
```bash
CASSANDRA_CONTACT_POINTS
CASSANDRA_USERNAME
CASSANDRA_PASSWORD
CASSANDRA_KEYSPACE
```


아스트라의 경우, 설정:
```bash
ASTRA_DB_APPLICATION_TOKEN
ASTRA_DB_DATABASE_ID
ASTRA_DB_KEYSPACE
```


예를 들어:

```bash
# Connection to Astra:
ASTRA_DB_DATABASE_ID=a1b2c3d4-...
ASTRA_DB_APPLICATION_TOKEN=AstraCS:...
ASTRA_DB_KEYSPACE=notebooks

# Also set 
OPENAI_API_KEY=sk-....
```


(아래 코드를 수정하여 `cassio`와 직접 연결할 수도 있습니다.)

```python
from dotenv import load_dotenv

load_dotenv(override=True)
```


```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Cassandra Database Toolkit"}, {"imported": "create_openai_tools_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_tools.base.create_openai_tools_agent.html", "title": "Cassandra Database Toolkit"}, {"imported": "CassandraDatabaseToolkit", "source": "langchain_community.agent_toolkits.cassandra_database.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.cassandra_database.toolkit.CassandraDatabaseToolkit.html", "title": "Cassandra Database Toolkit"}, {"imported": "CassandraDatabase", "source": "langchain_community.utilities.cassandra_database", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.cassandra_database.CassandraDatabase.html", "title": "Cassandra Database Toolkit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Cassandra Database Toolkit"}]-->
# Import necessary libraries
import os

import cassio
from langchain import hub
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain_community.agent_toolkits.cassandra_database.toolkit import (
    CassandraDatabaseToolkit,
)
from langchain_community.tools.cassandra_database.prompt import QUERY_PATH_PROMPT
from langchain_community.utilities.cassandra_database import CassandraDatabase
from langchain_openai import ChatOpenAI
```


## 카산드라 데이터베이스에 연결

```python
cassio.init(auto=True)
session = cassio.config.resolve_session()
if not session:
    raise Exception(
        "Check environment configuration or manually configure cassio connection parameters"
    )
```


```python
# Test data pep

session = cassio.config.resolve_session()

session.execute("""DROP KEYSPACE IF EXISTS langchain_agent_test; """)

session.execute(
    """
CREATE KEYSPACE if not exists langchain_agent_test 
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
"""
)

session.execute(
    """
    CREATE TABLE IF NOT EXISTS langchain_agent_test.user_credentials (
    user_email text PRIMARY KEY,
    user_id UUID,
    password TEXT
);
"""
)

session.execute(
    """
    CREATE TABLE IF NOT EXISTS langchain_agent_test.users (
    id UUID PRIMARY KEY,
    name TEXT,
    email TEXT
);"""
)

session.execute(
    """
    CREATE TABLE IF NOT EXISTS langchain_agent_test.user_videos ( 
    user_id UUID,
    video_id UUID,
    title TEXT,
    description TEXT,
    PRIMARY KEY (user_id, video_id)
);
"""
)

user_id = "522b1fe2-2e36-4cef-a667-cd4237d08b89"
video_id = "27066014-bad7-9f58-5a30-f63fe03718f6"

session.execute(
    f"""
    INSERT INTO langchain_agent_test.user_credentials (user_id, user_email) 
    VALUES ({user_id}, 'patrick@datastax.com');
"""
)

session.execute(
    f"""
    INSERT INTO langchain_agent_test.users (id, name, email) 
    VALUES ({user_id}, 'Patrick McFadin', 'patrick@datastax.com');
"""
)

session.execute(
    f"""
    INSERT INTO langchain_agent_test.user_videos (user_id, video_id, title)
    VALUES ({user_id}, {video_id}, 'Use Langflow to Build a LangChain LLM Application in 5 Minutes');
"""
)

session.set_keyspace("langchain_agent_test")
```


```python
# Create a CassandraDatabase instance
# Uses the cassio session to connect to the database
db = CassandraDatabase()
```


```python
# Choose the LLM that will drive the agent
# Only certain models support this
llm = ChatOpenAI(temperature=0, model="gpt-4-1106-preview")
toolkit = CassandraDatabaseToolkit(db=db)

tools = toolkit.get_tools()

print("Available tools:")
for tool in tools:
    print(tool.name + "\t- " + tool.description)
```

```output
Available tools:
cassandra_db_schema	- 
    Input to this tool is a keyspace name, output is a table description 
    of Apache Cassandra tables.
    If the query is not correct, an error message will be returned.
    If an error is returned, report back to the user that the keyspace 
    doesn't exist and stop.
    
cassandra_db_query	- 
    Execute a CQL query against the database and get back the result.
    If the query is not correct, an error message will be returned.
    If an error is returned, rewrite the query, check the query, and try again.
    
cassandra_db_select_table_data	- 
    Tool for getting data from a table in an Apache Cassandra database. 
    Use the WHERE clause to specify the predicate for the query that uses the 
    primary key. A blank predicate will return all rows. Avoid this if possible. 
    Use the limit to specify the number of rows to return. A blank limit will 
    return all rows.
```


```python
prompt = hub.pull("hwchase17/openai-tools-agent")

# Construct the OpenAI Tools agent
agent = create_openai_tools_agent(llm, tools, prompt)
```


```python
input = (
    QUERY_PATH_PROMPT
    + "\n\nHere is your task: Find all the videos that the user with the email address 'patrick@datastax.com' has uploaded to the langchain_agent_test keyspace."
)

agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

response = agent_executor.invoke({"input": input})

print(response["output"])
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `cassandra_db_schema` with `{'keyspace': 'langchain_agent_test'}`


[0m[36;1m[1;3mTable Name: user_credentials
- Keyspace: langchain_agent_test
- Columns
  - password (text)
  - user_email (text)
  - user_id (uuid)
- Partition Keys: (user_email)
- Clustering Keys: 

Table Name: user_videos
- Keyspace: langchain_agent_test
- Columns
  - description (text)
  - title (text)
  - user_id (uuid)
  - video_id (uuid)
- Partition Keys: (user_id)
- Clustering Keys: (video_id asc)


Table Name: users
- Keyspace: langchain_agent_test
- Columns
  - email (text)
  - id (uuid)
  - name (text)
- Partition Keys: (id)
- Clustering Keys: 

[0m[32;1m[1;3m
Invoking: `cassandra_db_select_table_data` with `{'keyspace': 'langchain_agent_test', 'table': 'user_credentials', 'predicate': "user_email = 'patrick@datastax.com'", 'limit': 1}`


[0m[38;5;200m[1;3mRow(user_email='patrick@datastax.com', password=None, user_id=UUID('522b1fe2-2e36-4cef-a667-cd4237d08b89'))[0m[32;1m[1;3m
Invoking: `cassandra_db_select_table_data` with `{'keyspace': 'langchain_agent_test', 'table': 'user_videos', 'predicate': 'user_id = 522b1fe2-2e36-4cef-a667-cd4237d08b89', 'limit': 10}`


[0m[38;5;200m[1;3mRow(user_id=UUID('522b1fe2-2e36-4cef-a667-cd4237d08b89'), video_id=UUID('27066014-bad7-9f58-5a30-f63fe03718f6'), description='DataStax Academy is a free resource for learning Apache Cassandra.', title='DataStax Academy')[0m[32;1m[1;3mTo find all the videos that the user with the email address 'patrick@datastax.com' has uploaded to the `langchain_agent_test` keyspace, we can follow these steps:

1. Query the `user_credentials` table to find the `user_id` associated with the email 'patrick@datastax.com'.
2. Use the `user_id` obtained from the first step to query the `user_videos` table to retrieve all the videos uploaded by the user.

Here is the query path in JSON format:

```json
{
  "query_paths": [
    {
      "description": "Find user_id from user_credentials and then query user_videos for all videos uploaded by the user",
      "steps": [
        {
          "table": "user_credentials",
          "query": "SELECT user_id FROM user_credentials WHERE user_email = 'patrick@datastax.com';"
        },
        {
          "table": "user_videos",
          "query": "SELECT * FROM user_videos WHERE user_id = 522b1fe2-2e36-4cef-a667-cd4237d08b89;"
        }
      ]
    }
  ]
}
```


이 쿼리 경로를 따라, 사용자 ID `522b1fe2-2e36-4cef-a667-cd4237d08b89`를 가진 사용자가 제목이 'DataStax Academy'이고 설명이 'DataStax Academy는 Apache Cassandra를 배우기 위한 무료 리소스입니다.'인 비디오를 최소한 하나 업로드했음을 발견했습니다. 이 비디오의 video_id는 `27066014-bad7-9f58-5a30-f63fe03718f6`입니다. 더 많은 비디오가 있다면, 동일한 쿼리를 사용하여 이를 검색할 수 있으며, 필요에 따라 제한을 늘릴 수 있습니다.

[1m> 체인 완료.[0m
이메일 주소 'patrick@datastax.com'을 가진 사용자가 `langchain_agent_test` 키스페이스에 업로드한 모든 비디오를 찾기 위해, 다음 단계를 따를 수 있습니다:

1. `user_credentials` 테이블을 쿼리하여 이메일 'patrick@datastax.com'과 관련된 `user_id`를 찾습니다.
2. 첫 번째 단계에서 얻은 `user_id`를 사용하여 `user_videos` 테이블을 쿼리하여 사용자가 업로드한 모든 비디오를 검색합니다.

여기 JSON 형식의 쿼리 경로가 있습니다:

```json
{
  "query_paths": [
    {
      "description": "Find user_id from user_credentials and then query user_videos for all videos uploaded by the user",
      "steps": [
        {
          "table": "user_credentials",
          "query": "SELECT user_id FROM user_credentials WHERE user_email = 'patrick@datastax.com';"
        },
        {
          "table": "user_videos",
          "query": "SELECT * FROM user_videos WHERE user_id = 522b1fe2-2e36-4cef-a667-cd4237d08b89;"
        }
      ]
    }
  ]
}
```


이 쿼리 경로를 따라, 사용자 ID `522b1fe2-2e36-4cef-a667-cd4237d08b89`를 가진 사용자가 제목이 'DataStax Academy'이고 설명이 'DataStax Academy는 Apache Cassandra를 배우기 위한 무료 리소스입니다.'인 비디오를 최소한 하나 업로드했음을 발견했습니다. 이 비디오의 video_id는 `27066014-bad7-9f58-5a30-f63fe03718f6`입니다. 더 많은 비디오가 있다면, 동일한 쿼리를 사용하여 이를 검색할 수 있으며, 필요에 따라 제한을 늘릴 수 있습니다.
```

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)
```