---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/oci_generative_ai.ipynb
description: Oracle Cloud Infrastructure의 Generative AI 서비스는 맞춤형 대형 언어 모델을 제공하며, LangChain과
  함께 사용할 수 있는 방법을 설명합니다.
---

## 오라클 클라우드 인프라스트럭처 생성 AI

오라클 클라우드 인프라스트럭처(OCI) 생성 AI는 다양한 사용 사례를 포괄하는 최첨단 맞춤형 대형 언어 모델(LLM) 세트를 제공하는 완전 관리형 서비스로, 단일 API를 통해 제공됩니다.  
OCI 생성 AI 서비스를 사용하면 즉시 사용할 수 있는 사전 훈련된 모델에 접근하거나, 전용 AI 클러스터에서 자신의 데이터에 기반하여 맞춤형 모델을 생성하고 호스팅할 수 있습니다. 서비스 및 API에 대한 자세한 문서는 **[여기](https://docs.oracle.com/en-us/iaas/Content/generative-ai/home.htm)** 및 **[여기](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai/20231130/)**에서 확인할 수 있습니다.

이 노트북은 OCI의 생성 AI 완전 모델을 LangChain과 함께 사용하는 방법을 설명합니다.

## 설정
oci sdk와 langchain-community 패키지가 설치되어 있는지 확인하십시오.

```python
!pip install -U oci langchain-community
```


## 사용법

```python
<!--IMPORTS:[{"imported": "OCIGenAI", "source": "langchain_community.llms.oci_generative_ai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.oci_generative_ai.OCIGenAI.html", "title": "# Oracle Cloud Infrastructure Generative AI"}]-->
from langchain_community.llms.oci_generative_ai import OCIGenAI

llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0, "max_tokens": 500},
)

response = llm.invoke("Tell me one fact about earth", temperature=0.7)
print(response)
```


#### 프롬프트 템플릿을 이용한 체이닝

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Oracle Cloud Infrastructure Generative AI"}]-->
from langchain_core.prompts import PromptTemplate

llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0, "max_tokens": 500},
)

prompt = PromptTemplate(input_variables=["query"], template="{query}")
llm_chain = prompt | llm

response = llm_chain.invoke("what is the capital of france?")
print(response)
```


#### 스트리밍

```python
llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    model_kwargs={"temperature": 0, "max_tokens": 500},
)

for chunk in llm.stream("Write me a song about sparkling water."):
    print(chunk, end="", flush=True)
```


## 인증
LlamaIndex에서 지원하는 인증 방법은 다른 OCI 서비스와 동일하며 **[표준 SDK 인증](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdk_authentication_methods.htm)** 방법을 따릅니다. 구체적으로 API 키, 세션 토큰, 인스턴스 주체 및 리소스 주체가 있습니다.

API 키는 위의 예제에서 사용되는 기본 인증 방법입니다. 다음 예제는 다른 인증 방법(세션 토큰)을 사용하는 방법을 보여줍니다.

```python
llm = OCIGenAI(
    model_id="cohere.command",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    auth_type="SECURITY_TOKEN",
    auth_profile="MY_PROFILE",  # replace with your profile name
)
```


## 전용 AI 클러스터
전용 AI 클러스터에 호스팅된 모델에 접근하려면 **[엔드포인트 생성](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai-inference/20231130/)**을 통해 할당된 OCID(현재 ‘ocid1.generativeaiendpoint.oc1.us-chicago-1’로 접두사가 붙음)를 모델 ID로 사용해야 합니다.

전용 AI 클러스터에 호스팅된 모델에 접근할 때는 OCIGenAI 인터페이스를 두 개의 추가 필수 매개변수("provider" 및 "context_size")로 초기화해야 합니다.

```python
llm = OCIGenAI(
    model_id="ocid1.generativeaiendpoint.oc1.us-chicago-1....",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="DEDICATED_COMPARTMENT_OCID",
    auth_profile="MY_PROFILE",  # replace with your profile name,
    provider="MODEL_PROVIDER",  # e.g., "cohere" or "meta"
    context_size="MODEL_CONTEXT_SIZE",  # e.g., 128000
)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)