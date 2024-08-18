---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/itrex.ipynb
description: Intel® Extension for Transformers를 사용하여 양자화된 BGE 임베딩 모델을 로드하고 고성능 NLP
  백엔드로 추론을 가속화합니다.
---

# Intel® Extension for Transformers 양자화된 텍스트 임베딩

[Intel® Extension for Transformers](https://github.com/intel/intel-extension-for-transformers) (ITREX)에서 생성한 양자화된 BGE 임베딩 모델을 로드하고, 고성능 NLP 백엔드인 ITREX [Neural Engine](https://github.com/intel/intel-extension-for-transformers/blob/main/intel_extension_for_transformers/llm/runtime/deprecated/docs/Installation.md)을 사용하여 정확성을 손상시키지 않으면서 모델의 추론을 가속화합니다.

자세한 내용은 [Intel Extension for Transformers를 이용한 효율적인 자연어 임베딩 모델](https://medium.com/intel-analytics-software/efficient-natural-language-embedding-models-with-intel-extension-for-transformers-2b6fcd0f8f34) 블로그와 [BGE 최적화 예제](https://github.com/intel/intel-extension-for-transformers/tree/main/examples/huggingface/pytorch/text-embedding/deployment/mteb/bge)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "QuantizedBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.itrex.QuantizedBgeEmbeddings.html", "title": "Intel\u00ae Extension for Transformers Quantized Text Embeddings"}]-->
from langchain_community.embeddings import QuantizedBgeEmbeddings

model_name = "Intel/bge-small-en-v1.5-sts-int8-static-inc"
encode_kwargs = {"normalize_embeddings": True}  # set True to compute cosine similarity

model = QuantizedBgeEmbeddings(
    model_name=model_name,
    encode_kwargs=encode_kwargs,
    query_instruction="Represent this sentence for searching relevant passages: ",
)
```

```output
/home/yuwenzho/.conda/envs/bge/lib/python3.9/site-packages/tqdm/auto.py:21: TqdmWarning: IProgress not found. Please update jupyter and ipywidgets. See https://ipywidgets.readthedocs.io/en/stable/user_install.html
  from .autonotebook import tqdm as notebook_tqdm
2024-03-04 10:17:17 [INFO] Start to extarct onnx model ops...
2024-03-04 10:17:17 [INFO] Extract onnxruntime model done...
2024-03-04 10:17:17 [INFO] Start to implement Sub-Graph matching and replacing...
2024-03-04 10:17:18 [INFO] Sub-Graph match and replace done...
```

## 사용법

```python
text = "This is a test document."
query_result = model.embed_query(text)
doc_result = model.embed_documents([text])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)