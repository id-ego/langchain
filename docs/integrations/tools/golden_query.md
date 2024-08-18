---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/golden_query.ipynb
description: 이 문서는 Golden Query API를 활용하여 자연어 쿼리 및 데이터 검색을 수행하는 방법을 설명합니다. API 키 설정
  방법도 포함되어 있습니다.
---

# 골든 쿼리

> [골든](https://golden.com)은 골든 지식 그래프를 사용하여 쿼리 및 보강을 위한 자연어 API 세트를 제공합니다. 예를 들어, `OpenAI의 제품`, `시리즈 A 자금을 받은 생성적 AI 회사`, `투자하는 래퍼들`과 같은 쿼리를 사용하여 관련 엔티티에 대한 구조화된 데이터를 검색할 수 있습니다.
> 
> `golden-query` langchain 도구는 이러한 결과에 대한 프로그래밍적 접근을 가능하게 하는 [골든 쿼리 API](https://docs.golden.com/reference/query-api) 위에 래핑된 도구입니다.
자세한 내용은 [골든 쿼리 API 문서](https://docs.golden.com/reference/query-api)를 참조하십시오.

이 노트북에서는 `golden-query` 도구를 사용하는 방법에 대해 설명합니다.

- [골든 API 문서](https://docs.golden.com/)로 가서 골든 API에 대한 개요를 확인하십시오.
- [골든 API 설정](https://golden.com/settings/api) 페이지에서 API 키를 가져옵니다.
- API 키를 GOLDEN_API_KEY 환경 변수에 저장합니다.

```python
%pip install -qU langchain-community
```


```python
import os

os.environ["GOLDEN_API_KEY"] = ""
```


```python
<!--IMPORTS:[{"imported": "GoldenQueryAPIWrapper", "source": "langchain_community.utilities.golden_query", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.golden_query.GoldenQueryAPIWrapper.html", "title": "Golden Query"}]-->
from langchain_community.utilities.golden_query import GoldenQueryAPIWrapper
```


```python
golden_query = GoldenQueryAPIWrapper()
```


```python
import json

json.loads(golden_query.run("companies in nanotech"))
```


```output
{'results': [{'id': 4673886,
   'latestVersionId': 60276991,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Samsung', 'citations': []}]}]},
  {'id': 7008,
   'latestVersionId': 61087416,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Intel', 'citations': []}]}]},
  {'id': 24193,
   'latestVersionId': 60274482,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Texas Instruments', 'citations': []}]}]},
  {'id': 1142,
   'latestVersionId': 61406205,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Advanced Micro Devices', 'citations': []}]}]},
  {'id': 193948,
   'latestVersionId': 58326582,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Freescale Semiconductor', 'citations': []}]}]},
  {'id': 91316,
   'latestVersionId': 60387380,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Agilent Technologies', 'citations': []}]}]},
  {'id': 90014,
   'latestVersionId': 60388078,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Novartis', 'citations': []}]}]},
  {'id': 237458,
   'latestVersionId': 61406160,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'Analog Devices', 'citations': []}]}]},
  {'id': 3941943,
   'latestVersionId': 60382250,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'AbbVie Inc.', 'citations': []}]}]},
  {'id': 4178762,
   'latestVersionId': 60542667,
   'properties': [{'predicateId': 'name',
     'instances': [{'value': 'IBM', 'citations': []}]}]}],
 'next': 'https://golden.com/api/v2/public/queries/59044/results/?cursor=eyJwb3NpdGlvbiI6IFsxNzYxNiwgIklCTS04M1lQM1oiXX0%3D&pageSize=10',
 'previous': None}
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)