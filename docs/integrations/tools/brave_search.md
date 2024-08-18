---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/brave_search.ipynb
description: 이 문서는 Brave Search 도구 사용 방법을 설명하며, 무료 계정 가입 및 API 키 획득 방법을 안내합니다.
---

# 브레이브 서치

이 노트북은 브레이브 서치 도구를 사용하는 방법에 대해 설명합니다.  
[브레이브 웹사이트](https://brave.com/search/api/)에 가서 무료 계정을 등록하고 API 키를 받으세요.

```python
%pip install --upgrade --quiet langchain-community
```


```python
<!--IMPORTS:[{"imported": "BraveSearch", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.brave_search.tool.BraveSearch.html", "title": "Brave Search"}]-->
from langchain_community.tools import BraveSearch
```


```python
api_key = "API KEY"
```


```python
tool = BraveSearch.from_api_key(api_key=api_key, search_kwargs={"count": 3})
```


```python
tool.run("obama middle name")
```


```output
'[{"title": "Obama\'s Middle Name -- My Last Name -- is \'Hussein.\' So?", "link": "https://www.cair.com/cair_in_the_news/obamas-middle-name-my-last-name-is-hussein-so/", "snippet": "I wasn\\u2019t sure whether to laugh or cry a few days back listening to radio talk show host Bill Cunningham repeatedly scream Barack <strong>Obama</strong>\\u2019<strong>s</strong> <strong>middle</strong> <strong>name</strong> \\u2014 my last <strong>name</strong> \\u2014 as if he had anti-Muslim Tourette\\u2019s. \\u201cHussein,\\u201d Cunningham hissed like he was beckoning Satan when shouting the ..."}, {"title": "What\'s up with Obama\'s middle name? - Quora", "link": "https://www.quora.com/Whats-up-with-Obamas-middle-name", "snippet": "Answer (1 of 15): A better question would be, \\u201cWhat\\u2019s up with <strong>Obama</strong>\\u2019s first <strong>name</strong>?\\u201d President Barack Hussein <strong>Obama</strong>\\u2019s father\\u2019s <strong>name</strong> was Barack Hussein <strong>Obama</strong>. He was <strong>named</strong> after his father. Hussein, <strong>Obama</strong>\\u2019<strong>s</strong> <strong>middle</strong> <strong>name</strong>, is a very common Arabic <strong>name</strong>, meaning &quot;good,&quot; &quot;handsome,&quot; or ..."}, {"title": "Barack Obama | Biography, Parents, Education, Presidency, Books, ...", "link": "https://www.britannica.com/biography/Barack-Obama", "snippet": "Barack <strong>Obama</strong>, in full Barack Hussein <strong>Obama</strong> II, (born August 4, 1961, Honolulu, Hawaii, U.S.), 44th president of the United States (2009\\u201317) and the first African American to hold the office. Before winning the presidency, <strong>Obama</strong> represented Illinois in the U.S."}]'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)