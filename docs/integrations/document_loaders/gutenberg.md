---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/gutenberg.ipynb
description: 구텐베르크 프로젝트의 무료 전자책 링크를 문서 형식으로 로드하는 방법을 다룬 노트북입니다.
---

# 구텐베르크

> [구텐베르크 프로젝트](https://www.gutenberg.org/about/)는 무료 전자책의 온라인 라이브러리입니다.

이 노트북은 `구텐베르크` 전자책의 링크를 우리가 하류에서 사용할 수 있는 문서 형식으로 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "GutenbergLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.gutenberg.GutenbergLoader.html", "title": "Gutenberg"}]-->
from langchain_community.document_loaders import GutenbergLoader
```


```python
loader = GutenbergLoader("https://www.gutenberg.org/cache/epub/69972/pg69972.txt")
```


```python
data = loader.load()
```


```python
data[0].page_content[:300]
```


```output
'The Project Gutenberg eBook of The changed brides, by Emma Dorothy\r\n\n\nEliza Nevitte Southworth\r\n\n\n\r\n\n\nThis eBook is for the use of anyone anywhere in the United States and\r\n\n\nmost other parts of the world at no cost and with almost no restrictions\r\n\n\nwhatsoever. You may copy it, give it away or re-u'
```


```python
data[0].metadata
```


```output
{'source': 'https://www.gutenberg.org/cache/epub/69972/pg69972.txt'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)