---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/baiduvectordb/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/baiduvectordb.ipynb
---

# Baidu VectorDB

> [Baidu VectorDB](https://cloud.baidu.com/product/vdb.html) is a robust, enterprise-level distributed database service, meticulously developed and fully managed by Baidu Intelligent Cloud. It stands out for its exceptional ability to store, retrieve, and analyze multi-dimensional vector data. At its core, VectorDB operates on Baidu's proprietary "Mochow" vector database kernel, which ensures high performance, availability, and security, alongside remarkable scalability and user-friendliness.

> This database service supports a diverse range of index types and similarity calculation methods, catering to various use cases. A standout feature of VectorDB is its capacity to manage an immense vector scale of up to 10 billion, while maintaining impressive query performance, supporting millions of queries per second (QPS) with millisecond-level query latency.

You'll need to install `langchain-community` with `pip install -qU langchain-community` to use this integration

This notebook shows how to use functionality related to the Baidu VectorDB. 

To run, you should have a [Database instance.](https://cloud.baidu.com/doc/VDB/s/hlrsoazuf).

```python
!pip3 install pymochow
```

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Baidu VectorDB"}, {"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Baidu VectorDB"}, {"imported": "BaiduVectorDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.baiduvectordb.BaiduVectorDB.html", "title": "Baidu VectorDB"}, {"imported": "ConnectionParams", "source": "langchain_community.vectorstores.baiduvectordb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.baiduvectordb.ConnectionParams.html", "title": "Baidu VectorDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Baidu VectorDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores import BaiduVectorDB
from langchain_community.vectorstores.baiduvectordb import ConnectionParams
from langchain_text_splitters import CharacterTextSplitter
```

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
embeddings = FakeEmbeddings(size=128)
```

```python
conn_params = ConnectionParams(
    endpoint="http://192.168.xx.xx:xxxx", account="root", api_key="****"
)

vector_db = BaiduVectorDB.from_documents(
    docs, embeddings, connection_params=conn_params, drop_old=True
)
```

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)
docs[0].page_content
```

```python
vector_db = BaiduVectorDB(embeddings, conn_params)
vector_db.add_texts(["Ankush went to Princeton"])
query = "Where did Ankush go to college?"
docs = vector_db.max_marginal_relevance_search(query)
docs[0].page_content
```

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)