---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/google_generative_ai.ipynb
description: 구글 생성 AI 임베딩 서비스에 연결하는 방법과 사용법, 배치 처리, 작업 유형에 대한 정보를 제공합니다.
---

# 구글 생성 AI 임베딩

`GoogleGenerativeAIEmbeddings` 클래스를 사용하여 구글의 생성 AI 임베딩 서비스에 연결합니다. 이 클래스는 [langchain-google-genai](https://pypi.org/project/langchain-google-genai/) 패키지에서 찾을 수 있습니다.

## 설치

```python
%pip install --upgrade --quiet  langchain-google-genai
```


## 자격 증명

```python
import getpass
import os

if "GOOGLE_API_KEY" not in os.environ:
    os.environ["GOOGLE_API_KEY"] = getpass("Provide your Google API key here")
```


## 사용법

```python
from langchain_google_genai import GoogleGenerativeAIEmbeddings

embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
vector = embeddings.embed_query("hello, world!")
vector[:5]
```


```output
[0.05636945, 0.0048285457, -0.0762591, -0.023642512, 0.05329321]
```


## 배치

처리 속도를 높이기 위해 여러 문자열을 한 번에 임베딩할 수도 있습니다:

```python
vectors = embeddings.embed_documents(
    [
        "Today is Monday",
        "Today is Tuesday",
        "Today is April Fools day",
    ]
)
len(vectors), len(vectors[0])
```


```output
(3, 768)
```


## 작업 유형
`GoogleGenerativeAIEmbeddings`는 선택적으로 `task_type`을 지원하며, 현재는 다음 중 하나여야 합니다:

- task_type_unspecified
- retrieval_query
- retrieval_document
- semantic_similarity
- classification
- clustering

기본적으로 `embed_documents` 메서드에서는 `retrieval_document`를 사용하고, `embed_query` 메서드에서는 `retrieval_query`를 사용합니다. 작업 유형을 제공하면 모든 메서드에 대해 해당 유형을 사용합니다.

```python
%pip install --upgrade --quiet  matplotlib scikit-learn
```

```output
Note: you may need to restart the kernel to use updated packages.
```


```python
query_embeddings = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001", task_type="retrieval_query"
)
doc_embeddings = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001", task_type="retrieval_document"
)
```


이 모든 것은 'retrieval_query' 작업 세트로 임베딩됩니다.
```python
query_vecs = [query_embeddings.embed_query(q) for q in [query, query_2, answer_1]]
```

이 모든 것은 'retrieval_document' 작업 세트로 임베딩됩니다.
```python
doc_vecs = [doc_embeddings.embed_query(q) for q in [query, query_2, answer_1]]
```


검색에서 상대적 거리가 중요합니다. 위 이미지에서 "관련 문서"와 "유사한 쿼리" 간의 유사성 점수 차이를 확인할 수 있습니다. 후자의 경우 관련 문서와 유사한 쿼리 간의 더 강한 델타가 있습니다.

## 추가 구성

SDK의 동작을 사용자 정의하기 위해 ChatGoogleGenerativeAI에 다음 매개변수를 전달할 수 있습니다:

- `client_options`: 구글 API 클라이언트에 전달할 [클라이언트 옵션](https://googleapis.dev/python/google-api-core/latest/client_options.html#module-google.api_core.client_options), 예를 들어 사용자 정의 `client_options["api_endpoint"]`
- `transport`: 사용할 전송 방법, 예를 들어 `rest`, `grpc` 또는 `grpc_asyncio`.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)