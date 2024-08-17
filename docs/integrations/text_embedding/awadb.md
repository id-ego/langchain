---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/awadb/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/awadb.ipynb
---

# AwaDB

>[AwaDB](https://github.com/awa-ai/awadb) is an AI Native database for the search and storage of embedding vectors used by LLM Applications.

This notebook explains how to use `AwaEmbeddings` in LangChain.


```python
# pip install awadb
```

## import the library


```python
<!--IMPORTS:[{"imported": "AwaEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.awa.AwaEmbeddings.html", "title": "AwaDB"}]-->
from langchain_community.embeddings import AwaEmbeddings
```


```python
Embedding = AwaEmbeddings()
```

# Set embedding model
Users can use `Embedding.set_model()` to specify the embedding model. \
The input of this function is a string which represents the model's name. \
The list of currently supported models can be obtained [here](https://github.com/awa-ai/awadb) \ \ 

The **default model** is `all-mpnet-base-v2`, it can be used without setting.


```python
text = "our embedding test"

Embedding.set_model("all-mpnet-base-v2")
```


```python
res_query = Embedding.embed_query("The test information")
res_document = Embedding.embed_documents(["test1", "another test"])
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)