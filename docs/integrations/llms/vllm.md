---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/vllm.ipynb
description: vLLM은 LLM 추론 및 서비스를 위한 빠르고 사용하기 쉬운 라이브러리로, 효율적인 메모리 관리와 분산 추론을 지원합니다.
---

# vLLM

[vLLM](https://vllm.readthedocs.io/en/latest/index.html)은 LLM 추론 및 서빙을 위한 빠르고 사용하기 쉬운 라이브러리로, 다음과 같은 기능을 제공합니다:

* 최첨단 서빙 처리량
* PagedAttention을 통한 효율적인 주의 키 및 값 메모리 관리
* 들어오는 요청의 지속적인 배치
* 최적화된 CUDA 커널

이 노트북에서는 langchain과 vLLM을 사용하여 LLM을 사용하는 방법을 설명합니다.

사용하려면 `vllm` 파이썬 패키지가 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  vllm -q
```


```python
<!--IMPORTS:[{"imported": "VLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.vllm.VLLM.html", "title": "vLLM"}]-->
from langchain_community.llms import VLLM

llm = VLLM(
    model="mosaicml/mpt-7b",
    trust_remote_code=True,  # mandatory for hf models
    max_new_tokens=128,
    top_k=10,
    top_p=0.95,
    temperature=0.8,
)

print(llm.invoke("What is the capital of France ?"))
```

```output
INFO 08-06 11:37:33 llm_engine.py:70] Initializing an LLM engine with config: model='mosaicml/mpt-7b', tokenizer='mosaicml/mpt-7b', tokenizer_mode=auto, trust_remote_code=True, dtype=torch.bfloat16, use_dummy_weights=False, download_dir=None, use_np_weights=False, tensor_parallel_size=1, seed=0)
INFO 08-06 11:37:41 llm_engine.py:196] # GPU blocks: 861, # CPU blocks: 512
``````output
Processed prompts: 100%|██████████| 1/1 [00:00<00:00,  2.00it/s]
``````output

What is the capital of France ? The capital of France is Paris.
``````output

```

## LLMChain에 모델 통합

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "vLLM"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "vLLM"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "Who was the US president in the year the first Pokemon game was released?"

print(llm_chain.invoke(question))
```

```output
Processed prompts: 100%|██████████| 1/1 [00:01<00:00,  1.34s/it]
``````output


1. The first Pokemon game was released in 1996.
2. The president was Bill Clinton.
3. Clinton was president from 1993 to 2001.
4. The answer is Clinton.
``````output

```

## 분산 추론

vLLM은 분산 텐서 병렬 추론 및 서빙을 지원합니다.

LLM 클래스를 사용하여 다중 GPU 추론을 실행하려면 `tensor_parallel_size` 인수를 사용하려는 GPU의 수로 설정하십시오. 예를 들어, 4개의 GPU에서 추론을 실행하려면

```python
<!--IMPORTS:[{"imported": "VLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.vllm.VLLM.html", "title": "vLLM"}]-->
from langchain_community.llms import VLLM

llm = VLLM(
    model="mosaicml/mpt-30b",
    tensor_parallel_size=4,
    trust_remote_code=True,  # mandatory for hf models
)

llm.invoke("What is the future of AI?")
```


## 양자화

vLLM은 `awq` 양자화를 지원합니다. 이를 활성화하려면 `quantization`을 `vllm_kwargs`에 전달하십시오.

```python
llm_q = VLLM(
    model="TheBloke/Llama-2-7b-Chat-AWQ",
    trust_remote_code=True,
    max_new_tokens=512,
    vllm_kwargs={"quantization": "awq"},
)
```


## OpenAI 호환 서버

vLLM은 OpenAI API 프로토콜을 모방하는 서버로 배포될 수 있습니다. 이를 통해 vLLM은 OpenAI API를 사용하는 애플리케이션의 대체품으로 사용될 수 있습니다.

이 서버는 OpenAI API와 동일한 형식으로 쿼리할 수 있습니다.

### OpenAI 호환 완료

```python
<!--IMPORTS:[{"imported": "VLLMOpenAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.vllm.VLLMOpenAI.html", "title": "vLLM"}]-->
from langchain_community.llms import VLLMOpenAI

llm = VLLMOpenAI(
    openai_api_key="EMPTY",
    openai_api_base="http://localhost:8000/v1",
    model_name="tiiuae/falcon-7b",
    model_kwargs={"stop": ["."]},
)
print(llm.invoke("Rome is"))
```

```output
 a city that is filled with history, ancient buildings, and art around every corner
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)