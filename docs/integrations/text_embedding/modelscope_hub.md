---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/modelscope_hub.ipynb
description: 모델스코프는 다양한 모델과 데이터셋을 제공하는 대규모 저장소입니다. Embedding 클래스를 로드하는 방법을 안내합니다.
---

# ModelScope

> [ModelScope](https://www.modelscope.cn/home)는 모델과 데이터셋의 큰 저장소입니다.

ModelScope Embedding 클래스를 로드해 봅시다.

```python
<!--IMPORTS:[{"imported": "ModelScopeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.modelscope_hub.ModelScopeEmbeddings.html", "title": "ModelScope"}]-->
from langchain_community.embeddings import ModelScopeEmbeddings
```


```python
model_id = "damo/nlp_corom_sentence-embedding_english-base"
```


```python
embeddings = ModelScopeEmbeddings(model_id=model_id)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_results = embeddings.embed_documents(["foo"])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)