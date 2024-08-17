---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/couchbase/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/couchbase.ipynb
---

# Couchbase 
[Couchbase](http://couchbase.com/) is an award-winning distributed NoSQL cloud database that delivers unmatched versatility, performance, scalability, and financial value for all of your cloud, mobile, AI, and edge computing applications. Couchbase embraces AI with coding assistance for developers and vector search for their applications.

Vector Search is a part of the [Full Text Search Service](https://docs.couchbase.com/server/current/learn/services-and-indexes/services/search-service.html) (Search Service) in Couchbase.

This tutorial explains how to use Vector Search in Couchbase. You can work with either [Couchbase Capella](https://www.couchbase.com/products/capella/) and your self-managed Couchbase Server.

## Setup

To access the `CouchbaseVectorStore` you first need to install the `langchain-couchbase` partner package:


```python
pip install -qU langchain-couchbase
```

### Credentials

Head over to the Couchbase [website](https://cloud.couchbase.com) and create a new connection, making sure to save your database username and password:


```python
import getpass

COUCHBASE_CONNECTION_STRING = getpass.getpass(
    "Enter the connection string for the Couchbase cluster: "
)
DB_USERNAME = getpass.getpass("Enter the username for the Couchbase cluster: ")
DB_PASSWORD = getpass.getpass("Enter the password for the Couchbase cluster: ")
```

If you want to get best in-class automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:


```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```

## Initialization

Before instantiating we need to create a connection.

### Create Couchbase Connection Object

We create a connection to the Couchbase cluster initially and then pass the cluster object to the Vector Store. 

Here, we are connecting using the username and password from above. You can also connect using any other supported way to your cluster. 

For more information on connecting to the Couchbase cluster, please check the [documentation](https://docs.couchbase.com/python-sdk/current/hello-world/start-using-sdk.html#connect).


```python
from datetime import timedelta

from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions

auth = PasswordAuthenticator(DB_USERNAME, DB_PASSWORD)
options = ClusterOptions(auth)
cluster = Cluster(COUCHBASE_CONNECTION_STRING, options)

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))
```

We will now set the bucket, scope, and collection names in the Couchbase cluster that we want to use for Vector Search. 

For this example, we are using the default scope & collections.


```python
BUCKET_NAME = "langchain_bucket"
SCOPE_NAME = "_default"
COLLECTION_NAME = "default"
SEARCH_INDEX_NAME = "langchain-test-index"
```

For details on how to create a Search index with support for Vector fields, please refer to the documentation.

- [Couchbase Capella](https://docs.couchbase.com/cloud/vector-search/create-vector-search-index-ui.html)
  
- [Couchbase Server](https://docs.couchbase.com/server/current/vector-search/create-vector-search-index-ui.html)

### Simple Instantiation

Below, we create the vector store object with the cluster information and the search index name. 

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>


```python
from langchain_couchbase.vectorstores import CouchbaseVectorStore

vector_store = CouchbaseVectorStore(
    cluster=cluster,
    bucket_name=BUCKET_NAME,
    scope_name=SCOPE_NAME,
    collection_name=COLLECTION_NAME,
    embedding=embeddings,
    index_name=SEARCH_INDEX_NAME,
)
```

### Specify the Text & Embeddings Field

You can optionally specify the text & embeddings field for the document using the `text_key` and `embedding_key` fields.


```python
vector_store_specific = CouchbaseVectorStore(
    cluster=cluster,
    bucket_name=BUCKET_NAME,
    scope_name=SCOPE_NAME,
    collection_name=COLLECTION_NAME,
    embedding=embeddings,
    index_name=SEARCH_INDEX_NAME,
    text_key="text",
    embedding_key="embedding",
)
```

## Manage vector store

Once you have created your vector store, we can interact with it by adding and deleting different items.

### Add items to vector store

We can add items to our vector store by using the `add_documents` function.


```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Couchbase "}]-->
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

### Delete items from vector store


```python
vector_store.delete(ids=[uuids[-1]])
```

## Query vector store

Once your vector store has been created and the relevant documents have been added you will most likely wish to query it during the running of your chain or agent.

### Query directly

#### Similarity search

Performing a simple similarity search can be done as follows:


```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy",
    k=2,
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

#### Similarity search with Score

You can also fetch the scores for the results by calling the `similarity_search_with_score` method.


```python
results = vector_store.similarity_search_with_score("Will it be hot tomorrow?", k=1)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

### Specifying Fields to Return

You can specify the fields to return from the document using `fields` parameter in the searches. These fields are returned as part of the `metadata` object in the returned Document. You can fetch any field that is stored in the Search index. The `text_key` of the document is returned as part of the document's `page_content`.

If you do not specify any fields to be fetched, all the fields stored in the index are returned.

If you want to fetch one of the fields in the metadata, you need to specify it using `.`

For example, to fetch the `source` field in the metadata, you need to specify `metadata.source`.



```python
query = "What did I eat for breakfast today?"
results = vector_store.similarity_search(query, fields=["metadata.source"])
print(results[0])
```

### Hybrid Queries

Couchbase allows you to do hybrid searches by combining Vector Search results with searches on non-vector fields of the document like the `metadata` object. 

The results will be based on the combination of the results from both Vector Search and the searches supported by Search Service. The scores of each of the component searches are added up to get the total score of the result.

To perform hybrid searches, there is an optional parameter, `search_options` that can be passed to all the similarity searches.  
The different search/query possibilities for the `search_options` can be found [here](https://docs.couchbase.com/server/current/search/search-request-params.html#query-object).

#### Create Diverse Metadata for Hybrid Search
In order to simulate hybrid search, let us create some random metadata from the existing documents. 
We uniformly add three fields to the metadata, `date` between 2010 & 2020, `rating` between 1 & 5 and `author` set to either John Doe or Jane Doe. 


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Couchbase "}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Couchbase "}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

# Adding metadata to documents
for i, doc in enumerate(docs):
    doc.metadata["date"] = f"{range(2010, 2020)[i % 10]}-01-01"
    doc.metadata["rating"] = range(1, 6)[i % 5]
    doc.metadata["author"] = ["John Doe", "Jane Doe"][i % 2]

vector_store.add_documents(docs)

query = "What did the president say about Ketanji Brown Jackson"
results = vector_store.similarity_search(query)
print(results[0].metadata)
```

### Query by Exact Value
We can search for exact matches on a textual field like the author in the `metadata` object.


```python
query = "What did the president say about Ketanji Brown Jackson"
results = vector_store.similarity_search(
    query,
    search_options={"query": {"field": "metadata.author", "match": "John Doe"}},
    fields=["metadata.author"],
)
print(results[0])
```

### Query by Partial Match
We can search for partial matches by specifying a fuzziness for the search. This is useful when you want to search for slight variations or misspellings of a search query.

Here, "Jae" is close (fuzziness of 1) to "Jane".


```python
query = "What did the president say about Ketanji Brown Jackson"
results = vector_store.similarity_search(
    query,
    search_options={
        "query": {"field": "metadata.author", "match": "Jae", "fuzziness": 1}
    },
    fields=["metadata.author"],
)
print(results[0])
```

### Query by Date Range Query
We can search for documents that are within a date range query on a date field like `metadata.date`.


```python
query = "Any mention about independence?"
results = vector_store.similarity_search(
    query,
    search_options={
        "query": {
            "start": "2016-12-31",
            "end": "2017-01-02",
            "inclusive_start": True,
            "inclusive_end": False,
            "field": "metadata.date",
        }
    },
)
print(results[0])
```

### Query by Numeric Range Query
We can search for documents that are within a range for a numeric field like `metadata.rating`.


```python
query = "Any mention about independence?"
results = vector_store.similarity_search_with_score(
    query,
    search_options={
        "query": {
            "min": 3,
            "max": 5,
            "inclusive_min": True,
            "inclusive_max": True,
            "field": "metadata.rating",
        }
    },
)
print(results[0])
```

### Combining Multiple Search Queries
Different search queries can be combined using AND (conjuncts) or OR (disjuncts) operators.

In this example, we are checking for documents with a rating between 3 & 4 and dated between 2015 & 2018.


```python
query = "Any mention about independence?"
results = vector_store.similarity_search_with_score(
    query,
    search_options={
        "query": {
            "conjuncts": [
                {"min": 3, "max": 4, "inclusive_max": True, "field": "metadata.rating"},
                {"start": "2016-12-31", "end": "2017-01-02", "field": "metadata.date"},
            ]
        }
    },
)
print(results[0])
```

### Other Queries
Similarly, you can use any of the supported Query methods like Geo Distance, Polygon Search, Wildcard, Regular Expressions, etc in the `search_options` parameter. Please refer to the documentation for more details on the available query methods and their syntax.

- [Couchbase Capella](https://docs.couchbase.com/cloud/search/search-request-params.html#query-object)
- [Couchbase Server](https://docs.couchbase.com/server/current/search/search-request-params.html#query-object)

### Query by turning into retriever

You can also transform the vector store into a retriever for easier usage in your chains. 

Here is how to transform your vector store into a retriever and then invoke the retreiever with a simple query and filter.


```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.5},
)
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```

## Usage for retrieval-augmented generation

For guides on how to use this vector store for retrieval-augmented generation (RAG), see the following sections:

- [Tutorials: working with external knowledge](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [How-to: Question and answer with RAG](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [Retrieval conceptual docs](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

# Frequently Asked Questions

## Question: Should I create the Search index before creating the CouchbaseVectorStore object?
Yes, currently you need to create the Search index before creating the `CouchbaseVectoreStore` object.


## Question: I am not seeing all the fields that I specified in my search results. 

In Couchbase, we can only return the fields stored in the Search index. Please ensure that the field that you are trying to access in the search results is part of the Search index.

One way to handle this is to index and store a document's fields dynamically in the index. 

- In Capella, you need to go to "Advanced Mode" then under the chevron "General Settings" you can check "[X] Store Dynamic Fields" or "[X] Index Dynamic Fields"
- In Couchbase Server, in the Index Editor (not Quick Editor) under the chevron  "Advanced" you can check "[X] Store Dynamic Fields" or "[X] Index Dynamic Fields"

Note that these options will increase the size of the index.

For more details on dynamic mappings, please refer to the [documentation](https://docs.couchbase.com/cloud/search/customize-index.html).


## Question: I am unable to see the metadata object in my search results. 
This is most likely due to the `metadata` field in the document not being indexed and/or stored by the Couchbase Search index. In order to index the `metadata` field in the document, you need to add it to the index as a child mapping. 

If you select to map all the fields in the mapping, you will be able to search by all metadata fields. Alternatively, to optimize the index, you can select the specific fields inside `metadata` object to be indexed. You can refer to the [docs](https://docs.couchbase.com/cloud/search/customize-index.html) to learn more about indexing child mappings.

Creating Child Mappings

* [Couchbase Capella](https://docs.couchbase.com/cloud/search/create-child-mapping.html)
* [Couchbase Server](https://docs.couchbase.com/server/current/search/create-child-mapping.html)

## API reference

For detailed documentation of all `CouchbaseVectorStore` features and configurations head to the API reference: https://api.python.langchain.com/en/latest/vectorstores/langchain_couchbase.vectorstores.CouchbaseVectorStore.html


## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)