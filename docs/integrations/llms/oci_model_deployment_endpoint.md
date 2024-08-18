---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/oci_model_deployment_endpoint.ipynb
description: OCI 데이터 과학 모델 배포 엔드포인트를 사용하여 LLM을 호스팅하고 인증하는 방법을 안내하는 문서입니다.
---

# OCI 데이터 과학 모델 배포 엔드포인트

[OCI 데이터 과학](https://docs.oracle.com/en-us/iaas/data-science/using/home.htm)은 데이터 과학 팀이 Oracle Cloud Infrastructure에서 기계 학습 모델을 구축, 훈련 및 관리할 수 있는 완전 관리형 서버리스 플랫폼입니다.

이 노트북은 [OCI 데이터 과학 모델 배포](https://docs.oracle.com/en-us/iaas/data-science/using/model-dep-about.htm)에서 호스팅되는 LLM을 사용하는 방법을 설명합니다.

인증을 위해 [oracle-ads](https://accelerated-data-science.readthedocs.io/en/latest/user_guide/cli/authentication.html)를 사용하여 엔드포인트를 호출하기 위한 자격 증명을 자동으로 로드합니다.

```python
!pip3 install oracle-ads
```


## 전제 조건

### 모델 배포
OCI 데이터 과학 모델 배포에서 LLM을 배포하는 방법은 [Oracle GitHub 샘플 리포지토리](https://github.com/oracle-samples/oci-data-science-ai-samples/tree/main/model-deployment/containers/llama2)를 확인하세요.

### 정책
OCI 데이터 과학 모델 배포 엔드포인트에 접근하기 위해 필요한 [정책](https://docs.oracle.com/en-us/iaas/data-science/using/model-dep-policies-auth.htm#model_dep_policies_auth__predict-endpoint)을 반드시 확인하세요.

## 설정

### vLLM
모델을 배포한 후, `OCIModelDeploymentVLLM` 호출의 다음 필수 매개변수를 설정해야 합니다:

- **`endpoint`**: 배포된 모델의 HTTP 엔드포인트, 예: `https://<MD_OCID>/predict`. 
- **`model`**: 모델의 위치.

### 텍스트 생성 추론 (TGI)
`OCIModelDeploymentTGI` 호출의 다음 필수 매개변수를 설정해야 합니다:

- **`endpoint`**: 배포된 모델의 HTTP 엔드포인트, 예: `https://<MD_OCID>/predict`. 

### 인증

ads 또는 환경 변수를 통해 인증을 설정할 수 있습니다. OCI 데이터 과학 노트북 세션에서 작업할 때는 리소스 주체를 활용하여 다른 OCI 리소스에 접근할 수 있습니다. 더 많은 옵션은 [여기](https://accelerated-data-science.readthedocs.io/en/latest/user_guide/cli/authentication.html)를 확인하세요.

## 예제

```python
<!--IMPORTS:[{"imported": "OCIModelDeploymentVLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.oci_data_science_model_deployment_endpoint.OCIModelDeploymentVLLM.html", "title": "OCI Data Science Model Deployment Endpoint"}]-->
import ads
from langchain_community.llms import OCIModelDeploymentVLLM

# Set authentication through ads
# Use resource principal are operating within a
# OCI service that has resource principal based
# authentication configured
ads.set_auth("resource_principal")

# Create an instance of OCI Model Deployment Endpoint
# Replace the endpoint uri and model name with your own
llm = OCIModelDeploymentVLLM(endpoint="https://<MD_OCID>/predict", model="model_name")

# Run the LLM
llm.invoke("Who is the first president of United States?")
```


```python
<!--IMPORTS:[{"imported": "OCIModelDeploymentTGI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.oci_data_science_model_deployment_endpoint.OCIModelDeploymentTGI.html", "title": "OCI Data Science Model Deployment Endpoint"}]-->
import os

from langchain_community.llms import OCIModelDeploymentTGI

# Set authentication through environment variables
# Use API Key setup when you are working from a local
# workstation or on platform which does not support
# resource principals.
os.environ["OCI_IAM_TYPE"] = "api_key"
os.environ["OCI_CONFIG_PROFILE"] = "default"
os.environ["OCI_CONFIG_LOCATION"] = "~/.oci"

# Set endpoint through environment variables
# Replace the endpoint uri with your own
os.environ["OCI_LLM_ENDPOINT"] = "https://<MD_OCID>/predict"

# Create an instance of OCI Model Deployment Endpoint
llm = OCIModelDeploymentTGI()

# Run the LLM
llm.invoke("Who is the first president of United States?")
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)