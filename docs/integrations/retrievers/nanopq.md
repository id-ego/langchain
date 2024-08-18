---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/nanopq.ipynb
description: 이 문서는 대규모 데이터셋에서 의미 검색을 위한 NanoPQ(제품 양자화) 알고리즘을 사용하는 검색기 구현 방법을 설명합니다.
---

# NanoPQ (제품 양자화)

> [제품 양자화 알고리즘 (k-NN)](https://towardsdatascience.com/similarity-search-product-quantization-b2a1a6397701)은 대규모 데이터 세트가 포함될 때 의미 검색에 도움이 되는 데이터베이스 벡터의 압축을 돕는 양자화 알고리즘입니다. 요약하자면, 임베딩은 M개의 하위 공간으로 나뉘며, 이후 클러스터링을 거칩니다. 벡터를 클러스터링한 후, 중심 벡터는 하위 공간의 각 클러스터에 존재하는 벡터에 매핑됩니다.

이 노트북은 [nanopq](https://github.com/matsui528/nanopq) 패키지에 의해 구현된 제품 양자화를 사용하는 검색기를 사용하는 방법을 다룹니다.

```python
%pip install -qU langchain-community langchain-openai nanopq
```


```python
<!--IMPORTS:[{"imported": "SpacyEmbeddings", "source": "langchain_community.embeddings.spacy_embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.spacy_embeddings.SpacyEmbeddings.html", "title": "NanoPQ (Product Quantization)"}, {"imported": "NanoPQRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.nanopq.NanoPQRetriever.html", "title": "NanoPQ (Product Quantization)"}]-->
from langchain_community.embeddings.spacy_embeddings import SpacyEmbeddings
from langchain_community.retrievers import NanoPQRetriever
```


## 텍스트로 새 검색기 만들기

```python
retriever = NanoPQRetriever.from_texts(
    ["Great world", "great words", "world", "planets of the world"],
    SpacyEmbeddings(model_name="en_core_web_sm"),
    clusters=2,
    subspace=2,
)
```


## 검색기 사용하기

이제 검색기를 사용할 수 있습니다!

```python
retriever.invoke("earth")
```

```output
M: 2, Ks: 2, metric : <class 'numpy.uint8'>, code_dtype: l2
iter: 20, seed: 123
Training the subspace: 0 / 2
Training the subspace: 1 / 2
Encoding the subspace: 0 / 2
Encoding the subspace: 1 / 2
```


```output
[Document(page_content='world'),
 Document(page_content='Great world'),
 Document(page_content='great words'),
 Document(page_content='planets of the world')]
```


## 관련 자료

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)