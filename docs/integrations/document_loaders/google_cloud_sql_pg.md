---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_cloud_sql_pg.ipynb
description: Google Cloud SQL for PostgreSQL은 PostgreSQL 데이터베이스를 관리하는 완전 관리형 서비스로,
  Langchain 통합을 통해 AI 경험을 구축할 수 있습니다.
---

# Google Cloud SQL for PostgreSQL

> [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)는 Google Cloud Platform에서 PostgreSQL 관계형 데이터베이스를 설정, 유지 관리, 관리 및 운영하는 데 도움을 주는 완전 관리형 데이터베이스 서비스입니다. Cloud SQL for PostgreSQL의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `PostgresLoader` 클래스를 사용하여 문서를 로드하는 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-cloud-sql-pg-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-cloud-sql-pg-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Cloud SQL Admin API 활성화하기.](https://console.cloud.google.com/marketplace/product/google/sqladmin.googleapis.com)
* [PostgreSQL 인스턴스 만들기.](https://cloud.google.com/sql/docs/postgres/create-instance)
* [PostgreSQL 데이터베이스 만들기.](https://cloud.google.com/sql/docs/postgres/create-manage-databases)
* [데이터베이스에 사용자 추가하기.](https://cloud.google.com/sql/docs/postgres/create-manage-users)

### 🦜🔗 라이브러리 설치
통합 라이브러리인 `langchain_google_cloud_sql_pg`를 설치합니다.

```python
%pip install --upgrade --quiet  langchain_google_cloud_sql_pg
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작합니다. Vertex AI Workbench의 경우 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
Google Cloud에 인증하여 이 노트북에 로그인한 IAM 사용자로 Google Cloud 프로젝트에 접근합니다.

* Colab을 사용하여 이 노트북을 실행하는 경우 아래 셀을 사용하고 계속 진행합니다.
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


### ☁ Google Cloud 프로젝트 설정
Google Cloud 프로젝트를 설정하여 이 노트북 내에서 Google Cloud 리소스를 활용할 수 있도록 합니다.

프로젝트 ID를 모르는 경우 다음을 시도하세요:

* `gcloud config list` 실행.
* `gcloud projects list` 실행.
* 지원 페이지 참조: [프로젝트 ID 찾기](https://support.google.com/googleapi/answer/7014113).

```python
# @title Project { display-mode: "form" }
PROJECT_ID = "gcp_project_id"  # @param {type:"string"}

# Set the project id
! gcloud config set project {PROJECT_ID}
```


## 기본 사용법

### Cloud SQL 데이터베이스 값 설정
[Cloud SQL 인스턴스 페이지](https://console.cloud.google.com/sql/instances)에서 데이터베이스 변수를 찾습니다.

```python
# @title Set Your Values Here { display-mode: "form" }
REGION = "us-central1"  # @param {type: "string"}
INSTANCE = "my-primary"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "vector_store"  # @param {type: "string"}
```


### Cloud SQL 엔진

문서 로더로 PostgreSQL을 설정하기 위한 요구 사항 및 인수 중 하나는 `PostgresEngine` 객체입니다. `PostgresEngine`은 Cloud SQL for PostgreSQL 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

`PostgresEngine.from_instance()`를 사용하여 `PostgresEngine`을 생성하려면 다음 4가지만 제공하면 됩니다:

1. `project_id` : Cloud SQL 인스턴스가 위치한 Google Cloud 프로젝트의 프로젝트 ID.
2. `region` : Cloud SQL 인스턴스가 위치한 지역.
3. `instance` : Cloud SQL 인스턴스의 이름.
4. `database` : Cloud SQL 인스턴스에서 연결할 데이터베이스의 이름.

기본적으로 [IAM 데이터베이스 인증](https://cloud.google.com/sql/docs/postgres/iam-authentication)이 데이터베이스 인증 방법으로 사용됩니다. 이 라이브러리는 환경에서 가져온 [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)에 속하는 IAM 주체를 사용합니다.

선택적으로, 사용자 이름과 비밀번호를 사용하여 Cloud SQL 데이터베이스에 접근하는 [내장 데이터베이스 인증](https://cloud.google.com/sql/docs/postgres/users)도 사용할 수 있습니다. `PostgresEngine.from_instance()`에 선택적 `user` 및 `password` 인수를 제공하기만 하면 됩니다:

* `user` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 사용자
* `password` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 비밀번호.

**참고**: 이 튜토리얼은 비동기 인터페이스를 보여줍니다. 모든 비동기 메서드에는 해당하는 동기 메서드가 있습니다.

```python
from langchain_google_cloud_sql_pg import PostgresEngine

engine = await PostgresEngine.afrom_instance(
    project_id=PROJECT_ID,
    region=REGION,
    instance=INSTANCE,
    database=DATABASE,
)
```


### PostgresLoader 생성

```python
from langchain_google_cloud_sql_pg import PostgresLoader

# Creating a basic PostgreSQL object
loader = await PostgresLoader.create(engine, table_name=TABLE_NAME)
```


### 기본 테이블을 통한 문서 로드
로더는 첫 번째 열을 page_content로, 나머지 열을 메타데이터로 사용하여 테이블에서 문서 목록을 반환합니다. 기본 테이블은 첫 번째 열이 page_content이고 두 번째 열이 메타데이터(JSON)로 구성됩니다. 각 행은 문서가 됩니다. 문서에 ID를 추가하려면 직접 추가해야 합니다.

```python
from langchain_google_cloud_sql_pg import PostgresLoader

# Creating a basic PostgresLoader object
loader = await PostgresLoader.create(engine, table_name=TABLE_NAME)

docs = await loader.aload()
print(docs)
```


### 사용자 정의 테이블/메타데이터 또는 사용자 정의 페이지 콘텐츠 열을 통한 문서 로드

```python
loader = await PostgresLoader.create(
    engine,
    table_name=TABLE_NAME,
    content_columns=["product_name"],  # Optional
    metadata_columns=["id"],  # Optional
)
docs = await loader.aload()
print(docs)
```


### 페이지 콘텐츠 형식 설정
로더는 지정된 문자열 형식으로 페이지 콘텐츠가 있는 각 행당 하나의 문서로 문서 목록을 반환합니다. 즉, 텍스트(공백으로 구분된 연결), JSON, YAML, CSV 등입니다. JSON 및 YAML 형식은 헤더를 포함하고, 텍스트 및 CSV는 필드 헤더를 포함하지 않습니다.

```python
loader = await PostgresLoader.create(
    engine,
    table_name="products",
    content_columns=["product_name", "description"],
    format="YAML",
)
docs = await loader.aload()
print(docs)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)