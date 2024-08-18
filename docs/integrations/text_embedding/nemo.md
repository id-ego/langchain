---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/nemo.ipynb
description: NVIDIA NeMo 임베딩 서비스에 연결하여 최첨단 텍스트 임베딩을 활용한 자연어 처리 및 이해 기능을 제공합니다.
---

# NVIDIA NeMo 임베딩

`NeMoEmbeddings` 클래스를 사용하여 NVIDIA의 임베딩 서비스에 연결합니다.

NeMo 검색기 임베딩 마이크로서비스(NREM)는 최첨단 텍스트 임베딩의 힘을 귀하의 애플리케이션에 제공하여 비할 데 없는 자연어 처리 및 이해 능력을 제공합니다. 의미 검색, 검색 증강 생성(RAG) 파이프라인을 개발 중이든—텍스트 임베딩을 사용해야 하는 모든 애플리케이션에 대해 NREM이 지원합니다. CUDA, TensorRT 및 Triton을 통합한 NVIDIA 소프트웨어 플랫폼을 기반으로 구축된 NREM은 최첨단 GPU 가속 텍스트 임베딩 모델 서비스를 제공합니다.

NREM은 텍스트 임베딩 모델의 최적화된 추론을 위해 Triton 추론 서버 위에 구축된 NVIDIA의 TensorRT를 사용합니다.

## 가져오기

```python
<!--IMPORTS:[{"imported": "NeMoEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.nemo.NeMoEmbeddings.html", "title": "NVIDIA NeMo embeddings"}]-->
from langchain_community.embeddings import NeMoEmbeddings
```


## 설정

```python
batch_size = 16
model = "NV-Embed-QA-003"
api_endpoint_url = "http://localhost:8080/v1/embeddings"
```


```python
embedding_model = NeMoEmbeddings(
    batch_size=batch_size, model=model, api_endpoint_url=api_endpoint_url
)
```

```output
Checking if endpoint is live: http://localhost:8080/v1/embeddings
```


```python
embedding_model.embed_query("This is a test.")
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)