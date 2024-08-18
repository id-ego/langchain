---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/imsdb.ipynb
description: IMSDb는 영화 스크립트를 저장하는 데이터베이스로, 웹페이지를 문서 형식으로 로드하는 방법을 다룹니다.
---

# IMSDb

> [IMSDb](https://imsdb.com/)는 `인터넷 영화 대본 데이터베이스`입니다.

이는 `IMSDb` 웹페이지를 우리가 하류에서 사용할 수 있는 문서 형식으로 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "IMSDbLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.imsdb.IMSDbLoader.html", "title": "IMSDb"}]-->
from langchain_community.document_loaders import IMSDbLoader
```


```python
loader = IMSDbLoader("https://imsdb.com/scripts/BlacKkKlansman.html")
```


```python
data = loader.load()
```


```python
data[0].page_content[:500]
```


```output
'\n\r\n\r\n\r\n\r\n                                    BLACKKKLANSMAN\r\n                         \r\n                         \r\n                         \r\n                         \r\n                                      Written by\r\n\r\n                          Charlie Wachtel & David Rabinowitz\r\n\r\n                                         and\r\n\r\n                              Kevin Willmott & Spike Lee\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n                         FADE IN:\r\n                         \r\n          SCENE FROM "GONE WITH'
```


```python
data[0].metadata
```


```output
{'source': 'https://imsdb.com/scripts/BlacKkKlansman.html'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)