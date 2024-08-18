---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/tf_idf.ipynb
description: TF-IDF를 사용하여 문서 검색기를 만드는 방법을 설명하며, scikit-learn 패키지를 활용한 예제를 포함합니다.
---

# TF-IDF

> [TF-IDF](https://scikit-learn.org/stable/modules/feature_extraction.html#tfidf-term-weighting)는 용어 빈도와 역 문서 빈도의 곱을 의미합니다.

이 노트북은 `scikit-learn` 패키지를 사용하여 기본적으로 [TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf)를 사용하는 검색기를 사용하는 방법을 설명합니다.

TF-IDF의 세부 사항에 대한 더 많은 정보는 [이 블로그 게시물](https://medium.com/data-science-bootcamp/tf-idf-basics-of-information-retrieval-48de122b2a4c)을 참조하세요.

```python
%pip install --upgrade --quiet  scikit-learn
```


```python
<!--IMPORTS:[{"imported": "TFIDFRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.tfidf.TFIDFRetriever.html", "title": "TF-IDF"}]-->
from langchain_community.retrievers import TFIDFRetriever
```


## 텍스트로 새 검색기 만들기

```python
retriever = TFIDFRetriever.from_texts(["foo", "bar", "world", "hello", "foo bar"])
```


## 문서로 새 검색기 만들기

이제 생성한 문서로 새 검색기를 만들 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "TF-IDF"}]-->
from langchain_core.documents import Document

retriever = TFIDFRetriever.from_documents(
    [
        Document(page_content="foo"),
        Document(page_content="bar"),
        Document(page_content="world"),
        Document(page_content="hello"),
        Document(page_content="foo bar"),
    ]
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


## 저장 및 로드

이 검색기를 쉽게 저장하고 로드할 수 있어 로컬 개발에 유용합니다!

```python
retriever.save_local("testing.pkl")
```


```python
retriever_copy = TFIDFRetriever.load_local("testing.pkl")
```


```python
retriever_copy.invoke("foo")
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