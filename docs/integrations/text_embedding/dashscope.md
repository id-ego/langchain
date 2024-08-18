---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/dashscope.ipynb
description: DashScope는 임베딩 클래스를 로드하는 방법을 안내하며, 관련 개념 및 가이드를 제공합니다.
---

# DashScope

DashScope 임베딩 클래스를 로드해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "DashScopeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.dashscope.DashScopeEmbeddings.html", "title": "DashScope"}]-->
from langchain_community.embeddings import DashScopeEmbeddings
```


```python
embeddings = DashScopeEmbeddings(
    model="text-embedding-v1", dashscope_api_key="your-dashscope-api-key"
)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
print(query_result)
```


```python
doc_results = embeddings.embed_documents(["foo"])
print(doc_results)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)