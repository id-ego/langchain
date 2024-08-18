---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ibm_watsonx.ipynb
description: IBM watsonx.ai 모델과 LangChain을 사용하여 WatsonxEmbeddings와 통신하는 방법을 설명하는 문서입니다.
---

# IBM watsonx.ai

> WatsonxEmbeddings는 IBM [watsonx.ai](https://www.ibm.com/products/watsonx-ai) 기초 모델을 위한 래퍼입니다.

이 예제는 `LangChain`을 사용하여 `watsonx.ai` 모델과 통신하는 방법을 보여줍니다.

## 설정

패키지 `langchain-ibm`을 설치합니다.

```python
!pip install -qU langchain-ibm
```


이 셀은 watsonx Embeddings 작업에 필요한 WML 자격 증명을 정의합니다.

**작업:** IBM Cloud 사용자 API 키를 제공합니다. 자세한 내용은 [문서](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui)를 참조하십시오.

```python
import os
from getpass import getpass

watsonx_api_key = getpass()
os.environ["WATSONX_APIKEY"] = watsonx_api_key
```


추가적으로 환경 변수로 추가 비밀을 전달할 수 있습니다.

```python
import os

os.environ["WATSONX_URL"] = "your service instance url"
os.environ["WATSONX_TOKEN"] = "your token for accessing the CPD cluster"
os.environ["WATSONX_PASSWORD"] = "your password for accessing the CPD cluster"
os.environ["WATSONX_USERNAME"] = "your username for accessing the CPD cluster"
os.environ["WATSONX_INSTANCE_ID"] = "your instance_id for accessing the CPD cluster"
```


## 모델 로드

다양한 모델에 대해 모델 `parameters`를 조정해야 할 수 있습니다.

```python
from ibm_watsonx_ai.metanames import EmbedTextParamsMetaNames

embed_params = {
    EmbedTextParamsMetaNames.TRUNCATE_INPUT_TOKENS: 3,
    EmbedTextParamsMetaNames.RETURN_OPTIONS: {"input_text": True},
}
```


이전 설정된 매개변수로 `WatsonxEmbeddings` 클래스를 초기화합니다.

**참고**:

- API 호출에 대한 컨텍스트를 제공하려면 `project_id` 또는 `space_id`를 추가해야 합니다. 자세한 내용은 [문서](https://www.ibm.com/docs/en/watsonx-as-a-service?topic=projects)를 참조하십시오.
- 프로비저닝된 서비스 인스턴스의 지역에 따라 [여기](https://ibm.github.io/watsonx-ai-python-sdk/setup_cloud.html#authentication)에 설명된 URL 중 하나를 사용하십시오.

이 예제에서는 `project_id`와 Dallas URL을 사용합니다.

추론에 사용할 `model_id`를 지정해야 합니다.

```python
from langchain_ibm import WatsonxEmbeddings

watsonx_embedding = WatsonxEmbeddings(
    model_id="ibm/slate-125m-english-rtrvr",
    url="https://us-south.ml.cloud.ibm.com",
    project_id="PASTE YOUR PROJECT_ID HERE",
    params=embed_params,
)
```


대안으로 Cloud Pak for Data 자격 증명을 사용할 수 있습니다. 자세한 내용은 [문서](https://ibm.github.io/watsonx-ai-python-sdk/setup_cpd.html)를 참조하십시오.

```python
watsonx_embedding = WatsonxEmbeddings(
    model_id="ibm/slate-125m-english-rtrvr",
    url="PASTE YOUR URL HERE",
    username="PASTE YOUR USERNAME HERE",
    password="PASTE YOUR PASSWORD HERE",
    instance_id="openshift",
    version="4.8",
    project_id="PASTE YOUR PROJECT_ID HERE",
    params=embed_params,
)
```


특정 요구 사항에 따라 IBM의 [`APIClient`](https://ibm.github.io/watsonx-ai-python-sdk/base.html#apiclient) 객체를 `WatsonxEmbeddings` 클래스에 전달할 수 있는 옵션이 있습니다.

```python
from ibm_watsonx_ai import APIClient

api_client = APIClient(...)

watsonx_llm = WatsonxEmbeddings(
    model_id="ibm/slate-125m-english-rtrvr",
    watsonx_client=api_client,
)
```


## 사용법

### 쿼리 포함

```python
text = "This is a test document."

query_result = watsonx_embedding.embed_query(text)
query_result[:5]
```


```output
[0.0094472, -0.024981909, -0.026013248, -0.040483925, -0.057804465]
```


### 문서 포함

```python
texts = ["This is a content of the document", "This is another document"]

doc_result = watsonx_embedding.embed_documents(texts)
doc_result[0][:5]
```


```output
[0.009447193, -0.024981918, -0.026013244, -0.040483937, -0.057804447]
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)