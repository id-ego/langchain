---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/sagemaker.ipynb
description: 이 문서는 Amazon SageMaker에서 호스팅된 LLM을 사용하는 방법과 SageMakerEndpoint 호출에 필요한
  설정을 설명합니다.
---

# SageMakerEndpoint

[Amazon SageMaker](https://aws.amazon.com/sagemaker/)는 완전 관리형 인프라, 도구 및 워크플로를 통해 모든 사용 사례에 대한 기계 학습(ML) 모델을 구축, 훈련 및 배포할 수 있는 시스템입니다.

이 노트북에서는 `SageMaker endpoint`에 호스팅된 LLM을 사용하는 방법에 대해 설명합니다.

```python
!pip3 install langchain boto3
```


## 설정

`SagemakerEndpoint` 호출의 다음 필수 매개변수를 설정해야 합니다:
- `endpoint_name`: 배포된 Sagemaker 모델의 엔드포인트 이름.
AWS 리전 내에서 고유해야 합니다.
- `credentials_profile_name`: ~/.aws/credentials 또는 ~/.aws/config 파일에 있는 프로필의 이름으로,
액세스 키 또는 역할 정보가 지정되어 있습니다.
지정하지 않으면 기본 자격 증명 프로필이 사용되거나, EC2 인스턴스인 경우 IMDS에서 자격 증명이 사용됩니다.
참조: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html

## 예시

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "SageMakerEndpoint"}]-->
from langchain_core.documents import Document
```


```python
example_doc_1 = """
Peter and Elizabeth took a taxi to attend the night party in the city. While in the party, Elizabeth collapsed and was rushed to the hospital.
Since she was diagnosed with a brain injury, the doctor told Peter to stay besides her until she gets well.
Therefore, Peter stayed with her at the hospital for 3 days without leaving.
"""

docs = [
    Document(
        page_content=example_doc_1,
    )
]
```


## 외부 boto3 세션으로 초기화하는 예시

### 크로스 계정 시나리오를 위한

```python
<!--IMPORTS:[{"imported": "load_qa_chain", "source": "langchain.chains.question_answering", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.question_answering.chain.load_qa_chain.html", "title": "SageMakerEndpoint"}, {"imported": "SagemakerEndpoint", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sagemaker_endpoint.SagemakerEndpoint.html", "title": "SageMakerEndpoint"}, {"imported": "LLMContentHandler", "source": "langchain_community.llms.sagemaker_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sagemaker_endpoint.LLMContentHandler.html", "title": "SageMakerEndpoint"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "SageMakerEndpoint"}]-->
import json
from typing import Dict

import boto3
from langchain.chains.question_answering import load_qa_chain
from langchain_community.llms import SagemakerEndpoint
from langchain_community.llms.sagemaker_endpoint import LLMContentHandler
from langchain_core.prompts import PromptTemplate

query = """How long was Elizabeth hospitalized?
"""

prompt_template = """Use the following pieces of context to answer the question at the end.

{context}

Question: {question}
Answer:"""
PROMPT = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)

roleARN = "arn:aws:iam::123456789:role/cross-account-role"
sts_client = boto3.client("sts")
response = sts_client.assume_role(
    RoleArn=roleARN, RoleSessionName="CrossAccountSession"
)

client = boto3.client(
    "sagemaker-runtime",
    region_name="us-west-2",
    aws_access_key_id=response["Credentials"]["AccessKeyId"],
    aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
    aws_session_token=response["Credentials"]["SessionToken"],
)


class ContentHandler(LLMContentHandler):
    content_type = "application/json"
    accepts = "application/json"

    def transform_input(self, prompt: str, model_kwargs: Dict) -> bytes:
        input_str = json.dumps({"inputs": prompt, "parameters": model_kwargs})
        return input_str.encode("utf-8")

    def transform_output(self, output: bytes) -> str:
        response_json = json.loads(output.read().decode("utf-8"))
        return response_json[0]["generated_text"]


content_handler = ContentHandler()

chain = load_qa_chain(
    llm=SagemakerEndpoint(
        endpoint_name="endpoint-name",
        client=client,
        model_kwargs={"temperature": 1e-10},
        content_handler=content_handler,
    ),
    prompt=PROMPT,
)

chain({"input_documents": docs, "question": query}, return_only_outputs=True)
```


```python
<!--IMPORTS:[{"imported": "load_qa_chain", "source": "langchain.chains.question_answering", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.question_answering.chain.load_qa_chain.html", "title": "SageMakerEndpoint"}, {"imported": "SagemakerEndpoint", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sagemaker_endpoint.SagemakerEndpoint.html", "title": "SageMakerEndpoint"}, {"imported": "LLMContentHandler", "source": "langchain_community.llms.sagemaker_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sagemaker_endpoint.LLMContentHandler.html", "title": "SageMakerEndpoint"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "SageMakerEndpoint"}]-->
import json
from typing import Dict

from langchain.chains.question_answering import load_qa_chain
from langchain_community.llms import SagemakerEndpoint
from langchain_community.llms.sagemaker_endpoint import LLMContentHandler
from langchain_core.prompts import PromptTemplate

query = """How long was Elizabeth hospitalized?
"""

prompt_template = """Use the following pieces of context to answer the question at the end.

{context}

Question: {question}
Answer:"""
PROMPT = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)


class ContentHandler(LLMContentHandler):
    content_type = "application/json"
    accepts = "application/json"

    def transform_input(self, prompt: str, model_kwargs: Dict) -> bytes:
        input_str = json.dumps({"inputs": prompt, "parameters": model_kwargs})
        return input_str.encode("utf-8")

    def transform_output(self, output: bytes) -> str:
        response_json = json.loads(output.read().decode("utf-8"))
        return response_json[0]["generated_text"]


content_handler = ContentHandler()

chain = load_qa_chain(
    llm=SagemakerEndpoint(
        endpoint_name="endpoint-name",
        credentials_profile_name="credentials-profile-name",
        region_name="us-west-2",
        model_kwargs={"temperature": 1e-10},
        content_handler=content_handler,
    ),
    prompt=PROMPT,
)

chain({"input_documents": docs, "question": query}, return_only_outputs=True)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)