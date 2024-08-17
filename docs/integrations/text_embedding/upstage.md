---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/upstage/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/upstage.ipynb
sidebar_label: Upstage
---

# UpstageEmbeddings

This notebook covers how to get started with Upstage embedding models.

## Installation

Install `langchain-upstage` package.

```bash
pip install -U langchain-upstage
```

## Environment Setup

Make sure to set the following environment variables:

- `UPSTAGE_API_KEY`: Your Upstage API key from [Upstage console](https://console.upstage.ai/).


```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```


## Usage

Initialize `UpstageEmbeddings` class.


```python
from langchain_upstage import UpstageEmbeddings

embeddings = UpstageEmbeddings(model="solar-embedding-1-large")
```

Use `embed_documents` to embed list of texts or documents. 


```python
doc_result = embeddings.embed_documents(
    ["Sung is a professor.", "This is another document"]
)
print(doc_result)
```

Use `embed_query` to embed query string.


```python
query_result = embeddings.embed_query("What does Sung do?")
print(query_result)
```

Use `aembed_documents` and `aembed_query` for async operations.


```python
# async embed query
await embeddings.aembed_query("My query to look up")
```


```python
# async embed documents
await embeddings.aembed_documents(
    ["This is a content of the document", "This is another document"]
)
```

## Using with vector store

You can use `UpstageEmbeddings` with vector store component. The following demonstrates a simple example.


```python
<!--IMPORTS:[{"imported": "DocArrayInMemorySearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.docarray.in_memory.DocArrayInMemorySearch.html", "title": "UpstageEmbeddings"}]-->
from langchain_community.vectorstores import DocArrayInMemorySearch

vectorstore = DocArrayInMemorySearch.from_texts(
    ["harrison worked at kensho", "bears like to eat honey"],
    embedding=UpstageEmbeddings(model="solar-embedding-1-large"),
)
retriever = vectorstore.as_retriever()
docs = retriever.invoke("Where did Harrison work?")
print(docs)
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)