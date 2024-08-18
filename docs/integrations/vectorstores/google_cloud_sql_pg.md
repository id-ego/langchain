---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_cloud_sql_pg.ipynb
description: Google Cloud SQL for PostgreSQL을 사용하여 벡터 임베딩을 저장하는 방법을 설명하는 노트북입니다. Langchain
  통합을 활용하세요.
---

# Google Cloud SQL for PostgreSQL

> [Cloud SQL](https://cloud.google.com/sql)는 높은 성능, 원활한 통합 및 인상적인 확장성을 제공하는 완전 관리형 관계형 데이터베이스 서비스입니다. PostgreSQL, PostgreSQL 및 SQL Server 데이터베이스 엔진을 제공합니다. Cloud SQL의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북은 `PostgresVectorStore` 클래스를 사용하여 벡터 임베딩을 저장하기 위해 `Cloud SQL for PostgreSQL`을 사용하는 방법을 다룹니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-cloud-sql-pg-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-cloud-sql-pg-python/blob/main/docs/vector_store.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Cloud SQL Admin API 활성화.](https://console.cloud.google.com/flows/enableapi?apiid=sqladmin.googleapis.com)
* [Cloud SQL 인스턴스 만들기.](https://cloud.google.com/sql/docs/postgres/connect-instance-auth-proxy#create-instance)
* [Cloud SQL 데이터베이스 만들기.](https://cloud.google.com/sql/docs/postgres/create-manage-databases)
* [데이터베이스에 사용자 추가.](https://cloud.google.com/sql/docs/postgres/create-manage-users)

### 🦜🔗 라이브러리 설치
통합 라이브러리인 `langchain-google-cloud-sql-pg`와 임베딩 서비스 라이브러리인 `langchain-google-vertexai`를 설치하세요.

```python
%pip install --upgrade --quiet  langchain-google-cloud-sql-pg langchain-google-vertexai
```


**Colab 전용:** 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench의 경우 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
Google Cloud에 인증하여 이 노트북에 로그인한 IAM 사용자로 Google Cloud 프로젝트에 접근하세요.

* Colab을 사용하여 이 노트북을 실행하는 경우 아래 셀을 사용하고 계속 진행하세요.
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

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
# @markdown Please fill in the value below with your Google Cloud project ID and then run the cell.

PROJECT_ID = "my-project-id"  # @param {type:"string"}

# Set the project id
!gcloud config set project {PROJECT_ID}
```


## 기본 사용법

### Cloud SQL 데이터베이스 값 설정
[Cloud SQL 인스턴스 페이지](https://console.cloud.google.com/sql?_ga=2.223735448.2062268965.1707700487-2088871159.1707257687)에서 데이터베이스 값을 찾으세요.

```python
# @title Set Your Values Here { display-mode: "form" }
REGION = "us-central1"  # @param {type: "string"}
INSTANCE = "my-pg-instance"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "vector_store"  # @param {type: "string"}
```


### PostgresEngine 연결 풀

Cloud SQL을 벡터 저장소로 설정하기 위한 요구 사항 및 인수 중 하나는 `PostgresEngine` 객체입니다. `PostgresEngine`은 Cloud SQL 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

`PostgresEngine.from_instance()`를 사용하여 `PostgresEngine`을 생성하려면 다음 4가지만 제공하면 됩니다:

1. `project_id` : Cloud SQL 인스턴스가 위치한 Google Cloud 프로젝트의 프로젝트 ID.
2. `region` : Cloud SQL 인스턴스가 위치한 지역.
3. `instance` : Cloud SQL 인스턴스의 이름.
4. `database` : Cloud SQL 인스턴스에서 연결할 데이터베이스의 이름.

기본적으로 [IAM 데이터베이스 인증](https://cloud.google.com/sql/docs/postgres/iam-authentication#iam-db-auth)이 데이터베이스 인증 방법으로 사용됩니다. 이 라이브러리는 환경에서 가져온 [애플리케이션 기본 자격 증명 (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)에 속한 IAM 주체를 사용합니다.

IAM 데이터베이스 인증에 대한 자세한 내용은 다음을 참조하세요:

* [IAM 데이터베이스 인증을 위한 인스턴스 구성](https://cloud.google.com/sql/docs/postgres/create-edit-iam-instances)
* [IAM 데이터베이스 인증으로 사용자 관리](https://cloud.google.com/sql/docs/postgres/add-manage-iam-users)

선택적으로, 사용자 이름과 비밀번호를 사용하여 Cloud SQL 데이터베이스에 접근하는 [내장 데이터베이스 인증](https://cloud.google.com/sql/docs/postgres/built-in-authentication)도 사용할 수 있습니다. `PostgresEngine.from_instance()`에 선택적 `user` 및 `password` 인수를 제공하기만 하면 됩니다:

* `user` : 내장 데이터베이스 인증 및 로그인을 위해 사용할 데이터베이스 사용자
* `password` : 내장 데이터베이스 인증 및 로그인을 위해 사용할 데이터베이스 비밀번호.

"**참고**: 이 튜토리얼은 비동기 인터페이스를 보여줍니다. 모든 비동기 메서드에는 해당하는 동기 메서드가 있습니다."

```python
from langchain_google_cloud_sql_pg import PostgresEngine

engine = await PostgresEngine.afrom_instance(
    project_id=PROJECT_ID, region=REGION, instance=INSTANCE, database=DATABASE
)
```


### 테이블 초기화
`PostgresVectorStore` 클래스는 데이터베이스 테이블을 필요로 합니다. `PostgresEngine` 엔진에는 적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 도우미 메서드 `init_vectorstore_table()`이 있습니다.

```python
from langchain_google_cloud_sql_pg import PostgresEngine

await engine.ainit_vectorstore_table(
    table_name=TABLE_NAME,
    vector_size=768,  # Vector size for VertexAI model(textembedding-gecko@latest)
)
```


### 임베딩 클래스 인스턴스 생성

[LangChain 임베딩 모델](/docs/integrations/text_embedding/)을 사용할 수 있습니다.
`VertexAIEmbeddings`를 사용하려면 Vertex AI API를 활성화해야 할 수 있습니다. 프로덕션을 위해 임베딩 모델의 버전을 설정하는 것을 권장하며, [텍스트 임베딩 모델](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/text-embeddings)에 대한 자세한 내용을 알아보세요.

```python
# enable Vertex AI API
!gcloud services enable aiplatform.googleapis.com
```


```python
from langchain_google_vertexai import VertexAIEmbeddings

embedding = VertexAIEmbeddings(
    model_name="textembedding-gecko@latest", project=PROJECT_ID
)
```


### 기본 PostgresVectorStore 초기화

```python
from langchain_google_cloud_sql_pg import PostgresVectorStore

store = await PostgresVectorStore.create(  # Use .create() to initialize an async vector store
    engine=engine,
    table_name=TABLE_NAME,
    embedding_service=embedding,
)
```


### 텍스트 추가

```python
import uuid

all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]
ids = [str(uuid.uuid4()) for _ in all_texts]

await store.aadd_texts(all_texts, metadatas=metadatas, ids=ids)
```


### 텍스트 삭제

```python
await store.adelete([ids[1]])
```


### 문서 검색

```python
query = "I'd like a fruit."
docs = await store.asimilarity_search(query)
print(docs)
```


### 벡터로 문서 검색

```python
query_vector = embedding.embed_query(query)
docs = await store.asimilarity_search_by_vector(query_vector, k=2)
print(docs)
```


## 인덱스 추가
벡터 검색 쿼리를 가속화하기 위해 벡터 인덱스를 적용하세요. [벡터 인덱스](https://cloud.google.com/blog/products/databases/faster-similarity-search-performance-with-pgvector-indexes)에 대한 자세한 내용을 알아보세요.

```python
from langchain_google_cloud_sql_pg.indexes import IVFFlatIndex

index = IVFFlatIndex()
await store.aapply_vector_index(index)
```


### 재인덱싱

```python
await store.areindex()  # Re-index using default index name
```


### 인덱스 제거

```python
await store.aadrop_vector_index()  # Delete index using default name
```


## 사용자 정의 벡터 저장소 생성
벡터 저장소는 유사성 검색을 필터링하기 위해 관계형 데이터를 활용할 수 있습니다.

사용자 정의 메타데이터 열로 테이블을 생성하세요.

```python
from langchain_google_cloud_sql_pg import Column

# Set table name
TABLE_NAME = "vectorstore_custom"

await engine.ainit_vectorstore_table(
    table_name=TABLE_NAME,
    vector_size=768,  # VertexAI model: textembedding-gecko@latest
    metadata_columns=[Column("len", "INTEGER")],
)


# Initialize PostgresVectorStore
custom_store = await PostgresVectorStore.create(
    engine=engine,
    table_name=TABLE_NAME,
    embedding_service=embedding,
    metadata_columns=["len"],
    # Connect to a existing VectorStore by customizing the table schema:
    # id_column="uuid",
    # content_column="documents",
    # embedding_column="vectors",
)
```


### 메타데이터 필터로 문서 검색

```python
import uuid

# Add texts to the Vector Store
all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]
ids = [str(uuid.uuid4()) for _ in all_texts]
await store.aadd_texts(all_texts, metadatas=metadatas, ids=ids)

# Use filter on search
docs = await custom_store.asimilarity_search_by_vector(query_vector, filter="len >= 6")

print(docs)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)