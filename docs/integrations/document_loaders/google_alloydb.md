---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_alloydb.ipynb
description: Google AlloyDB는 PostgreSQL과 100% 호환되는 완전 관리형 관계형 데이터베이스 서비스입니다. AI 기반
  경험을 구축할 수 있습니다.
---

# Google AlloyDB for PostgreSQL

> [AlloyDB](https://cloud.google.com/alloydb)는 고성능, 원활한 통합 및 인상적인 확장성을 제공하는 완전 관리형 관계형 데이터베이스 서비스입니다. AlloyDB는 PostgreSQL과 100% 호환됩니다. AlloyDB의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `AlloyDB for PostgreSQL`을 사용하여 `AlloyDBLoader` 클래스로 문서를 로드하는 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-alloydb-pg-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-alloydb-pg-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [AlloyDB API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=alloydb.googleapis.com)
* [AlloyDB 클러스터 및 인스턴스 만들기.](https://cloud.google.com/alloydb/docs/cluster-create)
* [AlloyDB 데이터베이스 만들기.](https://cloud.google.com/alloydb/docs/quickstart/create-and-connect)
* [데이터베이스에 사용자 추가.](https://cloud.google.com/alloydb/docs/database-users/about)

### 🦜🔗 라이브러리 설치
통합 라이브러리인 `langchain-google-alloydb-pg`를 설치하세요.

```python
%pip install --upgrade --quiet  langchain-google-alloydb-pg
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
Google Cloud에 인증하여 이 노트북에 로그인한 IAM 사용자로서 Google Cloud 프로젝트에 접근하세요.

* Colab을 사용하여 이 노트북을 실행하는 경우 아래 셀을 사용하고 계속 진행하세요.
* Vertex AI Workbench를 사용하고 있는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


### ☁ Google Cloud 프로젝트 설정
Google Cloud 프로젝트를 설정하여 이 노트북 내에서 Google Cloud 리소스를 활용할 수 있도록 하세요.

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

### AlloyDB 데이터베이스 변수 설정
[AlloyDB 인스턴스 페이지](https://console.cloud.google.com/alloydb/clusters)에서 데이터베이스 값을 찾으세요.

```python
# @title Set Your Values Here { display-mode: "form" }
REGION = "us-central1"  # @param {type: "string"}
CLUSTER = "my-cluster"  # @param {type: "string"}
INSTANCE = "my-primary"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "vector_store"  # @param {type: "string"}
```


### AlloyDBEngine 연결 풀

AlloyDB를 벡터 저장소로 설정하기 위한 요구 사항 및 인수 중 하나는 `AlloyDBEngine` 객체입니다. `AlloyDBEngine`은 AlloyDB 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

`AlloyDBEngine.from_instance()`를 사용하여 `AlloyDBEngine`을 생성하려면 다음 5가지만 제공하면 됩니다:

1. `project_id` : AlloyDB 인스턴스가 위치한 Google Cloud 프로젝트의 프로젝트 ID.
2. `region` : AlloyDB 인스턴스가 위치한 지역.
3. `cluster`: AlloyDB 클러스터의 이름.
4. `instance` : AlloyDB 인스턴스의 이름.
5. `database` : AlloyDB 인스턴스에서 연결할 데이터베이스의 이름.

기본적으로 [IAM 데이터베이스 인증](https://cloud.google.com/alloydb/docs/connect-iam)이 데이터베이스 인증 방법으로 사용됩니다. 이 라이브러리는 환경에서 가져온 [애플리케이션 기본 자격 증명(ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)에 속하는 IAM 주체를 사용합니다.

선택적으로, 사용자 이름과 비밀번호를 사용하여 AlloyDB 데이터베이스에 접근하는 [내장 데이터베이스 인증](https://cloud.google.com/alloydb/docs/database-users/about)도 사용할 수 있습니다. `AlloyDBEngine.from_instance()`에 선택적 `user` 및 `password` 인수를 제공하면 됩니다:

* `user` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 사용자
* `password` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 비밀번호.

**참고**: 이 튜토리얼은 비동기 인터페이스를 보여줍니다. 모든 비동기 메서드에는 해당하는 동기 메서드가 있습니다.

```python
from langchain_google_alloydb_pg import AlloyDBEngine

engine = await AlloyDBEngine.afrom_instance(
    project_id=PROJECT_ID,
    region=REGION,
    cluster=CLUSTER,
    instance=INSTANCE,
    database=DATABASE,
)
```


### AlloyDBLoader 생성

```python
from langchain_google_alloydb_pg import AlloyDBLoader

# Creating a basic AlloyDBLoader object
loader = await AlloyDBLoader.create(engine, table_name=TABLE_NAME)
```


### 기본 테이블을 통한 문서 로드
로더는 첫 번째 열을 page_content로 사용하고 나머지 모든 열을 메타데이터로 사용하여 테이블에서 문서 목록을 반환합니다. 기본 테이블은 첫 번째 열을 page_content로 하고 두 번째 열을 메타데이터(JSON)로 가집니다. 각 행은 문서가 됩니다.

```python
docs = await loader.aload()
print(docs)
```


### 사용자 정의 테이블/메타데이터 또는 사용자 정의 페이지 콘텐츠 열을 통한 문서 로드

```python
loader = await AlloyDBLoader.create(
    engine,
    table_name=TABLE_NAME,
    content_columns=["product_name"],  # Optional
    metadata_columns=["id"],  # Optional
)
docs = await loader.aload()
print(docs)
```


### 페이지 콘텐츠 형식 설정
로더는 지정된 문자열 형식으로 페이지 콘텐츠가 있는 각 행당 하나의 문서로 문서 목록을 반환합니다. 즉, 텍스트(공백으로 구분된 연결), JSON, YAML, CSV 등. JSON 및 YAML 형식에는 헤더가 포함되며, 텍스트 및 CSV에는 필드 헤더가 포함되지 않습니다.

```python
loader = AlloyDBLoader.create(
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