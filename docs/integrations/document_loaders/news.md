---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/news.ipynb
description: 뉴스 URL에서 HTML 기사 로드를 문서 형식으로 변환하여 후속 작업에 활용하는 방법을 설명합니다. NLP 분석도 지원합니다.
---

# 뉴스 URL

이 문서는 URL 목록에서 HTML 뉴스 기사를 문서 형식으로 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "NewsURLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.news.NewsURLLoader.html", "title": "News URL"}]-->
from langchain_community.document_loaders import NewsURLLoader
```


```python
urls = [
    "https://www.bbc.com/news/world-us-canada-66388172",
    "https://www.bbc.com/news/entertainment-arts-66384971",
]
```


문서로 로드할 URL을 전달합니다.

```python
loader = NewsURLLoader(urls=urls)
data = loader.load()
print("First article: ", data[0])
print("\nSecond article: ", data[1])
```

```output
First article:  page_content='In testimony to the congressional committee examining the 6 January riot, Mrs Powell said she did not review all of the many claims of election fraud she made, telling them that "no reasonable person" would view her claims as fact. Neither she nor her representatives have commented.' metadata={'title': 'Donald Trump indictment: What do we know about the six co-conspirators?', 'link': 'https://www.bbc.com/news/world-us-canada-66388172', 'authors': [], 'language': 'en', 'description': 'Six people accused of helping Mr Trump undermine the election have been described by prosecutors.', 'publish_date': None}

Second article:  page_content='Ms Williams added: "If there\'s anything that I can do in my power to ensure that dancers or singers or whoever decides to work with her don\'t have to go through that same experience, I\'m going to do that."' metadata={'title': "Lizzo dancers Arianna Davis and Crystal Williams: 'No one speaks out, they are scared'", 'link': 'https://www.bbc.com/news/entertainment-arts-66384971', 'authors': [], 'language': 'en', 'description': 'The US pop star is being sued for sexual harassment and fat-shaming but has yet to comment.', 'publish_date': None}
```

nlp=True를 사용하여 nlp 분석을 실행하고 키워드 + 요약을 생성합니다.

```python
loader = NewsURLLoader(urls=urls, nlp=True)
data = loader.load()
print("First article: ", data[0])
print("\nSecond article: ", data[1])
```

```output
First article:  page_content='In testimony to the congressional committee examining the 6 January riot, Mrs Powell said she did not review all of the many claims of election fraud she made, telling them that "no reasonable person" would view her claims as fact. Neither she nor her representatives have commented.' metadata={'title': 'Donald Trump indictment: What do we know about the six co-conspirators?', 'link': 'https://www.bbc.com/news/world-us-canada-66388172', 'authors': [], 'language': 'en', 'description': 'Six people accused of helping Mr Trump undermine the election have been described by prosecutors.', 'publish_date': None, 'keywords': ['powell', 'know', 'donald', 'trump', 'review', 'indictment', 'telling', 'view', 'reasonable', 'person', 'testimony', 'coconspirators', 'riot', 'representatives', 'claims'], 'summary': 'In testimony to the congressional committee examining the 6 January riot, Mrs Powell said she did not review all of the many claims of election fraud she made, telling them that "no reasonable person" would view her claims as fact.\nNeither she nor her representatives have commented.'}

Second article:  page_content='Ms Williams added: "If there\'s anything that I can do in my power to ensure that dancers or singers or whoever decides to work with her don\'t have to go through that same experience, I\'m going to do that."' metadata={'title': "Lizzo dancers Arianna Davis and Crystal Williams: 'No one speaks out, they are scared'", 'link': 'https://www.bbc.com/news/entertainment-arts-66384971', 'authors': [], 'language': 'en', 'description': 'The US pop star is being sued for sexual harassment and fat-shaming but has yet to comment.', 'publish_date': None, 'keywords': ['davis', 'lizzo', 'singers', 'experience', 'crystal', 'ensure', 'arianna', 'theres', 'williams', 'power', 'going', 'dancers', 'im', 'speaks', 'work', 'ms', 'scared'], 'summary': 'Ms Williams added: "If there\'s anything that I can do in my power to ensure that dancers or singers or whoever decides to work with her don\'t have to go through that same experience, I\'m going to do that."'}
```


```python
data[0].metadata["keywords"]
```


```output
['powell',
 'know',
 'donald',
 'trump',
 'review',
 'indictment',
 'telling',
 'view',
 'reasonable',
 'person',
 'testimony',
 'coconspirators',
 'riot',
 'representatives',
 'claims']
```


```python
data[0].metadata["summary"]
```


```output
'In testimony to the congressional committee examining the 6 January riot, Mrs Powell said she did not review all of the many claims of election fraud she made, telling them that "no reasonable person" would view her claims as fact.\nNeither she nor her representatives have commented.'
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)