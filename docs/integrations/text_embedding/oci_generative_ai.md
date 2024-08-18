---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/oci_generative_ai.ipynb
description: Oracle Cloud Infrastructure의 Generative AI 서비스와 LangChain을 활용하는 방법을 설명하는
  문서입니다.
---

# 오라클 클라우드 인프라스트럭처 생성 AI

오라클 클라우드 인프라스트럭처(OCI) 생성 AI는 최신의 사용자 정의 가능한 대형 언어 모델(LLM) 세트를 제공하는 완전 관리형 서비스로, 다양한 사용 사례를 포괄하며 단일 API를 통해 제공됩니다. OCI 생성 AI 서비스를 사용하면 즉시 사용할 수 있는 사전 훈련된 모델에 접근하거나, 전용 AI 클러스터에서 자신의 데이터에 기반한 맞춤형 모델을 생성하고 호스팅할 수 있습니다. 서비스 및 API에 대한 자세한 문서는 **[여기](https://docs.oracle.com/en-us/iaas/Content/generative-ai/home.htm)** 및 **[여기](https://docs.oracle.com/en-us/iaas/api/#/en/generative-ai/20231130/)**에서 확인할 수 있습니다.

이 노트북은 OCI의 생성 AI 모델을 LangChain과 함께 사용하는 방법을 설명합니다.

### 전제 조건
oci sdk를 설치해야 합니다.

```python
!pip install -U oci
```


### OCI 생성 AI API 엔드포인트
https://inference.generativeai.us-chicago-1.oci.oraclecloud.com

## 인증
이 langchain 통합에서 지원되는 인증 방법은 다음과 같습니다:

1. API 키
2. 세션 토큰
3. 인스턴스 주체
4. 리소스 주체 

이들은 **[여기](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdk_authentication_methods.htm)**에 자세히 설명된 표준 SDK 인증 방법을 따릅니다.

## 사용법

```python
<!--IMPORTS:[{"imported": "OCIGenAIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.oci_generative_ai.OCIGenAIEmbeddings.html", "title": "Oracle Cloud Infrastructure Generative AI"}]-->
from langchain_community.embeddings import OCIGenAIEmbeddings

# use default authN method API-key
embeddings = OCIGenAIEmbeddings(
    model_id="MY_EMBEDDING_MODEL",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
)


query = "This is a query in English."
response = embeddings.embed_query(query)
print(response)

documents = ["This is a sample document", "and here is another one"]
response = embeddings.embed_documents(documents)
print(response)
```


```python
# Use Session Token to authN
embeddings = OCIGenAIEmbeddings(
    model_id="MY_EMBEDDING_MODEL",
    service_endpoint="https://inference.generativeai.us-chicago-1.oci.oraclecloud.com",
    compartment_id="MY_OCID",
    auth_type="SECURITY_TOKEN",
    auth_profile="MY_PROFILE",  # replace with your profile name
)


query = "This is a sample query"
response = embeddings.embed_query(query)
print(response)

documents = ["This is a sample document", "and here is another one"]
response = embeddings.embed_documents(documents)
print(response)
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)