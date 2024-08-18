---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_memorystore_redis.ipynb
description: Google Memorystore for Redis는 애플리케이션 캐시를 구축하여 초밀리초 데이터 접근을 제공하는 완전 관리형
  서비스입니다.
---

# Google Memorystore for Redis

> [Google Memorystore for Redis](https://cloud.google.com/memorystore/docs/redis/memorystore-for-redis-overview)는 서브 밀리세컨드 데이터 액세스를 제공하는 애플리케이션 캐시를 구축하기 위해 Redis 인메모리 데이터 저장소를 기반으로 하는 완전 관리형 서비스입니다. Memorystore for Redis의 Langchain 통합을 활용하여 AI 기반 경험을 구축하기 위해 데이터베이스 애플리케이션을 확장하세요.

이 노트북에서는 `MemorystoreDocumentLoader` 및 `MemorystoreDocumentSaver`를 사용하여 [langchain 문서 저장, 로드 및 삭제하기](/docs/how_to#document-loaders)에 대해 설명합니다.

패키지에 대한 자세한 내용은 [GitHub](https://github.com/googleapis/langchain-google-memorystore-redis-python/)에서 확인하세요.

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googleapis/langchain-google-memorystore-redis-python/blob/main/docs/document_loader.ipynb)

## 시작하기 전에

이 노트북을 실행하려면 다음을 수행해야 합니다:

* [Google Cloud 프로젝트 만들기](https://developers.google.com/workspace/guides/create-project)
* [Memorystore for Redis API 사용 설정](https://console.cloud.google.com/flows/enableapi?apiid=redis.googleapis.com)
* [Memorystore for Redis 인스턴스 만들기](https://cloud.google.com/memorystore/docs/redis/create-instance-console). 버전이 5.0 이상인지 확인하세요.

이 노트북의 런타임 환경에서 데이터베이스에 대한 액세스를 확인한 후, 다음 값을 입력하고 예제 스크립트를 실행하기 전에 셀을 실행하세요.

```python
# @markdown Please specify an endpoint associated with the instance and a key prefix for demo purpose.
ENDPOINT = "redis://127.0.0.1:6379"  # @param {type:"string"}
KEY_PREFIX = "doc:"  # @param {type:"string"}
```


### 🦜🔗 라이브러리 설치

통합은 자체 `langchain-google-memorystore-redis` 패키지에 있으므로 설치해야 합니다.

```python
%pip install -upgrade --quiet langchain-google-memorystore-redis
```


**Colab 전용**: 다음 셀의 주석을 제거하여 커널을 재시작하거나 버튼을 사용하여 커널을 재시작하세요. Vertex AI Workbench에서는 상단의 버튼을 사용하여 터미널을 재시작할 수 있습니다.

```python
# # Automatically restart kernel after installs so that your environment can access the new packages
# import IPython

# app = IPython.Application.instance()
# app.kernel.do_shutdown(True)
```


### ☁ Google Cloud 프로젝트 설정
Google Cloud 리소스를 이 노트북 내에서 활용할 수 있도록 Google Cloud 프로젝트를 설정하세요.

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

Google Cloud에 인증하여 이 노트북에 로그인한 IAM 사용자로서 Google Cloud 프로젝트에 접근하세요.

- Colab을 사용하여 이 노트북을 실행하는 경우 아래 셀을 사용하고 계속 진행하세요.
- Vertex AI Workbench를 사용하는 경우 [여기](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env)에서 설정 지침을 확인하세요.

```python
from google.colab import auth

auth.authenticate_user()
```


## 기본 사용법

### 문서 저장

`MemorystoreDocumentSaver.add_documents(<documents>)`를 사용하여 langchain 문서를 저장하세요. `MemorystoreDocumentSaver` 클래스를 초기화하려면 두 가지를 제공해야 합니다:

1. `client` - `redis.Redis` 클라이언트 객체.
2. `key_prefix` - Redis에 문서를 저장할 키의 접두사.

문서는 지정된 `key_prefix`의 접두사를 가진 무작위로 생성된 키에 저장됩니다. 또는 `add_documents` 메서드에서 `ids`를 지정하여 키의 접미사를 지정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Google Memorystore for Redis"}]-->
import redis
from langchain_core.documents import Document
from langchain_google_memorystore_redis import MemorystoreDocumentSaver

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
doc_ids = [f"{i}" for i in range(len(test_docs))]

redis_client = redis.from_url(ENDPOINT)
saver = MemorystoreDocumentSaver(
    client=redis_client,
    key_prefix=KEY_PREFIX,
    content_field="page_content",
)
saver.add_documents(test_docs, ids=doc_ids)
```


### 문서 로드

특정 접두사를 가진 Memorystore for Redis 인스턴스에 저장된 모든 문서를 로드하는 로더를 초기화하세요.

`MemorystoreDocumentLoader.load()` 또는 `MemorystoreDocumentLoader.lazy_load()`를 사용하여 langchain 문서를 로드하세요. `lazy_load`는 반복하는 동안에만 데이터베이스를 쿼리하는 생성기를 반환합니다. `MemorystoreDocumentLoader` 클래스를 초기화하려면 다음을 제공해야 합니다:

1. `client` - `redis.Redis` 클라이언트 객체.
2. `key_prefix` - Redis에 문서를 저장할 키의 접두사.

```python
import redis
from langchain_google_memorystore_redis import MemorystoreDocumentLoader

redis_client = redis.from_url(ENDPOINT)
loader = MemorystoreDocumentLoader(
    client=redis_client,
    key_prefix=KEY_PREFIX,
    content_fields=set(["page_content"]),
)
for doc in loader.lazy_load():
    print("Loaded documents:", doc)
```


### 문서 삭제

`MemorystoreDocumentSaver.delete()`를 사용하여 Memorystore for Redis 인스턴스에서 지정된 접두사를 가진 모든 키를 삭제하세요. 키의 접미사를 알고 있다면 지정할 수도 있습니다.

```python
docs = loader.load()
print("Documents before delete:", docs)

saver.delete(ids=[0])
print("Documents after delete:", loader.load())

saver.delete()
print("Documents after delete all:", loader.load())
```


## 고급 사용법

### 문서 페이지 내용 및 메타데이터 사용자 정의

1개 이상의 콘텐츠 필드로 로더를 초기화할 때, 로드된 문서의 `page_content`는 `content_fields`에 지정된 필드와 동일한 최상위 필드를 가진 JSON 인코딩 문자열을 포함합니다.

`metadata_fields`가 지정된 경우, 로드된 문서의 `metadata` 필드는 지정된 `metadata_fields`와 동일한 최상위 필드만 가집니다. 메타데이터 필드의 값 중 하나라도 JSON 인코딩 문자열로 저장된 경우, 메타데이터 필드에 로드되기 전에 디코딩됩니다.

```python
loader = MemorystoreDocumentLoader(
    client=redis_client,
    key_prefix=KEY_PREFIX,
    content_fields=set(["content_field_1", "content_field_2"]),
    metadata_fields=set(["title", "author"]),
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)