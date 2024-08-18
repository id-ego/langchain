---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_spanner.ipynb
description: 이 문서는 `SpannerVectorStore` 클래스를 사용하여 Google Spanner에서 벡터 검색을 수행하는 방법을
  설명합니다.
---

# 구글 스패너
> [스패너](https://cloud.google.com/spanner)는 무제한 확장성과 관계형 의미론(예: 보조 인덱스, 강력한 일관성, 스키마 및 SQL)을 결합하여 99.999% 가용성을 제공하는 매우 확장 가능한 데이터베이스입니다.

이 노트북에서는 `SpannerVectorStore` 클래스를 사용하여 벡터 검색을 위한 `Spanner` 사용 방법을 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-spanner-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-spanner-python/blob/main/docs/vector_store.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [구글 클라우드 프로젝트 생성](https://developers.google.com/workspace/guides/create-project)
* [클라우드 스패너 API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=spanner.googleapis.com)
* [스패너 인스턴스 생성](https://cloud.google.com/spanner/docs/create-manage-instances)
* [스패너 데이터베이스 생성](https://cloud.google.com/spanner/docs/create-manage-databases)

### 🦜🔗 라이브러리 설치
통합은 자체 `langchain-google-spanner` 패키지에 있으므로 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-google-spanner
```

```output
Note: you may need to restart the kernel to use updated packages.
```

**Colab 전용:** 커널을 재시작하려면 다음 셀의 주석을 제거하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### 🔐 인증
구글 클라우드에 인증하여 이 노트북에 로그인한 IAM 사용자로서 구글 클라우드 프로젝트에 접근합니다.

* Colab을 사용하여 이 노트북을 실행하는 경우 아래 셀을 사용하고 계속 진행하세요.
* Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


### ☁ 구글 클라우드 프로젝트 설정
구글 클라우드 프로젝트를 설정하여 이 노트북 내에서 구글 클라우드 리소스를 활용할 수 있도록 합니다.

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


### 💡 API 활성화
`langchain-google-spanner` 패키지는 구글 클라우드 프로젝트에서 [스패너 API를 활성화](https://console.cloud.google.com/flows/enableapi?apiid=spanner.googleapis.com)해야 합니다.

```python
# enable Spanner API
!gcloud services enable spanner.googleapis.com
```


## 기본 사용법

### 스패너 데이터베이스 값 설정
[스패너 인스턴스 페이지](https://console.cloud.google.com/spanner?_ga=2.223735448.2062268965.1707700487-2088871159.1707257687)에서 데이터베이스 값을 찾습니다.

```python
# @title Set Your Values Here { display-mode: "form" }
INSTANCE = "my-instance"  # @param {type: "string"}
DATABASE = "my-database"  # @param {type: "string"}
TABLE_NAME = "vectors_search_data"  # @param {type: "string"}
```


### 테이블 초기화
`SpannerVectorStore` 클래스 인스턴스는 id, content 및 embeddings 열이 있는 데이터베이스 테이블이 필요합니다.

적절한 스키마로 테이블을 생성하는 데 사용할 수 있는 도우미 메서드 `init_vector_store_table()`가 있습니다.

```python
from langchain_google_spanner import SecondaryIndex, SpannerVectorStore, TableColumn

SpannerVectorStore.init_vector_store_table(
    instance_id=INSTANCE,
    database_id=DATABASE,
    table_name=TABLE_NAME,
    id_column="row_id",
    metadata_columns=[
        TableColumn(name="metadata", type="JSON", is_null=True),
        TableColumn(name="title", type="STRING(MAX)", is_null=False),
    ],
    secondary_indexes=[
        SecondaryIndex(index_name="row_id_and_title", columns=["row_id", "title"])
    ],
)
```


### 임베딩 클래스 인스턴스 생성

[LangChain 임베딩 모델](/docs/integrations/text_embedding/)을 사용할 수 있습니다.
`VertexAIEmbeddings`를 사용하려면 Vertex AI API를 활성화해야 할 수 있습니다. 프로덕션을 위해 임베딩 모델의 버전을 설정하는 것이 좋으며, [텍스트 임베딩 모델](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/text-embeddings)에 대해 자세히 알아보세요.

```python
# enable Vertex AI API
!gcloud services enable aiplatform.googleapis.com
```


```python
from langchain_google_vertexai import VertexAIEmbeddings

embeddings = VertexAIEmbeddings(
    model_name="textembedding-gecko@latest", project=PROJECT_ID
)
```


### SpannerVectorStore

`SpannerVectorStore` 클래스를 초기화하려면 4개의 필수 인수를 제공해야 하며, 나머지 인수는 선택 사항이며 기본값과 다를 경우에만 전달해야 합니다.

1. `instance_id` - 스패너 인스턴스의 이름
2. `database_id` - 스패너 데이터베이스의 이름
3. `table_name` - 문서 및 임베딩을 저장할 데이터베이스 내의 테이블 이름
4. `embedding_service` - 임베딩을 생성하는 데 사용되는 임베딩 구현

```python
db = SpannerVectorStore(
    instance_id=INSTANCE,
    database_id=DATABASE,
    table_name=TABLE_NAME,
    ignore_metadata_columns=[],
    embedding_service=embeddings,
    metadata_json_column="metadata",
)
```


#### 🔐 문서 추가
벡터 저장소에 문서를 추가합니다.

```python
<!--IMPORTS:[{"imported": "HNLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.hn.HNLoader.html", "title": "Google Spanner"}]-->
import uuid

from langchain_community.document_loaders import HNLoader

loader = HNLoader("https://news.ycombinator.com/item?id=34817881")

documents = loader.load()
ids = [str(uuid.uuid4()) for _ in range(len(documents))]
```


#### 🔐 문서 검색
유사성 검색을 통해 벡터 저장소에서 문서를 검색합니다.

```python
db.similarity_search(query="Explain me vector store?", k=3)
```


#### 🔐 문서 검색
최대 마진 관련성 검색을 통해 벡터 저장소에서 문서를 검색합니다.

```python
db.max_marginal_relevance_search("Testing the langchain integration with spanner", k=3)
```


#### 🔐 문서 삭제
벡터 저장소에서 문서를 제거하려면 벡터 저장소 초기화 시 `row_id` 열에 해당하는 ID를 사용하세요.

```python
db.delete(ids=["id1", "id2"])
```


#### 🔐 문서 삭제
벡터 저장소에서 문서를 제거하려면 문서 자체를 활용할 수 있습니다. 벡터 저장소 초기화 시 제공된 내용 열과 메타데이터 열을 사용하여 문서에 해당하는 행을 찾습니다. 일치하는 행은 삭제됩니다.

```python
db.delete(documents=[documents[0], documents[1]])
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)