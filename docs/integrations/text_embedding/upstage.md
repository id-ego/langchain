---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/upstage.ipynb
description: 이 문서는 Upstage 임베딩 모델을 시작하는 방법과 설치, 환경 설정, 사용법 및 벡터 저장소와의 통합에 대해 설명합니다.
sidebar_label: Upstage
---

# UpstageEmbeddings

이 노트북은 Upstage 임베딩 모델을 시작하는 방법을 다룹니다.

## 설치

`langchain-upstage` 패키지를 설치합니다.

```bash
pip install -U langchain-upstage
```


## 환경 설정

다음 환경 변수를 설정해야 합니다:

- `UPSTAGE_API_KEY`: [Upstage 콘솔](https://console.upstage.ai/)에서 가져온 Upstage API 키입니다.

```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```


## 사용법

`UpstageEmbeddings` 클래스를 초기화합니다.

```python
from langchain_upstage import UpstageEmbeddings

embeddings = UpstageEmbeddings(model="solar-embedding-1-large")
```


텍스트 또는 문서 목록을 임베드하려면 `embed_documents`를 사용합니다.

```python
doc_result = embeddings.embed_documents(
    ["Sung is a professor.", "This is another document"]
)
print(doc_result)
```


쿼리 문자열을 임베드하려면 `embed_query`를 사용합니다.

```python
query_result = embeddings.embed_query("What does Sung do?")
print(query_result)
```


비동기 작업을 위해 `aembed_documents` 및 `aembed_query`를 사용합니다.

```python
# async embed query
await embeddings.aembed_query("My query to look up")
```


```python
# async embed documents
await embeddings.aembed_documents(
    ["This is a content of the document", "This is another document"]
)
```


## 벡터 저장소와 함께 사용하기

`UpstageEmbeddings`를 벡터 저장소 구성 요소와 함께 사용할 수 있습니다. 다음은 간단한 예제를 보여줍니다.

```python
<!--IMPORTS:[{"imported": "DocArrayInMemorySearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.docarray.in_memory.DocArrayInMemorySearch.html", "title": "UpstageEmbeddings"}]-->
from langchain_community.vectorstores import DocArrayInMemorySearch

vectorstore = DocArrayInMemorySearch.from_texts(
    ["harrison worked at kensho", "bears like to eat honey"],
    embedding=UpstageEmbeddings(model="solar-embedding-1-large"),
)
retriever = vectorstore.as_retriever()
docs = retriever.invoke("Where did Harrison work?")
print(docs)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)