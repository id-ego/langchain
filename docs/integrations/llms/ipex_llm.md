---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/ipex_llm.ipynb
description: IPEX-LLM은 Intel CPU 및 GPU에서 저지연으로 LLM을 실행하기 위한 PyTorch 라이브러리입니다. LangChain을
  통해 텍스트 생성을 지원합니다.
---

# IPEX-LLM

> [IPEX-LLM](https://github.com/intel-analytics/ipex-llm/)은 Intel CPU 및 GPU(예: iGPU가 있는 로컬 PC, Arc, Flex 및 Max와 같은 분리형 GPU)에서 매우 낮은 대기 시간으로 LLM을 실행하기 위한 PyTorch 라이브러리입니다.

이 예제는 LangChain을 사용하여 텍스트 생성을 위해 `ipex-llm`과 상호작용하는 방법을 설명합니다.

## 설정

```python
# Update Langchain

%pip install -qU langchain langchain-community
```


Intel CPU에서 LLM을 로컬로 실행하기 위해 IEPX-LLM을 설치합니다.

```python
%pip install --pre --upgrade ipex-llm[all]
```


## 기본 사용법

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "IPEX-LLM"}, {"imported": "IpexLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.ipex_llm.IpexLLM.html", "title": "IPEX-LLM"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "IPEX-LLM"}]-->
import warnings

from langchain.chains import LLMChain
from langchain_community.llms import IpexLLM
from langchain_core.prompts import PromptTemplate

warnings.filterwarnings("ignore", category=UserWarning, message=".*padding_mask.*")
```


모델에 대한 프롬프트 템플릿을 지정합니다. 이 예제에서는 [vicuna-1.5](https://huggingface.co/lmsys/vicuna-7b-v1.5) 모델을 사용합니다. 다른 모델을 사용하는 경우 적절한 템플릿을 선택하십시오.

```python
template = "USER: {question}\nASSISTANT:"
prompt = PromptTemplate(template=template, input_variables=["question"])
```


`IpexLLM.from_model_id`를 사용하여 로컬에서 모델을 로드합니다. Huggingface 형식으로 모델을 직접 로드하고 자동으로 저비트 형식으로 변환하여 추론합니다.

```python
llm = IpexLLM.from_model_id(
    model_id="lmsys/vicuna-7b-v1.5",
    model_kwargs={"temperature": 0, "max_length": 64, "trust_remote_code": True},
)
```


체인에서 사용합니다:

```python
llm_chain = prompt | llm

question = "What is AI?"
output = llm_chain.invoke(question)
```


## 저비트 모델 저장/로드
대안으로, 저비트 모델을 한 번 디스크에 저장하고 `from_model_id_low_bit`를 사용하여 나중에 다시 로드할 수 있습니다 - 다른 머신 간에도 가능합니다. 저비트 모델은 원본 모델보다 훨씬 적은 디스크 공간을 요구하므로 공간 효율적입니다. 또한 `from_model_id_low_bit`는 모델 변환 단계를 건너뛰기 때문에 속도와 메모리 사용 측면에서도 `from_model_id`보다 더 효율적입니다.

저비트 모델을 저장하려면 다음과 같이 `save_low_bit`를 사용하십시오.

```python
saved_lowbit_model_path = "./vicuna-7b-1.5-low-bit"  # path to save low-bit model
llm.model.save_low_bit(saved_lowbit_model_path)
del llm
```


저장된 저비트 모델 경로에서 모델을 다음과 같이 로드합니다.
> 저비트 모델의 저장 경로에는 모델 자체만 포함되며 토크나이저는 포함되지 않습니다. 모든 것을 한 곳에 두고 싶다면 원본 모델의 디렉토리에서 토크나이저 파일을 수동으로 다운로드하거나 복사하여 저비트 모델이 저장된 위치로 이동해야 합니다.

```python
llm_lowbit = IpexLLM.from_model_id_low_bit(
    model_id=saved_lowbit_model_path,
    tokenizer_id="lmsys/vicuna-7b-v1.5",
    # tokenizer_name=saved_lowbit_model_path,  # copy the tokenizers to saved path if you want to use it this way
    model_kwargs={"temperature": 0, "max_length": 64, "trust_remote_code": True},
)
```


체인에서 로드된 모델을 사용합니다:

```python
llm_chain = prompt | llm_lowbit


question = "What is AI?"
output = llm_chain.invoke(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)