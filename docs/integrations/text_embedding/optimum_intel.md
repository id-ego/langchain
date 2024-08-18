---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/optimum_intel.ipynb
description: 문서에서는 최적화된 양자화 임베더를 사용하여 문서를 임베딩하는 방법을 설명하고, 질문에 대한 문서 비교를 다룹니다.
---

# 최적화되고 양자화된 임베더를 사용한 문서 임베딩

양자화된 임베더를 사용하여 모든 문서를 임베딩합니다.

임베더는 [optimum-intel](https://github.com/huggingface/optimum-intel.git)과 [IPEX](https://github.com/intel/intel-extension-for-pytorch)를 사용하여 생성된 최적화된 모델을 기반으로 합니다.

예제 텍스트는 [SBERT](https://www.sbert.net/docs/pretrained_cross-encoders.html)를 기반으로 합니다.

```python
<!--IMPORTS:[{"imported": "QuantizedBiEncoderEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.optimum_intel.QuantizedBiEncoderEmbeddings.html", "title": "Embedding Documents using Optimized and Quantized Embedders"}]-->
from langchain_community.embeddings import QuantizedBiEncoderEmbeddings

model_name = "Intel/bge-small-en-v1.5-rag-int8-static"
encode_kwargs = {"normalize_embeddings": True}  # set True to compute cosine similarity

model = QuantizedBiEncoderEmbeddings(
    model_name=model_name,
    encode_kwargs=encode_kwargs,
    query_instruction="Represent this sentence for searching relevant passages: ",
)
```

```output
loading configuration file inc_config.json from cache at 
INCConfig {
  "distillation": {},
  "neural_compressor_version": "2.4.1",
  "optimum_version": "1.16.2",
  "pruning": {},
  "quantization": {
    "dataset_num_samples": 50,
    "is_static": true
  },
  "save_onnx_model": false,
  "torch_version": "2.2.0",
  "transformers_version": "4.37.2"
}

Using `INCModel` to load a TorchScript model will be deprecated in v1.15.0, to load your model please use `IPEXModel` instead.
```

질문을 하고 2개의 문서를 비교해 봅시다. 첫 번째 문서는 질문에 대한 답변을 포함하고 있으며, 두 번째 문서는 포함하고 있지 않습니다.

우리는 어떤 것이 우리의 쿼리에 더 적합한지 확인할 수 있습니다.

```python
question = "How many people live in Berlin?"
```


```python
documents = [
    "Berlin had a population of 3,520,031 registered inhabitants in an area of 891.82 square kilometers.",
    "Berlin is well known for its museums.",
]
```


```python
doc_vecs = model.embed_documents(documents)
```

```output
Batches: 100%|██████████| 1/1 [00:00<00:00,  4.18it/s]
```


```python
query_vec = model.embed_query(question)
```


```python
import torch
```


```python
doc_vecs_torch = torch.tensor(doc_vecs)
```


```python
query_vec_torch = torch.tensor(query_vec)
```


```python
query_vec_torch @ doc_vecs_torch.T
```


```output
tensor([0.7980, 0.6529])
```


실제로 첫 번째 문서가 더 높은 순위를 차지하는 것을 볼 수 있습니다.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)