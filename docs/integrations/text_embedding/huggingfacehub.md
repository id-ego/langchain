---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/huggingfacehub/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/huggingfacehub.ipynb
---

# Hugging Face
Let's load the Hugging Face Embedding class.


```python
%pip install --upgrade --quiet  langchain sentence_transformers
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Hugging Face"}]-->
from langchain_huggingface.embeddings import HuggingFaceEmbeddings
```


```python
embeddings = HuggingFaceEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
query_result[:3]
```



```output
[-0.04895168915390968, -0.03986193612217903, -0.021562768146395683]
```



```python
doc_result = embeddings.embed_documents([text])
```

## Hugging Face Inference API
We can also access embedding models via the Hugging Face Inference API, which does not require us to install ``sentence_transformers`` and download models locally.


```python
import getpass

inference_api_key = getpass.getpass("Enter your HF Inference API Key:\n\n")
```
```output
Enter your HF Inference API Key:

 ········
```

```python
<!--IMPORTS:[{"imported": "HuggingFaceInferenceAPIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.HuggingFaceInferenceAPIEmbeddings.html", "title": "Hugging Face"}]-->
from langchain_community.embeddings import HuggingFaceInferenceAPIEmbeddings

embeddings = HuggingFaceInferenceAPIEmbeddings(
    api_key=inference_api_key, model_name="sentence-transformers/all-MiniLM-l6-v2"
)

query_result = embeddings.embed_query(text)
query_result[:3]
```



```output
[-0.038338541984558105, 0.1234646737575531, -0.028642963618040085]
```


## Hugging Face Hub
We can also generate embeddings locally via the Hugging Face Hub package, which requires us to install ``huggingface_hub ``


```python
!pip install huggingface_hub
```


```python
<!--IMPORTS:[{"imported": "HuggingFaceEndpointEmbeddings", "source": "langchain_huggingface.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface_endpoint.HuggingFaceEndpointEmbeddings.html", "title": "Hugging Face"}]-->
from langchain_huggingface.embeddings import HuggingFaceEndpointEmbeddings
```


```python
embeddings = HuggingFaceEndpointEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
query_result[:3]
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)