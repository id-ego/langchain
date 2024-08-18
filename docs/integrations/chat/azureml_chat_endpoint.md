---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/azureml_chat_endpoint.ipynb
description: 이 문서는 Azure Machine Learning의 온라인 엔드포인트를 사용하여 호스팅된 채팅 모델을 활용하는 방법을 설명합니다.
sidebar_label: Azure ML Endpoint
---

# AzureMLChatOnlineEndpoint

> [Azure Machine Learning](https://azure.microsoft.com/en-us/products/machine-learning/)은 기계 학습 모델을 구축, 훈련 및 배포하는 데 사용되는 플랫폼입니다. 사용자는 다양한 제공업체의 기본 및 일반 목적 모델을 제공하는 모델 카탈로그에서 배포할 모델의 유형을 탐색할 수 있습니다.
> 
> 일반적으로 예측(추론)을 소비하기 위해 모델을 배포해야 합니다. `Azure Machine Learning`에서 [온라인 엔드포인트](https://learn.microsoft.com/en-us/azure/machine-learning/concept-endpoints)는 이러한 모델을 실시간으로 제공하기 위해 사용됩니다. 이는 프로덕션 작업의 인터페이스를 이를 제공하는 구현과 분리할 수 있도록 하는 `엔드포인트` 및 `배포`의 아이디어를 기반으로 합니다.

이 노트북은 `Azure Machine Learning Endpoint`에서 호스팅되는 채팅 모델을 사용하는 방법을 설명합니다.

```python
<!--IMPORTS:[{"imported": "AzureMLChatOnlineEndpoint", "source": "langchain_community.chat_models.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.azureml_endpoint.AzureMLChatOnlineEndpoint.html", "title": "AzureMLChatOnlineEndpoint"}]-->
from langchain_community.chat_models.azureml_endpoint import AzureMLChatOnlineEndpoint
```


## 설정

[Azure ML에 모델을 배포](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-use-foundation-models?view=azureml-api-2#deploying-foundation-models-to-endpoints-for-inferencing)하거나 [Azure AI 스튜디오에 배포](https://learn.microsoft.com/en-us/azure/ai-studio/how-to/deploy-models-open)하고 다음 매개변수를 얻어야 합니다:

* `endpoint_url`: 엔드포인트에서 제공하는 REST 엔드포인트 URL입니다.
* `endpoint_api_type`: **전용 엔드포인트**(호스팅 관리 인프라)에 모델을 배포할 때는 `endpoint_type='dedicated'`를 사용합니다. **사용한 만큼 지불** 제공(서비스로서의 모델)을 사용하여 모델을 배포할 때는 `endpoint_type='serverless'`를 사용합니다.
* `endpoint_api_key`: 엔드포인트에서 제공하는 API 키입니다.

## 콘텐츠 포맷터

`content_formatter` 매개변수는 AzureML 엔드포인트의 요청 및 응답을 요구되는 스키마에 맞게 변환하는 핸들러 클래스입니다. 모델 카탈로그에는 다양한 모델이 있으며, 각 모델은 서로 다른 방식으로 데이터를 처리할 수 있으므로 사용자가 원하는 대로 데이터를 변환할 수 있도록 `ContentFormatterBase` 클래스가 제공됩니다. 다음 콘텐츠 포맷터가 제공됩니다:

* `CustomOpenAIChatContentFormatter`: OpenAI API 사양에 따라 요청 및 응답을 포맷하는 LLaMa2-chat과 같은 모델을 위한 요청 및 응답 데이터를 포맷합니다.

*참고: `langchain.chat_models.azureml_endpoint.LlamaChatContentFormatter`는 더 이상 사용되지 않으며 `langchain.chat_models.azureml_endpoint.CustomOpenAIChatContentFormatter`로 대체됩니다.*

모델에 특정한 사용자 정의 콘텐츠 포맷터를 `langchain_community.llms.azureml_endpoint.ContentFormatterBase` 클래스를 상속하여 구현할 수 있습니다.

## 예제

다음 섹션에는 이 클래스를 사용하는 방법에 대한 예제가 포함되어 있습니다:

### 예제: 실시간 엔드포인트를 통한 채팅 완성

```python
<!--IMPORTS:[{"imported": "AzureMLEndpointApiType", "source": "langchain_community.chat_models.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.AzureMLEndpointApiType.html", "title": "AzureMLChatOnlineEndpoint"}, {"imported": "CustomOpenAIChatContentFormatter", "source": "langchain_community.chat_models.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.azureml_endpoint.CustomOpenAIChatContentFormatter.html", "title": "AzureMLChatOnlineEndpoint"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "AzureMLChatOnlineEndpoint"}]-->
from langchain_community.chat_models.azureml_endpoint import (
    AzureMLEndpointApiType,
    CustomOpenAIChatContentFormatter,
)
from langchain_core.messages import HumanMessage

chat = AzureMLChatOnlineEndpoint(
    endpoint_url="https://<your-endpoint>.<your_region>.inference.ml.azure.com/score",
    endpoint_api_type=AzureMLEndpointApiType.dedicated,
    endpoint_api_key="my-api-key",
    content_formatter=CustomOpenAIChatContentFormatter(),
)
response = chat.invoke(
    [HumanMessage(content="Will the Collatz conjecture ever be solved?")]
)
response
```


```output
AIMessage(content='  The Collatz Conjecture is one of the most famous unsolved problems in mathematics, and it has been the subject of much study and research for many years. While it is impossible to predict with certainty whether the conjecture will ever be solved, there are several reasons why it is considered a challenging and important problem:\n\n1. Simple yet elusive: The Collatz Conjecture is a deceptively simple statement that has proven to be extraordinarily difficult to prove or disprove. Despite its simplicity, the conjecture has eluded some of the brightest minds in mathematics, and it remains one of the most famous open problems in the field.\n2. Wide-ranging implications: The Collatz Conjecture has far-reaching implications for many areas of mathematics, including number theory, algebra, and analysis. A solution to the conjecture could have significant impacts on these fields and potentially lead to new insights and discoveries.\n3. Computational evidence: While the conjecture remains unproven, extensive computational evidence supports its validity. In fact, no counterexample to the conjecture has been found for any starting value up to 2^64 (a number', additional_kwargs={}, example=False)
```


### 예제: 사용한 만큼 지불하는 배포(서비스로서의 모델)를 통한 채팅 완성

```python
chat = AzureMLChatOnlineEndpoint(
    endpoint_url="https://<your-endpoint>.<your_region>.inference.ml.azure.com/v1/chat/completions",
    endpoint_api_type=AzureMLEndpointApiType.serverless,
    endpoint_api_key="my-api-key",
    content_formatter=CustomOpenAIChatContentFormatter,
)
response = chat.invoke(
    [HumanMessage(content="Will the Collatz conjecture ever be solved?")]
)
response
```


모델에 추가 매개변수를 전달해야 하는 경우 `model_kwargs` 인수를 사용합니다:

```python
chat = AzureMLChatOnlineEndpoint(
    endpoint_url="https://<your-endpoint>.<your_region>.inference.ml.azure.com/v1/chat/completions",
    endpoint_api_type=AzureMLEndpointApiType.serverless,
    endpoint_api_key="my-api-key",
    content_formatter=CustomOpenAIChatContentFormatter,
    model_kwargs={"temperature": 0.8},
)
```


호출 중에 매개변수를 전달할 수도 있습니다:

```python
response = chat.invoke(
    [HumanMessage(content="Will the Collatz conjecture ever be solved?")],
    max_tokens=512,
)
response
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)