---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/dashvector/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/dashvector.ipynb
---

# DashVector

> [DashVector](https://help.aliyun.com/document_detail/2510225.html) is a fully-managed vectorDB service that supports high-dimension dense and sparse vectors, real-time insertion and filtered search. It is built to scale automatically and can adapt to different application requirements.

This notebook shows how to use functionality related to the `DashVector` vector database.

To use DashVector, you must have an API key.
Here are the [installation instructions](https://help.aliyun.com/document_detail/2510223.html).

## Install

```python
%pip install --upgrade --quiet  langchain-community dashvector dashscope
```

We want to use `DashScopeEmbeddings` so we also have to get the Dashscope API Key.

```python
import getpass
import os

os.environ["DASHVECTOR_API_KEY"] = getpass.getpass("DashVector API Key:")
os.environ["DASHSCOPE_API_KEY"] = getpass.getpass("DashScope API Key:")
```

## Example

```python
<!--IMPORTS:[{"imported": "DashScopeEmbeddings", "source": "langchain_community.embeddings.dashscope", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.dashscope.DashScopeEmbeddings.html", "title": "DashVector"}, {"imported": "DashVector", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.dashvector.DashVector.html", "title": "DashVector"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "DashVector"}]-->
from langchain_community.embeddings.dashscope import DashScopeEmbeddings
from langchain_community.vectorstores import DashVector
from langchain_text_splitters import CharacterTextSplitter
```

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "DashVector"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = DashScopeEmbeddings()
```

We can create DashVector from documents.

```python
dashvector = DashVector.from_documents(docs, embeddings)

query = "What did the president say about Ketanji Brown Jackson"
docs = dashvector.similarity_search(query)
print(docs)
```

We can add texts with meta datas and ids, and search with meta filter.

```python
texts = ["foo", "bar", "baz"]
metadatas = [{"key": i} for i in range(len(texts))]
ids = ["0", "1", "2"]

dashvector.add_texts(texts, metadatas=metadatas, ids=ids)

docs = dashvector.similarity_search("foo", filter="key = 2")
print(docs)
```
```output
[Document(page_content='baz', metadata={'key': 2})]
```
### Operating band `partition` parameters

The `partition` parameter defaults to default, and if a non-existent `partition` parameter is passed in, the `partition` will be created automatically. 

```python
texts = ["foo", "bar", "baz"]
metadatas = [{"key": i} for i in range(len(texts))]
ids = ["0", "1", "2"]
partition = "langchain"

# add texts
dashvector.add_texts(texts, metadatas=metadatas, ids=ids, partition=partition)

# similarity search
query = "What did the president say about Ketanji Brown Jackson"
docs = dashvector.similarity_search(query, partition=partition)

# delete
dashvector.delete(ids=ids, partition=partition)
```

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)