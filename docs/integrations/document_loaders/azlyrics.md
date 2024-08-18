---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/azlyrics.ipynb
description: AZLyrics 웹페이지를 문서 형식으로 로드하는 방법을 다루며, 이후 활용할 수 있는 내용을 제공합니다.
---

# AZLyrics

> [AZLyrics](https://www.azlyrics.com/)는 크고 합법적이며 매일 성장하는 가사 컬렉션입니다.

이는 AZLyrics 웹페이지를 우리가 하류에서 사용할 수 있는 문서 형식으로 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "AZLyricsLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.azlyrics.AZLyricsLoader.html", "title": "AZLyrics"}]-->
from langchain_community.document_loaders import AZLyricsLoader
```


```python
loader = AZLyricsLoader("https://www.azlyrics.com/lyrics/mileycyrus/flowers.html")
```


```python
data = loader.load()
```


```python
data
```


```output
[Document(page_content="Miley Cyrus - Flowers Lyrics | AZLyrics.com\n\r\nWe were good, we were gold\nKinda dream that can't be sold\nWe were right till we weren't\nBuilt a home and watched it burn\n\nI didn't wanna leave you\nI didn't wanna lie\nStarted to cry but then remembered I\n\nI can buy myself flowers\nWrite my name in the sand\nTalk to myself for hours\nSay things you don't understand\nI can take myself dancing\nAnd I can hold my own hand\nYeah, I can love me better than you can\n\nCan love me better\nI can love me better, baby\nCan love me better\nI can love me better, baby\n\nPaint my nails, cherry red\nMatch the roses that you left\nNo remorse, no regret\nI forgive every word you said\n\nI didn't wanna leave you, baby\nI didn't wanna fight\nStarted to cry but then remembered I\n\nI can buy myself flowers\nWrite my name in the sand\nTalk to myself for hours, yeah\nSay things you don't understand\nI can take myself dancing\nAnd I can hold my own hand\nYeah, I can love me better than you can\n\nCan love me better\nI can love me better, baby\nCan love me better\nI can love me better, baby\nCan love me better\nI can love me better, baby\nCan love me better\nI\n\nI didn't wanna wanna leave you\nI didn't wanna fight\nStarted to cry but then remembered I\n\nI can buy myself flowers\nWrite my name in the sand\nTalk to myself for hours (Yeah)\nSay things you don't understand\nI can take myself dancing\nAnd I can hold my own hand\nYeah, I can love me better than\nYeah, I can love me better than you can, uh\n\nCan love me better\nI can love me better, baby\nCan love me better\nI can love me better, baby (Than you can)\nCan love me better\nI can love me better, baby\nCan love me better\nI\n", lookup_str='', metadata={'source': 'https://www.azlyrics.com/lyrics/mileycyrus/flowers.html'}, lookup_index=0)]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)