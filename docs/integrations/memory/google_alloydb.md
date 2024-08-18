---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/google_alloydb.ipynb
description: Google Cloud AlloyDB for PostgreSQL를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명하는 노트북입니다.
  AI 기반 경험을 구축하세요.
---

# Google AlloyDB for PostgreSQL

> [Google Cloud AlloyDB for PostgreSQL](https://cloud.google.com/alloydb)는 가장 까다로운 기업 워크로드를 위한 완전 관리형 `PostgreSQL` 호환 데이터베이스 서비스입니다. `AlloyDB`는 `Google Cloud`와 `PostgreSQL`의 장점을 결합하여 뛰어난 성능, 확장성 및 가용성을 제공합니다. `AlloyDB` Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북은 `AlloyDBChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-alloydb-pg-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-alloydb-pg-python/blob/main/docs/chat_message_history.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [AlloyDB API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=alloydb.googleapis.com)
* [AlloyDB 인스턴스 만들기](https://cloud.google.com/alloydb/docs/instance-primary-create)
* [AlloyDB 데이터베이스 만들기](https://cloud.google.com/alloydb/docs/database-create)
* [데이터베이스에 IAM 데이터베이스 사용자 추가](https://cloud.google.com/alloydb/docs/manage-iam-authn) (선택 사항)

### 🦜🔗 라이브러리 설치
통합은 자체 `langchain-google-alloydb-pg` 패키지에 있으므로 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-google-alloydb-pg langchain-google-vertexai
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench의 경우 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
이 노트북에 로그인한 IAM 사용자로 Google Cloud에 인증하여 Google Cloud 프로젝트에 접근하세요.

* Colab을 사용하여 이 노트북을 실행하는 경우 아래 셀을 사용하고 계속 진행하세요.
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
`langchain-google-alloydb-pg` 패키지는 Google Cloud 프로젝트에서 [AlloyDB Admin API](https://console.cloud.google.com/flows/enableapi?apiid=alloydb.googleapis.com)를 활성화해야 합니다.

```python
# enable AlloyDB API
!gcloud services enable alloydb.googleapis.com
```


## 기본 사용법

### AlloyDB 데이터베이스 값 설정
[AlloyDB 클러스터 페이지](https://console.cloud.google.com/alloydb?_ga=2.223735448.2062268965.1707700487-2088871159.1707257687)에서 데이터베이스 값을 찾으세요.

```python
# @title Set Your Values Here { display-mode: "form" }
REGION = "us-central1"  # @param {type: "string"}
CLUSTER = "my-alloydb-cluster"  # @param {type: "string"}
INSTANCE = "my-alloydb-instance"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "message_store"  # @param {type: "string"}
```


### AlloyDBEngine 연결 풀

`ChatMessageHistory` 메모리 저장소로 AlloyDB를 설정하기 위한 요구 사항 및 인수 중 하나는 `AlloyDBEngine` 객체입니다. `AlloyDBEngine`은 AlloyDB 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

`AlloyDBEngine.from_instance()`를 사용하여 `AlloyDBEngine`을 생성하려면 다음 5가지만 제공하면 됩니다:

1. `project_id` : AlloyDB 인스턴스가 위치한 Google Cloud 프로젝트의 프로젝트 ID.
2. `region` : AlloyDB 인스턴스가 위치한 지역.
3. `cluster`: AlloyDB 클러스터의 이름.
4. `instance` : AlloyDB 인스턴스의 이름.
5. `database` : AlloyDB 인스턴스에서 연결할 데이터베이스의 이름.

기본적으로 [IAM 데이터베이스 인증](https://cloud.google.com/alloydb/docs/manage-iam-authn)이 데이터베이스 인증 방법으로 사용됩니다. 이 라이브러리는 환경에서 가져온 [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)에 속한 IAM 주체를 사용합니다.

선택적으로, AlloyDB 데이터베이스에 접근하기 위해 사용자 이름과 비밀번호를 사용하는 [내장 데이터베이스 인증](https://cloud.google.com/alloydb/docs/database-users/about)도 사용할 수 있습니다. `AlloyDBEngine.from_instance()`에 선택적 `user` 및 `password` 인수를 제공하면 됩니다:

* `user` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 사용자
* `password` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 비밀번호.

```python
from langchain_google_alloydb_pg import AlloyDBEngine

engine = AlloyDBEngine.from_instance(
    project_id=PROJECT_ID,
    region=REGION,
    cluster=CLUSTER,
    instance=INSTANCE,
    database=DATABASE,
)
```


### 테이블 초기화
`AlloyDBChatMessageHistory` 클래스는 채팅 메시지 기록을 저장하기 위해 특정 스키마를 가진 데이터베이스 테이블이 필요합니다.

`AlloyDBEngine` 엔진에는 적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 도우미 메서드 `init_chat_history_table()`가 있습니다.

```python
engine.init_chat_history_table(table_name=TABLE_NAME)
```


### AlloyDBChatMessageHistory

`AlloyDBChatMessageHistory` 클래스를 초기화하려면 다음 3가지만 제공하면 됩니다:

1. `engine` - `AlloyDBEngine` 엔진의 인스턴스.
2. `session_id` - 세션의 ID를 지정하는 고유 식별자 문자열.
3. `table_name` : 채팅 메시지 기록을 저장할 AlloyDB 데이터베이스 내의 테이블 이름.

```python
from langchain_google_alloydb_pg import AlloyDBChatMessageHistory

history = AlloyDBChatMessageHistory.create_sync(
    engine, session_id="test_session", table_name=TABLE_NAME
)
history.add_user_message("hi!")
history.add_ai_message("whats up?")
```


```python
history.messages
```


#### 정리
특정 세션의 기록이 더 이상 필요하지 않고 삭제할 수 있는 경우 다음과 같이 수행할 수 있습니다.

**참고:** 삭제되면 데이터는 더 이상 AlloyDB에 저장되지 않으며 영원히 사라집니다.

```python
history.clear()
```


## 🔗 체이닝

이 메시지 기록 클래스를 [LCEL Runnables](/docs/how_to/message_history)와 쉽게 결합할 수 있습니다.

이를 위해 [Google의 Vertex AI 채팅 모델](/docs/integrations/chat/google_vertex_ai_palm)을 사용하며, Google Cloud 프로젝트에서 [Vertex AI API](https://console.cloud.google.com/flows/enableapi?apiid=aiplatform.googleapis.com)를 활성화해야 합니다.

```python
# enable Vertex AI API
!gcloud services enable aiplatform.googleapis.com
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Google AlloyDB for PostgreSQL"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Google AlloyDB for PostgreSQL"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Google AlloyDB for PostgreSQL"}]-->
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
    lambda session_id: AlloyDBChatMessageHistory.create_sync(
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


```python
chain_with_history.invoke({"question": "Whats my name"}, config=config)
```