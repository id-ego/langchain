---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/google_firestore.ipynb
description: Google Cloud Firestore를 사용하여 채팅 메시지 기록을 저장하는 방법을 설명하는 문서입니다. Langchain
  통합을 활용하세요.
---

# Google Firestore (네이티브 모드)

> [Google Cloud Firestore](https://cloud.google.com/firestore)는 수요에 맞게 확장되는 서버리스 문서 지향 데이터베이스입니다. `Firestore`의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `FirestoreChatMessageHistory` 클래스를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-firestore-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-firestore-python/blob/main/docs/chat_message_history.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Firestore API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=firestore.googleapis.com)
* [Firestore 데이터베이스 만들기](https://cloud.google.com/firestore/docs/manage-databases)

이 노트북의 런타임 환경에서 데이터베이스에 대한 액세스를 확인한 후, 다음 값을 입력하고 예제 스크립트를 실행하기 전에 셀을 실행하세요.

### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-firestore` 패키지에 있으므로 설치해야 합니다.

```python
%pip install -upgrade --quiet langchain-google-firestore
```


**Colab 전용**: 커널을 재시작하려면 다음 셀의 주석을 제거하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
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


### 🔐 인증

Google Cloud 프로젝트에 액세스하기 위해 이 노트북에 로그인한 IAM 사용자로 Google Cloud에 인증하세요.

- 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
- Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


## 기본 사용법

### FirestoreChatMessageHistory

`FirestoreChatMessageHistory` 클래스를 초기화하려면 다음 3가지만 제공하면 됩니다:

1. `session_id` - 세션을 위한 ID를 지정하는 고유 식별자 문자열.
2. `collection` : Firestore 컬렉션에 대한 단일 `/`로 구분된 경로.

```python
from langchain_google_firestore import FirestoreChatMessageHistory

chat_history = FirestoreChatMessageHistory(
    session_id="user-session-id", collection="HistoryMessages"
)

chat_history.add_user_message("Hi!")
chat_history.add_ai_message("How can I help you?")
```


```python
chat_history.messages
```


#### 정리
특정 세션의 기록이 더 이상 필요하지 않으면 데이터베이스와 메모리에서 삭제할 수 있습니다.

**참고:** 삭제되면 데이터는 더 이상 Firestore에 저장되지 않으며 영원히 사라집니다.

```python
chat_history.clear()
```


### 사용자 정의 클라이언트

클라이언트는 기본적으로 사용 가능한 환경 변수를 사용하여 생성됩니다. [사용자 정의 클라이언트](https://cloud.google.com/python/docs/reference/firestore/latest/client)를 생성자에 전달할 수 있습니다.

```python
from google.auth import compute_engine
from google.cloud import firestore

client = firestore.Client(
    project="project-custom",
    database="non-default-database",
    credentials=compute_engine.Credentials(),
)

history = FirestoreChatMessageHistory(
    session_id="session-id", collection="History", client=client
)

history.add_user_message("New message")

history.messages

history.clear()
```