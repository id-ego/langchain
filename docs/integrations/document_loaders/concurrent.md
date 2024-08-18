---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/concurrent.ipynb
description: 동시 로더는 GenericLoader와 유사하지만, 작업 흐름을 최적화하기 위해 동시에 작동합니다.
---

# 동시 로더

GenericLoader와 동일하게 작동하지만, 워크플로우를 최적화하려는 사용자들을 위해 동시적으로 작동합니다.

```python
<!--IMPORTS:[{"imported": "ConcurrentLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.concurrent.ConcurrentLoader.html", "title": "Concurrent Loader"}]-->
from langchain_community.document_loaders import ConcurrentLoader
```


```python
loader = ConcurrentLoader.from_filesystem("example_data/", glob="**/*.txt")
```


```python
files = loader.load()
```


```python
len(files)
```


```output
2
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)