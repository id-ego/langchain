---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/open_city_data.ipynb
description: 이 문서는 도시 오픈 데이터 API 사용법을 설명하며, 샌프란시스코의 다양한 데이터셋 식별자를 제공합니다.
---

# 오픈 시티 데이터

[Socrata](https://dev.socrata.com/foundry/data.sfgov.org/vw6y-z8j6)는 도시 오픈 데이터에 대한 API를 제공합니다.

[SF 범죄](https://data.sfgov.org/Public-Safety/Police-Department-Incident-Reports-Historical-2003/tmnf-yvry)와 같은 데이터 세트의 경우, 오른쪽 상단의 `API` 탭으로 이동합니다.

그러면 `데이터 세트 식별자`를 제공합니다.

데이터 세트 식별자를 사용하여 특정 city_id(`data.sfgov.org`)에 대한 테이블을 가져옵니다 -

예: [SF 311 데이터](https://dev.socrata.com/foundry/data.sfgov.org/vw6y-z8j6)의 경우 `vw6y-z8j6`.

예: [SF 경찰 데이터](https://dev.socrata.com/foundry/data.sfgov.org/tmnf-yvry)의 경우 `tmnf-yvry`.

```python
%pip install --upgrade --quiet  sodapy
```


```python
<!--IMPORTS:[{"imported": "OpenCityDataLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.open_city_data.OpenCityDataLoader.html", "title": "Open City Data"}]-->
from langchain_community.document_loaders import OpenCityDataLoader
```


```python
dataset = "vw6y-z8j6"  # 311 data
dataset = "tmnf-yvry"  # crime data
loader = OpenCityDataLoader(city_id="data.sfgov.org", dataset_id=dataset, limit=2000)
```


```python
docs = loader.load()
```

```output
WARNING:root:Requests made without an app_token will be subject to strict throttling limits.
```


```python
eval(docs[0].page_content)
```


```output
{'pdid': '4133422003074',
 'incidntnum': '041334220',
 'incident_code': '03074',
 'category': 'ROBBERY',
 'descript': 'ROBBERY, BODILY FORCE',
 'dayofweek': 'Monday',
 'date': '2004-11-22T00:00:00.000',
 'time': '17:50',
 'pddistrict': 'INGLESIDE',
 'resolution': 'NONE',
 'address': 'GENEVA AV / SANTOS ST',
 'x': '-122.420084075249',
 'y': '37.7083109744362',
 'location': {'type': 'Point',
  'coordinates': [-122.420084075249, 37.7083109744362]},
 ':@computed_region_26cr_cadq': '9',
 ':@computed_region_rxqg_mtj9': '8',
 ':@computed_region_bh8s_q3mv': '309'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)