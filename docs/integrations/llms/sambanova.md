---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/sambanova.ipynb
description: SambaNova의 Sambaverse와 Sambastudio를 사용하여 오픈 소스 모델과 상호작용하는 방법을 소개합니다.
  LangChain과 함께 활용해보세요.
---

# SambaNova

**[SambaNova](https://sambanova.ai/)**의 **[Sambaverse](https://sambaverse.sambanova.ai/)**와 **[Sambastudio](https://sambanova.ai/technology/full-stack-ai-platform)**는 오픈 소스 모델을 실행하기 위한 플랫폼입니다.

이 예제는 LangChain을 사용하여 SambaNova 모델과 상호작용하는 방법을 설명합니다.

## Sambaverse

**Sambaverse**는 여러 오픈 소스 모델과 상호작용할 수 있게 해줍니다. 사용 가능한 모델 목록을 보고 [playground](https://sambaverse.sambanova.ai/playground)에서 상호작용할 수 있습니다.  
**Sambaverse의 무료 제공은 성능이 제한되어 있습니다.** 생산 토큰 당 초당 성능, 볼륨 처리량 및 SambaNova의 총 소유 비용(TCO)을 10배 낮출 준비가 된 회사는 [문의해 주시기 바랍니다](https://sambaverse.sambanova.ai/contact-us) 비제한 평가 인스턴스를 위해.

Sambaverse 모델에 접근하려면 API 키가 필요합니다. 키를 얻으려면 [sambaverse.sambanova.ai](https://sambaverse.sambanova.ai/)에서 계정을 생성하세요.

스트리밍 예측을 실행하려면 [sseclient-py](https://pypi.org/project/sseclient-py/) 패키지가 필요합니다.

```python
%pip install --quiet sseclient-py==1.8.0
```


API 키를 환경 변수로 등록하세요:

```python
import os

sambaverse_api_key = "<Your sambaverse API key>"

# Set the environment variables
os.environ["SAMBAVERSE_API_KEY"] = sambaverse_api_key
```


LangChain에서 직접 Sambaverse 모델을 호출하세요!

```python
<!--IMPORTS:[{"imported": "Sambaverse", "source": "langchain_community.llms.sambanova", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sambanova.Sambaverse.html", "title": "SambaNova"}]-->
from langchain_community.llms.sambanova import Sambaverse

llm = Sambaverse(
    sambaverse_model_name="Meta/llama-2-7b-chat-hf",
    streaming=False,
    model_kwargs={
        "do_sample": True,
        "max_tokens_to_generate": 1000,
        "temperature": 0.01,
        "select_expert": "llama-2-7b-chat-hf",
        "process_prompt": False,
        # "stop_sequences": '\"sequence1\",\"sequence2\"',
        # "repetition_penalty":  1.0,
        # "top_k": 50,
        # "top_p": 1.0
    },
)

print(llm.invoke("Why should I use open source models?"))
```


```python
<!--IMPORTS:[{"imported": "Sambaverse", "source": "langchain_community.llms.sambanova", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sambanova.Sambaverse.html", "title": "SambaNova"}]-->
# Streaming response

from langchain_community.llms.sambanova import Sambaverse

llm = Sambaverse(
    sambaverse_model_name="Meta/llama-2-7b-chat-hf",
    streaming=True,
    model_kwargs={
        "do_sample": True,
        "max_tokens_to_generate": 1000,
        "temperature": 0.01,
        "select_expert": "llama-2-7b-chat-hf",
        "process_prompt": False,
        # "stop_sequences": '\"sequence1\",\"sequence2\"',
        # "repetition_penalty":  1.0,
        # "top_k": 50,
        # "top_p": 1.0
    },
)

for chunk in llm.stream("Why should I use open source models?"):
    print(chunk, end="", flush=True)
```


## SambaStudio

**SambaStudio**는 모델을 훈련하고, 배치 추론 작업을 실행하며, 직접 조정한 오픈 소스 모델을 실행하기 위한 온라인 추론 엔드포인트를 배포할 수 있게 해줍니다.

모델을 배포하려면 SambaStudio 환경이 필요합니다. 더 많은 정보는 [sambanova.ai/products/enterprise-ai-platform-sambanova-suite](https://sambanova.ai/products/enterprise-ai-platform-sambanova-suite)에서 확인하세요.

스트리밍 예측을 실행하려면 [sseclient-py](https://pypi.org/project/sseclient-py/) 패키지가 필요합니다.

```python
%pip install --quiet sseclient-py==1.8.0
```


환경 변수를 등록하세요:

```python
import os

sambastudio_base_url = "<Your SambaStudio environment URL>"
sambastudio_base_uri = "<Your SambaStudio endpoint base URI>"  # optional, "api/predict/generic" set as default
sambastudio_project_id = "<Your SambaStudio project id>"
sambastudio_endpoint_id = "<Your SambaStudio endpoint id>"
sambastudio_api_key = "<Your SambaStudio endpoint API key>"

# Set the environment variables
os.environ["SAMBASTUDIO_BASE_URL"] = sambastudio_base_url
os.environ["SAMBASTUDIO_BASE_URI"] = sambastudio_base_uri
os.environ["SAMBASTUDIO_PROJECT_ID"] = sambastudio_project_id
os.environ["SAMBASTUDIO_ENDPOINT_ID"] = sambastudio_endpoint_id
os.environ["SAMBASTUDIO_API_KEY"] = sambastudio_api_key
```


LangChain에서 직접 SambaStudio 모델을 호출하세요!

```python
<!--IMPORTS:[{"imported": "SambaStudio", "source": "langchain_community.llms.sambanova", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sambanova.SambaStudio.html", "title": "SambaNova"}]-->
from langchain_community.llms.sambanova import SambaStudio

llm = SambaStudio(
    streaming=False,
    model_kwargs={
        "do_sample": True,
        "max_tokens_to_generate": 1000,
        "temperature": 0.01,
        # "repetition_penalty":  1.0,
        # "top_k": 50,
        # "top_logprobs": 0,
        # "top_p": 1.0
    },
)

print(llm.invoke("Why should I use open source models?"))
```


```python
<!--IMPORTS:[{"imported": "SambaStudio", "source": "langchain_community.llms.sambanova", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sambanova.SambaStudio.html", "title": "SambaNova"}]-->
# Streaming response

from langchain_community.llms.sambanova import SambaStudio

llm = SambaStudio(
    streaming=True,
    model_kwargs={
        "do_sample": True,
        "max_tokens_to_generate": 1000,
        "temperature": 0.01,
        # "repetition_penalty":  1.0,
        # "top_k": 50,
        # "top_logprobs": 0,
        # "top_p": 1.0
    },
)

for chunk in llm.stream("Why should I use open source models?"):
    print(chunk, end="", flush=True)
```


CoE 엔드포인트 전문가 모델도 호출할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "SambaStudio", "source": "langchain_community.llms.sambanova", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sambanova.SambaStudio.html", "title": "SambaNova"}]-->
# Using a CoE endpoint

from langchain_community.llms.sambanova import SambaStudio

llm = SambaStudio(
    streaming=False,
    model_kwargs={
        "do_sample": True,
        "max_tokens_to_generate": 1000,
        "temperature": 0.01,
        "process_prompt": False,
        "select_expert": "Meta-Llama-3-8B-Instruct",
        # "repetition_penalty":  1.0,
        # "top_k": 50,
        # "top_logprobs": 0,
        # "top_p": 1.0
    },
)

print(llm.invoke("Why should I use open source models?"))
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)