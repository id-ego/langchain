---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/knn.ipynb
description: kNN 알고리즘을 활용한 검색기 사용법을 다루는 노트북으로, 분류 및 회귀에 대한 비모수 감독 학습 방법을 설명합니다.
---

# kNN

> 통계학에서 [k-최근접 이웃 알고리즘 (k-NN)](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm)은 1951년 `Evelyn Fix`와 `Joseph Hodges`에 의해 처음 개발된 비모수 감독 학습 방법으로, 이후 `Thomas Cover`에 의해 확장되었습니다. 이는 분류 및 회귀에 사용됩니다.

이 노트북은 내부적으로 kNN을 사용하는 검색기를 사용하는 방법을 다룹니다.

주로 [Andrej Karpathy](https://github.com/karpathy/randomfun/blob/master/knn_vs_svm.html)의 코드를 기반으로 합니다.

```python
<!--IMPORTS:[{"imported": "KNNRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.knn.KNNRetriever.html", "title": "kNN"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "kNN"}]-->
from langchain_community.retrievers import KNNRetriever
from langchain_openai import OpenAIEmbeddings
```


## 텍스트로 새 검색기 만들기

```python
retriever = KNNRetriever.from_texts(
    ["foo", "bar", "world", "hello", "foo bar"], OpenAIEmbeddings()
)
```


## 검색기 사용하기

이제 검색기를 사용할 수 있습니다!

```python
result = retriever.invoke("foo")
```


```python
result
```


```output
[Document(page_content='foo', metadata={}),
 Document(page_content='foo bar', metadata={}),
 Document(page_content='hello', metadata={}),
 Document(page_content='bar', metadata={})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)