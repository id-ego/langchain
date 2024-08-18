---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/fake.ipynb
description: LangChain의 가짜 임베딩 클래스를 사용하여 파이프라인을 테스트하는 방법에 대한 설명과 관련 자료를 제공합니다.
---

# 가짜 임베딩

LangChain은 가짜 임베딩 클래스를 제공합니다. 이를 사용하여 파이프라인을 테스트할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "FakeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Fake Embeddings"}]-->
from langchain_community.embeddings import FakeEmbeddings
```


```python
embeddings = FakeEmbeddings(size=1352)
```


```python
query_result = embeddings.embed_query("foo")
```


```python
doc_results = embeddings.embed_documents(["foo"])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)