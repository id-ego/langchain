---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/google_spanner.ipynb
description: 구글 클라우드 스패너를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다. SpannerChatMessageHistory
  클래스를 활용하세요.
---

# 구글 스패너
> [구글 클라우드 스패너](https://cloud.google.com/spanner)는 무제한 확장성과 관계형 의미론(예: 보조 인덱스, 강력한 일관성, 스키마 및 SQL)을 결합하여 99.999% 가용성을 제공하는 매우 확장 가능한 데이터베이스입니다.

이 노트북은 `SpannerChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하는 방법을 다룹니다. 패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-spanner-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-spanner-python/blob/main/samples/chat_message_history.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [구글 클라우드 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [클라우드 스패너 API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=spanner.googleapis.com)
* [스패너 인스턴스 만들기](https://cloud.google.com/spanner/docs/create-manage-instances)
* [스패너 데이터베이스 만들기](https://cloud.google.com/spanner/docs/create-manage-databases)

### 🦜🔗 라이브러리 설치
통합은 자체 `langchain-google-spanner` 패키지에 있으므로 이를 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-google-spanner
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench의 경우 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
구글 클라우드에 이 노트북에 로그인한 IAM 사용자로 인증하여 구글 클라우드 프로젝트에 접근합니다.

* 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


### ☁ 구글 클라우드 프로젝트 설정
이 노트북 내에서 구글 클라우드 리소스를 활용할 수 있도록 구글 클라우드 프로젝트를 설정하세요.

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
`langchain-google-spanner` 패키지는 구글 클라우드 프로젝트에서 [스패너 API를 활성화](https://console.cloud.google.com/flows/enableapi?apiid=spanner.googleapis.com)해야 합니다.

```python
# enable Spanner API
!gcloud services enable spanner.googleapis.com
```


## 기본 사용법

### 스패너 데이터베이스 값 설정
[스패너 인스턴스 페이지](https://console.cloud.google.com/spanner)에서 데이터베이스 값을 찾으세요.

```python
# @title Set Your Values Here { display-mode: "form" }
INSTANCE = "my-instance"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "message_store"  # @param {type: "string"}
```


### 테이블 초기화
`SpannerChatMessageHistory` 클래스는 채팅 메시지 기록을 저장하기 위해 특정 스키마를 가진 데이터베이스 테이블이 필요합니다.

적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 도우미 메서드 `init_chat_history_table()`이 있습니다.

```python
from langchain_google_spanner import (
    SpannerChatMessageHistory,
)

SpannerChatMessageHistory.init_chat_history_table(table_name=TABLE_NAME)
```


### SpannerChatMessageHistory

`SpannerChatMessageHistory` 클래스를 초기화하려면 다음 3가지만 제공하면 됩니다:

1. `instance_id` - 스패너 인스턴스의 이름
2. `database_id` - 스패너 데이터베이스의 이름
3. `session_id` - 세션에 대한 ID를 지정하는 고유 식별자 문자열
4. `table_name` - 채팅 메시지 기록을 저장할 데이터베이스 내의 테이블 이름

```python
message_history = SpannerChatMessageHistory(
    instance_id=INSTANCE,
    database_id=DATABASE,
    table_name=TABLE_NAME,
    session_id="user-session-id",
)

message_history.add_user_message("hi!")
message_history.add_ai_message("whats up?")
```


```python
message_history.messages
```


## 사용자 정의 클라이언트
기본적으로 생성된 클라이언트는 기본 클라이언트입니다. 비기본 클라이언트를 사용하려면 [사용자 정의 클라이언트](https://cloud.google.com/spanner/docs/samples/spanner-create-client-with-query-options#spanner_create_client_with_query_options-python)를 생성자에 전달할 수 있습니다.

```python
from google.cloud import spanner

custom_client_message_history = SpannerChatMessageHistory(
    instance_id="my-instance",
    database_id="my-database",
    client=spanner.Client(...),
)
```


## 정리

특정 세션의 기록이 더 이상 필요하지 않거나 삭제할 수 있는 경우 다음과 같은 방법으로 삭제할 수 있습니다. 
참고: 삭제되면 데이터는 더 이상 클라우드 스패너에 저장되지 않으며 영원히 사라집니다.

```python
message_history = SpannerChatMessageHistory(
    instance_id=INSTANCE,
    database_id=DATABASE,
    table_name=TABLE_NAME,
    session_id="user-session-id",
)

message_history.clear()
```