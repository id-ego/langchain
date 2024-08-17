---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/pgembedding/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/pgembedding.ipynb
---

# Postgres Embedding

> [Postgres Embedding](https://github.com/neondatabase/pg_embedding) is an open-source vector similarity search for `Postgres` that uses  `Hierarchical Navigable Small Worlds (HNSW)` for approximate nearest neighbor search.

> It supports:
> - exact and approximate nearest neighbor search using HNSW
> - L2 distance

This notebook shows how to use the Postgres vector database (`PGEmbedding`).

> The PGEmbedding integration creates the pg_embedding extension for you, but you run the following Postgres query to add it:
```sql
CREATE EXTENSION embedding;
```

```python
# Pip install necessary package
%pip install --upgrade --quiet  langchain-openai langchain-community
%pip install --upgrade --quiet  psycopg2-binary
%pip install --upgrade --quiet  tiktoken
```

Add the OpenAI API Key to the environment variables to use `OpenAIEmbeddings`.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```
```output
OpenAI API Key:········
```

```python
## Loading Environment Variables
from typing import List, Tuple
```

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Postgres Embedding"}, {"imported": "PGEmbedding", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.pgembedding.PGEmbedding.html", "title": "Postgres Embedding"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Postgres Embedding"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Postgres Embedding"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Postgres Embedding"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import PGEmbedding
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```

```python
os.environ["DATABASE_URL"] = getpass.getpass("Database Url:")
```
```output
Database Url:········
```

```python
loader = TextLoader("state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
connection_string = os.environ.get("DATABASE_URL")
collection_name = "state_of_the_union"
```

```python
db = PGEmbedding.from_documents(
    embedding=embeddings,
    documents=docs,
    collection_name=collection_name,
    connection_string=connection_string,
)

query = "What did the president say about Ketanji Brown Jackson"
docs_with_score: List[Tuple[Document, float]] = db.similarity_search_with_score(query)
```

```python
for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print(doc.page_content)
    print("-" * 80)
```

## Working with vectorstore in Postgres

### Uploading a vectorstore in PG

```python
db = PGEmbedding.from_documents(
    embedding=embeddings,
    documents=docs,
    collection_name=collection_name,
    connection_string=connection_string,
    pre_delete_collection=False,
)
```

### Create HNSW Index
By default, the extension performs a sequential scan search, with 100% recall. You might consider creating an HNSW index for approximate nearest neighbor (ANN) search to speed up `similarity_search_with_score` execution time. To create the HNSW index on your vector column, use a `create_hnsw_index` function:

```python
PGEmbedding.create_hnsw_index(
    max_elements=10000, dims=1536, m=8, ef_construction=16, ef_search=16
)
```

The function above is equivalent to running the below SQL query:
```sql
CREATE INDEX ON vectors USING hnsw(vec) WITH (maxelements=10000, dims=1536, m=3, efconstruction=16, efsearch=16);
```
The HNSW index options used in the statement above include:

- maxelements: Defines the maximum number of elements indexed. This is a required parameter. The example shown above has a value of 3. A real-world example would have a much large value, such as 1000000. An "element" refers to a data point (a vector) in the dataset, which is represented as a node in the HNSW graph. Typically, you would set this option to a value able to accommodate the number of rows in your in your dataset.
- dims: Defines the number of dimensions in your vector data. This is a required parameter. A small value is used in the example above. If you are storing data generated using OpenAI's text-embedding-ada-002 model, which supports 1536 dimensions, you would define a value of 1536, for example.
- m: Defines the maximum number of bi-directional links (also referred to as "edges") created for each node during graph construction.
The following additional index options are supported:
- efConstruction: Defines the number of nearest neighbors considered during index construction. The default value is 32.
- efsearch: Defines the number of nearest neighbors considered during index search. The default value is 32.
For information about how you can configure these options to influence the HNSW algorithm, refer to [Tuning the HNSW algorithm](https://neon.tech/docs/extensions/pg_embedding#tuning-the-hnsw-algorithm).

### Retrieving a vectorstore in PG

```python
store = PGEmbedding(
    connection_string=connection_string,
    embedding_function=embeddings,
    collection_name=collection_name,
)

retriever = store.as_retriever()
```

```python
retriever
```

```output
VectorStoreRetriever(vectorstore=<langchain_community.vectorstores.pghnsw.HNSWVectoreStore object at 0x121d3c8b0>, search_type='similarity', search_kwargs={})
```

```python
db1 = PGEmbedding.from_existing_index(
    embedding=embeddings,
    collection_name=collection_name,
    pre_delete_collection=False,
    connection_string=connection_string,
)

query = "What did the president say about Ketanji Brown Jackson"
docs_with_score: List[Tuple[Document, float]] = db1.similarity_search_with_score(query)
```

```python
for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print(doc.page_content)
    print("-" * 80)
```

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)