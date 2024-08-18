---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/minimax.ipynb
description: MiniMax는 텍스트 임베딩을 위한 LangChain과의 상호작용 방법을 설명하는 가이드를 제공합니다.
---

# MiniMax

[MiniMax](https://api.minimax.chat/document/guides/embeddings?id=6464722084cdc277dfaa966a)는 임베딩 서비스를 제공합니다.

이 예제는 LangChain을 사용하여 MiniMax 추론과 상호작용하여 텍스트 임베딩을 사용하는 방법을 설명합니다.

```python
import os

os.environ["MINIMAX_GROUP_ID"] = "MINIMAX_GROUP_ID"
os.environ["MINIMAX_API_KEY"] = "MINIMAX_API_KEY"
```


```python
<!--IMPORTS:[{"imported": "MiniMaxEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.minimax.MiniMaxEmbeddings.html", "title": "MiniMax"}]-->
from langchain_community.embeddings import MiniMaxEmbeddings
```


```python
embeddings = MiniMaxEmbeddings()
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

```output
Cosine similarity between document and query: 0.1573236279277012
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)