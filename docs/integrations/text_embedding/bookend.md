---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/bookend.ipynb
description: Bookend AI의 Embeddings 클래스를 로드하는 방법과 관련된 문서입니다. 임베딩 모델에 대한 개념 및 가이드를
  포함하고 있습니다.
---

# 북엔드 AI

북엔드 AI 임베딩 클래스 로드해봅시다.

```python
<!--IMPORTS:[{"imported": "BookendEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.bookend.BookendEmbeddings.html", "title": "Bookend AI"}]-->
from langchain_community.embeddings import BookendEmbeddings
```


```python
embeddings = BookendEmbeddings(
    domain="your_domain",
    api_token="your_api_token",
    model_id="your_embeddings_model_id",
)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_result = embeddings.embed_documents([text])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)