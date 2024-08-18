---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/weather.ipynb
description: OpenWeatherMap의 OneCall API를 사용하여 날씨 데이터를 가져오는 로더에 대한 설명입니다. API 토큰과
  도시 이름이 필요합니다.
---

# 날씨

> [OpenWeatherMap](https://openweathermap.org/)는 오픈 소스 날씨 서비스 제공업체입니다.

이 로더는 pyowm Python 패키지를 사용하여 OpenWeatherMap의 OneCall API에서 날씨 데이터를 가져옵니다. 로더를 초기화하려면 OpenWeatherMap API 토큰과 날씨 데이터를 가져오고자 하는 도시의 이름을 입력해야 합니다.

```python
<!--IMPORTS:[{"imported": "WeatherDataLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.weather.WeatherDataLoader.html", "title": "Weather"}]-->
from langchain_community.document_loaders import WeatherDataLoader
```


```python
%pip install --upgrade --quiet  pyowm
```


```python
# Set API key either by passing it in to constructor directly
# or by setting the environment variable "OPENWEATHERMAP_API_KEY".

from getpass import getpass

OPENWEATHERMAP_API_KEY = getpass()
```


```python
loader = WeatherDataLoader.from_params(
    ["chennai", "vellore"], openweathermap_api_key=OPENWEATHERMAP_API_KEY
)
```


```python
documents = loader.load()
documents
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)