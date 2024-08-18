---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/openvino.ipynb
description: OpenVINO™는 AI 추론 최적화 및 배포를 위한 오픈 소스 툴킷으로, 다양한 하드웨어에서 모델을 실행할 수 있게 해줍니다.
---

# OpenVINO

[OpenVINO™](https://github.com/openvinotoolkit/openvino)는 AI 추론을 최적화하고 배포하기 위한 오픈 소스 툴킷입니다. OpenVINO™ Runtime은 다양한 하드웨어 [장치](https://github.com/openvinotoolkit/openvino?tab=readme-ov-file#supported-hardware-matrix)에서 최적화된 동일한 모델을 실행할 수 있게 합니다. 언어 + LLM, 컴퓨터 비전, 자동 음성 인식 등과 같은 사용 사례에서 딥 러닝 성능을 가속화하세요.

OpenVINO 모델은 `HuggingFacePipeline` [클래스](https://python.langchain.com/docs/integrations/llms/huggingface_pipeline)를 통해 로컬에서 실행할 수 있습니다. OpenVINO로 모델을 배포하려면 `backend="openvino"` 매개변수를 지정하여 OpenVINO를 백엔드 추론 프레임워크로 트리거할 수 있습니다.

사용하려면 `optimum-intel`과 OpenVINO Accelerator python [패키지 설치](https://github.com/huggingface/optimum-intel?tab=readme-ov-file#installation)가 필요합니다.

```python
%pip install --upgrade-strategy eager "optimum[openvino,nncf]" langchain-huggingface --quiet
```


### 모델 로딩

모델 매개변수를 사용하여 `from_model_id` 메서드를 지정함으로써 모델을 로드할 수 있습니다.

Intel GPU가 있는 경우 `model_kwargs={"device": "GPU"}`를 지정하여 해당 GPU에서 추론을 실행할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HuggingFacePipeline", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_pipeline.HuggingFacePipeline.html", "title": "OpenVINO"}]-->
from langchain_huggingface import HuggingFacePipeline

ov_config = {"PERFORMANCE_HINT": "LATENCY", "NUM_STREAMS": "1", "CACHE_DIR": ""}

ov_llm = HuggingFacePipeline.from_model_id(
    model_id="gpt2",
    task="text-generation",
    backend="openvino",
    model_kwargs={"device": "CPU", "ov_config": ov_config},
    pipeline_kwargs={"max_new_tokens": 10},
)
```


기존 [`optimum-intel`](https://huggingface.co/docs/optimum/main/en/intel/inference) 파이프라인을 직접 전달하여 로드할 수도 있습니다.

```python
from optimum.intel.openvino import OVModelForCausalLM
from transformers import AutoTokenizer, pipeline

model_id = "gpt2"
device = "CPU"
tokenizer = AutoTokenizer.from_pretrained(model_id)
ov_model = OVModelForCausalLM.from_pretrained(
    model_id, export=True, device=device, ov_config=ov_config
)
ov_pipe = pipeline(
    "text-generation", model=ov_model, tokenizer=tokenizer, max_new_tokens=10
)
ov_llm = HuggingFacePipeline(pipeline=ov_pipe)
```


### 체인 생성

메모리에 로드된 모델을 사용하여 프롬프트와 결합하여 체인을 형성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OpenVINO"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | ov_llm

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


프롬프트 없이 응답을 얻으려면 LLM과 함께 `skip_prompt=True`를 바인딩할 수 있습니다.

```python
chain = prompt | ov_llm.bind(skip_prompt=True)

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


### 로컬 OpenVINO 모델로 추론하기

CLI를 사용하여 모델을 OpenVINO IR 형식으로 [내보내기](https://github.com/huggingface/optimum-intel?tab=readme-ov-file#export)하고 로컬 폴더에서 모델을 로드할 수 있습니다.

```python
!optimum-cli export openvino --model gpt2 ov_model_dir
```


추론 지연 시간과 모델 크기를 줄이기 위해 `--weight-format`을 사용하여 8비트 또는 4비트 가중치 양자화를 적용하는 것이 좋습니다:

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

chain = prompt | ov_llm

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


활성화 및 KV-캐시 양자화의 동적 양자화를 통해 추가적인 추론 속도 개선을 얻을 수 있습니다. 이러한 옵션은 다음과 같이 `ov_config`로 활성화할 수 있습니다:

```python
ov_config = {
    "KV_CACHE_PRECISION": "u8",
    "DYNAMIC_QUANTIZATION_GROUP_SIZE": "32",
    "PERFORMANCE_HINT": "LATENCY",
    "NUM_STREAMS": "1",
    "CACHE_DIR": "",
}
```


### 스트리밍

LLM 출력의 스트리밍을 얻으려면 `stream` 메서드를 사용할 수 있습니다.

```python
generation_config = {"skip_prompt": True, "pipeline_kwargs": {"max_new_tokens": 100}}
chain = prompt | ov_llm.bind(**generation_config)

for chunk in chain.stream(question):
    print(chunk, end="", flush=True)
```


자세한 정보는 다음을 참조하세요:

* [OpenVINO LLM 가이드](https://docs.openvino.ai/2024/learn-openvino/llm_inference_guide.html).
* [OpenVINO 문서](https://docs.openvino.ai/2024/home.html).
* [OpenVINO 시작 가이드](https://www.intel.com/content/www/us/en/content-details/819067/openvino-get-started-guide.html).
* [LangChain과 함께하는 RAG 노트북](https://github.com/openvinotoolkit/openvino_notebooks/tree/latest/notebooks/llm-rag-langchain).

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)