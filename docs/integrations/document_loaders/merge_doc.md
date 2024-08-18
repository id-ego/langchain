---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/merge_doc.ipynb
description: 문서 로더에서 반환된 문서를 병합하는 방법을 설명합니다. 다양한 데이터 로더를 사용하여 효율적으로 문서를 통합하세요.
---

# 문서 병합 로더

지정된 데이터 로더 세트에서 반환된 문서를 병합합니다.

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Merge Documents Loader"}]-->
from langchain_community.document_loaders import WebBaseLoader

loader_web = WebBaseLoader(
    "https://github.com/basecamp/handbook/blob/master/37signals-is-you.md"
)
```


```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "Merge Documents Loader"}]-->
from langchain_community.document_loaders import PyPDFLoader

loader_pdf = PyPDFLoader("../MachineLearning-Lecture01.pdf")
```


```python
<!--IMPORTS:[{"imported": "MergedDataLoader", "source": "langchain_community.document_loaders.merge", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.merge.MergedDataLoader.html", "title": "Merge Documents Loader"}]-->
from langchain_community.document_loaders.merge import MergedDataLoader

loader_all = MergedDataLoader(loaders=[loader_web, loader_pdf])
```


```python
docs_all = loader_all.load()
```


```python
len(docs_all)
```


```output
23
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)