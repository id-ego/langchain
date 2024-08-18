---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_firestore.ipynb
description: Firestore는 서버리스 문서 지향 데이터베이스로, Langchain 통합을 통해 AI 기반 경험을 구축하는 방법을 안내합니다.
---

# Google Firestore (네이티브 모드)

> [Firestore](https://cloud.google.com/firestore)는 수요에 맞게 확장되는 서버리스 문서 지향 데이터베이스입니다. Firestore의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `FirestoreLoader`와 `FirestoreSaver`를 사용하여 [langchain 문서를 저장, 로드 및 삭제하는 방법](/docs/how_to#document-loaders)에 대해 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-firestore-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-firestore-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Firestore API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=firestore.googleapis.com)
* [Firestore 데이터베이스 만들기](https://cloud.google.com/firestore/docs/manage-databases)

이 노트북의 런타임 환경에서 데이터베이스에 대한 액세스가 확인된 후, 다음 값을 입력하고 예제 스크립트를 실행하기 전에 셀을 실행하세요.

```python
# @markdown Please specify a source for demo purpose.
SOURCE = "test"  # @param {type:"Query"|"CollectionGroup"|"DocumentReference"|"string"}
```


### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-firestore` 패키지에 있으므로 설치해야 합니다.

```python
%pip install -upgrade --quiet langchain-google-firestore
```


**Colab 전용**: 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

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
* 지원 페이지 확인: [프로젝트 ID 찾기](https://support.google.com/googleapi/answer/7014113).

```python
# @markdown Please fill in the value below with your Google Cloud project ID and then run the cell.

PROJECT_ID = "my-project-id"  # @param {type:"string"}

# Set the project id
!gcloud config set project {PROJECT_ID}
```


### 🔐 인증

Google Cloud에 인증하여 이 노트북에 로그인한 IAM 사용자로 Google Cloud 프로젝트에 액세스하세요.

- 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
- Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


## 기본 사용법

### 문서 저장

`FirestoreSaver`는 문서를 Firestore에 저장할 수 있습니다. 기본적으로 메타데이터에서 문서 참조를 추출하려고 시도합니다.

`FirestoreSaver.upsert_documents(<documents>)`를 사용하여 langchain 문서를 저장하세요.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Google Firestore (Native Mode)"}]-->
from langchain_core.documents import Document
from langchain_google_firestore import FirestoreSaver

saver = FirestoreSaver()

data = [Document(page_content="Hello, World!")]

saver.upsert_documents(data)
```


#### 참조 없이 문서 저장

컬렉션이 지정되면 문서는 자동 생성된 ID로 저장됩니다.

```python
saver = FirestoreSaver("Collection")

saver.upsert_documents(data)
```


#### 다른 참조로 문서 저장

```python
doc_ids = ["AnotherCollection/doc_id", "foo/bar"]
saver = FirestoreSaver()

saver.upsert_documents(documents=data, document_ids=doc_ids)
```


### 컬렉션 또는 하위 컬렉션에서 로드

`FirestoreLoader.load()` 또는 `Firestore.lazy_load()`를 사용하여 langchain 문서를 로드하세요. `lazy_load`는 반복 중에만 데이터베이스를 쿼리하는 생성기를 반환합니다. `FirestoreLoader` 클래스를 초기화하려면 다음을 제공해야 합니다:

1. `source` - 쿼리, CollectionGroup, DocumentReference의 인스턴스 또는 Firestore 컬렉션에 대한 단일 `\`로 구분된 경로.

```python
from langchain_google_firestore import FirestoreLoader

loader_collection = FirestoreLoader("Collection")
loader_subcollection = FirestoreLoader("Collection/doc/SubCollection")


data_collection = loader_collection.load()
data_subcollection = loader_subcollection.load()
```


### 단일 문서 로드

```python
from google.cloud import firestore

client = firestore.Client()
doc_ref = client.collection("foo").document("bar")

loader_document = FirestoreLoader(doc_ref)

data = loader_document.load()
```


### CollectionGroup 또는 쿼리에서 로드

```python
from google.cloud.firestore import CollectionGroup, FieldFilter, Query

col_ref = client.collection("col_group")
collection_group = CollectionGroup(col_ref)

loader_group = FirestoreLoader(collection_group)

col_ref = client.collection("collection")
query = col_ref.where(filter=FieldFilter("region", "==", "west_coast"))

loader_query = FirestoreLoader(query)
```


### 문서 삭제

`FirestoreSaver.delete_documents(<documents>)`를 사용하여 Firestore 컬렉션에서 langchain 문서 목록을 삭제하세요.

문서 ID가 제공되면 문서는 무시됩니다.

```python
saver = FirestoreSaver()

saver.delete_documents(data)

# The Documents will be ignored and only the document ids will be used.
saver.delete_documents(data, doc_ids)
```


## 고급 사용법

### 사용자 정의 문서 페이지 콘텐츠 및 메타데이터로 문서 로드

`page_content_fields` 및 `metadata_fields`의 인수는 LangChain 문서 `page_content` 및 `metadata`에 기록될 Firestore 문서 필드를 지정합니다.

```python
loader = FirestoreLoader(
    source="foo/bar/subcol",
    page_content_fields=["data_field"],
    metadata_fields=["metadata_field"],
)

data = loader.load()
```


#### 페이지 콘텐츠 형식 사용자 정의

`page_content`에 단일 필드만 포함된 경우 정보는 필드 값만 포함됩니다. 그렇지 않으면 `page_content`는 JSON 형식이 됩니다.

### 연결 및 인증 사용자 정의

```python
from google.auth import compute_engine
from google.cloud.firestore import Client

client = Client(database="non-default-db", creds=compute_engine.Credentials())
loader = FirestoreLoader(
    source="foo",
    client=client,
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)