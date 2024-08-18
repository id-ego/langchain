---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/google_bigtable.ipynb
description: 구글 클라우드 빅테이블을 사용하여 채팅 메시지 기록을 저장하는 방법을 다루며, Langchain 통합을 활용한 AI 경험 구축을
  안내합니다.
---

# 구글 빅테이블

> [구글 클라우드 빅테이블](https://cloud.google.com/bigtable)은 구조화된, 반구조화된 또는 비구조화된 데이터에 대한 빠른 접근을 위해 이상적인 키-값 및 와이드 컬럼 저장소입니다. 빅테이블의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북은 `BigtableChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-bigtable-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-bigtable-python/blob/main/docs/chat_message_history.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [구글 클라우드 프로젝트 생성하기](https://developers.google.com/workspace/guides/create-project)
* [빅테이블 API 활성화하기](https://console.cloud.google.com/flows/enableapi?apiid=bigtable.googleapis.com)
* [빅테이블 인스턴스 생성하기](https://cloud.google.com/bigtable/docs/creating-instance)
* [빅테이블 테이블 생성하기](https://cloud.google.com/bigtable/docs/managing-tables)
* [빅테이블 접근 자격 증명 생성하기](https://developers.google.com/workspace/guides/create-credentials)

### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-bigtable` 패키지에 있으므로 설치해야 합니다.

```python
%pip install -upgrade --quiet langchain-google-bigtable
```


**Colab 전용**: 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench의 경우 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
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


### 🔐 인증

구글 클라우드에 인증하여 이 노트북에 로그인한 IAM 사용자로서 구글 클라우드 프로젝트에 접근하세요.

- 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
- Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


## 기본 사용법

### 빅테이블 스키마 초기화

BigtableChatMessageHistory의 스키마는 인스턴스와 테이블이 존재해야 하며, `langchain`이라는 컬럼 패밀리가 있어야 합니다.

```python
# @markdown Please specify an instance and a table for demo purpose.
INSTANCE_ID = "my_instance"  # @param {type:"string"}
TABLE_ID = "my_table"  # @param {type:"string"}
```


테이블이나 컬럼 패밀리가 존재하지 않는 경우 다음 함수를 사용하여 생성할 수 있습니다:

```python
from google.cloud import bigtable
from langchain_google_bigtable import create_chat_history_table

create_chat_history_table(
    instance_id=INSTANCE_ID,
    table_id=TABLE_ID,
)
```


### BigtableChatMessageHistory

`BigtableChatMessageHistory` 클래스를 초기화하려면 다음 3가지만 제공하면 됩니다:

1. `instance_id` - 채팅 메시지 기록에 사용할 빅테이블 인스턴스.
2. `table_id` : 채팅 메시지 기록을 저장할 빅테이블 테이블.
3. `session_id` - 세션을 위한 고유 식별자 문자열.

```python
from langchain_google_bigtable import BigtableChatMessageHistory

message_history = BigtableChatMessageHistory(
    instance_id=INSTANCE_ID,
    table_id=TABLE_ID,
    session_id="user-session-id",
)

message_history.add_user_message("hi!")
message_history.add_ai_message("whats up?")
```


```python
message_history.messages
```


#### 정리하기

특정 세션의 기록이 더 이상 필요하지 않으면 다음과 같은 방법으로 삭제할 수 있습니다.

**참고:** 삭제되면 데이터는 더 이상 빅테이블에 저장되지 않으며 영원히 사라집니다.

```python
message_history.clear()
```


## 고급 사용법

### 사용자 정의 클라이언트
기본적으로 생성된 클라이언트는 admin=True 옵션만 사용하는 기본 클라이언트입니다. 비기본 클라이언트를 사용하려면 [사용자 정의 클라이언트](https://cloud.google.com/python/docs/reference/bigtable/latest/client#class-googlecloudbigtableclientclientprojectnone-credentialsnone-readonlyfalse-adminfalse-clientinfonone-clientoptionsnone-adminclientoptionsnone-channelnone)를 생성자에 전달할 수 있습니다.

```python
from google.cloud import bigtable

client = (bigtable.Client(...),)

create_chat_history_table(
    instance_id="my-instance",
    table_id="my-table",
    client=client,
)

custom_client_message_history = BigtableChatMessageHistory(
    instance_id="my-instance",
    table_id="my-table",
    client=client,
)
```