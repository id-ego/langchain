---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/huggingface_endpoint.ipynb
description: Hugging Face Hub는 12만 개 모델, 2만 개 데이터셋, 5만 개 데모 앱을 제공하며, ML 애플리케이션을 구축하기
  위한 다양한 엔드포인트를 지원합니다.
---

# Huggingface Endpoints

> [Hugging Face Hub](https://huggingface.co/docs/hub/index)는 12만 개 이상의 모델, 2만 개의 데이터셋, 5만 개의 데모 앱(Spaces)을 포함한 플랫폼으로, 모두 오픈 소스이며 공개적으로 이용 가능하며, 사람들이 쉽게 협력하고 ML을 함께 구축할 수 있는 온라인 플랫폼입니다.

`Hugging Face Hub`는 ML 애플리케이션을 구축하기 위한 다양한 엔드포인트도 제공합니다. 이 예제는 다양한 엔드포인트 유형에 연결하는 방법을 보여줍니다.

특히, 텍스트 생성 추론은 [Text Generation Inference](https://github.com/huggingface/text-generation-inference)에 의해 지원됩니다: 빠른 텍스트 생성 추론을 위한 맞춤형 Rust, Python 및 gRPC 서버입니다.

```python
<!--IMPORTS:[{"imported": "HuggingFaceEndpoint", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_endpoint.HuggingFaceEndpoint.html", "title": "Huggingface Endpoints"}]-->
from langchain_huggingface import HuggingFaceEndpoint
```


## 설치 및 설정

사용하려면 `huggingface_hub` 파이썬 [패키지를 설치해야](https://huggingface.co/docs/huggingface_hub/installation) 합니다.

```python
%pip install --upgrade --quiet huggingface_hub
```


```python
# get a token: https://huggingface.co/docs/api-inference/quicktour#get-your-api-token

from getpass import getpass

HUGGINGFACEHUB_API_TOKEN = getpass()
```


```python
import os

os.environ["HUGGINGFACEHUB_API_TOKEN"] = HUGGINGFACEHUB_API_TOKEN
```


## 예제 준비

```python
<!--IMPORTS:[{"imported": "HuggingFaceEndpoint", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_endpoint.HuggingFaceEndpoint.html", "title": "Huggingface Endpoints"}]-->
from langchain_huggingface import HuggingFaceEndpoint
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Huggingface Endpoints"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Huggingface Endpoints"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate
```


```python
question = "Who won the FIFA World Cup in the year 1994? "

template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


## 예제

무료 [서버리스 엔드포인트](https://huggingface.co/inference-endpoints/serverless) API의 `HuggingFaceEndpoint` 통합에 접근하는 방법의 예는 다음과 같습니다.

```python
repo_id = "mistralai/Mistral-7B-Instruct-v0.2"

llm = HuggingFaceEndpoint(
    repo_id=repo_id,
    max_length=128,
    temperature=0.5,
    huggingfacehub_api_token=HUGGINGFACEHUB_API_TOKEN,
)
llm_chain = prompt | llm
print(llm_chain.invoke({"question": question}))
```


## 전용 엔드포인트

무료 서버리스 API는 솔루션을 구현하고 신속하게 반복할 수 있게 해주지만, 요청이 다른 요청과 공유되기 때문에 대량 사용 사례에 대해 속도 제한이 있을 수 있습니다.

기업 워크로드의 경우, [Inference Endpoints - Dedicated](https://huggingface.co/inference-endpoints/dedicated)를 사용하는 것이 가장 좋습니다. 이는 더 많은 유연성과 속도를 제공하는 완전 관리형 인프라에 접근할 수 있게 해줍니다. 이러한 리소스는 지속적인 지원과 가동 시간 보장을 제공하며, AutoScaling과 같은 옵션도 포함됩니다.

```python
# Set the url to your Inference Endpoint below
your_endpoint_url = "https://fayjubiy2xqn36z0.us-east-1.aws.endpoints.huggingface.cloud"
```


```python
llm = HuggingFaceEndpoint(
    endpoint_url=f"{your_endpoint_url}",
    max_new_tokens=512,
    top_k=10,
    top_p=0.95,
    typical_p=0.95,
    temperature=0.01,
    repetition_penalty=1.03,
)
llm("What did foo say about bar?")
```


### 스트리밍

```python
<!--IMPORTS:[{"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Huggingface Endpoints"}, {"imported": "HuggingFaceEndpoint", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_endpoint.HuggingFaceEndpoint.html", "title": "Huggingface Endpoints"}]-->
from langchain_core.callbacks import StreamingStdOutCallbackHandler
from langchain_huggingface import HuggingFaceEndpoint

llm = HuggingFaceEndpoint(
    endpoint_url=f"{your_endpoint_url}",
    max_new_tokens=512,
    top_k=10,
    top_p=0.95,
    typical_p=0.95,
    temperature=0.01,
    repetition_penalty=1.03,
    streaming=True,
)
llm("What did foo say about bar?", callbacks=[StreamingStdOutCallbackHandler()])
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)