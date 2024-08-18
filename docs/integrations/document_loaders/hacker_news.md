---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/hacker_news.ipynb
description: 해커 뉴스(Hacker News)에서 페이지 데이터와 댓글을 추출하는 방법을 다룬 노트북입니다. 컴퓨터 과학 및 기업가 정신에
  중점을 둡니다.
---

# 해커 뉴스

> [해커 뉴스](https://en.wikipedia.org/wiki/Hacker_News) (가끔 `HN`으로 약칭됨)는 컴퓨터 과학과 기업가 정신에 중점을 둔 소셜 뉴스 웹사이트입니다. 이는 투자 펀드 및 스타트업 인큐베이터 `Y Combinator`에 의해 운영됩니다. 일반적으로 제출할 수 있는 콘텐츠는 "지적 호기심을 충족시키는 모든 것"으로 정의됩니다.

이 노트북은 [해커 뉴스](https://news.ycombinator.com/)에서 페이지 데이터와 댓글을 가져오는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "HNLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.hn.HNLoader.html", "title": "Hacker News"}]-->
from langchain_community.document_loaders import HNLoader
```


```python
loader = HNLoader("https://news.ycombinator.com/item?id=34817881")
```


```python
data = loader.load()
```


```python
data[0].page_content[:300]
```


```output
"delta_p_delta_x 73 days ago  \n             | next [–] \n\nAstrophysical and cosmological simulations are often insightful. They're also very cross-disciplinary; besides the obvious astrophysics, there's networking and sysadmin, parallel computing and algorithm theory (so that the simulation programs a"
```


```python
data[0].metadata
```


```output
{'source': 'https://news.ycombinator.com/item?id=34817881',
 'title': 'What Lights the Universe’s Standard Candles?'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)