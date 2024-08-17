---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/localai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/localai.ipynb
---

# LocalAI

Let's load the LocalAI Embedding class. In order to use the LocalAI Embedding class, you need to have the LocalAI service hosted somewhere and configure the embedding models. See the documentation at https://localai.io/basics/getting_started/index.html and https://localai.io/features/embeddings/index.html.


```python
<!--IMPORTS:[{"imported": "LocalAIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.localai.LocalAIEmbeddings.html", "title": "LocalAI"}]-->
from langchain_community.embeddings import LocalAIEmbeddings
```


```python
embeddings = LocalAIEmbeddings(
    openai_api_base="http://localhost:8080", model="embedding-model-name"
)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_result = embeddings.embed_documents([text])
```

Let's load the LocalAI Embedding class with first generation models (e.g. text-search-ada-doc-001/text-search-ada-query-001). Note: These are not recommended models - see [here](https://platform.openai.com/docs/guides/embeddings/what-are-embeddings)


```python
<!--IMPORTS:[{"imported": "LocalAIEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.localai.LocalAIEmbeddings.html", "title": "LocalAI"}]-->
from langchain_community.embeddings import LocalAIEmbeddings
```


```python
embeddings = LocalAIEmbeddings(
    openai_api_base="http://localhost:8080", model="embedding-model-name"
)
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_result = embeddings.embed_documents([text])
```


```python
import os

# if you are behind an explicit proxy, you can use the OPENAI_PROXY environment variable to pass through
os.environ["OPENAI_PROXY"] = "http://proxy.yourcompany.com:8080"
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)