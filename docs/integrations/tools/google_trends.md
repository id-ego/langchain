---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_trends.ipynb
description: 구글 트렌드 도구를 사용하여 트렌드 정보를 가져오는 방법을 설명합니다. SerpApi 키 설정 및 관련 코드 사용법을 포함합니다.
---

# 구글 트렌드

이 노트북은 구글 트렌드 도구를 사용하여 트렌드 정보를 가져오는 방법에 대해 설명합니다.

먼저, `SerpApi key`를 다음 링크에서 등록해야 합니다: https://serpapi.com/users/sign_up.

그런 다음, 다음 명령어로 `google-search-results`를 설치해야 합니다:

`pip install google-search-results`

그 후, 환경 변수 `SERPAPI_API_KEY`를 `SerpApi key`로 설정해야 합니다.

[또는 래퍼에 인수로 키를 전달할 수 있습니다 `serp_api_key="your secret key"`]

## 도구 사용하기

```python
%pip install --upgrade --quiet  google-search-results langchain_community
```

```output
Requirement already satisfied: google-search-results in c:\python311\lib\site-packages (2.4.2)
Requirement already satisfied: requests in c:\python311\lib\site-packages (from google-search-results) (2.31.0)
Requirement already satisfied: charset-normalizer<4,>=2 in c:\python311\lib\site-packages (from requests->google-search-results) (3.3.2)
Requirement already satisfied: idna<4,>=2.5 in c:\python311\lib\site-packages (from requests->google-search-results) (3.4)
Requirement already satisfied: urllib3<3,>=1.21.1 in c:\python311\lib\site-packages (from requests->google-search-results) (2.1.0)
Requirement already satisfied: certifi>=2017.4.17 in c:\python311\lib\site-packages (from requests->google-search-results) (2023.7.22)
```


```python
<!--IMPORTS:[{"imported": "GoogleTrendsQueryRun", "source": "langchain_community.tools.google_trends", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.google_trends.tool.GoogleTrendsQueryRun.html", "title": "Google Trends"}, {"imported": "GoogleTrendsAPIWrapper", "source": "langchain_community.utilities.google_trends", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.google_trends.GoogleTrendsAPIWrapper.html", "title": "Google Trends"}]-->
import os

from langchain_community.tools.google_trends import GoogleTrendsQueryRun
from langchain_community.utilities.google_trends import GoogleTrendsAPIWrapper

os.environ["SERPAPI_API_KEY"] = ""
tool = GoogleTrendsQueryRun(api_wrapper=GoogleTrendsAPIWrapper())
```


```python
tool.run("Water")
```


```output
'Query: Water\nDate From: Nov 20, 2022\nDate To: Nov 11, 2023\nMin Value: 72\nMax Value: 100\nAverage Value: 84.25490196078431\nPrecent Change: 5.555555555555555%\nTrend values: 72, 72, 74, 77, 86, 80, 82, 88, 79, 79, 85, 82, 81, 84, 83, 77, 80, 85, 82, 80, 88, 84, 82, 84, 83, 85, 92, 92, 100, 92, 100, 96, 94, 95, 94, 98, 96, 84, 86, 84, 85, 83, 83, 76, 81, 85, 78, 77, 81, 75, 76\nRising Related Queries: avatar way of water, avatar the way of water, owala water bottle, air up water bottle, lake mead water level\nTop Related Queries: water park, water bottle, water heater, water filter, water tank, water bill, water world, avatar way of water, avatar the way of water, coconut water, deep water, water cycle, water dispenser, water purifier, water pollution, distilled water, hot water heater, water cooler, sparkling water, american water, micellar water, density of water, tankless water heater, tonic water, water jug'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)