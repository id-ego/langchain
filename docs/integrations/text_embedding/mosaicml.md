---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/mosaicml.ipynb
description: MosaicML은 다양한 오픈 소스 모델을 사용하거나 자체 모델을 배포할 수 있는 관리형 추론 서비스를 제공합니다. LangChain을
  활용한 예시를 다룹니다.
---

# MosaicML

> [MosaicML](https://docs.mosaicml.com/en/latest/inference.html)은 관리형 추론 서비스를 제공합니다. 다양한 오픈 소스 모델을 사용하거나 자신의 모델을 배포할 수 있습니다.

이 예제에서는 LangChain을 사용하여 `MosaicML` 추론과 상호 작용하는 방법을 설명합니다.

```python
# sign up for an account: https://forms.mosaicml.com/demo?utm_source=langchain

from getpass import getpass

MOSAICML_API_TOKEN = getpass()
```


```python
import os

os.environ["MOSAICML_API_TOKEN"] = MOSAICML_API_TOKEN
```


```python
<!--IMPORTS:[{"imported": "MosaicMLInstructorEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.mosaicml.MosaicMLInstructorEmbeddings.html", "title": "MosaicML"}]-->
from langchain_community.embeddings import MosaicMLInstructorEmbeddings
```


```python
embeddings = MosaicMLInstructorEmbeddings(
    query_instruction="Represent the query for retrieval: "
)
```


```python
query_text = "This is a test query."
query_result = embeddings.embed_query(query_text)
```


```python
document_text = "This is a test document."
document_result = embeddings.embed_documents([document_text])
```


```python
import numpy as np

query_numpy = np.array(query_result)
document_numpy = np.array(document_result[0])
similarity = np.dot(query_numpy, document_numpy) / (
    np.linalg.norm(query_numpy) * np.linalg.norm(document_numpy)
)
print(f"Cosine similarity between document and query: {similarity}")
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)