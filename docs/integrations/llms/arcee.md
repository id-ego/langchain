---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/arcee.ipynb
description: 이 문서는 Arcee 클래스를 사용하여 도메인 적응 언어 모델(DALM)로 텍스트를 생성하는 방법을 설명합니다.
---

# Arcee
이 노트북은 Arcee의 도메인 적응 언어 모델(DALMs)을 사용하여 텍스트를 생성하는 `Arcee` 클래스 사용 방법을 보여줍니다.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


### 설정

Arcee를 사용하기 전에 Arcee API 키가 `ARCEE_API_KEY` 환경 변수로 설정되어 있는지 확인하세요. API 키를 명명된 매개변수로 전달할 수도 있습니다.

```python
<!--IMPORTS:[{"imported": "Arcee", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.arcee.Arcee.html", "title": "Arcee"}]-->
from langchain_community.llms import Arcee

# Create an instance of the Arcee class
arcee = Arcee(
    model="DALM-PubMed",
    # arcee_api_key="ARCEE-API-KEY" # if not already set in the environment
)
```


### 추가 구성

필요에 따라 `arcee_api_url`, `arcee_app_url`, 및 `model_kwargs`와 같은 Arcee의 매개변수를 구성할 수 있습니다. 객체 초기화 시 `model_kwargs`를 설정하면 이후 모든 응답 생성 호출에 대해 기본값으로 사용됩니다.

```python
arcee = Arcee(
    model="DALM-Patent",
    # arcee_api_key="ARCEE-API-KEY", # if not already set in the environment
    arcee_api_url="https://custom-api.arcee.ai",  # default is https://api.arcee.ai
    arcee_app_url="https://custom-app.arcee.ai",  # default is https://app.arcee.ai
    model_kwargs={
        "size": 5,
        "filters": [
            {
                "field_name": "document",
                "filter_type": "fuzzy_search",
                "value": "Einstein",
            }
        ],
    },
)
```


### 텍스트 생성

프롬프트를 제공하여 Arcee에서 텍스트를 생성할 수 있습니다. 예를 들면 다음과 같습니다:

```python
# Generate text
prompt = "Can AI-driven music therapy contribute to the rehabilitation of patients with disorders of consciousness?"
response = arcee(prompt)
```


### 추가 매개변수

Arcee는 텍스트 생성을 돕기 위해 `filters`를 적용하고 검색된 문서의 `size`(수량 기준)를 설정할 수 있습니다. 필터는 결과를 좁히는 데 도움이 됩니다. 이러한 매개변수를 사용하는 방법은 다음과 같습니다:

```python
# Define filters
filters = [
    {"field_name": "document", "filter_type": "fuzzy_search", "value": "Einstein"},
    {"field_name": "year", "filter_type": "strict_search", "value": "1905"},
]

# Generate text with filters and size params
response = arcee(prompt, size=5, filters=filters)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)