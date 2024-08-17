---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/qdrant/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/qdrant.ipynb
---

# Qdrant

> [Qdrant](https://qdrant.tech/documentation/) (read: quadrant ) is a vector similarity search engine. It provides a production-ready service with a convenient API to store, search, and manage vectors with additional payload and extended filtering support. It makes it useful for all sorts of neural network or semantic-based matching, faceted search, and other applications.

This documentation demonstrates how to use Qdrant with Langchain for dense/sparse and hybrid retrieval.

> This page documents the `QdrantVectorStore` class that supports multiple retrieval modes via Qdrant's new [Query API](https://qdrant.tech/blog/qdrant-1.10.x/). It requires you to run Qdrant v1.10.0 or above.

## Setup

There are various modes of how to run `Qdrant`, and depending on the chosen one, there will be some subtle differences. The options include:
- Local mode, no server required
- Docker deployments
- Qdrant Cloud

See the [installation instructions](https://qdrant.tech/documentation/install/).

```python
%pip install -qU langchain-qdrant
```

### Credentials

There are no credentials needed to run the code in this notebook.

If you want to get best in-class automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

## Initialization

### Local mode

Python client allows you to run the same code in local mode without running the Qdrant server. That's great for testing things out and debugging or storing just a small amount of vectors. The embeddings might be fully kept in memory or persisted on disk.

#### In-memory

For some testing scenarios and quick experiments, you may prefer to keep all the data in memory only, so it gets lost when the client is destroyed - usually at the end of your script/notebook.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>


```python
<!--IMPORTS:[{"imported": "QdrantVectorStore", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.QdrantVectorStore.html", "title": "Qdrant"}]-->
from langchain_qdrant import QdrantVectorStore
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams

client = QdrantClient(":memory:")

client.create_collection(
    collection_name="demo_collection",
    vectors_config=VectorParams(size=3072, distance=Distance.COSINE),
)

vector_store = QdrantVectorStore(
    client=client,
    collection_name="demo_collection",
    embedding=embeddings,
)
```

#### On-disk storage

Local mode, without using the Qdrant server, may also store your vectors on disk so they persist between runs.

```python
client = QdrantClient(path="/tmp/langchain_qdrant")

client.create_collection(
    collection_name="demo_collection",
    vectors_config=VectorParams(size=3072, distance=Distance.COSINE),
)

vector_store = QdrantVectorStore(
    client=client,
    collection_name="demo_collection",
    embedding=embeddings,
)
```

### On-premise server deployment

No matter if you choose to launch Qdrant locally with [a Docker container](https://qdrant.tech/documentation/install/), or select a Kubernetes deployment with [the official Helm chart](https://github.com/qdrant/qdrant-helm), the way you're going to connect to such an instance will be identical. You'll need to provide a URL pointing to the service.

```python
url = "<---qdrant url here --->"
docs = []  # put docs here
qdrant = QdrantVectorStore.from_documents(
    docs,
    embeddings,
    url=url,
    prefer_grpc=True,
    collection_name="my_documents",
)
```

### Qdrant Cloud

If you prefer not to keep yourself busy with managing the infrastructure, you can choose to set up a fully-managed Qdrant cluster on [Qdrant Cloud](https://cloud.qdrant.io/). There is a free forever 1GB cluster included for trying out. The main difference with using a managed version of Qdrant is that you'll need to provide an API key to secure your deployment from being accessed publicly. The value can also be set in a `QDRANT_API_KEY` environment variable.

```python
url = "<---qdrant cloud cluster url here --->"
api_key = "<---api key here--->"
qdrant = QdrantVectorStore.from_documents(
    docs,
    embeddings,
    url=url,
    prefer_grpc=True,
    api_key=api_key,
    collection_name="my_documents",
)
```

## Using an existing collection

To get an instance of `langchain_qdrant.Qdrant` without loading any new documents or texts, you can use the `Qdrant.from_existing_collection()` method.

```python
qdrant = QdrantVectorStore.from_existing_collection(
    embedding=embeddings,
    collection_name="my_documents",
    url="http://localhost:6333",
)
```

## Manage vector store

Once you have created your vector store, we can interact with it by adding and deleting different items.

### Add items to vector store

We can add items to our vector store by using the `add_documents` function.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Qdrant"}]-->
from uuid import uuid4

from langchain_core.documents import Document

document_1 = Document(
    page_content="I had chocalate chip pancakes and scrambled eggs for breakfast this morning.",
    metadata={"source": "tweet"},
)

document_2 = Document(
    page_content="The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees.",
    metadata={"source": "news"},
)

document_3 = Document(
    page_content="Building an exciting new project with LangChain - come check it out!",
    metadata={"source": "tweet"},
)

document_4 = Document(
    page_content="Robbers broke into the city bank and stole $1 million in cash.",
    metadata={"source": "news"},
)

document_5 = Document(
    page_content="Wow! That was an amazing movie. I can't wait to see it again.",
    metadata={"source": "tweet"},
)

document_6 = Document(
    page_content="Is the new iPhone worth the price? Read this review to find out.",
    metadata={"source": "website"},
)

document_7 = Document(
    page_content="The top 10 soccer players in the world right now.",
    metadata={"source": "website"},
)

document_8 = Document(
    page_content="LangGraph is the best framework for building stateful, agentic applications!",
    metadata={"source": "tweet"},
)

document_9 = Document(
    page_content="The stock market is down 500 points today due to fears of a recession.",
    metadata={"source": "news"},
)

document_10 = Document(
    page_content="I have a bad feeling I am going to get deleted :(",
    metadata={"source": "tweet"},
)

documents = [
    document_1,
    document_2,
    document_3,
    document_4,
    document_5,
    document_6,
    document_7,
    document_8,
    document_9,
    document_10,
]
uuids = [str(uuid4()) for _ in range(len(documents))]

vector_store.add_documents(documents=documents, ids=uuids)
```

```output
['c04134c3-273d-4766-949a-eee46052ad32',
 '9e6ba50c-794f-4b88-94e5-411f15052a02',
 'd3202666-6f2b-4186-ac43-e35389de8166',
 '50d8d6ee-69bf-4173-a6a2-b254e9928965',
 'bd2eae02-74b5-43ec-9fcf-09e9d9db6fd3',
 '6dae6b37-826d-4f14-8376-da4603b35de3',
 'b0964ab5-5a14-47b4-a983-37fa5c5bd154',
 '91ed6c56-fe53-49e2-8199-c3bb3c33c3eb',
 '42a580cb-7469-4324-9927-0febab57ce92',
 'ff774e5c-f158-4d12-94e2-0a0162b22f27']
```

### Delete items from vector store

```python
vector_store.delete(ids=[uuids[-1]])
```

```output
True
```

## Query vector store

Once your vector store has been created and the relevant documents have been added you will most likely wish to query it during the running of your chain or agent. 

### Query directly

The simplest scenario for using Qdrant vector store is to perform a similarity search. Under the hood, our query will be encoded into vector embeddings and used to find similar documents in Qdrant collection.

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy", k=2
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```
```output
* Building an exciting new project with LangChain - come check it out! [{'source': 'tweet', '_id': 'd3202666-6f2b-4186-ac43-e35389de8166', '_collection_name': 'demo_collection'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'source': 'tweet', '_id': '91ed6c56-fe53-49e2-8199-c3bb3c33c3eb', '_collection_name': 'demo_collection'}]
```
`QdrantVectorStore` supports 3 modes for similarity searches. They can be configured using the `retrieval_mode` parameter when setting up the class.

- Dense Vector Search(Default)
- Sparse Vector Search
- Hybrid Search

### Dense Vector Search

To search with only dense vectors,

- The `retrieval_mode` parameter should be set to `RetrievalMode.DENSE`(default).
- A [dense embeddings](https://python.langchain.com/v0.2/docs/integrations/text_embedding/) value should be provided to the `embedding` parameter.

```python
<!--IMPORTS:[{"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import RetrievalMode

qdrant = QdrantVectorStore.from_documents(
    docs,
    embedding=embeddings,
    location=":memory:",
    collection_name="my_documents",
    retrieval_mode=RetrievalMode.DENSE,
)

query = "What did the president say about Ketanji Brown Jackson"
found_docs = qdrant.similarity_search(query)
```

### Sparse Vector Search

To search with only sparse vectors,

- The `retrieval_mode` parameter should be set to `RetrievalMode.SPARSE`.
- An implementation of the [`SparseEmbeddings`](https://github.com/langchain-ai/langchain/blob/master/libs/partners/qdrant/langchain_qdrant/sparse_embeddings.py) interface using any sparse embeddings provider has to be provided as value to the `sparse_embedding` parameter.

The `langchain-qdrant` package provides a [FastEmbed](https://github.com/qdrant/fastembed) based implementation out of the box.

To use it, install the FastEmbed package.

```python
%pip install fastembed
```

```python
<!--IMPORTS:[{"imported": "FastEmbedSparse", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/fastembed_sparse/langchain_qdrant.fastembed_sparse.FastEmbedSparse.html", "title": "Qdrant"}, {"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import FastEmbedSparse, RetrievalMode

sparse_embeddings = FastEmbedSparse(model_name="Qdrant/BM25")

qdrant = QdrantVectorStore.from_documents(
    docs,
    sparse_embedding=sparse_embeddings,
    location=":memory:",
    collection_name="my_documents",
    retrieval_mode=RetrievalMode.SPARSE,
)

query = "What did the president say about Ketanji Brown Jackson"
found_docs = qdrant.similarity_search(query)
```

### Hybrid Vector Search

To perform a hybrid search using dense and sparse vectors with score fusion,

- The `retrieval_mode` parameter should be set to `RetrievalMode.HYBRID`.
- A [dense embeddings](https://python.langchain.com/v0.2/docs/integrations/text_embedding/) value should be provided to the `embedding` parameter.
- An implementation of the [`SparseEmbeddings`](https://github.com/langchain-ai/langchain/blob/master/libs/partners/qdrant/langchain_qdrant/sparse_embeddings.py) interface using any sparse embeddings provider has to be provided as value to the `sparse_embedding` parameter.

Note that if you've added documents with the `HYBRID` mode, you can switch to any retrieval mode when searching. Since both the dense and sparse vectors are available in the collection.

```python
<!--IMPORTS:[{"imported": "FastEmbedSparse", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/fastembed_sparse/langchain_qdrant.fastembed_sparse.FastEmbedSparse.html", "title": "Qdrant"}, {"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import FastEmbedSparse, RetrievalMode

sparse_embeddings = FastEmbedSparse(model_name="Qdrant/BM25")

qdrant = QdrantVectorStore.from_documents(
    docs,
    embedding=embeddings,
    sparse_embedding=sparse_embeddings,
    location=":memory:",
    collection_name="my_documents",
    retrieval_mode=RetrievalMode.HYBRID,
)

query = "What did the president say about Ketanji Brown Jackson"
found_docs = qdrant.similarity_search(query)
```

If you want to execute a similarity search and receive the corresponding scores you can run:

```python
results = vector_store.similarity_search_with_score(
    query="Will it be hot tomorrow", k=1
)
for doc, score in results:
    print(f"* [SIM={score:3f}] {doc.page_content} [{doc.metadata}]")
```
```output
* [SIM=0.531834] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news', '_id': '9e6ba50c-794f-4b88-94e5-411f15052a02', '_collection_name': 'demo_collection'}]
```
For a full list of all the search functions available for a `QdrantVectorStore`, read the [API reference](https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.QdrantVectorStore.html)

### Metadata filtering

Qdrant has an [extensive filtering system](https://qdrant.tech/documentation/concepts/filtering/) with rich type support. It is also possible to use the filters in Langchain, by passing an additional param to both the `similarity_search_with_score` and `similarity_search` methods.

```python
from qdrant_client.http import models

results = vector_store.similarity_search(
    query="Who are the best soccer players in the world?",
    k=1,
    filter=models.Filter(
        should=[
            models.FieldCondition(
                key="page_content",
                match=models.MatchValue(
                    value="The top 10 soccer players in the world right now."
                ),
            ),
        ]
    ),
)
for doc in results:
    print(f"* {doc.page_content} [{doc.metadata}]")
```
```output
* The top 10 soccer players in the world right now. [{'source': 'website', '_id': 'b0964ab5-5a14-47b4-a983-37fa5c5bd154', '_collection_name': 'demo_collection'}]
```
### Query by turning into retriever

You can also transform the vector store into a retriever for easier usage in your chains. 

```python
retriever = vector_store.as_retriever(search_type="mmr", search_kwargs={"k": 1})
retriever.invoke("Stealing from the bank is a crime")
```

```output
[Document(metadata={'source': 'news', '_id': '50d8d6ee-69bf-4173-a6a2-b254e9928965', '_collection_name': 'demo_collection'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```

## Usage for retrieval-augmented generation

For guides on how to use this vector store for retrieval-augmented generation (RAG), see the following sections:

- [Tutorials: working with external knowledge](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [How-to: Question and answer with RAG](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [Retrieval conceptual docs](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## Customizing Qdrant

There are options to use an existing Qdrant collection within your Langchain application. In such cases, you may need to define how to map Qdrant point into the Langchain `Document`.

### Named vectors

Qdrant supports [multiple vectors per point](https://qdrant.tech/documentation/concepts/collections/#collection-with-multiple-vectors) by named vectors. If you work with a collection created externally or want to have the differently named vector used, you can configure it by providing its name.

```python
<!--IMPORTS:[{"imported": "RetrievalMode", "source": "langchain_qdrant", "docs": "https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.RetrievalMode.html", "title": "Qdrant"}]-->
from langchain_qdrant import RetrievalMode

QdrantVectorStore.from_documents(
    docs,
    embedding=embeddings,
    sparse_embedding=sparse_embeddings,
    location=":memory:",
    collection_name="my_documents_2",
    retrieval_mode=RetrievalMode.HYBRID,
    vector_name="custom_vector",
    sparse_vector_name="custom_sparse_vector",
)
```

### Metadata

Qdrant stores your vector embeddings along with the optional JSON-like payload. Payloads are optional, but since LangChain assumes the embeddings are generated from the documents, we keep the context data, so you can extract the original texts as well.

By default, your document is going to be stored in the following payload structure:

```json
{
    "page_content": "Lorem ipsum dolor sit amet",
    "metadata": {
        "foo": "bar"
    }
}
```

You can, however, decide to use different keys for the page content and metadata. That's useful if you already have a collection that you'd like to reuse.

```python
QdrantVectorStore.from_documents(
    docs,
    embeddings,
    location=":memory:",
    collection_name="my_documents_2",
    content_payload_key="my_page_content_key",
    metadata_payload_key="my_meta",
)
```

## API reference

For detailed documentation of all `QdrantVectorStore` features and configurations head to the API reference: https://api.python.langchain.com/en/latest/qdrant/langchain_qdrant.qdrant.QdrantVectorStore.html

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)