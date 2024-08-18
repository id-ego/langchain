---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ipex_llm.ipynb
description: 이 문서는 Intel CPU에서 IPEX-LLM 최적화를 활용하여 LangChain을 사용한 로컬 BGE 임베딩 작업 수행
  방법을 설명합니다.
---

# 로컬 BGE 임베딩을 위한 IPEX-LLM 인텔 CPU에서의 사용

> [IPEX-LLM](https://github.com/intel-analytics/ipex-llm)은 인텔 CPU 및 GPU(예: iGPU가 장착된 로컬 PC, Arc, Flex 및 Max와 같은 분리형 GPU)에서 매우 낮은 대기 시간으로 LLM을 실행하기 위한 PyTorch 라이브러리입니다.

이 예제는 인텔 CPU에서 `ipex-llm` 최적화를 사용하여 LangChain을 통해 임베딩 작업을 수행하는 방법을 설명합니다. 이는 RAG, 문서 QA 등과 같은 애플리케이션에서 유용할 것입니다.

## 설정

```python
%pip install -qU langchain langchain-community
```


인텔 CPU에서 최적화를 위해 IPEX-LLM과 `sentence-transformers`를 설치합니다.

```python
%pip install --pre --upgrade ipex-llm[all] --extra-index-url https://download.pytorch.org/whl/cpu
%pip install sentence-transformers
```


> **참고**
> 
> Windows 사용자에게는 `ipex-llm` 설치 시 `--extra-index-url https://download.pytorch.org/whl/cpu`가 필요하지 않습니다.

## 기본 사용법

```python
<!--IMPORTS:[{"imported": "IpexLLMBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ipex_llm.IpexLLMBgeEmbeddings.html", "title": "Local BGE Embeddings with IPEX-LLM on Intel CPU"}]-->
from langchain_community.embeddings import IpexLLMBgeEmbeddings

embedding_model = IpexLLMBgeEmbeddings(
    model_name="BAAI/bge-large-en-v1.5",
    model_kwargs={},
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