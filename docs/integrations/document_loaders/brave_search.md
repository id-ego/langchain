---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/brave_search.ipynb
description: 브레이브 서치는 브레이브 소프트웨어가 개발한 검색 엔진으로, 자체 웹 인덱스를 사용하여 광고 없는 검색 경험을 제공합니다.
---

# 브레이브 서치

> [브레이브 서치](https://en.wikipedia.org/wiki/Brave_Search)는 브레이브 소프트웨어에서 개발한 검색 엔진입니다.
> - `브레이브 서치`는 자체 웹 인덱스를 사용합니다. 2022년 5월 기준으로 100억 개 이상의 페이지를 포함하고 있으며, 92%의 검색 결과를 제3자에 의존하지 않고 제공했습니다. 나머지는 서버 측에서 빙 API를 통해 또는 (선택적으로) 클라이언트 측에서 구글로부터 검색됩니다. 브레이브에 따르면, 인덱스는 스팸 및 기타 저품질 콘텐츠를 피하기 위해 "구글이나 빙보다 의도적으로 작게 유지"되었으며, "브레이브 서치는 긴 꼬리 쿼리를 복구하는 데 있어 구글만큼 좋지 않다"는 단점이 있습니다.
> - `브레이브 서치 프리미엄`: 2023년 4월 기준으로 브레이브 서치는 광고 없는 웹사이트이지만, 결국 광고가 포함된 새로운 모델로 전환될 예정이며, 프리미엄 사용자는 광고 없는 경험을 하게 됩니다. IP 주소를 포함한 사용자 데이터는 기본적으로 수집되지 않습니다. 선택적 데이터 수집을 위해서는 프리미엄 계정이 필요합니다.

## 설치 및 설정

브레이브 서치 API에 접근하려면 [계정을 생성하고 API 키를 받아야](https://api.search.brave.com/app/dashboard) 합니다.

```python
api_key = "..."
```


```python
<!--IMPORTS:[{"imported": "BraveSearchLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.brave_search.BraveSearchLoader.html", "title": "Brave Search"}]-->
from langchain_community.document_loaders import BraveSearchLoader
```


## 예제

```python
loader = BraveSearchLoader(
    query="obama middle name", api_key=api_key, search_kwargs={"count": 3}
)
docs = loader.load()
len(docs)
```


```output
3
```


```python
[doc.metadata for doc in docs]
```


```output
[{'title': "Obama's Middle Name -- My Last Name -- is 'Hussein.' So?",
  'link': 'https://www.cair.com/cair_in_the_news/obamas-middle-name-my-last-name-is-hussein-so/'},
 {'title': "What's up with Obama's middle name? - Quora",
  'link': 'https://www.quora.com/Whats-up-with-Obamas-middle-name'},
 {'title': 'Barack Obama | Biography, Parents, Education, Presidency, Books, ...',
  'link': 'https://www.britannica.com/biography/Barack-Obama'}]
```


```python
[doc.page_content for doc in docs]
```


```output
['I wasn’t sure whether to laugh or cry a few days back listening to radio talk show host Bill Cunningham repeatedly scream Barack <strong>Obama</strong>’<strong>s</strong> <strong>middle</strong> <strong>name</strong> — my last <strong>name</strong> — as if he had anti-Muslim Tourette’s. “Hussein,” Cunningham hissed like he was beckoning Satan when shouting the ...',
 'Answer (1 of 15): A better question would be, “What’s up with <strong>Obama</strong>’s first <strong>name</strong>?” President Barack Hussein <strong>Obama</strong>’s father’s <strong>name</strong> was Barack Hussein <strong>Obama</strong>. He was <strong>named</strong> after his father. Hussein, <strong>Obama</strong>’<strong>s</strong> <strong>middle</strong> <strong>name</strong>, is a very common Arabic <strong>name</strong>, meaning &quot;good,&quot; &quot;handsome,&quot; or ...',
 'Barack <strong>Obama</strong>, in full Barack Hussein <strong>Obama</strong> II, (born August 4, 1961, Honolulu, Hawaii, U.S.), 44th president of the United States (2009–17) and the first African American to hold the office. Before winning the presidency, <strong>Obama</strong> represented Illinois in the U.S.']
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)