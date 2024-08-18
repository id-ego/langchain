---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/google_sql_pg.ipynb
description: Google Cloud SQL for PostgreSQL을 사용하여 채팅 메시지 기록을 저장하는 방법을 설명하는 노트북입니다.
  Langchain 통합을 활용하세요.
---

# Google SQL for PostgreSQL

> [Google Cloud SQL](https://cloud.google.com/sql)는 높은 성능, 원활한 통합 및 인상적인 확장성을 제공하는 완전 관리형 관계형 데이터베이스 서비스입니다. `MySQL`, `PostgreSQL`, 및 `SQL Server` 데이터베이스 엔진을 제공합니다. Cloud SQL의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `PostgresChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하기 위해 `Google Cloud SQL for PostgreSQL`을 사용하는 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-cloud-sql-pg-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-cloud-sql-pg-python/blob/main/docs/chat_message_history.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Cloud SQL Admin API 활성화.](https://console.cloud.google.com/marketplace/product/google/sqladmin.googleapis.com)
* [PostgreSQL용 Cloud SQL 인스턴스 만들기](https://cloud.google.com/sql/docs/postgres/create-instance)
* [Cloud SQL 데이터베이스 만들기](https://cloud.google.com/sql/docs/mysql/create-manage-databases)
* [데이터베이스에 IAM 데이터베이스 사용자 추가](https://cloud.google.com/sql/docs/postgres/add-manage-iam-users#creating-a-database-user) (선택 사항)

### 🦜🔗 라이브러리 설치
통합은 자체 `langchain-google-cloud-sql-pg` 패키지에 있으므로 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-google-cloud-sql-pg langchain-google-vertexai
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench의 경우 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
Google Cloud에 인증하여 이 노트북에 로그인한 IAM 사용자로 Google Cloud 프로젝트에 접근합니다.

* 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


### ☁ Google Cloud 프로젝트 설정
이 노트북 내에서 Google Cloud 리소스를 활용할 수 있도록 Google Cloud 프로젝트를 설정하세요.

프로젝트 ID를 모르는 경우 다음을 시도하세요:

* `gcloud config list` 실행.
* `gcloud projects list` 실행.
* 지원 페이지 참조: [프로젝트 ID 찾기](https://support.google.com/googleapi/answer/7014113).

```python
# @markdown Please fill in the value below with your Google Cloud project ID and then run the cell.

PROJECT_ID = "my-project-id"  # @param {type:"string"}

# Set the project id
!gcloud config set project {PROJECT_ID}
```


### 💡 API 활성화
`langchain-google-cloud-sql-pg` 패키지는 Google Cloud 프로젝트에서 [Cloud SQL Admin API를 활성화](https://console.cloud.google.com/flows/enableapi?apiid=sqladmin.googleapis.com)해야 합니다.

```python
# enable Cloud SQL Admin API
!gcloud services enable sqladmin.googleapis.com
```


## 기본 사용법

### Cloud SQL 데이터베이스 값 설정
[Cloud SQL 인스턴스 페이지](https://console.cloud.google.com/sql?_ga=2.223735448.2062268965.1707700487-2088871159.1707257687)에서 데이터베이스 값을 찾으세요.

```python
# @title Set Your Values Here { display-mode: "form" }
REGION = "us-central1"  # @param {type: "string"}
INSTANCE = "my-postgresql-instance"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "message_store"  # @param {type: "string"}
```


### PostgresEngine 연결 풀

Cloud SQL을 ChatMessageHistory 메모리 저장소로 설정하기 위한 요구 사항 중 하나는 `PostgresEngine` 객체입니다. `PostgresEngine`은 Cloud SQL 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

`PostgresEngine.from_instance()`를 사용하여 `PostgresEngine`을 생성하려면 4가지 정보만 제공하면 됩니다:

1. `project_id` : Cloud SQL 인스턴스가 위치한 Google Cloud 프로젝트의 프로젝트 ID.
2. `region` : Cloud SQL 인스턴스가 위치한 지역.
3. `instance` : Cloud SQL 인스턴스의 이름.
4. `database` : Cloud SQL 인스턴스에서 연결할 데이터베이스의 이름.

기본적으로 [IAM 데이터베이스 인증](https://cloud.google.com/sql/docs/postgres/iam-authentication#iam-db-auth)이 데이터베이스 인증 방법으로 사용됩니다. 이 라이브러리는 환경에서 가져온 [응용 프로그램 기본 자격 증명 (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)에 속하는 IAM 주체를 사용합니다.

IAM 데이터베이스 인증에 대한 자세한 내용은 다음을 참조하세요:

* [IAM 데이터베이스 인증을 위한 인스턴스 구성](https://cloud.google.com/sql/docs/postgres/create-edit-iam-instances)
* [IAM 데이터베이스 인증으로 사용자 관리](https://cloud.google.com/sql/docs/postgres/add-manage-iam-users)

선택적으로, Cloud SQL 데이터베이스에 접근하기 위해 사용자 이름과 비밀번호를 사용하는 [내장 데이터베이스 인증](https://cloud.google.com/sql/docs/postgres/built-in-authentication)도 사용할 수 있습니다. `PostgresEngine.from_instance()`에 선택적 `user` 및 `password` 인수를 제공하면 됩니다:

* `user` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 사용자
* `password` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 비밀번호.

```python
from langchain_google_cloud_sql_pg import PostgresEngine

engine = PostgresEngine.from_instance(
    project_id=PROJECT_ID, region=REGION, instance=INSTANCE, database=DATABASE
)
```


### 테이블 초기화
`PostgresChatMessageHistory` 클래스는 채팅 메시지 기록을 저장하기 위해 특정 스키마를 가진 데이터베이스 테이블이 필요합니다.

`PostgresEngine` 엔진에는 적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 도우미 메서드 `init_chat_history_table()`이 있습니다.

```python
engine.init_chat_history_table(table_name=TABLE_NAME)
```


### PostgresChatMessageHistory

`PostgresChatMessageHistory` 클래스를 초기화하려면 3가지 정보만 제공하면 됩니다:

1. `engine` - `PostgresEngine` 엔진의 인스턴스.
2. `session_id` - 세션을 위한 고유 식별자 문자열.
3. `table_name` : 채팅 메시지 기록을 저장할 Cloud SQL 데이터베이스 내의 테이블 이름.

```python
from langchain_google_cloud_sql_pg import PostgresChatMessageHistory

history = PostgresChatMessageHistory.create_sync(
    engine, session_id="test_session", table_name=TABLE_NAME
)
history.add_user_message("hi!")
history.add_ai_message("whats up?")
```


```python
history.messages
```


```output
[HumanMessage(content='hi!'), AIMessage(content='whats up?')]
```


#### 정리
특정 세션의 기록이 더 이상 필요하지 않고 삭제할 수 있는 경우 다음과 같은 방법으로 삭제할 수 있습니다.

**참고:** 삭제되면 데이터는 더 이상 Cloud SQL에 저장되지 않으며 영구적으로 사라집니다.

```python
history.clear()
```


## 🔗 체이닝

이 메시지 기록 클래스를 [LCEL Runnables](/docs/how_to/message_history)와 쉽게 결합할 수 있습니다.

이를 위해 [Google의 Vertex AI 채팅 모델](/docs/integrations/chat/google_vertex_ai_palm)을 사용하며, Google Cloud 프로젝트에서 [Vertex AI API를 활성화](https://console.cloud.google.com/flows/enableapi?apiid=aiplatform.googleapis.com)해야 합니다.

```python
# enable Vertex AI API
!gcloud services enable aiplatform.googleapis.com
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Google SQL for PostgreSQL"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Google SQL for PostgreSQL"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Google SQL for PostgreSQL"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_google_vertexai import ChatVertexAI
```


```python
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a helpful assistant."),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}"),
    ]
)

chain = prompt | ChatVertexAI(project=PROJECT_ID)
```


```python
chain_with_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: PostgresChatMessageHistory.create_sync(
        engine,
        session_id=session_id,
        table_name=TABLE_NAME,
    ),
    input_messages_key="question",
    history_messages_key="history",
)
```


```python
# This is where we configure the session id
config = {"configurable": {"session_id": "test_session"}}
```


```python
chain_with_history.invoke({"question": "Hi! I'm bob"}, config=config)
```


```output
AIMessage(content=' Hello Bob, how can I help you today?')
```


```python
chain_with_history.invoke({"question": "Whats my name"}, config=config)
```


```output
AIMessage(content=' Your name is Bob.')
```