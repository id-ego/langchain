---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_spanner.ipynb
description: Google Spanner는 무제한 확장성과 관계형 의미론을 결합한 데이터베이스로, Langchain 문서를 저장, 로드 및
  삭제하는 방법을 다룹니다.
---

# 구글 스패너

> [스패너](https://cloud.google.com/spanner)는 무제한 확장성과 관계형 의미론(예: 보조 인덱스, 강력한 일관성, 스키마 및 SQL)을 결합하여 99.999% 가용성을 제공하는 매우 확장 가능한 데이터베이스입니다.

이 노트북은 `SpannerLoader`와 `SpannerDocumentSaver`를 사용하여 [langchain 문서 저장, 로드 및 삭제하기](/docs/how_to#document-loaders)에 대해 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-spanner-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-spanner-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [구글 클라우드 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [클라우드 스패너 API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=spanner.googleapis.com)
* [스패너 인스턴스 만들기](https://cloud.google.com/spanner/docs/create-manage-instances)
* [스패너 데이터베이스 만들기](https://cloud.google.com/spanner/docs/create-manage-databases)
* [스패너 테이블 만들기](https://cloud.google.com/spanner/docs/create-query-database-console#create-schema)

이 노트북의 런타임 환경에서 데이터베이스에 대한 액세스를 확인한 후, 다음 값을 입력하고 예제 스크립트를 실행하기 전에 셀을 실행하세요.

```python
# @markdown Please specify an instance id, a database, and a table for demo purpose.
INSTANCE_ID = "test_instance"  # @param {type:"string"}
DATABASE_ID = "test_database"  # @param {type:"string"}
TABLE_NAME = "test_table"  # @param {type:"string"}
```


### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-spanner` 패키지에 있으므로 설치해야 합니다.

```python
%pip install -upgrade --quiet langchain-google-spanner langchain
```


**콜랩 전용**: 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

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

구글 클라우드 프로젝트에 액세스하기 위해 이 노트북에 로그인한 IAM 사용자로 구글 클라우드에 인증하세요.

- 이 노트북을 실행하기 위해 콜랩을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
- Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


## 기본 사용법

### 문서 저장

`SpannerDocumentSaver.add_documents(<documents>)`를 사용하여 langchain 문서를 저장하세요. `SpannerDocumentSaver` 클래스를 초기화하려면 3가지가 필요합니다:

1. `instance_id` - 데이터를 로드할 스패너 인스턴스.
2. `database_id` - 데이터를 로드할 스패너 데이터베이스 인스턴스.
3. `table_name` - langchain 문서를 저장할 스패너 데이터베이스 내의 테이블 이름.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Google Spanner"}]-->
from langchain_core.documents import Document
from langchain_google_spanner import SpannerDocumentSaver

test_docs = [
    Document(
        page_content="Apple Granny Smith 150 0.99 1",
        metadata={"fruit_id": 1},
    ),
    Document(
        page_content="Banana Cavendish 200 0.59 0",
        metadata={"fruit_id": 2},
    ),
    Document(
        page_content="Orange Navel 80 1.29 1",
        metadata={"fruit_id": 3},
    ),
]

saver = SpannerDocumentSaver(
    instance_id=INSTANCE_ID,
    database_id=DATABASE_ID,
    table_name=TABLE_NAME,
)
saver.add_documents(test_docs)
```


### 스패너에서 문서 쿼리하기

스패너 테이블에 연결하는 방법에 대한 자세한 내용은 [Python SDK 문서](https://cloud.google.com/python/docs/reference/spanner/latest)를 확인하세요.

#### 테이블에서 문서 로드

`SpannerLoader.load()` 또는 `SpannerLoader.lazy_load()`를 사용하여 langchain 문서를 로드하세요. `lazy_load`는 반복 중에만 데이터베이스를 쿼리하는 생성기를 반환합니다. `SpannerLoader` 클래스를 초기화하려면 다음을 제공해야 합니다:

1. `instance_id` - 데이터를 로드할 스패너 인스턴스.
2. `database_id` - 데이터를 로드할 스패너 데이터베이스 인스턴스.
3. `query` - 데이터베이스 방언의 쿼리.

```python
from langchain_google_spanner import SpannerLoader

query = f"SELECT * from {TABLE_NAME}"
loader = SpannerLoader(
    instance_id=INSTANCE_ID,
    database_id=DATABASE_ID,
    query=query,
)

for doc in loader.lazy_load():
    print(doc)
    break
```


### 문서 삭제

`SpannerDocumentSaver.delete(<documents>)`를 사용하여 테이블에서 langchain 문서 목록을 삭제하세요.

```python
docs = loader.load()
print("Documents before delete:", docs)

doc = test_docs[0]
saver.delete([doc])
print("Documents after delete:", loader.load())
```


## 고급 사용법

### 사용자 정의 클라이언트

기본적으로 생성된 클라이언트는 기본 클라이언트입니다. `credentials`와 `project`를 명시적으로 전달하려면 사용자 정의 클라이언트를 생성자에 전달할 수 있습니다.

```python
from google.cloud import spanner
from google.oauth2 import service_account

creds = service_account.Credentials.from_service_account_file("/path/to/key.json")
custom_client = spanner.Client(project="my-project", credentials=creds)
loader = SpannerLoader(
    INSTANCE_ID,
    DATABASE_ID,
    query,
    client=custom_client,
)
```


### 문서 페이지 콘텐츠 및 메타데이터 사용자 정의

로더는 특정 데이터 열에서 페이지 콘텐츠가 포함된 문서 목록을 반환합니다. 모든 다른 데이터 열은 메타데이터에 추가됩니다. 각 행은 문서가 됩니다.

#### 페이지 콘텐츠 형식 사용자 정의

SpannerLoader는 `page_content`라는 열이 있다고 가정합니다. 이러한 기본값은 다음과 같이 변경할 수 있습니다:

```python
custom_content_loader = SpannerLoader(
    INSTANCE_ID, DATABASE_ID, query, content_columns=["custom_content"]
)
```


여러 열이 지정된 경우 페이지 콘텐츠의 문자열 형식은 기본적으로 `text`(공백으로 구분된 문자열 연결)로 설정됩니다. 사용자가 지정할 수 있는 다른 형식으로는 `text`, `JSON`, `YAML`, `CSV`가 있습니다.

#### 메타데이터 형식 사용자 정의

SpannerLoader는 JSON 데이터를 저장하는 `langchain_metadata`라는 메타데이터 열이 있다고 가정합니다. 메타데이터 열은 기본 사전으로 사용됩니다. 기본적으로 모든 다른 열 데이터가 추가되며 원래 값을 덮어쓸 수 있습니다. 이러한 기본값은 다음과 같이 변경할 수 있습니다:

```python
custom_metadata_loader = SpannerLoader(
    INSTANCE_ID, DATABASE_ID, query, metadata_columns=["column1", "column2"]
)
```


#### JSON 메타데이터 열 이름 사용자 정의

기본적으로 로더는 `langchain_metadata`를 기본 사전으로 사용합니다. 이는 문서의 메타데이터를 위한 기본 사전으로 사용할 JSON 열을 선택하도록 사용자 정의할 수 있습니다.

```python
custom_metadata_json_loader = SpannerLoader(
    INSTANCE_ID, DATABASE_ID, query, metadata_json_column="another-json-column"
)
```


### 사용자 정의 신선도

기본 [신선도](https://cloud.google.com/python/docs/reference/spanner/latest/snapshot-usage#beginning-a-snapshot)는 15초입니다. 이는 약한 경계를 지정하여 사용자 정의할 수 있습니다(특정 타임스탬프 기준으로 모든 읽기를 수행하거나 과거의 특정 기간 기준으로).

```python
import datetime

timestamp = datetime.datetime.utcnow()
custom_timestamp_loader = SpannerLoader(
    INSTANCE_ID,
    DATABASE_ID,
    query,
    staleness=timestamp,
)
```


```python
duration = 20.0
custom_duration_loader = SpannerLoader(
    INSTANCE_ID,
    DATABASE_ID,
    query,
    staleness=duration,
)
```


### 데이터 부스트 활성화

기본적으로 로더는 [데이터 부스트](https://cloud.google.com/spanner/docs/databoost/databoost-overview)를 사용하지 않으며, 이는 추가 비용이 발생하고 추가 IAM 권한이 필요합니다. 그러나 사용자는 이를 활성화할 수 있습니다.

```python
custom_databoost_loader = SpannerLoader(
    INSTANCE_ID,
    DATABASE_ID,
    query,
    databoost=True,
)
```


### 사용자 정의 클라이언트

기본적으로 생성된 클라이언트는 기본 클라이언트입니다. `credentials`와 `project`를 명시적으로 전달하려면 사용자 정의 클라이언트를 생성자에 전달할 수 있습니다.

```python
from google.cloud import spanner

custom_client = spanner.Client(project="my-project", credentials=creds)
saver = SpannerDocumentSaver(
    INSTANCE_ID,
    DATABASE_ID,
    TABLE_NAME,
    client=custom_client,
)
```


### SpannerDocumentSaver의 사용자 정의 초기화

SpannerDocumentSaver는 사용자 정의 초기화를 허용합니다. 이를 통해 사용자는 문서가 테이블에 저장되는 방식을 지정할 수 있습니다.

content_column: 문서의 페이지 콘텐츠에 대한 열 이름으로 사용됩니다. 기본값은 `page_content`입니다.

metadata_columns: 이러한 메타데이터는 문서의 메타데이터에 키가 존재하는 경우 특정 열에 저장됩니다.

metadata_json_column: 특별한 JSON 열에 대한 열 이름입니다. 기본값은 `langchain_metadata`입니다.

```python
custom_saver = SpannerDocumentSaver(
    INSTANCE_ID,
    DATABASE_ID,
    TABLE_NAME,
    content_column="my-content",
    metadata_columns=["foo"],
    metadata_json_column="my-special-json-column",
)
```


### Spanner에 대한 사용자 정의 스키마 초기화

SpannerDocumentSaver는 사용자 정의 스키마로 문서를 저장할 새 테이블을 생성하기 위한 `init_document_table` 메서드를 가집니다.

```python
from langchain_google_spanner import Column

new_table_name = "my_new_table"

SpannerDocumentSaver.init_document_table(
    INSTANCE_ID,
    DATABASE_ID,
    new_table_name,
    content_column="my-page-content",
    metadata_columns=[
        Column("category", "STRING(36)", True),
        Column("price", "FLOAT64", False),
    ],
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)