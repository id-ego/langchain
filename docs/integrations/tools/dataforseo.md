---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/dataforseo.ipynb
description: DataForSeo API를 사용하여 Google, Bing, Yahoo 등 인기 검색 엔진의 SERP를 얻는 방법을 설명하는
  문서입니다.
---

# DataForSEO

> [DataForSeo](https://dataforseo.com/)는 API를 통해 포괄적인 SEO 및 디지털 마케팅 데이터 솔루션을 제공합니다.
> 
> `DataForSeo API`는 `Google`, `Bing`, `Yahoo`와 같은 가장 인기 있는 검색 엔진에서 `SERP`를 검색합니다. 또한 `Maps`, `News`, `Events` 등 다양한 검색 엔진 유형의 SERP를 가져올 수 있습니다.

이 노트북은 [DataForSeo API](https://dataforseo.com/apis)를 사용하여 검색 엔진 결과를 얻는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet langchain-community
```


```python
<!--IMPORTS:[{"imported": "DataForSeoAPIWrapper", "source": "langchain_community.utilities.dataforseo_api_search", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.dataforseo_api_search.DataForSeoAPIWrapper.html", "title": "DataForSEO"}]-->
from langchain_community.utilities.dataforseo_api_search import DataForSeoAPIWrapper
```


## API 자격 증명 설정

`DataForSeo` 웹사이트에 등록하여 API 자격 증명을 얻을 수 있습니다.

```python
import os

os.environ["DATAFORSEO_LOGIN"] = "your_api_access_username"
os.environ["DATAFORSEO_PASSWORD"] = "your_api_access_password"

wrapper = DataForSeoAPIWrapper()
```


run 메소드는 다음 요소 중 하나에서 첫 번째 결과 스니펫을 반환합니다: answer_box, knowledge_graph, featured_snippet, shopping, organic.

```python
wrapper.run("Weather in Los Angeles")
```


## `run`과 `results`의 차이
`run`과 `results`는 `DataForSeoAPIWrapper` 클래스에서 제공하는 두 가지 메소드입니다.

`run` 메소드는 검색을 실행하고 answer box, knowledge graph, featured snippet, shopping 또는 organic 결과에서 첫 번째 결과 스니펫을 반환합니다. 이러한 요소는 우선 순위에 따라 가장 높은 것부터 가장 낮은 것까지 정렬됩니다.

`results` 메소드는 래퍼에 설정된 매개변수에 따라 구성된 JSON 응답을 반환합니다. 이를 통해 API에서 반환할 데이터에 대한 더 많은 유연성을 제공합니다.

## JSON으로 결과 얻기
JSON 응답에서 반환할 결과 유형 및 필드를 사용자 정의할 수 있습니다. 반환할 상위 결과의 최대 개수를 설정할 수도 있습니다.

```python
json_wrapper = DataForSeoAPIWrapper(
    json_result_types=["organic", "knowledge_graph", "answer_box"],
    json_result_fields=["type", "title", "description", "text"],
    top_count=3,
)
```


```python
json_wrapper.results("Bill Gates")
```


## 위치 및 언어 사용자 정의
API 래퍼에 추가 매개변수를 전달하여 검색 결과의 위치 및 언어를 지정할 수 있습니다.

```python
customized_wrapper = DataForSeoAPIWrapper(
    top_count=10,
    json_result_types=["organic", "local_pack"],
    json_result_fields=["title", "description", "type"],
    params={"location_name": "Germany", "language_code": "en"},
)
customized_wrapper.results("coffee near me")
```


## 검색 엔진 사용자 정의
사용하려는 검색 엔진을 지정할 수도 있습니다.

```python
customized_wrapper = DataForSeoAPIWrapper(
    top_count=10,
    json_result_types=["organic", "local_pack"],
    json_result_fields=["title", "description", "type"],
    params={"location_name": "Germany", "language_code": "en", "se_name": "bing"},
)
customized_wrapper.results("coffee near me")
```


## 검색 유형 사용자 정의
API 래퍼는 수행하려는 검색 유형을 지정할 수 있도록 합니다. 예를 들어, 지도 검색을 수행할 수 있습니다.

```python
maps_search = DataForSeoAPIWrapper(
    top_count=10,
    json_result_fields=["title", "value", "address", "rating", "type"],
    params={
        "location_coordinate": "52.512,13.36,12z",
        "language_code": "en",
        "se_type": "maps",
    },
)
maps_search.results("coffee near me")
```


## Langchain 에이전트와의 통합
`langchain.agents` 모듈의 `Tool` 클래스를 사용하여 `DataForSeoAPIWrapper`를 langchain 에이전트와 통합할 수 있습니다. `Tool` 클래스는 에이전트가 호출할 수 있는 함수를 캡슐화합니다.

```python
<!--IMPORTS:[{"imported": "Tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.simple.Tool.html", "title": "DataForSEO"}]-->
from langchain_core.tools import Tool

search = DataForSeoAPIWrapper(
    top_count=3,
    json_result_types=["organic"],
    json_result_fields=["title", "description", "type"],
)
tool = Tool(
    name="google-search-answer",
    description="My new answer tool",
    func=search.run,
)
json_tool = Tool(
    name="google-search-json",
    description="My new json tool",
    func=search.results,
)
```


## 관련

- Tool [개념 가이드](/docs/concepts/#tools)
- Tool [사용 방법 가이드](/docs/how_to/#tools)