---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/aleph_alpha.ipynb
description: Aleph Alpha의 비대칭 및 대칭 임베딩 사용법에 대한 설명과 관련 자료 링크를 제공합니다.
---

# 알레프 알파

알레프 알파의 의미 임베딩을 사용하는 두 가지 가능한 방법이 있습니다. 구조가 다른 텍스트(예: 문서와 쿼리)가 있는 경우 비대칭 임베딩을 사용하고 싶을 것입니다. 반대로, 구조가 유사한 텍스트의 경우 대칭 임베딩이 권장되는 접근 방식입니다.

## 비대칭

```python
<!--IMPORTS:[{"imported": "AlephAlphaAsymmetricSemanticEmbedding", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.aleph_alpha.AlephAlphaAsymmetricSemanticEmbedding.html", "title": "Aleph Alpha"}]-->
from langchain_community.embeddings import AlephAlphaAsymmetricSemanticEmbedding
```


```python
document = "This is a content of the document"
query = "What is the content of the document?"
```


```python
embeddings = AlephAlphaAsymmetricSemanticEmbedding(normalize=True, compress_to_size=128)
```


```python
doc_result = embeddings.embed_documents([document])
```


```python
query_result = embeddings.embed_query(query)
```


## 대칭

```python
<!--IMPORTS:[{"imported": "AlephAlphaSymmetricSemanticEmbedding", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.aleph_alpha.AlephAlphaSymmetricSemanticEmbedding.html", "title": "Aleph Alpha"}]-->
from langchain_community.embeddings import AlephAlphaSymmetricSemanticEmbedding
```


```python
text = "This is a test text"
```


```python
embeddings = AlephAlphaSymmetricSemanticEmbedding(normalize=True, compress_to_size=128)
```


```python
doc_result = embeddings.embed_documents([text])
```


```python
query_result = embeddings.embed_query(text)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)