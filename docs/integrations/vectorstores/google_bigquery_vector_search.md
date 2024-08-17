---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/google_bigquery_vector_search/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/google_bigquery_vector_search.ipynb
---

# Google BigQuery Vector Search

> [Google Cloud BigQuery Vector Search](https://cloud.google.com/bigquery/docs/vector-search-intro) lets you use GoogleSQL to do semantic search, using vector indexes for fast approximate results, or using brute force for exact results. 

This tutorial illustrates how to work with an end-to-end data and embedding management system in LangChain, and provides a scalable semantic search in BigQuery using the`BigQueryVectorStore` class. This class is part of a set of 2 classes capable of providing a unified data storage and flexible vector search in Google Cloud:
- **BigQuery Vector Search**: with `BigQueryVectorStore` class, which is ideal for rapid prototyping with no infrastructure setup and batch retrieval.
- **Feature Store Online Store**: with `VertexFSVectorStore` class, enables low-latency retrieval with manual or scheduled data sync. Perfect for production-ready user-facing GenAI applications.

![Diagram BQ-VertexFS](/img/d02d482be891fa79a6d59d218105e02e.png)

## Getting started

### Install the library

```python
%pip install --upgrade --quiet  langchain langchain-google-vertexai "langchain-google-community[featurestore]"
```

To use the newly installed packages in this Jupyter runtime, you must restart the runtime. You can do this by running the cell below, which restarts the current kernel.

```python
import IPython

app = IPython.Application.instance()
app.kernel.do_shutdown(True)
```

## Before you begin

#### Set your project ID

If you don't know your project ID, try the following:
* Run `gcloud config list`.
* Run `gcloud projects list`.
* See the support page: [Locate the project ID](https://support.google.com/googleapi/answer/7014113).

```python
PROJECT_ID = ""  # @param {type:"string"}

# Set the project id
! gcloud config set project {PROJECT_ID}
```

#### Set the region

You can also change the `REGION` variable used by BigQuery. Learn more about [BigQuery regions](https://cloud.google.com/bigquery/docs/locations#supported_locations).

```python
REGION = "us-central1"  # @param {type: "string"}
```

#### Set the dataset and table names

They will be your BigQuery Vector Store.

```python
DATASET = "my_langchain_dataset"  # @param {type: "string"}
TABLE = "doc_and_vectors"  # @param {type: "string"}
```

### Authenticating your notebook environment

- If you are using **Colab** to run this notebook, uncomment the cell below and continue.
- If you are using **Vertex AI Workbench**, check out the setup instructions [here](https://github.com/GoogleCloudPlatform/generative-ai/tree/main/setup-env).

```python
# from google.colab import auth as google_auth

# google_auth.authenticate_user()
```

## Demo: BigQueryVectorStore

### Create an embedding class instance

You may need to enable Vertex AI API in your project by running
`gcloud services enable aiplatform.googleapis.com --project {PROJECT_ID}`
(replace `{PROJECT_ID}` with the name of your project).

You can use any [LangChain embeddings model](/docs/integrations/text_embedding/).

```python
from langchain_google_vertexai import VertexAIEmbeddings

embedding = VertexAIEmbeddings(
    model_name="textembedding-gecko@latest", project=PROJECT_ID
)
```

### Initialize BigQueryVectorStore

BigQuery Dataset and Table will be automatically created if they do not exist. See class definition [here](https://github.com/langchain-ai/langchain-google/blob/main/libs/community/langchain_google_community/bq_storage_vectorstores/bigquery.py#L26) for all optional paremeters.

```python
from langchain_google_community import BigQueryVectorStore

store = BigQueryVectorStore(
    project_id=PROJECT_ID,
    dataset_name=DATASET,
    table_name=TABLE,
    location=REGION,
    embedding=embedding,
)
```

### Add texts

```python
all_texts = ["Apples and oranges", "Cars and airplanes", "Pineapple", "Train", "Banana"]
metadatas = [{"len": len(t)} for t in all_texts]

store.add_texts(all_texts, metadatas=metadatas)
```

### Search for documents

```python
query = "I'd like a fruit."
docs = store.similarity_search(query)
print(docs)
```

### Search for documents by vector

```python
query_vector = embedding.embed_query(query)
docs = store.similarity_search_by_vector(query_vector, k=2)
print(docs)
```

### Search for documents with metadata filter

```python
# This should only return "Banana" document.
docs = store.similarity_search_by_vector(query_vector, filter={"len": 6})
print(docs)
```

### Batch search
BigQueryVectorStore offers a `batch_search` method for scalable Vector similarity search.

```python
results = store.batch_search(
    embeddings=None,  # can pass embeddings or
    queries=["search_query", "search_query"],  # can pass queries
)
```

### Add text with embeddings

You can also bring your own embeddings with the `add_texts_with_embeddings` method.
This is particularly useful for multimodal data which might require custom preprocessing before the embedding generation.

```python
items = ["some text"]
embs = embedding.embed(items)

ids = store.add_texts_with_embeddings(
    texts=["some text"], embs=embs, metadatas=[{"len": 1}]
)
```

### Low-latency serving with Feature Store
You can simply use the method `.to_vertex_fs_vector_store()` to get a VertexFSVectorStore object, which offers low latency for online use cases. All mandatory parameters will be automatically transferred from the existing BigQueryVectorStore class. See the [class definition](https://github.com/langchain-ai/langchain-google/blob/main/libs/community/langchain_google_community/bq_storage_vectorstores/featurestore.py#L33) for all the other parameters you can use.

Moving back to BigQueryVectorStore is equivalently easy with the `.to_bq_vector_store()` method.

```python
store.to_vertex_fs_vector_store()  # pass optional VertexFSVectorStore parameters as arguments
```

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)