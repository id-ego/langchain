---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/svm.ipynb
description: 이 문서는 SVM(서포트 벡터 머신)을 사용하여 텍스트 검색기를 만드는 방법을 설명하며, scikit-learn 패키지를 활용합니다.
---

# SVM

> [서포트 벡터 머신(SVM)](https://scikit-learn.org/stable/modules/svm.html#support-vector-machines)은 분류, 회귀 및 이상치 탐지를 위해 사용되는 일련의 감독 학습 방법입니다.

이 노트북은 `scikit-learn` 패키지를 사용하여 내부적으로 `SVM`을 사용하는 검색기를 사용하는 방법을 설명합니다.

주로 https://github.com/karpathy/randomfun/blob/master/knn_vs_svm.html 에 기반합니다.

```python
%pip install --upgrade --quiet  scikit-learn
```


```python
%pip install --upgrade --quiet  lark
```


우리는 `OpenAIEmbeddings`를 사용하고 싶으므로 OpenAI API 키를 받아야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```output
OpenAI API Key: ········
```


```python
<!--IMPORTS:[{"imported": "SVMRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.svm.SVMRetriever.html", "title": "SVM"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "SVM"}]-->
from langchain_community.retrievers import SVMRetriever
from langchain_openai import OpenAIEmbeddings
```


## 텍스트로 새 검색기 만들기

```python
retriever = SVMRetriever.from_texts(
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
 Document(page_content='world', metadata={})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)