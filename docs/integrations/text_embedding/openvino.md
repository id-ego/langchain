---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/openvino/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/openvino.ipynb
---

# OpenVINO
[OpenVINO™](https://github.com/openvinotoolkit/openvino) is an open-source toolkit for optimizing and deploying AI inference. The OpenVINO™ Runtime supports various hardware [devices](https://github.com/openvinotoolkit/openvino?tab=readme-ov-file#supported-hardware-matrix) including x86 and ARM CPUs, and Intel GPUs. It can help to boost deep learning performance in Computer Vision, Automatic Speech Recognition, Natural Language Processing and other common tasks.

Hugging Face embedding model can be supported by OpenVINO through `OpenVINOEmbeddings` class. If you have an Intel GPU, you can specify `model_kwargs={"device": "GPU"}` to run inference on it.

```python
%pip install --upgrade-strategy eager "optimum[openvino,nncf]" --quiet
```
```output
Note: you may need to restart the kernel to use updated packages.
```

```python
<!--IMPORTS:[{"imported": "OpenVINOEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.openvino.OpenVINOEmbeddings.html", "title": "OpenVINO"}]-->
from langchain_community.embeddings import OpenVINOEmbeddings
```

```python
model_name = "sentence-transformers/all-mpnet-base-v2"
model_kwargs = {"device": "CPU"}
encode_kwargs = {"mean_pooling": True, "normalize_embeddings": True}

ov_embeddings = OpenVINOEmbeddings(
    model_name_or_path=model_name,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs,
)
```

```python
text = "This is a test document."
```

```python
query_result = ov_embeddings.embed_query(text)
```

```python
query_result[:3]
```

```output
[-0.048951778560876846, -0.03986183926463127, -0.02156277745962143]
```

```python
doc_result = ov_embeddings.embed_documents([text])
```

## Export IR model
It is possible to export your embedding model to the OpenVINO IR format with `OVModelForFeatureExtraction`, and load the model from local folder.

```python
from pathlib import Path

ov_model_dir = "all-mpnet-base-v2-ov"
if not Path(ov_model_dir).exists():
    ov_embeddings.save_model(ov_model_dir)
```

```python
ov_embeddings = OpenVINOEmbeddings(
    model_name_or_path=ov_model_dir,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs,
)
```
```output
Compiling the model to CPU ...
```
## BGE with OpenVINO
We can also access BGE embedding models via the `OpenVINOBgeEmbeddings` class with OpenVINO. 

```python
<!--IMPORTS:[{"imported": "OpenVINOBgeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.openvino.OpenVINOBgeEmbeddings.html", "title": "OpenVINO"}]-->
from langchain_community.embeddings import OpenVINOBgeEmbeddings

model_name = "BAAI/bge-small-en"
model_kwargs = {"device": "CPU"}
encode_kwargs = {"normalize_embeddings": True}
ov_embeddings = OpenVINOBgeEmbeddings(
    model_name_or_path=model_name,
    model_kwargs=model_kwargs,
    encode_kwargs=encode_kwargs,
)
```

```python
embedding = ov_embeddings.embed_query("hi this is harrison")
len(embedding)
```

```output
384
```

For more information refer to:

* [OpenVINO LLM guide](https://docs.openvino.ai/2024/learn-openvino/llm_inference_guide.html).
* [OpenVINO Documentation](https://docs.openvino.ai/2024/home.html).
* [OpenVINO Get Started Guide](https://www.intel.com/content/www/us/en/content-details/819067/openvino-get-started-guide.html).
* [RAG Notebook with LangChain](https://github.com/openvinotoolkit/openvino_notebooks/tree/latest/notebooks/llm-rag-langchain).

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)