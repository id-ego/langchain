---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/pinecone_hybrid_search.ipynb
description: 이 문서는 Pinecone을 사용한 하이브리드 검색 리트리버 설정 방법과 OpenAI 임베딩을 활용하는 방법을 설명합니다.
---

# 파인콘 하이브리드 검색

> [파인콘](https://docs.pinecone.io/docs/overview)은 폭넓은 기능을 가진 벡터 데이터베이스입니다.

이 노트북은 파인콘과 하이브리드 검색을 사용하는 리트리버를 사용하는 방법을 설명합니다.

이 리트리버의 논리는 [이 문서](https://docs.pinecone.io/docs/hybrid-search)에서 가져왔습니다.

파인콘을 사용하려면 API 키와 환경이 필요합니다. [설치 지침](https://docs.pinecone.io/docs/quickstart)을 참조하세요.

```python
%pip install --upgrade --quiet  pinecone-client pinecone-text pinecone-notebooks
```


```python
# Connect to Pinecone and get an API key.
from pinecone_notebooks.colab import Authenticate

Authenticate()

import os

api_key = os.environ["PINECONE_API_KEY"]
```


```python
<!--IMPORTS:[{"imported": "PineconeHybridSearchRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.pinecone_hybrid_search.PineconeHybridSearchRetriever.html", "title": "Pinecone Hybrid Search"}]-->
from langchain_community.retrievers import (
    PineconeHybridSearchRetriever,
)
```


우리는 `OpenAIEmbeddings`를 사용하고 싶으므로 OpenAI API 키를 얻어야 합니다.

```python
import getpass

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


## 파인콘 설정

이 부분은 한 번만 수행하면 됩니다.

```python
import os

from pinecone import Pinecone, ServerlessSpec

index_name = "langchain-pinecone-hybrid-search"

# initialize Pinecone client
pc = Pinecone(api_key=api_key)

# create the index
if index_name not in pc.list_indexes().names():
    pc.create_index(
        name=index_name,
        dimension=1536,  # dimensionality of dense model
        metric="dotproduct",  # sparse values supported only for dotproduct
        spec=ServerlessSpec(cloud="aws", region="us-east-1"),
    )
```


```output
WhoAmIResponse(username='load', user_label='label', projectname='load-test')
```


인덱스가 생성되었으므로 이제 사용할 수 있습니다.

```python
index = pc.Index(index_name)
```


## 임베딩 및 희소 인코더 가져오기

임베딩은 밀집 벡터에 사용되며, 토크나이저는 희소 벡터에 사용됩니다.

```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Pinecone Hybrid Search"}]-->
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
```


텍스트를 희소 값으로 인코딩하려면 SPLADE 또는 BM25 중에서 선택할 수 있습니다. 도메인 외 작업에는 BM25를 사용하는 것을 권장합니다.

희소 인코더에 대한 자세한 정보는 파인콘 텍스트 라이브러리 [문서](https://pinecone-io.github.io/pinecone-text/pinecone_text.html)를 확인하세요.

```python
from pinecone_text.sparse import BM25Encoder

# or from pinecone_text.sparse import SpladeEncoder if you wish to work with SPLADE

# use default tf-idf values
bm25_encoder = BM25Encoder().default()
```


위 코드는 기본 tf-idf 값을 사용하고 있습니다. tf-idf 값을 자신의 말뭉치에 맞게 조정하는 것이 강력히 권장됩니다. 다음과 같이 할 수 있습니다:

```python
corpus = ["foo", "bar", "world", "hello"]

# fit tf-idf values on your corpus
bm25_encoder.fit(corpus)

# store the values to a json file
bm25_encoder.dump("bm25_values.json")

# load to your BM25Encoder object
bm25_encoder = BM25Encoder().load("bm25_values.json")
```


## 리트리버 로드

이제 리트리버를 구성할 수 있습니다!

```python
retriever = PineconeHybridSearchRetriever(
    embeddings=embeddings, sparse_encoder=bm25_encoder, index=index
)
```


## 텍스트 추가 (필요한 경우)

리트리버에 텍스트를 선택적으로 추가할 수 있습니다 (이미 포함되어 있지 않은 경우).

```python
retriever.add_texts(["foo", "bar", "world", "hello"])
```

```output
100%|██████████| 1/1 [00:02<00:00,  2.27s/it]
```

## 리트리버 사용

이제 리트리버를 사용할 수 있습니다!

```python
result = retriever.invoke("foo")
```


```python
result[0]
```


```output
Document(page_content='foo', metadata={})
```


## 관련

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)