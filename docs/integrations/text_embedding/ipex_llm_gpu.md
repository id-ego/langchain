---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ipex_llm_gpu.ipynb
description: Intel GPU에서 IPEX-LLM을 활용한 LangChain을 이용한 로컬 BGE 임베딩 작업을 다루는 예제입니다. RAG
  및 문서 QA에 유용합니다.
---

# 로컬 BGE 임베딩을 위한 IPEX-LLM 인텔 GPU에서의 사용

> [IPEX-LLM](https://github.com/intel-analytics/ipex-llm)은 인텔 CPU 및 GPU(예: iGPU가 장착된 로컬 PC, Arc, Flex 및 Max와 같은 독립형 GPU)에서 LLM을 매우 낮은 대기 시간으로 실행하기 위한 PyTorch 라이브러리입니다.

이 예제에서는 인텔 GPU에서 `ipex-llm` 최적화를 사용하여 임베딩 작업을 수행하기 위해 LangChain을 사용하는 방법을 설명합니다. 이는 RAG, 문서 QA 등과 같은 애플리케이션에 유용할 것입니다.

> **참고**
> 
> 인텔 Arc A-Series GPU(인텔 Arc A300-Series 또는 Pro A60 제외)를 사용하는 Windows 사용자만 이 Jupyter 노트북을 직접 실행하는 것이 권장됩니다. 다른 경우(예: 리눅스 사용자, 인텔 iGPU 등)에는 최상의 경험을 위해 터미널에서 Python 스크립트를 사용하여 코드를 실행하는 것이 좋습니다.

## 필수 구성 요소 설치
인텔 GPU에서 IPEX-LLM의 이점을 누리기 위해 도구 설치 및 환경 준비를 위한 몇 가지 필수 단계가 필요합니다.

Windows 사용자라면 [인텔 GPU에서 Windows에 IPEX-LLM 설치 가이드](https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Quickstart/install_windows_gpu.html)를 방문하고, [필수 구성 요소 설치](https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Quickstart/install_windows_gpu.html#install-prerequisites)를 따라 GPU 드라이버(선택 사항)를 업데이트하고 Conda를 설치하세요.

리눅스 사용자라면 [인텔 GPU에서 리눅스에 IPEX-LLM 설치](https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Quickstart/install_linux_gpu.html)를 방문하고, [**필수 구성 요소 설치**](https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Quickstart/install_linux_gpu.html#install-prerequisites)를 따라 GPU 드라이버, Intel® oneAPI Base Toolkit 2024.0 및 Conda를 설치하세요.

## 설정

필수 구성 요소 설치 후, 모든 필수 구성 요소가 설치된 conda 환경을 생성해야 합니다. **이 conda 환경에서 jupyter 서비스를 시작하세요**:

```python
%pip install -qU langchain langchain-community
```


인텔 GPU에서 최적화를 위한 IPEX-LLM과 `sentence-transformers`를 설치하세요.

```python
%pip install --pre --upgrade ipex-llm[xpu] --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
%pip install sentence-transformers
```


> **참고**
> 
> 추가 인덱스 URL로 `https://pytorch-extension.intel.com/release-whl/stable/xpu/cn/`를 사용할 수도 있습니다.

## 런타임 구성

최적의 성능을 위해 장치에 따라 여러 환경 변수를 설정하는 것이 권장됩니다:

### 인텔 코어 울트라 통합 GPU를 사용하는 Windows 사용자

```python
import os

os.environ["SYCL_CACHE_PERSISTENT"] = "1"
os.environ["BIGDL_LLM_XMX_DISABLED"] = "1"
```


### 인텔 Arc A-Series GPU를 사용하는 Windows 사용자

```python
import os

os.environ["SYCL_CACHE_PERSISTENT"] = "1"
```


> **참고**
> 
> 각 모델이 인텔 iGPU/인텔 Arc A300-Series 또는 Pro A60에서 처음 실행될 때는 컴파일하는 데 몇 분이 걸릴 수 있습니다.
> 
> 다른 GPU 유형의 경우, Windows 사용자는 [여기](https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Overview/install_gpu.html#runtime-configuration)를 참조하고, 리눅스 사용자는 [여기](https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Overview/install_gpu.html#id5)를 참조하세요.

## 기본 사용법

`IpexLLMBgeEmbeddings`를 초기화할 때 `model_kwargs`에서 `device`를 `"xpu"`로 설정하면 임베딩 모델이 인텔 GPU에 배치되고 IPEX-LLM 최적화를 통해 이점을 누릴 수 있습니다:

```python
<!--IMPORTS:[{"imported": "IpexLLMBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ipex_llm.IpexLLMBgeEmbeddings.html", "title": "Local BGE Embeddings with IPEX-LLM on Intel GPU"}]-->
from langchain_community.embeddings import IpexLLMBgeEmbeddings

embedding_model = IpexLLMBgeEmbeddings(
    model_name="BAAI/bge-large-en-v1.5",
    model_kwargs={"device": "xpu"},
    encode_kwargs={"normalize_embeddings": True},
)
```


API 참조
- [IpexLLMBgeEmbeddings](https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ipex_llm.IpexLLMBgeEmbeddings.html)

```python
sentence = "IPEX-LLM is a PyTorch library for running LLM on Intel CPU and GPU (e.g., local PC with iGPU, discrete GPU such as Arc, Flex and Max) with very low latency."
query = "What is IPEX-LLM?"

text_embeddings = embedding_model.embed_documents([sentence, query])
print(f"text_embeddings[0][:10]: {text_embeddings[0][:10]}")
print(f"text_embeddings[1][:10]: {text_embeddings[1][:10]}")

query_embedding = embedding_model.embed_query(query)
print(f"query_embedding[:10]: {query_embedding[:10]}")
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)