---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/mongodb_atlas/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/mongodb_atlas.ipynb
---

# MongoDB Atlas

This notebook covers how to MongoDB Atlas vector search in LangChain, using the `langchain-mongodb` package.

> [MongoDB Atlas](https://www.mongodb.com/docs/atlas/) is a fully-managed cloud database available in AWS, Azure, and GCP.  It supports native Vector Search and full text search (BM25) on your MongoDB document data.

> [MongoDB Atlas Vector Search](https://www.mongodb.com/products/platform/atlas-vector-search) allows to store your embeddings in MongoDB documents, create a vector search index, and perform KNN search with an approximate nearest neighbor algorithm (`Hierarchical Navigable Small Worlds`). It uses the [$vectorSearch MQL Stage](https://www.mongodb.com/docs/atlas/atlas-vector-search/vector-search-overview/). 

## Setup

> *An Atlas cluster running MongoDB version 6.0.11, 7.0.2, or later (including RCs).

To use MongoDB Atlas, you must first deploy a cluster. We have a Forever-Free tier of clusters available. To get started head over to Atlas here: [quick start](https://www.mongodb.com/docs/atlas/getting-started/).

You'll need to install `langchain-mongodb` and `pymongo` to use this integration.

```python
pip install -qU langchain-mongodb pymongo
```

### Credentials

For this notebook you will need to find your MongoDB cluster URI.

For information on finding your cluster URI read through [this guide](https://www.mongodb.com/docs/manual/reference/connection-string/).

```python
import getpass

MONGODB_ATLAS_CLUSTER_URI = getpass.getpass("MongoDB Atlas Cluster URI:")
```

If you want to get best in-class automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

## Initialization

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>


```python
<!--IMPORTS:[{"imported": "MongoDBAtlasVectorSearch", "source": "langchain_mongodb.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_mongodb.vectorstores.MongoDBAtlasVectorSearch.html", "title": "MongoDB Atlas"}]-->
from langchain_mongodb.vectorstores import MongoDBAtlasVectorSearch
from pymongo import MongoClient

# initialize MongoDB python client
client = MongoClient(MONGODB_ATLAS_CLUSTER_URI)

DB_NAME = "langchain_test_db"
COLLECTION_NAME = "langchain_test_vectorstores"
ATLAS_VECTOR_SEARCH_INDEX_NAME = "langchain-test-index-vectorstores"

MONGODB_COLLECTION = client[DB_NAME][COLLECTION_NAME]

vector_store = MongoDBAtlasVectorSearch(
    collection=MONGODB_COLLECTION,
    embedding=embeddings,
    index_name=ATLAS_VECTOR_SEARCH_INDEX_NAME,
    relevance_score_fn="cosine",
)
```

## Manage vector store

Once you have created your vector store, we can interact with it by adding and deleting different items.

### Add items to vector store

We can add items to our vector store by using the `add_documents` function.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "MongoDB Atlas"}]-->
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
['03ad81e8-32a0-46f0-b7d8-f5b977a6b52a',
 '8396a68d-f4a3-4176-a581-a1a8c303eea4',
 'e7d95150-67f6-499f-b611-84367c50fa60',
 '8c31b84e-2636-48b6-8b99-9fccb47f7051',
 'aa02e8a2-a811-446a-9785-8cea0faba7a9',
 '19bd72ff-9766-4c3b-b1fd-195c732c562b',
 '642d6f2f-3e34-4efa-a1ed-c4ba4ef0da8d',
 '7614bb54-4eb5-4b3b-990c-00e35cb31f99',
 '69e18c67-bf1b-43e5-8a6e-64fb3f240e52',
 '30d599a7-4a1a-47a9-bbf8-6ed393e2e33c']
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

#### Similarity search

Performing a simple similarity search can be done as follows:

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy", k=2
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```
```output
* Building an exciting new project with LangChain - come check it out! [{'_id': 'e7d95150-67f6-499f-b611-84367c50fa60', 'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'_id': '7614bb54-4eb5-4b3b-990c-00e35cb31f99', 'source': 'tweet'}]
```
#### Similarity search with score

You can also search with score:

```python
results = vector_store.similarity_search_with_score("Will it be hot tomorrow?", k=1)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```
```output
* [SIM=0.784560] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'_id': '8396a68d-f4a3-4176-a581-a1a8c303eea4', 'source': 'news'}]
```
### Pre-filtering with Similarity Search

Atlas Vector Search supports pre-filtering using MQL Operators for filtering.  Below is an example index and query on the same data loaded above that allows you do metadata filtering on the "page" field.  You can update your existing index with the filter defined and do pre-filtering with vector search.

```json
{
  "fields":[
    {
      "type": "vector",
      "path": "embedding",
      "numDimensions": 1536,
      "similarity": "cosine"
    },
    {
      "type": "filter",
      "path": "source"
    }
  ]
}
```

You can also update the index programmatically using the `MongoDBAtlasVectorSearch.create_index` method.

```python
vectorstore.create_index(
  dimensions=1536,
  filters=[{"type":"filter", "path":"source"}],
  update=True
)
```

And then you can run a query with filter as follows:

```python
results = vector_store.similarity_search(query="foo",k=1,pre_filter={"source": {"$eq": "https://example.com"}})
for doc in results:
    print(f"* {doc.page_content} [{doc.metadata}]")
```

#### Other search methods

There are a variety of other search methods that are not covered in this notebook, such as MMR search or searching by vector. For a full list of the search abilities available for `AstraDBVectorStore` check out the [API reference](https://api.python.langchain.com/en/latest/vectorstores/langchain_astradb.vectorstores.AstraDBVectorStore.html).

### Query by turning into retriever

You can also transform the vector store into a retriever for easier usage in your chains. 

Here is how to transform your vector store into a retriever and then invoke the retreiever with a simple query and filter.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.2},
)
retriever.invoke("Stealing from the bank is a crime")
```

```output
[Document(metadata={'_id': '8c31b84e-2636-48b6-8b99-9fccb47f7051', 'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```

## Usage for retrieval-augmented generation

For guides on how to use this vector store for retrieval-augmented generation (RAG), see the following sections:

- [Tutorials: working with external knowledge](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [How-to: Question and answer with RAG](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [Retrieval conceptual docs](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

# Other Notes
> * More documentation can be found at [LangChain-MongoDB](https://www.mongodb.com/docs/atlas/atlas-vector-search/ai-integrations/langchain/) site
> * This feature is Generally Available and ready for production deployments.
> * The langchain version 0.0.305 ([release notes](https://github.com/langchain-ai/langchain/releases/tag/v0.0.305)) introduces the support for $vectorSearch MQL stage, which is available with MongoDB Atlas 6.0.11 and 7.0.2. Users utilizing earlier versions of MongoDB Atlas need to pin their LangChain version to <=0.0.304
> 

## API reference

For detailed documentation of all `MongoDBAtlasVectorSearch` features and configurations head to the API reference: https://api.python.langchain.com/en/latest/mongodb_api_reference.html

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)