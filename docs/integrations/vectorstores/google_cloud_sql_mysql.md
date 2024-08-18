---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_cloud_sql_mysql.ipynb
description: Google Cloud SQL for MySQL을 사용하여 벡터 임베딩을 저장하는 방법을 설명하는 노트북입니다. LangChain
  통합을 활용하세요.
---

# Google Cloud SQL for MySQL

> [Cloud SQL](https://cloud.google.com/sql)는 높은 성능, 원활한 통합 및 인상적인 확장성을 제공하는 완전 관리형 관계형 데이터베이스 서비스입니다. PostgreSQL, MySQL 및 SQL Server 데이터베이스 엔진을 제공합니다. Cloud SQL의 LangChain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북은 `MySQLVectorStore` 클래스를 사용하여 벡터 임베딩을 저장하기 위해 `Cloud SQL for MySQL`을 사용하는 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-cloud-sql-mysql-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-cloud-sql-mysql-python/blob/main/docs/vector_store.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Cloud SQL Admin API 활성화.](https://console.cloud.google.com/flows/enableapi?apiid=sqladmin.googleapis.com)
* [Cloud SQL 인스턴스 만들기.](https://cloud.google.com/sql/docs/mysql/connect-instance-auth-proxy#create-instance) (버전은 **8.0.36** 이상이어야 하며 **cloudsql_vector** 데이터베이스 플래그가 "On"으로 설정되어야 합니다)
* [Cloud SQL 데이터베이스 만들기.](https://cloud.google.com/sql/docs/mysql/create-manage-databases)
* [데이터베이스에 사용자 추가.](https://cloud.google.com/sql/docs/mysql/create-manage-users)

### 🦜🔗 라이브러리 설치
통합 라이브러리인 `langchain-google-cloud-sql-mysql`과 임베딩 서비스 라이브러리인 `langchain-google-vertexai`를 설치하세요.

```python
%pip install --upgrade --quiet langchain-google-cloud-sql-mysql langchain-google-vertexai
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
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


### ☁ Google Cloud 프로젝트 설정
Google Cloud 프로젝트를 설정하여 이 노트북 내에서 Google Cloud 리소스를 활용할 수 있도록 합니다.

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

### Cloud SQL 데이터베이스 값 설정
[Cloud SQL 인스턴스 페이지](https://console.cloud.google.com/sql?_ga=2.223735448.2062268965.1707700487-2088871159.1707257687)에서 데이터베이스 값을 찾으세요.

**참고:** MySQL 벡터 지원은 **>= 8.0.36** 버전의 MySQL 인스턴스에서만 사용할 수 있습니다.

기존 인스턴스의 경우, [셀프 서비스 유지 관리 업데이트](https://cloud.google.com/sql/docs/mysql/self-service-maintenance)를 수행하여 유지 관리 버전을 **MYSQL_8_0_36.R20240401.03_00** 이상으로 업데이트해야 할 수 있습니다. 업데이트 후, [데이터베이스 플래그 구성](https://cloud.google.com/sql/docs/mysql/flags)을 통해 새로운 **cloudsql_vector** 플래그를 "On"으로 설정하세요.

```python
# @title Set Your Values Here { display-mode: "form" }
REGION = "us-central1"  # @param {type: "string"}
INSTANCE = "my-mysql-instance"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "vector_store"  # @param {type: "string"}
```


### MySQLEngine 연결 풀

Cloud SQL을 벡터 저장소로 설정하기 위한 요구 사항 중 하나는 `MySQLEngine` 객체입니다. `MySQLEngine`은 Cloud SQL 데이터베이스에 대한 연결 풀을 구성하여 애플리케이션에서 성공적인 연결을 가능하게 하고 업계 모범 사례를 따릅니다.

`MySQLEngine.from_instance()`를 사용하여 `MySQLEngine`을 생성하려면 4가지 정보만 제공하면 됩니다:

1. `project_id` : Cloud SQL 인스턴스가 위치한 Google Cloud 프로젝트의 프로젝트 ID.
2. `region` : Cloud SQL 인스턴스가 위치한 지역.
3. `instance` : Cloud SQL 인스턴스의 이름.
4. `database` : Cloud SQL 인스턴스에 연결할 데이터베이스의 이름.

기본적으로 [IAM 데이터베이스 인증](https://cloud.google.com/sql/docs/mysql/iam-authentication#iam-db-auth)이 데이터베이스 인증 방법으로 사용됩니다. 이 라이브러리는 환경에서 가져온 [응용 프로그램 기본 자격 증명(ADC)](https://cloud.google.com/docs/authentication/application-default-credentials)에 속하는 IAM 주체를 사용합니다.

IAM 데이터베이스 인증에 대한 자세한 내용은 다음을 참조하세요:

* [IAM 데이터베이스 인증을 위한 인스턴스 구성](https://cloud.google.com/sql/docs/mysql/create-edit-iam-instances)
* [IAM 데이터베이스 인증으로 사용자 관리](https://cloud.google.com/sql/docs/mysql/add-manage-iam-users)

선택적으로, 사용자 이름과 비밀번호를 사용하여 Cloud SQL 데이터베이스에 접근하는 [내장 데이터베이스 인증](https://cloud.google.com/sql/docs/mysql/built-in-authentication)도 사용할 수 있습니다. `MySQLEngine.from_instance()`에 선택적 `user` 및 `password` 인수를 제공하세요:

* `user` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 사용자
* `password` : 내장 데이터베이스 인증 및 로그인에 사용할 데이터베이스 비밀번호.

```python
from langchain_google_cloud_sql_mysql import MySQLEngine

engine = MySQLEngine.from_instance(
    project_id=PROJECT_ID, region=REGION, instance=INSTANCE, database=DATABASE
)
```


### 테이블 초기화
`MySQLVectorStore` 클래스는 데이터베이스 테이블이 필요합니다. `MySQLEngine` 클래스에는 적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 도우미 메서드 `init_vectorstore_table()`이 있습니다.

```python
engine.init_vectorstore_table(
    table_name=TABLE_NAME,
    vector_size=768,  # Vector size for VertexAI model(textembedding-gecko@latest)
)
```


### 임베딩 클래스 인스턴스 생성

모든 [LangChain 임베딩 모델](/docs/integrations/text_embedding/)을 사용할 수 있습니다.
`VertexAIEmbeddings`를 사용하려면 Vertex AI API를 활성화해야 할 수 있습니다.

생산 환경에서는 임베딩 모델의 버전을 고정하는 것이 좋습니다. [텍스트 임베딩 모델](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/text-embeddings)에 대한 자세한 내용을 확인하세요.

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


### 기본 MySQLVectorStore 초기화

`MySQLVectorStore` 클래스를 초기화하려면 3가지 정보만 제공하면 됩니다:

1. `engine` - `MySQLEngine` 엔진의 인스턴스.
2. `embedding_service` - LangChain 임베딩 모델의 인스턴스.
3. `table_name` : 벡터 저장소로 사용할 Cloud SQL 데이터베이스 내의 테이블 이름.

```python
from langchain_google_cloud_sql_mysql import MySQLVectorStore

store = MySQLVectorStore(
    engine=engine,
    embedding_service=embedding,
    table_name=TABLE_NAME,
)
```


### 텍스트 추가

```python
import uuid

all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]
ids = [str(uuid.uuid4()) for _ in all_texts]

store.add_texts(all_texts, metadatas=metadatas, ids=ids)
```


### 텍스트 삭제

ID로 벡터 저장소에서 벡터를 삭제합니다.

```python
store.delete([ids[1]])
```


### 문서 검색

```python
query = "I'd like a fruit."
docs = store.similarity_search(query)
print(docs[0].page_content)
```

```output
Pineapple
```

### 벡터로 문서 검색

주어진 임베딩 벡터와 유사한 문서를 검색하는 것도 가능하며, `similarity_search_by_vector`를 사용하여 문자열 대신 임베딩 벡터를 매개변수로 전달합니다.

```python
query_vector = embedding.embed_query(query)
docs = store.similarity_search_by_vector(query_vector, k=2)
print(docs)
```

```output
[Document(page_content='Pineapple', metadata={'len': 9}), Document(page_content='Banana', metadata={'len': 6})]
```

### 인덱스 추가
벡터 검색 쿼리를 가속화하기 위해 벡터 인덱스를 적용하세요. [MySQL 벡터 인덱스](https://github.com/googleapis/langchain-google-cloud-sql-mysql-python/blob/main/src/langchain_google_cloud_sql_mysql/indexes.py)에 대해 자세히 알아보세요.

**참고:** IAM 데이터베이스 인증(기본 사용)의 경우, IAM 데이터베이스 사용자는 벡터 인덱스에 대한 전체 제어를 위해 특권 데이터베이스 사용자에 의해 다음 권한을 부여받아야 합니다.

```
GRANT EXECUTE ON PROCEDURE mysql.create_vector_index TO '<IAM_DB_USER>'@'%';
GRANT EXECUTE ON PROCEDURE mysql.alter_vector_index TO '<IAM_DB_USER>'@'%';
GRANT EXECUTE ON PROCEDURE mysql.drop_vector_index TO '<IAM_DB_USER>'@'%';
GRANT SELECT ON mysql.vector_indexes TO '<IAM_DB_USER>'@'%';
```


```python
from langchain_google_cloud_sql_mysql import VectorIndex

store.apply_vector_index(VectorIndex())
```


### 인덱스 제거

```python
store.drop_vector_index()
```


## 고급 사용법

### 사용자 정의 메타데이터로 MySQLVectorStore 생성

벡터 저장소는 관계형 데이터를 활용하여 유사성 검색을 필터링할 수 있습니다.

사용자 정의 메타데이터 열로 테이블과 `MySQLVectorStore` 인스턴스를 생성하세요.

```python
from langchain_google_cloud_sql_mysql import Column

# set table name
CUSTOM_TABLE_NAME = "vector_store_custom"

engine.init_vectorstore_table(
    table_name=CUSTOM_TABLE_NAME,
    vector_size=768,  # VertexAI model: textembedding-gecko@latest
    metadata_columns=[Column("len", "INTEGER")],
)


# initialize MySQLVectorStore with custom metadata columns
custom_store = MySQLVectorStore(
    engine=engine,
    embedding_service=embedding,
    table_name=CUSTOM_TABLE_NAME,
    metadata_columns=["len"],
    # connect to an existing VectorStore by customizing the table schema:
    # id_column="uuid",
    # content_column="documents",
    # embedding_column="vectors",
)
```


### 메타데이터 필터로 문서 검색

작업하기 전에 문서를 좁히는 데 도움이 될 수 있습니다.

예를 들어, 문서는 `filter` 인수를 사용하여 메타데이터로 필터링할 수 있습니다.

```python
import uuid

# add texts to the vector store
all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]
ids = [str(uuid.uuid4()) for _ in all_texts]
custom_store.add_texts(all_texts, metadatas=metadatas, ids=ids)

# use filter on search
query_vector = embedding.embed_query("I'd like a fruit.")
docs = custom_store.similarity_search_by_vector(query_vector, filter="len >= 6")

print(docs)
```

```output
[Document(page_content='Pineapple', metadata={'len': 9}), Document(page_content='Banana', metadata={'len': 6}), Document(page_content='Apples and oranges', metadata={'len': 18}), Document(page_content='Cars and airplanes', metadata={'len': 18})]
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)