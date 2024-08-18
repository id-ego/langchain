---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/weight_only_quantization.ipynb
description: 인텔 확장을 통해 Hugging Face 모델을 Weight-Only 양자화로 로컬에서 실행하는 방법을 설명합니다.
---

# 인텔 가중치 전용 양자화
## 인텔 확장을 통한 Huggingface 모델의 가중치 전용 양자화

Hugging Face 모델은 `WeightOnlyQuantPipeline` 클래스를 통해 로컬에서 가중치 전용 양자화를 실행할 수 있습니다.

[Hugging Face 모델 허브](https://huggingface.co/models)에는 12만 개 이상의 모델, 2만 개의 데이터셋, 5만 개의 데모 앱(스페이스)이 호스팅되어 있으며, 모두 오픈 소스이며 공개적으로 사용 가능합니다. 사람들이 쉽게 협업하고 ML을 함께 구축할 수 있는 온라인 플랫폼입니다.

이들은 LangChain을 통해 이 로컬 파이프라인 래퍼 클래스를 통해 호출할 수 있습니다.

사용하려면 `transformers` 파이썬 [패키지를 설치해야](https://pypi.org/project/transformers/) 하며, [pytorch](https://pytorch.org/get-started/locally/), [intel-extension-for-transformers](https://github.com/intel/intel-extension-for-transformers)도 설치해야 합니다.

```python
%pip install transformers --quiet
%pip install intel-extension-for-transformers
```


### 모델 로딩

모델은 `from_model_id` 메서드를 사용하여 모델 매개변수를 지정하여 로드할 수 있습니다. 모델 매개변수에는 intel_extension_for_transformers의 `WeightOnlyQuantConfig` 클래스가 포함됩니다.

```python
<!--IMPORTS:[{"imported": "WeightOnlyQuantPipeline", "source": "langchain_community.llms.weight_only_quantization", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.weight_only_quantization.WeightOnlyQuantPipeline.html", "title": "Intel Weight-Only Quantization"}]-->
from intel_extension_for_transformers.transformers import WeightOnlyQuantConfig
from langchain_community.llms.weight_only_quantization import WeightOnlyQuantPipeline

conf = WeightOnlyQuantConfig(weight_dtype="nf4")
hf = WeightOnlyQuantPipeline.from_model_id(
    model_id="google/flan-t5-large",
    task="text2text-generation",
    quantization_config=conf,
    pipeline_kwargs={"max_new_tokens": 10},
)
```


기존 `transformers` 파이프라인을 직접 전달하여 로드할 수도 있습니다.

```python
from intel_extension_for_transformers.transformers import AutoModelForSeq2SeqLM
from transformers import AutoTokenizer, pipeline

model_id = "google/flan-t5-large"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForSeq2SeqLM.from_pretrained(model_id)
pipe = pipeline(
    "text2text-generation", model=model, tokenizer=tokenizer, max_new_tokens=10
)
hf = WeightOnlyQuantPipeline(pipeline=pipe)
```


### 체인 생성

메모리에 모델이 로드되면 프롬프트와 함께 조합하여 체인을 형성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Intel Weight-Only Quantization"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | hf

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


### CPU 추론

현재 intel-extension-for-transformers는 CPU 장치 추론만 지원합니다. 곧 인텔 GPU를 지원할 예정입니다. CPU가 있는 머신에서 실행할 때는 `device="cpu"` 또는 `device=-1` 매개변수를 지정하여 모델을 CPU 장치에 배치할 수 있습니다. 기본값은 CPU 추론을 위해 `-1`입니다.

```python
conf = WeightOnlyQuantConfig(weight_dtype="nf4")
llm = WeightOnlyQuantPipeline.from_model_id(
    model_id="google/flan-t5-large",
    task="text2text-generation",
    quantization_config=conf,
    pipeline_kwargs={"max_new_tokens": 10},
)

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | llm

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


### 배치 CPU 추론

CPU에서 배치 모드로 추론을 실행할 수도 있습니다.

```python
conf = WeightOnlyQuantConfig(weight_dtype="nf4")
llm = WeightOnlyQuantPipeline.from_model_id(
    model_id="google/flan-t5-large",
    task="text2text-generation",
    quantization_config=conf,
    pipeline_kwargs={"max_new_tokens": 10},
)

chain = prompt | llm.bind(stop=["\n\n"])

questions = []
for i in range(4):
    questions.append({"question": f"What is the number {i} in french?"})

answers = chain.batch(questions)
for answer in answers:
    print(answer)
```


### 인텔 확장에서 지원하는 데이터 유형

다음 데이터 유형으로 가중치를 양자화하여 저장합니다(weight_dtype in WeightOnlyQuantConfig):

* **int8**: 8비트 데이터 유형을 사용합니다.
* **int4_fullrange**: 일반 int4 범위 [-7,7]와 비교하여 int4 범위의 -8 값을 사용합니다.
* **int4_clip**: int4 범위 내의 값을 클리핑하고 유지하며, 나머지는 0으로 설정합니다.
* **nf4**: 정규화된 4비트 부동 소수점 데이터 유형을 사용합니다.
* **fp4_e2m1**: 일반 4비트 부동 소수점 데이터 유형을 사용합니다. "e2"는 지수에 2비트를 사용하고, "m1"은 가수에 1비트를 사용함을 의미합니다.

이러한 기술은 4비트 또는 8비트로 가중치를 저장하지만, 계산은 여전히 float32, bfloat16 또는 int8(compute_dtype in WeightOnlyQuantConfig)에서 발생합니다:
* **fp32**: 계산을 위해 float32 데이터 유형을 사용합니다.
* **bf16**: 계산을 위해 bfloat16 데이터 유형을 사용합니다.
* **int8**: 계산을 위해 8비트 데이터 유형을 사용합니다.

### 지원되는 알고리즘 매트릭스

intel-extension-for-transformers에서 지원하는 양자화 알고리즘(algorithm in WeightOnlyQuantConfig):

| 알고리즘 |   PyTorch  |    LLM 런타임    |
|:--------------:|:----------:|:----------:|
|       RTN      |  &#10004;  |  &#10004;  |
|       AWQ      |  &#10004;  | 곧 발표 예정 |
|      TEQ      | &#10004; | 곧 발표 예정 |
> **RTN:** 매우 직관적으로 생각할 수 있는 양자화 방법입니다. 추가 데이터셋이 필요하지 않으며 매우 빠른 양자화 방법입니다. 일반적으로 RTN은 가중치를 균일하게 분포된 정수 데이터 유형으로 변환하지만, Qlora와 같은 일부 알고리즘은 비균일 NF4 데이터 유형을 제안하고 이론적 최적성을 입증합니다.

> **AWQ:** 두드러진 가중치의 1%만 보호하면 양자화 오류를 크게 줄일 수 있음을 입증했습니다. 두드러진 가중치 채널은 각 채널의 활성화 및 가중치 분포를 관찰하여 선택됩니다. 두드러진 가중치는 양자화 전에 큰 스케일 팩터를 곱한 후 양자화됩니다.

> **TEQ:** 가중치 전용 양자화에서 FP32 정밀도를 유지하는 학습 가능한 동등 변환입니다. AWQ에서 영감을 받아 활성화와 가중치 간의 최적의 채널별 스케일링 팩터를 찾기 위한 새로운 솔루션을 제공합니다.

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)