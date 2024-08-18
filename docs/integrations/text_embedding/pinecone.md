---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/pinecone.ipynb
description: Pinecone의 인퍼런스 API를 사용하여 텍스트 임베딩을 생성하는 방법을 설명합니다. 동기 및 비동기 방식의 임베딩 생성
  예시 포함.
---

# 파인콘 임베딩

파인콘의 추론 API는 `PineconeEmbeddings`를 통해 접근할 수 있습니다. 파인콘 서비스를 통해 텍스트 임베딩을 제공합니다. 먼저 필수 라이브러리를 설치합니다:

```python
!pip install -qU "langchain-pinecone>=0.2.0" 
```


다음으로 [파인콘에 가입/로그인](https://app.pinecone.io)하여 API 키를 받습니다:

```python
import os
from getpass import getpass

os.environ["PINECONE_API_KEY"] = os.getenv("PINECONE_API_KEY") or getpass(
    "Enter your Pinecone API key: "
)
```


사용 가능한 [모델](https://docs.pinecone.io/models/overview)을 문서에서 확인합니다. 이제 다음과 같이 임베딩 모델을 초기화합니다:

```python
<!--IMPORTS:[{"imported": "PineconeEmbeddings", "source": "langchain_pinecone", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_pinecone.embeddings.PineconeEmbeddings.html", "title": "Pinecone Embeddings"}]-->
from langchain_pinecone import PineconeEmbeddings

embeddings = PineconeEmbeddings(model="multilingual-e5-large")
```


여기서 우리는 동기 또는 비동기로 임베딩을 생성할 수 있습니다. 먼저 동기 방식으로 시작하겠습니다! `embed_query`를 사용하여 단일 텍스트를 쿼리 임베딩(즉, RAG에서 검색하는 내용)으로 임베딩합니다:

```python
docs = [
    "Apple is a popular fruit known for its sweetness and crisp texture.",
    "The tech company Apple is known for its innovative products like the iPhone.",
    "Many people enjoy eating apples as a healthy snack.",
    "Apple Inc. has revolutionized the tech industry with its sleek designs and user-friendly interfaces.",
    "An apple a day keeps the doctor away, as the saying goes.",
]
```


```python
doc_embeds = embeddings.embed_documents(docs)
doc_embeds
```


```python
query = "Tell me about the tech company known as Apple"
query_embed = embeddings.embed_query(query)
query_embed
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)