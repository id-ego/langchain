---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_bigquery_vector_search.ipynb
description: Google BigQuery 벡터 검색을 활용한 LangChain의 데이터 및 임베딩 관리 시스템을 통해 확장 가능한 의미
  검색 방법을 소개합니다.
---

# 구글 빅쿼리 벡터 검색

> [구글 클라우드 빅쿼리 벡터 검색](https://cloud.google.com/bigquery/docs/vector-search-intro)은 구글SQL을 사용하여 의미 검색을 수행할 수 있게 해주며, 벡터 인덱스를 사용하여 빠른 근사 결과를 얻거나, 정확한 결과를 위해 브루트 포스를 사용할 수 있습니다.

이 튜토리얼은 LangChain에서 엔드 투 엔드 데이터 및 임베딩 관리 시스템을 사용하는 방법을 설명하고, `BigQueryVectorStore` 클래스를 사용하여 빅쿼리에서 확장 가능한 의미 검색을 제공합니다. 이 클래스는 구글 클라우드에서 통합 데이터 저장소와 유연한 벡터 검색을 제공할 수 있는 2개의 클래스 세트의 일부입니다:
- **빅쿼리 벡터 검색**: 인프라 설정 없이 빠른 프로토타입 제작 및 배치 검색에 적합한 `BigQueryVectorStore` 클래스.
- **피처 스토어 온라인 스토어**: 수동 또는 예약된 데이터 동기화를 통해 저지연 검색을 가능하게 하는 `VertexFSVectorStore` 클래스. 생산 준비가 완료된 사용자 대면 GenAI 애플리케이션에 적합합니다.

![Diagram BQ-VertexFS](/img/d02d482be891fa79a6d59d218105e02e.png)

## 시작하기

### 라이브러리 설치

```python
%pip install --upgrade --quiet  langchain langchain-google-vertexai "langchain-google-community[featurestore]"
```


이 Jupyter 런타임에서 새로 설치한 패키지를 사용하려면 런타임을 재시작해야 합니다. 아래 셀을 실행하여 현재 커널을 재시작할 수 있습니다.

```python
import IPython

app = IPython.Application.instance()
app.kernel.do_shutdown(True)
```


## 시작하기 전에

#### 프로젝트 ID 설정

프로젝트 ID를 모르는 경우 다음을 시도해 보세요:
* `gcloud config list` 실행.
* `gcloud projects list` 실행.
* 지원 페이지 참조: [프로젝트 ID 찾기](https://support.google.com/googleapi/answer/7014113).

```python
PROJECT_ID = ""  # @param {type:"string"}

# Set the project id
! gcloud config set project {PROJECT_ID}
```


#### 지역 설정

빅쿼리에서 사용하는 `REGION` 변수를 변경할 수도 있습니다. [빅쿼리 지역](https://cloud.google.com/bigquery/docs/locations#supported_locations)에 대해 자세히 알아보세요.

```python
REGION = "us-central1"  # @param {type: "string"}
```


#### 데이터셋 및 테이블 이름 설정

이들은 당신의 빅쿼리 벡터 저장소가 될 것입니다.

```python
DATASET = "my_langchain_dataset"  # @param {type: "string"}
TABLE = "doc_and_vectors"  # @param {type: "string"}
```


### 노트북 환경 인증

- **Colab**을 사용하여 이 노트북을 실행하는 경우 아래 셀의 주석을 해제하고 계속 진행하세요.
- **Vertex AI Workbench**를 사용하고 있는 경우, [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
# from google.colab import auth as google_auth

# google_auth.authenticate_user()
```


## 데모: BigQueryVectorStore

### 임베딩 클래스 인스턴스 생성

프로젝트에서 Vertex AI API를 활성화해야 할 수 있습니다. 다음을 실행하세요:
`gcloud services enable aiplatform.googleapis.com --project {PROJECT_ID}`
(`{PROJECT_ID}`를 프로젝트 이름으로 교체).

아래의 [LangChain 임베딩 모델](/docs/integrations/text_embedding/)을 사용할 수 있습니다.

```python
from langchain_google_vertexai import VertexAIEmbeddings

embedding = VertexAIEmbeddings(
    model_name="textembedding-gecko@latest", project=PROJECT_ID
)
```


### BigQueryVectorStore 초기화

빅쿼리 데이터셋과 테이블은 존재하지 않을 경우 자동으로 생성됩니다. 모든 선택적 매개변수에 대한 클래스 정의는 [여기](https://github.com/langchain-ai/langchain-google/blob/main/libs/community/langchain_google_community/bq_storage_vectorstores/bigquery.py#L26)에서 확인하세요.

```python
from langchain_google_community import BigQueryVectorStore

store = BigQueryVectorStore(
    project_id=PROJECT_ID,
    dataset_name=DATASET,
    table_name=TABLE,
    location=REGION,
    embedding=embedding,
)
```


### 텍스트 추가

```python
all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]

store.add_texts(all_texts, metadatas=metadatas)
```


### 문서 검색

```python
query = "I'd like a fruit."
docs = store.similarity_search(query)
print(docs)
```


### 벡터로 문서 검색

```python
query_vector = embedding.embed_query(query)
docs = store.similarity_search_by_vector(query_vector, k=2)
print(docs)
```


### 메타데이터 필터로 문서 검색

```python
# This should only return "Banana" document.
docs = store.similarity_search_by_vector(query_vector, filter={"len": 6})
print(docs)
```


### 배치 검색
BigQueryVectorStore는 확장 가능한 벡터 유사성 검색을 위한 `batch_search` 메서드를 제공합니다.

```python
results = store.batch_search(
    embeddings=None,  # can pass embeddings or
    queries=["search_query", "search_query"],  # can pass queries
)
```


### 임베딩과 함께 텍스트 추가

`add_texts_with_embeddings` 메서드를 사용하여 자신의 임베딩을 가져올 수도 있습니다. 이는 임베딩 생성 전에 사용자 정의 전처리가 필요할 수 있는 다중 모드 데이터에 특히 유용합니다.

```python
items = ["some text"]
embs = embedding.embed(items)

ids = store.add_texts_with_embeddings(
    texts=["some text"], embs=embs, metadatas=[{"len": 1}]
)
```


### 피처 스토어를 통한 저지연 서비스
`.to_vertex_fs_vector_store()` 메서드를 사용하여 VertexFSVectorStore 객체를 간단히 얻을 수 있으며, 이는 온라인 사용 사례에 대해 저지연을 제공합니다. 모든 필수 매개변수는 기존 BigQueryVectorStore 클래스에서 자동으로 전송됩니다. 사용할 수 있는 다른 모든 매개변수에 대한 [클래스 정의](https://github.com/langchain-ai/langchain-google/blob/main/libs/community/langchain_google_community/bq_storage_vectorstores/featurestore.py#L33)를 참조하세요.

BigQueryVectorStore로 다시 돌아가는 것도 `.to_bq_vector_store()` 메서드를 사용하여 쉽게 할 수 있습니다.

```python
store.to_vertex_fs_vector_store()  # pass optional VertexFSVectorStore parameters as arguments
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)