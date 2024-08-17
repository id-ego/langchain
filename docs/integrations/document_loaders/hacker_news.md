---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/hacker_news/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/hacker_news.ipynb
---

# Hacker News

>[Hacker News](https://en.wikipedia.org/wiki/Hacker_News) (sometimes abbreviated as `HN`) is a social news website focusing on computer science and entrepreneurship. It is run by the investment fund and startup incubator `Y Combinator`. In general, content that can be submitted is defined as "anything that gratifies one's intellectual curiosity."

This notebook covers how to pull page data and comments from [Hacker News](https://news.ycombinator.com/)


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



## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)