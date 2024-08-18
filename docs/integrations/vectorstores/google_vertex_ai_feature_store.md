---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_vertex_ai_feature_store.ipynb
description: Google Cloud Vertex AI Feature Store를 사용하여 BigQuery 데이터에서 저지연 벡터 검색 및
  근사 최근접 이웃 검색을 수행하는 방법을 안내합니다.
---

# Google Vertex AI Feature Store

> [Google Cloud Vertex Feature Store](https://cloud.google.com/vertex-ai/docs/featurestore/latest/overview)는 [Google Cloud BigQuery](https://cloud.google.com/bigquery?hl=ko)에서 데이터를 저지연으로 제공할 수 있게 하여 ML 기능 관리 및 온라인 제공 프로세스를 간소화합니다. 여기에는 임베딩에 대한 근사 이웃 검색을 수행할 수 있는 기능이 포함됩니다.

이 튜토리얼에서는 BigQuery 데이터에서 저지연 벡터 검색 및 근사 최근접 이웃 검색을 쉽게 수행하는 방법을 보여줍니다. 최소한의 설정으로 강력한 ML 애플리케이션을 가능하게 합니다. 우리는 `VertexFSVectorStore` 클래스를 사용하여 이를 수행할 것입니다.

이 클래스는 Google Cloud에서 통합 데이터 저장소 및 유연한 벡터 검색을 제공할 수 있는 2개의 클래스 세트의 일부입니다:
- **BigQuery 벡터 검색**: `BigQueryVectorStore` 클래스를 사용하여 인프라 설정 없이 신속한 프로토타이핑 및 배치 검색에 적합합니다.
- **기능 저장소 온라인 저장소**: `VertexFSVectorStore` 클래스를 사용하여 수동 또는 예약된 데이터 동기화로 저지연 검색을 가능하게 합니다. 생산 준비가 완료된 사용자 대면 GenAI 애플리케이션에 적합합니다.

![Diagram BQ-VertexFS](/img/d02d482be891fa79a6d59d218105e02e.png)

## 시작하기

### 라이브러리 설치

```python
%pip install --upgrade --quiet  langchain langchain-google-vertexai "langchain-google-community[featurestore]"
```


이 Jupyter 런타임에서 새로 설치된 패키지를 사용하려면 런타임을 재시작해야 합니다. 아래 셀을 실행하여 현재 커널을 재시작할 수 있습니다.

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

BigQuery에서 사용하는 `REGION` 변수를 변경할 수도 있습니다. [BigQuery 지역](https://cloud.google.com/bigquery/docs/locations#supported_locations)에 대해 자세히 알아보세요.

```python
REGION = "us-central1"  # @param {type: "string"}
```


#### 데이터세트 및 테이블 이름 설정

이들은 귀하의 BigQuery 벡터 저장소가 될 것입니다.

```python
DATASET = "my_langchain_dataset"  # @param {type: "string"}
TABLE = "doc_and_vectors"  # @param {type: "string"}
```


### 노트북 환경 인증

- **Colab**을 사용하여 이 노트북을 실행하는 경우 아래 셀의 주석을 제거하고 계속 진행하세요.
- **Vertex AI Workbench**를 사용하고 있는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
# from google.colab import auth as google_auth

# google_auth.authenticate_user()
```


## 데모: VertexFSVectorStore

### 임베딩 클래스 인스턴스 생성

프로젝트에서 Vertex AI API를 활성화해야 할 수 있습니다. 
`gcloud services enable aiplatform.googleapis.com --project {PROJECT_ID}`
(`{PROJECT_ID}`를 프로젝트 이름으로 바꾸세요) 명령을 실행하세요.

아무 [LangChain 임베딩 모델](/docs/integrations/text_embedding/)을 사용할 수 있습니다.

```python
from langchain_google_vertexai import VertexAIEmbeddings

embedding = VertexAIEmbeddings(
    model_name="textembedding-gecko@latest", project=PROJECT_ID
)
```


### VertexFSVectorStore 초기화

BigQuery 데이터세트와 테이블은 존재하지 않는 경우 자동으로 생성됩니다. 모든 선택적 매개변수에 대한 클래스 정의는 [여기](https://github.com/langchain-ai/langchain-google/blob/main/libs/community/langchain_google_community/bq_storage_vectorstores/featurestore.py#L33)에서 확인하세요.

```python
from langchain_google_community import VertexFSVectorStore

store = VertexFSVectorStore(
    project_id=PROJECT_ID,
    dataset_name=DATASET,
    table_name=TABLE,
    location=REGION,
    embedding=embedding,
)
```


### 텍스트 추가

> 참고: 첫 번째 동기화 프로세스는 기능 온라인 저장소 생성으로 인해 약 20분 정도 소요됩니다.

```python
all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]

store.add_texts(all_texts, metadatas=metadatas)
```


`sync_data` 메서드를 실행하여 필요에 따라 동기화를 시작할 수도 있습니다.

```python
store.sync_data()
```


생산 환경에서는 `cron_schedule` 클래스 매개변수를 사용하여 자동 예약 동기화를 설정할 수 있습니다.
예를 들어:
```python
store = VertexFSVectorStore(cron_schedule="TZ=America/Los_Angeles 00 13 11 8 *", ...)
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


### 임베딩과 함께 텍스트 추가

`add_texts_with_embeddings` 메서드를 사용하여 자신의 임베딩을 가져올 수도 있습니다. 이는 임베딩 생성 전에 사용자 정의 전처리가 필요할 수 있는 다중 모드 데이터에 특히 유용합니다.

```python
items = ["some text"]
embs = embedding.embed(items)

ids = store.add_texts_with_embeddings(
    texts=["some text"], embs=embs, metadatas=[{"len": 1}]
)
```


### BigQuery로 배치 제공
`.to_bq_vector_store()` 메서드를 사용하여 BigQueryVectorStore 객체를 얻을 수 있으며, 이는 배치 사용 사례에 최적화된 성능을 제공합니다. 모든 필수 매개변수는 기존 클래스에서 자동으로 전송됩니다. 사용할 수 있는 모든 매개변수에 대한 [클래스 정의](https://github.com/langchain-ai/langchain-google/blob/main/libs/community/langchain_google_community/bq_storage_vectorstores/bigquery.py#L26)를 참조하세요.

BigQueryVectorStore로 다시 이동하는 것도 `.to_vertex_fs_vector_store()` 메서드를 사용하여 쉽게 할 수 있습니다.

```python
store.to_bq_vector_store()  # pass optional VertexFSVectorStore parameters as arguments
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)