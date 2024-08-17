---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/elasticsearch/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/elasticsearch.ipynb
---

# Elasticsearch

>[Elasticsearch](https://www.elastic.co/elasticsearch/) is a distributed, RESTful search and analytics engine, capable of performing both vector and lexical search. It is built on top of the Apache Lucene library. 

This notebook shows how to use functionality related to the `Elasticsearch` vector store.

## Setup

In order to use the `Elasticsearch` vector search you must install the `langchain-elasticsearch` package.


```python
%pip install -qU langchain-elasticsearch
```

### Credentials

There are two main ways to setup an Elasticsearch instance for use with:

1. Elastic Cloud: Elastic Cloud is a managed Elasticsearch service. Signup for a [free trial](https://cloud.elastic.co/registration?utm_source=langchain&utm_content=documentation).

To connect to an Elasticsearch instance that does not require
login credentials (starting the docker instance with security enabled), pass the Elasticsearch URL and index name along with the
embedding object to the constructor.

2. Local Install Elasticsearch: Get started with Elasticsearch by running it locally. The easiest way is to use the official Elasticsearch Docker image. See the [Elasticsearch Docker documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) for more information.


### Running Elasticsearch via Docker 
Example: Run a single-node Elasticsearch instance with security disabled. This is not recommended for production use.


```python
%docker run -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" -e "xpack.security.http.ssl.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.12.1
```


### Running with Authentication
For production, we recommend you run with security enabled. To connect with login credentials, you can use the parameters `es_api_key` or `es_user` and `es_password`.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>


```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}]-->
from langchain_elasticsearch import ElasticsearchStore

elastic_vector_search = ElasticsearchStore(
    es_url="http://localhost:9200",
    index_name="langchain_index",
    embedding=embeddings,
    es_user="elastic",
    es_password="changeme",
)
```

#### How to obtain a password for the default "elastic" user?

To obtain your Elastic Cloud password for the default "elastic" user:
1. Log in to the Elastic Cloud console at https://cloud.elastic.co
2. Go to "Security" > "Users"
3. Locate the "elastic" user and click "Edit"
4. Click "Reset password"
5. Follow the prompts to reset the password

#### How to obtain an API key?

To obtain an API key:
1. Log in to the Elastic Cloud console at https://cloud.elastic.co
2. Open Kibana and go to Stack Management > API Keys
3. Click "Create API key"
4. Enter a name for the API key and click "Create"
5. Copy the API key and paste it into the `api_key` parameter

### Elastic Cloud

To connect to an Elasticsearch instance on Elastic Cloud, you can use either the `es_cloud_id` parameter or `es_url`.


```python
elastic_vector_search = ElasticsearchStore(
    es_cloud_id="<cloud_id>",
    index_name="test_index",
    embedding=embeddings,
    es_user="elastic",
    es_password="changeme",
)
```

If you want to get best in-class automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:


```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

## Initialization

Elasticsearch is running locally on localhost:9200 with [docker](#running-elasticsearch-via-docker). For more details on how to connect to Elasticsearch from Elastic Cloud, see [connecting with authentication](#running-with-authentication) above.



```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}]-->
from langchain_elasticsearch import ElasticsearchStore

vector_store = ElasticsearchStore(
    "langchain-demo", embedding=embeddings, es_url="http://localhost:9201"
)
```

## Manage vector store

### Add items to vector store


```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Elasticsearch"}]-->
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
['21cca03c-9089-42d2-b41c-3d156be2b519',
 'a6ceb967-b552-4802-bb06-c0e95fce386e',
 '3a35fac4-e5f0-493b-bee0-9143b41aedae',
 '176da099-66b1-4d6a-811b-dfdfe0808d30',
 'ecfa1a30-3c97-408b-80c0-5c43d68bf5ff',
 'c0f08baa-e70b-4f83-b387-c6e0a0f36f73',
 '489b2c9c-1925-43e1-bcf0-0fa94cf1cbc4',
 '408c6503-9ba4-49fd-b1cc-95584cd914c5',
 '5248c899-16d5-4377-a9e9-736ca443ad4f',
 'ca182769-c4fc-4e25-8f0a-8dd0a525955c']
```


### Delete items from vector store


```python
vector_store.delete(ids=[uuids[-1]])
```



```output
True
```


## Query vector store

Once your vector store has been created and the relevant documents have been added you will most likely wish to query it during the running of your chain or agent. These examples also show how to use filtering when searching.

### Query directly

#### Similarity search

Performing a simple similarity search with filtering on metadata can be done as follows:


```python
results = vector_store.similarity_search(
    query="LangChain provides abstractions to make working with LLMs easy",
    k=2,
    filter=[{"term": {"metadata.source.keyword": "tweet"}}],
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```
```output
* Building an exciting new project with LangChain - come check it out! [{'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'source': 'tweet'}]
```
#### Similarity search with score

If you want to execute a similarity search and receive the corresponding scores you can run:


```python
results = vector_store.similarity_search_with_score(
    query="Will it be hot tomorrow",
    k=1,
    filter=[{"term": {"metadata.source.keyword": "news"}}],
)
for doc, score in results:
    print(f"* [SIM={score:3f}] {doc.page_content} [{doc.metadata}]")
```
```output
* [SIM=0.765887] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news'}]
```
### Query by turning into retriever

You can also transform the vector store into a retriever for easier usage in your chains. 


```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold", search_kwargs={"score_threshold": 0.2}
)
retriever.invoke("Stealing from the bank is a crime")
```



```output
[Document(metadata={'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.'),
 Document(metadata={'source': 'news'}, page_content='The stock market is down 500 points today due to fears of a recession.'),
 Document(metadata={'source': 'website'}, page_content='Is the new iPhone worth the price? Read this review to find out.'),
 Document(metadata={'source': 'tweet'}, page_content='Building an exciting new project with LangChain - come check it out!')]
```


## Usage for retrieval-augmented generation

For guides on how to use this vector store for retrieval-augmented generation (RAG), see the following sections:

- [Tutorials: working with external knowledge](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [How-to: Question and answer with RAG](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [Retrieval conceptual docs](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

# FAQ

## Question: Im getting timeout errors when indexing documents into Elasticsearch. How do I fix this?
One possible issue is your documents might take longer to index into Elasticsearch. ElasticsearchStore uses the Elasticsearch bulk API which has a few defaults that you can adjust to reduce the chance of timeout errors.

This is also a good idea when you're using SparseVectorRetrievalStrategy.

The defaults are:
- `chunk_size`: 500
- `max_chunk_bytes`: 100MB

To adjust these, you can pass in the `chunk_size` and `max_chunk_bytes` parameters to the ElasticsearchStore `add_texts` method.

```python
    vector_store.add_texts(
        texts,
        bulk_kwargs={
            "chunk_size": 50,
            "max_chunk_bytes": 200000000
        }
    )
```

# Upgrading to ElasticsearchStore

If you're already using Elasticsearch in your langchain based project, you may be using the old implementations: `ElasticVectorSearch` and `ElasticKNNSearch` which are now deprecated. We've introduced a new implementation called `ElasticsearchStore` which is more flexible and easier to use. This notebook will guide you through the process of upgrading to the new implementation.

## What's new?

The new implementation is now one class called `ElasticsearchStore` which can be used for approximate dense vector, exact dense vector, sparse vector (ELSER), BM25 retrieval and hybrid retrieval, via strategies.

## I am using ElasticKNNSearch

Old implementation:

```python

from langchain_community.vectorstores.elastic_vector_search import ElasticKNNSearch

db = ElasticKNNSearch(
  elasticsearch_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding
)

```

New implementation:

```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}, {"imported": "DenseVectorStrategy", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/helpers/elasticsearch.helpers.vectorstore._sync.strategies.DenseVectorStrategy.html", "title": "Elasticsearch"}]-->

from langchain_elasticsearch import ElasticsearchStore, DenseVectorStrategy

db = ElasticsearchStore(
  es_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding,
  # if you use the model_id
  # strategy=DenseVectorStrategy(model_id="test_model")
  # if you use hybrid search
  # strategy=DenseVectorStrategy(hybrid=True)
)

```

## I am using ElasticVectorSearch

Old implementation:

```python
<!--IMPORTS:[{"imported": "ElasticVectorSearch", "source": "langchain_community.vectorstores.elastic_vector_search", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.elastic_vector_search.ElasticVectorSearch.html", "title": "Elasticsearch"}]-->

from langchain_community.vectorstores.elastic_vector_search import ElasticVectorSearch

db = ElasticVectorSearch(
  elasticsearch_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding
)

```

New implementation:

```python
<!--IMPORTS:[{"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "Elasticsearch"}, {"imported": "DenseVectorScriptScoreStrategy", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/helpers/elasticsearch.helpers.vectorstore._sync.strategies.DenseVectorScriptScoreStrategy.html", "title": "Elasticsearch"}]-->

from langchain_elasticsearch import ElasticsearchStore, DenseVectorScriptScoreStrategy

db = ElasticsearchStore(
  es_url="http://localhost:9200",
  index_name="test_index",
  embedding=embedding,
  strategy=DenseVectorScriptScoreStrategy()
)

```

```python
db.client.indices.delete(
    index="test-metadata, test-elser, test-basic",
    ignore_unavailable=True,
    allow_no_indices=True,
)
```

## API reference

For detailed documentation of all `ElasticSearchStore` features and configurations head to the API reference: https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html


## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)