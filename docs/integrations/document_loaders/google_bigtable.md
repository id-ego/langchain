---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_bigtable.ipynb
description: Google Bigtable을 사용하여 Langchain 문서를 저장, 로드 및 삭제하는 방법을 안내하는 노트북입니다. AI
  경험을 구축하세요.
---

# 구글 빅테이블

> [빅테이블](https://cloud.google.com/bigtable)은 구조화된, 반구조화된 또는 비구조화된 데이터에 대한 빠른 액세스에 적합한 키-값 및 와이드 컬럼 저장소입니다. 빅테이블의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `BigtableLoader` 및 `BigtableSaver`를 사용하여 [langchain 문서를 저장, 로드 및 삭제하는 방법](/docs/how_to#document-loaders)을 다룹니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-bigtable-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-bigtable-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [구글 클라우드 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [빅테이블 API 활성화](https://console.cloud.google.com/flows/enableapi?apiid=bigtable.googleapis.com)
* [빅테이블 인스턴스 만들기](https://cloud.google.com/bigtable/docs/creating-instance)
* [빅테이블 테이블 만들기](https://cloud.google.com/bigtable/docs/managing-tables)
* [빅테이블 액세스 자격 증명 만들기](https://developers.google.com/workspace/guides/create-credentials)

이 노트북의 런타임 환경에서 데이터베이스에 대한 액세스를 확인한 후, 다음 값을 입력하고 예제 스크립트를 실행하기 전에 셀을 실행하세요.

```python
# @markdown Please specify an instance and a table for demo purpose.
INSTANCE_ID = "my_instance"  # @param {type:"string"}
TABLE_ID = "my_table"  # @param {type:"string"}
```


### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-bigtable` 패키지에 있으므로 설치해야 합니다.

```python
%pip install -upgrade --quiet langchain-google-bigtable
```


**Colab 전용**: 커널을 재시작하려면 다음 셀의 주석을 해제하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

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
* 지원 페이지 보기: [프로젝트 ID 찾기](https://support.google.com/googleapi/answer/7014113).

```python
# @markdown Please fill in the value below with your Google Cloud project ID and then run the cell.

PROJECT_ID = "my-project-id"  # @param {type:"string"}

# Set the project id
!gcloud config set project {PROJECT_ID}
```


### 🔐 인증

구글 클라우드 프로젝트에 액세스하기 위해 이 노트북에 로그인한 IAM 사용자로 구글 클라우드에 인증하세요.

- 이 노트북을 실행하기 위해 Colab을 사용하는 경우 아래 셀을 사용하고 계속 진행하세요.
- Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


## 기본 사용법

### 세이버 사용하기

`BigtableSaver.add_documents(<documents>)`를 사용하여 langchain 문서를 저장하세요. `BigtableSaver` 클래스를 초기화하려면 2가지를 제공해야 합니다:

1. `instance_id` - 빅테이블의 인스턴스.
2. `table_id` - langchain 문서를 저장할 빅테이블 내의 테이블 이름.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Google Bigtable"}]-->
from langchain_core.documents import Document
from langchain_google_bigtable import BigtableSaver

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

saver = BigtableSaver(
    instance_id=INSTANCE_ID,
    table_id=TABLE_ID,
)

saver.add_documents(test_docs)
```


### 빅테이블에서 문서 쿼리하기
빅테이블 테이블에 연결하는 방법에 대한 자세한 내용은 [Python SDK 문서](https://cloud.google.com/python/docs/reference/bigtable/latest/client)를 확인하세요.

#### 테이블에서 문서 로드하기

`BigtableLoader.load()` 또는 `BigtableLoader.lazy_load()`를 사용하여 langchain 문서를 로드하세요. `lazy_load`는 반복 중에만 데이터베이스를 쿼리하는 생성기를 반환합니다. `BigtableLoader` 클래스를 초기화하려면 다음을 제공해야 합니다:

1. `instance_id` - 빅테이블의 인스턴스.
2. `table_id` - langchain 문서를 저장할 빅테이블 내의 테이블 이름.

```python
from langchain_google_bigtable import BigtableLoader

loader = BigtableLoader(
    instance_id=INSTANCE_ID,
    table_id=TABLE_ID,
)

for doc in loader.lazy_load():
    print(doc)
    break
```


### 문서 삭제하기

`BigtableSaver.delete(<documents>)`를 사용하여 빅테이블 테이블에서 langchain 문서 목록을 삭제하세요.

```python
from langchain_google_bigtable import BigtableSaver

docs = loader.load()
print("Documents before delete: ", docs)

onedoc = test_docs[0]
saver.delete([onedoc])
print("Documents after delete: ", loader.load())
```


## 고급 사용법

### 반환된 행 제한하기
반환된 행을 제한하는 방법에는 두 가지가 있습니다:

1. [필터](https://cloud.google.com/python/docs/reference/bigtable/latest/row-filters) 사용
2. [row_set](https://cloud.google.com/python/docs/reference/bigtable/latest/row-set#google.cloud.bigtable.row_set.RowSet) 사용

```python
import google.cloud.bigtable.row_filters as row_filters

filter_loader = BigtableLoader(
    INSTANCE_ID, TABLE_ID, filter=row_filters.ColumnQualifierRegexFilter(b"os_build")
)


from google.cloud.bigtable.row_set import RowSet

row_set = RowSet()
row_set.add_row_range_from_keys(
    start_key="phone#4c410523#20190501", end_key="phone#4c410523#201906201"
)

row_set_loader = BigtableLoader(
    INSTANCE_ID,
    TABLE_ID,
    row_set=row_set,
)
```


### 사용자 정의 클라이언트
기본적으로 생성된 클라이언트는 admin=True 옵션만 사용하는 기본 클라이언트입니다. 비기본 [사용자 정의 클라이언트](https://cloud.google.com/python/docs/reference/bigtable/latest/client#class-googlecloudbigtableclientclientprojectnone-credentialsnone-readonlyfalse-adminfalse-clientinfonone-clientoptionsnone-adminclientoptionsnone-channelnone)를 생성자에 전달할 수 있습니다.

```python
from google.cloud import bigtable

custom_client_loader = BigtableLoader(
    INSTANCE_ID,
    TABLE_ID,
    client=bigtable.Client(...),
)
```


### 사용자 정의 콘텐츠
BigtableLoader는 `langchain`이라는 열 패밀리가 있고, `content`라는 열이 있으며, UTF-8로 인코딩된 값을 포함한다고 가정합니다. 이러한 기본값은 다음과 같이 변경할 수 있습니다:

```python
from langchain_google_bigtable import Encoding

custom_content_loader = BigtableLoader(
    INSTANCE_ID,
    TABLE_ID,
    content_encoding=Encoding.ASCII,
    content_column_family="my_content_family",
    content_column_name="my_content_column_name",
)
```


### 메타데이터 매핑
기본적으로 `Document` 객체의 `metadata` 맵에는 행의 rowkey 값이 포함된 단일 키 `rowkey`가 포함됩니다. 해당 맵에 더 많은 항목을 추가하려면 metadata_mapping을 사용하세요.

```python
import json

from langchain_google_bigtable import MetadataMapping

metadata_mapping_loader = BigtableLoader(
    INSTANCE_ID,
    TABLE_ID,
    metadata_mappings=[
        MetadataMapping(
            column_family="my_int_family",
            column_name="my_int_column",
            metadata_key="key_in_metadata_map",
            encoding=Encoding.INT_BIG_ENDIAN,
        ),
        MetadataMapping(
            column_family="my_custom_family",
            column_name="my_custom_column",
            metadata_key="custom_key",
            encoding=Encoding.CUSTOM,
            custom_decoding_func=lambda input: json.loads(input.decode()),
            custom_encoding_func=lambda input: str.encode(json.dumps(input)),
        ),
    ],
)
```


### JSON으로서의 메타데이터

빅테이블에 출력 문서 메타데이터에 추가하고 싶은 JSON 문자열이 포함된 열이 있는 경우, BigtableLoader에 다음 매개변수를 추가할 수 있습니다. `metadata_as_json_encoding`의 기본값은 UTF-8입니다.

```python
metadata_as_json_loader = BigtableLoader(
    INSTANCE_ID,
    TABLE_ID,
    metadata_as_json_encoding=Encoding.ASCII,
    metadata_as_json_family="my_metadata_as_json_family",
    metadata_as_json_name="my_metadata_as_json_column_name",
)
```


### BigtableSaver 사용자 정의

BigtableSaver는 BigtableLoader와 유사하게 사용자 정의할 수 있습니다.

```python
saver = BigtableSaver(
    INSTANCE_ID,
    TABLE_ID,
    client=bigtable.Client(...),
    content_encoding=Encoding.ASCII,
    content_column_family="my_content_family",
    content_column_name="my_content_column_name",
    metadata_mappings=[
        MetadataMapping(
            column_family="my_int_family",
            column_name="my_int_column",
            metadata_key="key_in_metadata_map",
            encoding=Encoding.INT_BIG_ENDIAN,
        ),
        MetadataMapping(
            column_family="my_custom_family",
            column_name="my_custom_column",
            metadata_key="custom_key",
            encoding=Encoding.CUSTOM,
            custom_decoding_func=lambda input: json.loads(input.decode()),
            custom_encoding_func=lambda input: str.encode(json.dumps(input)),
        ),
    ],
    metadata_as_json_encoding=Encoding.ASCII,
    metadata_as_json_family="my_metadata_as_json_family",
    metadata_as_json_name="my_metadata_as_json_column_name",
)
```


## 관련 자료

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)