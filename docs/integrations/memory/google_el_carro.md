---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/google_el_carro.ipynb
description: Google El Carro Oracle을 사용하여 Kubernetes에서 Oracle 데이터베이스를 실행하고 Langchain
  통합으로 AI 경험을 구축하는 방법을 안내합니다.
---

# Google El Carro Oracle

> [Google Cloud El Carro Oracle](https://github.com/GoogleCloudPlatform/elcarro-oracle-operator)는 `Kubernetes`에서 `Oracle` 데이터베이스를 실행할 수 있는 방법을 제공하는 포터블, 오픈 소스, 커뮤니티 주도, 공급업체 종속이 없는 컨테이너 오케스트레이션 시스템입니다. `El Carro`는 포괄적이고 일관된 구성 및 배포뿐만 아니라 실시간 운영 및 모니터링을 위한 강력한 선언적 API를 제공합니다. `El Carro` Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 `Oracle` 데이터베이스의 기능을 확장하십시오.

이 가이드는 `El Carro` Langchain 통합을 사용하여 `ElCarroChatMessageHistory` 클래스를 통해 채팅 메시지 기록을 저장하는 방법을 설명합니다. 이 통합은 실행 위치에 관계없이 모든 `Oracle` 데이터베이스에서 작동합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-el-carro-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-el-carro-python/blob/main/docs/chat_message_history.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* `El Carro`로 Oracle 데이터베이스를 실행하려면 [시작하기](https://github.com/googleapis/langchain-google-el-carro-python/tree/main/README.md#getting-started) 섹션을 완료하세요.

### 🦜🔗 라이브러리 설치
통합은 자체 `langchain-google-el-carro` 패키지에 있으므로 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-google-el-carro langchain-google-vertexai langchain
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
Google Cloud에 이 노트북에 로그인한 IAM 사용자로 인증하여 Google Cloud 프로젝트에 접근합니다.

* 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
# from google.colab import auth

# auth.authenticate_user()
```


### ☁ Google Cloud 프로젝트 설정
이 노트북 내에서 Google Cloud 리소스를 활용할 수 있도록 Google Cloud 프로젝트를 설정합니다.

프로젝트 ID를 모르는 경우 다음을 시도하세요:

* `gcloud config list`를 실행합니다.
* `gcloud projects list`를 실행합니다.
* 지원 페이지를 참조하세요: [프로젝트 ID 찾기](https://support.google.com/googleapi/answer/7014113).

```python
# @markdown Please fill in the value below with your Google Cloud project ID and then run the cell.

PROJECT_ID = "my-project-id"  # @param {type:"string"}

# Set the project id
!gcloud config set project {PROJECT_ID}
```


## 기본 사용법

### Oracle 데이터베이스 연결 설정
다음 변수를 Oracle 데이터베이스 연결 세부정보로 채웁니다.

```python
# @title Set Your Values Here { display-mode: "form" }
HOST = "127.0.0.1"  # @param {type: "string"}
PORT = 3307  # @param {type: "integer"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "message_store"  # @param {type: "string"}
USER = "my-user"  # @param {type: "string"}
PASSWORD = input("Please provide a password to be used for the database user: ")
```


`El Carro`를 사용하는 경우 `El Carro` Kubernetes 인스턴스의 상태에서 호스트 이름과 포트 값을 찾을 수 있습니다.
PDB에 대해 생성한 사용자 비밀번호를 사용하세요.
예시

kubectl get -w instances.oracle.db.anthosapis.com -n db
NAME   DB ENGINE   VERSION   EDITION      ENDPOINT      URL                DB NAMES   BACKUP ID   READYSTATUS   READYREASON        DBREADYSTATUS   DBREADYREASON
mydb   Oracle      18c       Express      mydb-svc.db   34.71.69.25:6021                          False         CreateInProgress

### ElCarroEngine 연결 풀

`ElCarroEngine`은 Oracle 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

```python
from langchain_google_el_carro import ElCarroEngine

elcarro_engine = ElCarroEngine.from_instance(
    db_host=HOST,
    db_port=PORT,
    db_name=DATABASE,
    db_user=USER,
    db_password=PASSWORD,
)
```


### 테이블 초기화
`ElCarroChatMessageHistory` 클래스는 채팅 메시지 기록을 저장하기 위해 특정 스키마를 가진 데이터베이스 테이블이 필요합니다.

`ElCarroEngine` 클래스에는 적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 `init_chat_history_table()` 메서드가 있습니다.

```python
elcarro_engine.init_chat_history_table(table_name=TABLE_NAME)
```


### ElCarroChatMessageHistory

`ElCarroChatMessageHistory` 클래스를 초기화하려면 다음 3가지만 제공하면 됩니다:

1. `elcarro_engine` - `ElCarroEngine` 엔진의 인스턴스.
2. `session_id` - 세션을 위한 ID를 지정하는 고유 식별자 문자열.
3. `table_name` : 채팅 메시지 기록을 저장할 Oracle 데이터베이스 내의 테이블 이름.

```python
from langchain_google_el_carro import ElCarroChatMessageHistory

history = ElCarroChatMessageHistory(
    elcarro_engine=elcarro_engine, session_id="test_session", table_name=TABLE_NAME
)
history.add_user_message("hi!")
history.add_ai_message("whats up?")
```


```python
history.messages
```


#### 정리
특정 세션의 기록이 더 이상 필요하지 않으면 다음 방법으로 삭제할 수 있습니다.

**참고:** 삭제되면 데이터는 더 이상 데이터베이스에 저장되지 않으며 영원히 사라집니다.

```python
history.clear()
```


## 🔗 체이닝

이 메시지 기록 클래스를 [LCEL Runnables](/docs/how_to/message_history)와 쉽게 결합할 수 있습니다.

이를 위해 [Google의 Vertex AI 채팅 모델](/docs/integrations/chat/google_vertex_ai_palm) 중 하나를 사용할 것이며, 이를 위해 Google Cloud 프로젝트에서 [Vertex AI API를 활성화](https://console.cloud.google.com/flows/enableapi?apiid=aiplatform.googleapis.com)해야 합니다.

```python
# enable Vertex AI API
!gcloud services enable aiplatform.googleapis.com
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Google El Carro Oracle"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Google El Carro Oracle"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Google El Carro Oracle"}]-->
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
    lambda session_id: ElCarroChatMessageHistory(
        elcarro_engine,
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