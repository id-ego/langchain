---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/huggingface_pipelines.ipynb
description: Hugging Face 모델을 로컬에서 실행할 수 있는 방법과 LangChain을 통한 사용법을 설명합니다. 다양한 모델과
  데이터셋을 활용하세요.
---

# 허깅 페이스 로컬 파이프라인

허깅 페이스 모델은 `HuggingFacePipeline` 클래스를 통해 로컬에서 실행할 수 있습니다.

[허깅 페이스 모델 허브](https://huggingface.co/models)에는 120,000개 이상의 모델, 20,000개 데이터셋, 50,000개 데모 앱(스페이스)이 호스팅되어 있으며, 모두 오픈 소스이고 공개적으로 사용 가능하여 사람들이 쉽게 협업하고 ML을 함께 구축할 수 있는 온라인 플랫폼입니다.

이들은 LangChain에서 이 로컬 파이프라인 래퍼를 통해 호출하거나 HuggingFaceHub 클래스를 통해 호스팅된 추론 엔드포인트를 호출하여 사용할 수 있습니다.

사용하려면 `transformers` 파이썬 [패키지를 설치해야](https://pypi.org/project/transformers/) 하며, [pytorch](https://pytorch.org/get-started/locally/)도 필요합니다. 더 메모리 효율적인 어텐션 구현을 위해 `xformer`를 설치할 수도 있습니다.

```python
%pip install --upgrade --quiet transformers
```


### 모델 로딩

모델은 `from_model_id` 메서드를 사용하여 모델 매개변수를 지정하여 로드할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HuggingFacePipeline", "source": "langchain_huggingface.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_pipeline.HuggingFacePipeline.html", "title": "Hugging Face Local Pipelines"}]-->
from langchain_huggingface.llms import HuggingFacePipeline

hf = HuggingFacePipeline.from_model_id(
    model_id="gpt2",
    task="text-generation",
    pipeline_kwargs={"max_new_tokens": 10},
)
```


기존의 `transformers` 파이프라인을 직접 전달하여 로드할 수도 있습니다.

```python
<!--IMPORTS:[{"imported": "HuggingFacePipeline", "source": "langchain_huggingface.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_pipeline.HuggingFacePipeline.html", "title": "Hugging Face Local Pipelines"}]-->
from langchain_huggingface.llms import HuggingFacePipeline
from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline

model_id = "gpt2"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(model_id)
pipe = pipeline("text-generation", model=model, tokenizer=tokenizer, max_new_tokens=10)
hf = HuggingFacePipeline(pipeline=pipe)
```


### 체인 생성

메모리에 모델이 로드되면, 프롬프트와 함께 조합하여 체인을 형성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Hugging Face Local Pipelines"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | hf

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


프롬프트 없이 응답을 받으려면, LLM과 함께 `skip_prompt=True`를 바인딩할 수 있습니다.

```python
chain = prompt | hf.bind(skip_prompt=True)

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


스트리밍 응답.

```python
for chunk in chain.stream(question):
    print(chunk, end="", flush=True)
```


### GPU 추론

GPU가 있는 머신에서 실행할 때는 `device=n` 매개변수를 지정하여 모델을 지정된 장치에 배치할 수 있습니다. 기본값은 CPU 추론을 위한 `-1`입니다.

여러 개의 GPU가 있거나 모델이 단일 GPU에 비해 너무 큰 경우, `device_map="auto"`를 지정할 수 있으며, 이는 모델 가중치를 자동으로 로드하는 방법을 결정하기 위해 [Accelerate](https://huggingface.co/docs/accelerate/index) 라이브러리를 요구하고 사용합니다.

*참고*: `device`와 `device_map`은 함께 지정해서는 안 되며, 예기치 않은 동작을 초래할 수 있습니다.

```python
gpu_llm = HuggingFacePipeline.from_model_id(
    model_id="gpt2",
    task="text-generation",
    device=0,  # replace with device_map="auto" to use the accelerate library.
    pipeline_kwargs={"max_new_tokens": 10},
)

gpu_chain = prompt | gpu_llm

question = "What is electroencephalography?"

print(gpu_chain.invoke({"question": question}))
```


### 배치 GPU 추론

GPU가 있는 장치에서 실행할 경우, GPU에서 배치 모드로 추론을 실행할 수도 있습니다.

```python
gpu_llm = HuggingFacePipeline.from_model_id(
    model_id="bigscience/bloom-1b7",
    task="text-generation",
    device=0,  # -1 for CPU
    batch_size=2,  # adjust as needed based on GPU map and model size.
    model_kwargs={"temperature": 0, "max_length": 64},
)

gpu_chain = prompt | gpu_llm.bind(stop=["\n\n"])

questions = []
for i in range(4):
    questions.append({"question": f"What is the number {i} in french?"})

answers = gpu_chain.batch(questions)
for answer in answers:
    print(answer)
```


### OpenVINO 백엔드로 추론

OpenVINO로 모델을 배포하려면, `backend="openvino"` 매개변수를 지정하여 OpenVINO를 백엔드 추론 프레임워크로 트리거할 수 있습니다.

Intel GPU가 있는 경우, `model_kwargs={"device": "GPU"}`를 지정하여 그 위에서 추론을 실행할 수 있습니다.

```python
%pip install --upgrade-strategy eager "optimum[openvino,nncf]" --quiet
```


```python
ov_config = {"PERFORMANCE_HINT": "LATENCY", "NUM_STREAMS": "1", "CACHE_DIR": ""}

ov_llm = HuggingFacePipeline.from_model_id(
    model_id="gpt2",
    task="text-generation",
    backend="openvino",
    model_kwargs={"device": "CPU", "ov_config": ov_config},
    pipeline_kwargs={"max_new_tokens": 10},
)

ov_chain = prompt | ov_llm

question = "What is electroencephalography?"

print(ov_chain.invoke({"question": question}))
```


### 로컬 OpenVINO 모델로 추론

CLI를 사용하여 모델을 [OpenVINO IR 형식으로 내보내는](https://github.com/huggingface/optimum-intel?tab=readme-ov-file#export) 것이 가능하며, 로컬 폴더에서 모델을 로드할 수 있습니다.

```python
!optimum-cli export openvino --model gpt2 ov_model_dir
```


추론 지연 시간과 모델 풋프린트를 줄이기 위해 `--weight-format`을 사용하여 8비트 또는 4비트 가중치 양자화를 적용하는 것이 권장됩니다.

```python
!optimum-cli export openvino --model gpt2  --weight-format int8 ov_model_dir # for 8-bit quantization

!optimum-cli export openvino --model gpt2  --weight-format int4 ov_model_dir # for 4-bit quantization
```


```python
ov_llm = HuggingFacePipeline.from_model_id(
    model_id="ov_model_dir",
    task="text-generation",
    backend="openvino",
    model_kwargs={"device": "CPU", "ov_config": ov_config},
    pipeline_kwargs={"max_new_tokens": 10},
)

ov_chain = prompt | ov_llm

question = "What is electroencephalography?"

print(ov_chain.invoke({"question": question}))
```


활성화 및 KV-캐시 양자화의 동적 양자화를 통해 추가적인 추론 속도 개선을 얻을 수 있습니다. 이러한 옵션은 다음과 같이 `ov_config`로 활성화할 수 있습니다.

```python
ov_config = {
    "KV_CACHE_PRECISION": "u8",
    "DYNAMIC_QUANTIZATION_GROUP_SIZE": "32",
    "PERFORMANCE_HINT": "LATENCY",
    "NUM_STREAMS": "1",
    "CACHE_DIR": "",
}
```


자세한 정보는 [OpenVINO LLM 가이드](https://docs.openvino.ai/2024/learn-openvino/llm_inference_guide.html) 및 [OpenVINO 로컬 파이프라인 노트북](/docs/integrations/llms/openvino/)을 참조하십시오.

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)