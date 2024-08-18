---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/huggingface.ipynb
description: '`langchain_huggingface`의 채팅 모델을 시작하는 데 도움이 되는 문서입니다. 다양한 기능과 구성에 대한
  자세한 내용을 확인하세요.'
---

# ChatHuggingFace

이 문서는 `langchain_huggingface` [채팅 모델](/docs/concepts/#chat-models) 사용을 시작하는 데 도움이 됩니다. 모든 `ChatHuggingFace` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html)에서 확인할 수 있습니다. Hugging Face에서 지원하는 모델 목록은 [이 페이지](https://huggingface.co/models)에서 확인하세요.

## 개요
### 통합 세부정보

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatHuggingFace](https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html) | [langchain-huggingface](https://api.python.langchain.com/en/latest/huggingface_api_reference.html) | ✅ | beta | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_huggingface?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_huggingface?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | 

## 설정

Hugging Face 모델에 접근하려면 Hugging Face 계정을 생성하고, API 키를 얻고, `langchain-huggingface` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Hugging Face 액세스 토큰](https://huggingface.co/docs/hub/security-tokens)을 생성하고 이를 환경 변수로 저장하세요: `HUGGINGFACEHUB_API_TOKEN`.

```python
import getpass
import os

if not os.getenv("HUGGINGFACEHUB_API_TOKEN"):
    os.environ["HUGGINGFACEHUB_API_TOKEN"] = getpass.getpass("Enter your token: ")
```


### 설치

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatHuggingFace](https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html) | [langchain_huggingface](https://api.python.langchain.com/en/latest/huggingface_api_reference.html) | ✅ | ❌ | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_huggingface?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_huggingface?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그 확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | 

## 설정

`langchain_huggingface` 모델에 접근하려면 `Hugging Face` 계정을 생성하고, API 키를 얻고, `langchain_huggingface` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Hugging Face 액세스 토큰](https://huggingface.co/docs/hub/security-tokens)을 환경 변수로 저장해야 합니다: `HUGGINGFACEHUB_API_TOKEN`.

```python
import getpass
import os

os.environ["HUGGINGFACEHUB_API_TOKEN"] = getpass.getpass(
    "Enter your Hugging Face API key: "
)
```


```python
%pip install --upgrade --quiet  langchain-huggingface text-generation transformers google-search-results numexpr langchainhub sentencepiece jinja2 bitsandbytes accelerate
```

```output

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m24.0[0m[39;49m -> [0m[32;49m24.1.2[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

`ChatHuggingFace` 모델을 두 가지 방법으로 인스턴스화할 수 있습니다. `HuggingFaceEndpoint` 또는 `HuggingFacePipeline`에서 인스턴스화할 수 있습니다.

### `HuggingFaceEndpoint`

```python
<!--IMPORTS:[{"imported": "ChatHuggingFace", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html", "title": "ChatHuggingFace"}, {"imported": "HuggingFaceEndpoint", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_endpoint.HuggingFaceEndpoint.html", "title": "ChatHuggingFace"}]-->
from langchain_huggingface import ChatHuggingFace, HuggingFaceEndpoint

llm = HuggingFaceEndpoint(
    repo_id="HuggingFaceH4/zephyr-7b-beta",
    task="text-generation",
    max_new_tokens=512,
    do_sample=False,
    repetition_penalty=1.03,
)

chat_model = ChatHuggingFace(llm=llm)
```

```output
The token has not been saved to the git credentials helper. Pass `add_to_git_credential=True` in this function directly or `--add-to-git-credential` if using via `huggingface-cli` if you want to set the git credential as well.
Token is valid (permission: fineGrained).
Your token has been saved to /Users/isaachershenson/.cache/huggingface/token
Login successful
```

### `HuggingFacePipeline`

```python
<!--IMPORTS:[{"imported": "ChatHuggingFace", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html", "title": "ChatHuggingFace"}, {"imported": "HuggingFacePipeline", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_pipeline.HuggingFacePipeline.html", "title": "ChatHuggingFace"}]-->
from langchain_huggingface import ChatHuggingFace, HuggingFacePipeline

llm = HuggingFacePipeline.from_model_id(
    model_id="HuggingFaceH4/zephyr-7b-beta",
    task="text-generation",
    pipeline_kwargs=dict(
        max_new_tokens=512,
        do_sample=False,
        repetition_penalty=1.03,
    ),
)

chat_model = ChatHuggingFace(llm=llm)
```


```output
config.json:   0%|          | 0.00/638 [00:00<?, ?B/s]
```


```output
model.safetensors.index.json:   0%|          | 0.00/23.9k [00:00<?, ?B/s]
```


```output
Downloading shards:   0%|          | 0/8 [00:00<?, ?it/s]
```


```output
model-00001-of-00008.safetensors:   0%|          | 0.00/1.89G [00:00<?, ?B/s]
```


```output
model-00002-of-00008.safetensors:   0%|          | 0.00/1.95G [00:00<?, ?B/s]
```


```output
model-00003-of-00008.safetensors:   0%|          | 0.00/1.98G [00:00<?, ?B/s]
```


```output
model-00004-of-00008.safetensors:   0%|          | 0.00/1.95G [00:00<?, ?B/s]
```


```output
model-00005-of-00008.safetensors:   0%|          | 0.00/1.98G [00:00<?, ?B/s]
```


```output
model-00006-of-00008.safetensors:   0%|          | 0.00/1.95G [00:00<?, ?B/s]
```


```output
model-00007-of-00008.safetensors:   0%|          | 0.00/1.98G [00:00<?, ?B/s]
```


```output
model-00008-of-00008.safetensors:   0%|          | 0.00/816M [00:00<?, ?B/s]
```


```output
Loading checkpoint shards:   0%|          | 0/8 [00:00<?, ?it/s]
```


```output
generation_config.json:   0%|          | 0.00/111 [00:00<?, ?B/s]
```


### 양자화로 인스턴스화

모델의 양자화된 버전을 실행하려면 다음과 같이 `bitsandbytes` 양자화 구성을 지정할 수 있습니다:

```python
from transformers import BitsAndBytesConfig

quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype="float16",
    bnb_4bit_use_double_quant=True,
)
```


그리고 이를 `HuggingFacePipeline`의 `model_kwargs`의 일부로 전달합니다:

```python
llm = HuggingFacePipeline.from_model_id(
    model_id="HuggingFaceH4/zephyr-7b-beta",
    task="text-generation",
    pipeline_kwargs=dict(
        max_new_tokens=512,
        do_sample=False,
        repetition_penalty=1.03,
    ),
    model_kwargs={"quantization_config": quantization_config},
)

chat_model = ChatHuggingFace(llm=llm)
```


## 호출

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatHuggingFace"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatHuggingFace"}]-->
from langchain_core.messages import (
    HumanMessage,
    SystemMessage,
)

messages = [
    SystemMessage(content="You're a helpful assistant"),
    HumanMessage(
        content="What happens when an unstoppable force meets an immovable object?"
    ),
]

ai_msg = chat_model.invoke(messages)
```


```python
print(ai_msg.content)
```

```output
According to the popular phrase and hypothetical scenario, when an unstoppable force meets an immovable object, a paradoxical situation arises as both forces are seemingly contradictory. On one hand, an unstoppable force is an entity that cannot be stopped or prevented from moving forward, while on the other hand, an immovable object is something that cannot be moved or displaced from its position. 

In this scenario, it is un
```

## API 참조

모든 `ChatHuggingFace` 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html

## API 참조

모든 ChatHuggingFace 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/chat_models/langchain_huggingface.chat_models.huggingface.ChatHuggingFace.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)