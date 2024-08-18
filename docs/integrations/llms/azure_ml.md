---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/azure_ml.ipynb
description: Azure ML 플랫폼을 사용하여 기계 학습 모델을 구축, 훈련 및 배포하는 방법을 설명하는 노트북입니다. LLM을 Azure
  ML 온라인 엔드포인트에서 사용하는 방법을 다룹니다.
---

# Azure ML

[Azure ML](https://azure.microsoft.com/en-us/products/machine-learning/)은 기계 학습 모델을 구축, 훈련 및 배포하는 데 사용되는 플랫폼입니다. 사용자는 다양한 제공업체의 기본 및 일반 목적 모델을 제공하는 모델 카탈로그에서 배포할 모델의 유형을 탐색할 수 있습니다.

이 노트북에서는 `Azure ML Online Endpoint`에서 호스팅되는 LLM을 사용하는 방법을 설명합니다.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


```python
<!--IMPORTS:[{"imported": "AzureMLOnlineEndpoint", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.AzureMLOnlineEndpoint.html", "title": "Azure ML"}]-->
from langchain_community.llms.azureml_endpoint import AzureMLOnlineEndpoint
```


## 설정

[Azure ML에 모델을 배포해야 합니다](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-use-foundation-models?view=azureml-api-2#deploying-foundation-models-to-endpoints-for-inferencing) 또는 [Azure AI 스튜디오에 배포](https://learn.microsoft.com/en-us/azure/ai-studio/how-to/deploy-models-open)하고 다음 매개변수를 얻어야 합니다:

* `endpoint_url`: 엔드포인트에서 제공하는 REST 엔드포인트 URL.
* `endpoint_api_type`: **전용 엔드포인트**(호스팅 관리 인프라)에 모델을 배포할 때는 `endpoint_type='dedicated'`를 사용합니다. **사용한 만큼 지불** 제공(모델 서비스)을 사용하는 모델을 배포할 때는 `endpoint_type='serverless'`를 사용합니다.
* `endpoint_api_key`: 엔드포인트에서 제공하는 API 키.
* `deployment_name`: (선택 사항) 엔드포인트를 사용하는 모델의 배포 이름.

## 콘텐츠 포맷터

`content_formatter` 매개변수는 AzureML 엔드포인트의 요청 및 응답을 필요한 스키마에 맞게 변환하는 핸들러 클래스입니다. 모델 카탈로그에는 다양한 모델이 있으며, 각 모델은 서로 다른 방식으로 데이터를 처리할 수 있으므로 사용자가 원하는 대로 데이터를 변환할 수 있도록 `ContentFormatterBase` 클래스가 제공됩니다. 다음 콘텐츠 포맷터가 제공됩니다:

* `GPT2ContentFormatter`: GPT2의 요청 및 응답 데이터를 포맷합니다.
* `DollyContentFormatter`: Dolly-v2의 요청 및 응답 데이터를 포맷합니다.
* `HFContentFormatter`: 텍스트 생성 Hugging Face 모델의 요청 및 응답 데이터를 포맷합니다.
* `CustomOpenAIContentFormatter`: OpenAI API 호환 스키마를 따르는 LLaMa2와 같은 모델의 요청 및 응답 데이터를 포맷합니다.

*참고: `OSSContentFormatter`는 더 이상 사용되지 않으며 `GPT2ContentFormatter`로 대체됩니다. 로직은 동일하지만 `GPT2ContentFormatter`가 더 적합한 이름입니다. 변경 사항이 이전 버전과 호환되므로 여전히 `OSSContentFormatter`를 사용할 수 있습니다.*

## 예제

### 예제: 실시간 엔드포인트를 통한 LlaMa 2 완성

```python
<!--IMPORTS:[{"imported": "AzureMLEndpointApiType", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.AzureMLEndpointApiType.html", "title": "Azure ML"}, {"imported": "CustomOpenAIContentFormatter", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.CustomOpenAIContentFormatter.html", "title": "Azure ML"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Azure ML"}]-->
from langchain_community.llms.azureml_endpoint import (
    AzureMLEndpointApiType,
    CustomOpenAIContentFormatter,
)
from langchain_core.messages import HumanMessage

llm = AzureMLOnlineEndpoint(
    endpoint_url="https://<your-endpoint>.<your_region>.inference.ml.azure.com/score",
    endpoint_api_type=AzureMLEndpointApiType.dedicated,
    endpoint_api_key="my-api-key",
    content_formatter=CustomOpenAIContentFormatter(),
    model_kwargs={"temperature": 0.8, "max_new_tokens": 400},
)
response = llm.invoke("Write me a song about sparkling water:")
response
```


모델 매개변수는 호출 중에 지정할 수도 있습니다:

```python
response = llm.invoke("Write me a song about sparkling water:", temperature=0.5)
response
```


### 예제: 사용한 만큼 지불하는 배포(모델 서비스)로 채팅 완성

```python
<!--IMPORTS:[{"imported": "AzureMLEndpointApiType", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.AzureMLEndpointApiType.html", "title": "Azure ML"}, {"imported": "CustomOpenAIContentFormatter", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.CustomOpenAIContentFormatter.html", "title": "Azure ML"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Azure ML"}]-->
from langchain_community.llms.azureml_endpoint import (
    AzureMLEndpointApiType,
    CustomOpenAIContentFormatter,
)
from langchain_core.messages import HumanMessage

llm = AzureMLOnlineEndpoint(
    endpoint_url="https://<your-endpoint>.<your_region>.inference.ml.azure.com/v1/completions",
    endpoint_api_type=AzureMLEndpointApiType.serverless,
    endpoint_api_key="my-api-key",
    content_formatter=CustomOpenAIContentFormatter(),
    model_kwargs={"temperature": 0.8, "max_new_tokens": 400},
)
response = llm.invoke("Write me a song about sparkling water:")
response
```


### 예제: 사용자 정의 콘텐츠 포맷터

아래는 Hugging Face의 요약 모델을 사용하는 예제입니다.

```python
<!--IMPORTS:[{"imported": "AzureMLOnlineEndpoint", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.AzureMLOnlineEndpoint.html", "title": "Azure ML"}, {"imported": "ContentFormatterBase", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.ContentFormatterBase.html", "title": "Azure ML"}]-->
import json
import os
from typing import Dict

from langchain_community.llms.azureml_endpoint import (
    AzureMLOnlineEndpoint,
    ContentFormatterBase,
)


class CustomFormatter(ContentFormatterBase):
    content_type = "application/json"
    accepts = "application/json"

    def format_request_payload(self, prompt: str, model_kwargs: Dict) -> bytes:
        input_str = json.dumps(
            {
                "inputs": [prompt],
                "parameters": model_kwargs,
                "options": {"use_cache": False, "wait_for_model": True},
            }
        )
        return str.encode(input_str)

    def format_response_payload(self, output: bytes) -> str:
        response_json = json.loads(output)
        return response_json[0]["summary_text"]


content_formatter = CustomFormatter()

llm = AzureMLOnlineEndpoint(
    endpoint_api_type="dedicated",
    endpoint_api_key=os.getenv("BART_ENDPOINT_API_KEY"),
    endpoint_url=os.getenv("BART_ENDPOINT_URL"),
    model_kwargs={"temperature": 0.8, "max_new_tokens": 400},
    content_formatter=content_formatter,
)
large_text = """On January 7, 2020, Blockberry Creative announced that HaSeul would not participate in the promotion for Loona's 
next album because of mental health concerns. She was said to be diagnosed with "intermittent anxiety symptoms" and would be 
taking time to focus on her health.[39] On February 5, 2020, Loona released their second EP titled [#] (read as hash), along 
with the title track "So What".[40] Although HaSeul did not appear in the title track, her vocals are featured on three other 
songs on the album, including "365". Once peaked at number 1 on the daily Gaon Retail Album Chart,[41] the EP then debuted at 
number 2 on the weekly Gaon Album Chart. On March 12, 2020, Loona won their first music show trophy with "So What" on Mnet's 
M Countdown.[42]

On October 19, 2020, Loona released their third EP titled [12:00] (read as midnight),[43] accompanied by its first single 
"Why Not?". HaSeul was again not involved in the album, out of her own decision to focus on the recovery of her health.[44] 
The EP then became their first album to enter the Billboard 200, debuting at number 112.[45] On November 18, Loona released 
the music video for "Star", another song on [12:00].[46] Peaking at number 40, "Star" is Loona's first entry on the Billboard 
Mainstream Top 40, making them the second K-pop girl group to enter the chart.[47]

On June 1, 2021, Loona announced that they would be having a comeback on June 28, with their fourth EP, [&] (read as and).
[48] The following day, on June 2, a teaser was posted to Loona's official social media accounts showing twelve sets of eyes, 
confirming the return of member HaSeul who had been on hiatus since early 2020.[49] On June 12, group members YeoJin, Kim Lip, 
Choerry, and Go Won released the song "Yum-Yum" as a collaboration with Cocomong.[50] On September 8, they released another 
collaboration song named "Yummy-Yummy".[51] On June 27, 2021, Loona announced at the end of their special clip that they are 
making their Japanese debut on September 15 under Universal Music Japan sublabel EMI Records.[52] On August 27, it was announced 
that Loona will release the double A-side single, "Hula Hoop / Star Seed" on September 15, with a physical CD release on October 
20.[53] In December, Chuu filed an injunction to suspend her exclusive contract with Blockberry Creative.[54][55]
"""
summarized_text = llm.invoke(large_text)
print(summarized_text)
```


### 예제: LLMChain을 사용한 Dolly

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Azure ML"}, {"imported": "DollyContentFormatter", "source": "langchain_community.llms.azureml_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.azureml_endpoint.DollyContentFormatter.html", "title": "Azure ML"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Azure ML"}]-->
from langchain.chains import LLMChain
from langchain_community.llms.azureml_endpoint import DollyContentFormatter
from langchain_core.prompts import PromptTemplate

formatter_template = "Write a {word_count} word essay about {topic}."

prompt = PromptTemplate(
    input_variables=["word_count", "topic"], template=formatter_template
)

content_formatter = DollyContentFormatter()

llm = AzureMLOnlineEndpoint(
    endpoint_api_key=os.getenv("DOLLY_ENDPOINT_API_KEY"),
    endpoint_url=os.getenv("DOLLY_ENDPOINT_URL"),
    model_kwargs={"temperature": 0.8, "max_tokens": 300},
    content_formatter=content_formatter,
)

chain = LLMChain(llm=llm, prompt=prompt)
print(chain.invoke({"word_count": 100, "topic": "how to make friends"}))
```


## LLM 직렬화
LLM 구성을 저장하고 로드할 수도 있습니다.

```python
<!--IMPORTS:[{"imported": "load_llm", "source": "langchain_community.llms.loading", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.loading.load_llm.html", "title": "Azure ML"}]-->
from langchain_community.llms.loading import load_llm

save_llm = AzureMLOnlineEndpoint(
    deployment_name="databricks-dolly-v2-12b-4",
    model_kwargs={
        "temperature": 0.2,
        "max_tokens": 150,
        "top_p": 0.8,
        "frequency_penalty": 0.32,
        "presence_penalty": 72e-3,
    },
)
save_llm.save("azureml.json")
loaded_llm = load_llm("azureml.json")

print(loaded_llm)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)