---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/tensorflowhub/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/tensorflowhub.ipynb
---

# TensorFlow Hub

> [TensorFlow Hub](https://www.tensorflow.org/hub) is a repository of trained machine learning models ready for fine-tuning and deployable anywhere. Reuse trained models like `BERT` and `Faster R-CNN` with just a few lines of code.
> 
Let's load the TensorflowHub Embedding class.

```python
<!--IMPORTS:[{"imported": "TensorflowHubEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.tensorflow_hub.TensorflowHubEmbeddings.html", "title": "TensorFlow Hub"}]-->
from langchain_community.embeddings import TensorflowHubEmbeddings
```

```python
embeddings = TensorflowHubEmbeddings()
```
```output
2023-01-30 23:53:01.652176: I tensorflow/core/platform/cpu_feature_guard.cc:193] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX2 FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
2023-01-30 23:53:34.362802: I tensorflow/core/platform/cpu_feature_guard.cc:193] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX2 FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
```

```python
text = "This is a test document."
```

```python
query_result = embeddings.embed_query(text)
```

```python
doc_results = embeddings.embed_documents(["foo"])
```

```python
doc_results
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)