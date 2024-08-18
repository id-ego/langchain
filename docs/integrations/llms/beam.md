---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/beam.ipynb
description: Beam API를 사용하여 클라우드에서 gpt2 LLM 인스턴스를 배포하고 호출하는 방법을 안내합니다. API 키 등록 및
  설치 방법 포함.
---

# 빔

Beam API 래퍼를 호출하여 클라우드 배포에서 gpt2 LLM 인스턴스를 배포하고 이후 호출을 수행합니다. Beam 라이브러리 설치와 Beam 클라이언트 ID 및 클라이언트 비밀 등록이 필요합니다. 래퍼를 호출함으로써 모델의 인스턴스가 생성되고 실행되며, 프롬프트와 관련된 텍스트가 반환됩니다. 이후에는 Beam API를 직접 호출하여 추가 호출을 할 수 있습니다.

[계정을 생성하세요](https://www.beam.cloud/), 아직 계정이 없다면. [대시보드](https://www.beam.cloud/dashboard/settings/api-keys)에서 API 키를 가져오세요.

Beam CLI 설치

```python
!curl https://raw.githubusercontent.com/slai-labs/get-beam/main/get-beam.sh -sSfL | sh
```


API 키를 등록하고 beam 클라이언트 ID 및 비밀 환경 변수를 설정하세요:

```python
import os

beam_client_id = "<Your beam client id>"
beam_client_secret = "<Your beam client secret>"

# Set the environment variables
os.environ["BEAM_CLIENT_ID"] = beam_client_id
os.environ["BEAM_CLIENT_SECRET"] = beam_client_secret

# Run the beam configure command
!beam configure --clientId={beam_client_id} --clientSecret={beam_client_secret}
```


Beam SDK 설치:

```python
%pip install --upgrade --quiet  beam-sdk
```


**Langchain에서 Beam을 직접 배포하고 호출하세요!**

콜드 스타트는 응답을 반환하는 데 몇 분이 걸릴 수 있지만, 이후 호출은 더 빨라질 것입니다!

```python
<!--IMPORTS:[{"imported": "Beam", "source": "langchain_community.llms.beam", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.beam.Beam.html", "title": "Beam"}]-->
from langchain_community.llms.beam import Beam

llm = Beam(
    model_name="gpt2",
    name="langchain-gpt2-test",
    cpu=8,
    memory="32Gi",
    gpu="A10G",
    python_version="python3.8",
    python_packages=[
        "diffusers[torch]>=0.10",
        "transformers",
        "torch",
        "pillow",
        "accelerate",
        "safetensors",
        "xformers",
    ],
    max_length="50",
    verbose=False,
)

llm._deploy()

response = llm._call("Running machine learning on a remote GPU")

print(response)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)