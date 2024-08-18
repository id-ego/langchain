---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/kinetica.ipynb
description: Kinetica는 자연어를 SQL로 변환하여 데이터 검색을 간소화하는 방법을 보여주는 노트북입니다. LLM 체인 사용법을 설명합니다.
sidebar_label: Kinetica
---

# Kinetica 언어를 SQL 채팅 모델로 변환하기

이 노트북은 Kinetica를 사용하여 자연어를 SQL로 변환하고 데이터 검색 프로세스를 단순화하는 방법을 보여줍니다. 이 데모는 LLM의 기능보다는 체인을 생성하고 사용하는 메커니즘을 보여주기 위한 것입니다.

## 개요

Kinetica LLM 워크플로우를 사용하면 데이터베이스에서 테이블, 주석, 규칙 및 샘플을 포함한 추론에 필요한 정보를 제공하는 LLM 컨텍스트를 생성합니다. `ChatKinetica.load_messages_from_context()`를 호출하면 데이터베이스에서 컨텍스트 정보를 검색하여 채팅 프롬프트를 생성하는 데 사용할 수 있습니다.

채팅 프롬프트는 `SystemMessage`와 질문/SQL 쌍을 포함하는 `HumanMessage`/`AIMessage` 쌍으로 구성됩니다. 이 리스트에 쌍 샘플을 추가할 수 있지만 일반적인 자연어 대화를 촉진하기 위한 것은 아닙니다.

채팅 프롬프트에서 체인을 생성하고 실행하면 Kinetica LLM이 입력으로부터 SQL을 생성합니다. 선택적으로 `KineticaSqlOutputParser`를 사용하여 SQL을 실행하고 결과를 데이터프레임으로 반환할 수 있습니다.

현재 SQL 생성을 위해 지원되는 LLM은 2개입니다:

1. **Kinetica SQL-GPT**: 이 LLM은 OpenAI ChatGPT API를 기반으로 합니다.
2. **Kinetica SqlAssist**: 이 LLM은 Kinetica 데이터베이스와 통합하기 위해 특별히 제작되었으며 안전한 고객 프레미스에서 실행될 수 있습니다.

이번 데모에서는 **SqlAssist**를 사용할 것입니다. 더 많은 정보는 [Kinetica 문서 사이트](https://docs.kinetica.com/7.1/sql-gpt/concepts/)를 참조하십시오.

## 전제 조건

시작하려면 Kinetica DB 인스턴스가 필요합니다. 인스턴스가 없는 경우 [무료 개발 인스턴스](https://cloud.kinetica.com/trynow)를 얻을 수 있습니다.

다음 패키지를 설치해야 합니다...

```python
# Install Langchain community and core packages
%pip install --upgrade --quiet langchain-core langchain-community

# Install Kineitca DB connection package
%pip install --upgrade --quiet 'gpudb>=7.2.0.8' typeguard pandas tqdm

# Install packages needed for this tutorial
%pip install --upgrade --quiet faker ipykernel 
```


## 데이터베이스 연결

다음 환경 변수에서 데이터베이스 연결을 설정해야 합니다. 가상 환경을 사용하는 경우 프로젝트의 `.env` 파일에서 설정할 수 있습니다:
* `KINETICA_URL`: 데이터베이스 연결 URL
* `KINETICA_USER`: 데이터베이스 사용자
* `KINETICA_PASSWD`: 보안 비밀번호.

`KineticaChatLLM`의 인스턴스를 생성할 수 있다면 성공적으로 연결된 것입니다.

```python
<!--IMPORTS:[{"imported": "ChatKinetica", "source": "langchain_community.chat_models.kinetica", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.kinetica.ChatKinetica.html", "title": "Kinetica Language To SQL Chat Model"}]-->
from langchain_community.chat_models.kinetica import ChatKinetica

kinetica_llm = ChatKinetica()

# Test table we will create
table_name = "demo.user_profiles"

# LLM Context we will create
kinetica_ctx = "demo.test_llm_ctx"
```


## 테스트 데이터 생성

SQL을 생성하기 전에 Kinetica 테이블과 테이블을 추론할 수 있는 LLM 컨텍스트를 생성해야 합니다.

### 가짜 사용자 프로필 생성

`faker` 패키지를 사용하여 100개의 가짜 프로필로 데이터프레임을 생성합니다.

```python
from typing import Generator

import pandas as pd
from faker import Faker

Faker.seed(5467)
faker = Faker(locale="en-US")


def profile_gen(count: int) -> Generator:
    for id in range(0, count):
        rec = dict(id=id, **faker.simple_profile())
        rec["birthdate"] = pd.Timestamp(rec["birthdate"])
        yield rec


load_df = pd.DataFrame.from_records(data=profile_gen(100), index="id")
print(load_df.head())
```

```output
         username             name sex  \
id                                       
0       eduardo69       Haley Beck   F   
1        lbarrera  Joshua Stephens   M   
2         bburton     Paula Kaiser   F   
3       melissa49      Wendy Reese   F   
4   melissacarter      Manuel Rios   M   

                                              address                    mail  \
id                                                                              
0   59836 Carla Causeway Suite 939\nPort Eugene, I...  meltondenise@yahoo.com   
1   3108 Christina Forges\nPort Timothychester, KY...     erica80@hotmail.com   
2                    Unit 7405 Box 3052\nDPO AE 09858  timothypotts@gmail.com   
3   6408 Christopher Hill Apt. 459\nNew Benjamin, ...        dadams@gmail.com   
4    2241 Bell Gardens Suite 723\nScottside, CA 38463  williamayala@gmail.com   

    birthdate  
id             
0  1997-12-08  
1  1924-08-03  
2  1933-12-05  
3  1988-10-26  
4  1931-03-19
```

### 데이터프레임에서 Kinetica 테이블 생성

```python
from gpudb import GPUdbTable

gpudb_table = GPUdbTable.from_df(
    load_df,
    db=kinetica_llm.kdbc,
    table_name=table_name,
    clear_table=True,
    load_data=True,
)

# See the Kinetica column types
print(gpudb_table.type_as_df())
```

```output
        name    type   properties
0   username  string     [char32]
1       name  string     [char32]
2        sex  string      [char2]
3    address  string     [char64]
4       mail  string     [char32]
5  birthdate    long  [timestamp]
```

### LLM 컨텍스트 생성

Kinetica Workbench UI를 사용하여 LLM 컨텍스트를 생성하거나 `CREATE OR REPLACE CONTEXT` 구문으로 수동으로 생성할 수 있습니다.

여기서는 생성한 테이블을 참조하여 SQL 구문에서 컨텍스트를 생성합니다.

```python
from gpudb import GPUdbSamplesClause, GPUdbSqlContext, GPUdbTableClause

table_ctx = GPUdbTableClause(table=table_name, comment="Contains user profiles.")

samples_ctx = GPUdbSamplesClause(
    samples=[
        (
            "How many male users are there?",
            f"""
            select count(1) as num_users
                from {table_name}
                where sex = 'M';
            """,
        )
    ]
)

context_sql = GPUdbSqlContext(
    name=kinetica_ctx, tables=[table_ctx], samples=samples_ctx
).build_sql()

print(context_sql)
count_affected = kinetica_llm.kdbc.execute(context_sql)
count_affected
```

```output
CREATE OR REPLACE CONTEXT "demo"."test_llm_ctx" (
    TABLE = "demo"."user_profiles",
    COMMENT = 'Contains user profiles.'
),
(
    SAMPLES = ( 
        'How many male users are there?' = 'select count(1) as num_users
    from demo.user_profiles
    where sex = ''M'';' )
)
```


```output
1
```


## Langchain을 사용한 추론

아래 예제에서는 이전에 생성한 테이블과 LLM 컨텍스트에서 체인을 생성합니다. 이 체인은 SQL을 생성하고 결과 데이터를 데이터프레임으로 반환합니다.

### Kinetica DB에서 채팅 프롬프트 로드

`load_messages_from_context()` 함수는 DB에서 컨텍스트를 검색하고 이를 `ChatPromptTemplate`을 생성하는 데 사용하는 채팅 메시지 목록으로 변환합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Kinetica Language To SQL Chat Model"}]-->
from langchain_core.prompts import ChatPromptTemplate

# load the context from the database
ctx_messages = kinetica_llm.load_messages_from_context(kinetica_ctx)

# Add the input prompt. This is where input question will be substituted.
ctx_messages.append(("human", "{input}"))

# Create the prompt template.
prompt_template = ChatPromptTemplate.from_messages(ctx_messages)
prompt_template.pretty_print()
```

```output
================================[1m System Message [0m================================

CREATE TABLE demo.user_profiles AS
(
   username VARCHAR (32) NOT NULL,
   name VARCHAR (32) NOT NULL,
   sex VARCHAR (2) NOT NULL,
   address VARCHAR (64) NOT NULL,
   mail VARCHAR (32) NOT NULL,
   birthdate TIMESTAMP NOT NULL
);
COMMENT ON TABLE demo.user_profiles IS 'Contains user profiles.';

================================[1m Human Message [0m=================================

How many male users are there?

==================================[1m Ai Message [0m==================================

select count(1) as num_users
    from demo.user_profiles
    where sex = 'M';

================================[1m Human Message [0m=================================

[33;1m[1;3m{input}[0m
```

### 체인 생성

이 체인의 마지막 요소는 SQL을 실행하고 데이터프레임을 반환하는 `KineticaSqlOutputParser`입니다. 이는 선택 사항이며, 이를 생략하면 SQL만 반환됩니다.

```python
<!--IMPORTS:[{"imported": "KineticaSqlOutputParser", "source": "langchain_community.chat_models.kinetica", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.kinetica.KineticaSqlOutputParser.html", "title": "Kinetica Language To SQL Chat Model"}, {"imported": "KineticaSqlResponse", "source": "langchain_community.chat_models.kinetica", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.kinetica.KineticaSqlResponse.html", "title": "Kinetica Language To SQL Chat Model"}]-->
from langchain_community.chat_models.kinetica import (
    KineticaSqlOutputParser,
    KineticaSqlResponse,
)

chain = prompt_template | kinetica_llm | KineticaSqlOutputParser(kdbc=kinetica_llm.kdbc)
```


### SQL 생성

우리가 생성한 체인은 질문을 입력으로 받아 생성된 SQL과 데이터를 포함하는 `KineticaSqlResponse`를 반환합니다. 질문은 프롬프트를 생성하는 데 사용한 LLM 컨텍스트와 관련이 있어야 합니다.

```python
# Here you must ask a question relevant to the LLM context provided in the prompt template.
response: KineticaSqlResponse = chain.invoke(
    {"input": "What are the female users ordered by username?"}
)

print(f"SQL: {response.sql}")
print(response.dataframe.head())
```

```output
SQL: SELECT username, name
    FROM demo.user_profiles
    WHERE sex = 'F'
    ORDER BY username;
      username               name
0  alexander40       Tina Ramirez
1      bburton       Paula Kaiser
2      brian12  Stefanie Williams
3    brownanna      Jennifer Rowe
4       carl19       Amanda Potts
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)