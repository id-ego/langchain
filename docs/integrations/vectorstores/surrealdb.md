---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/surrealdb/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/surrealdb.ipynb
---

# SurrealDB

> [SurrealDB](https://surrealdb.com/) is an end-to-end cloud-native database designed for modern applications, including web, mobile, serverless, Jamstack, backend, and traditional applications. With SurrealDB, you can simplify your database and API infrastructure, reduce development time, and build secure, performant apps quickly and cost-effectively.
> 
> **Key features of SurrealDB include:**
> 
> * **Reduces development time:** SurrealDB simplifies your database and API stack by removing the need for most server-side components, allowing you to build secure, performant apps faster and cheaper.
> * **Real-time collaborative API backend service:** SurrealDB functions as both a database and an API backend service, enabling real-time collaboration.
> * **Support for multiple querying languages:** SurrealDB supports SQL querying from client devices, GraphQL, ACID transactions, WebSocket connections, structured and unstructured data, graph querying, full-text indexing, and geospatial querying.
> * **Granular access control:** SurrealDB provides row-level permissions-based access control, giving you the ability to manage data access with precision.
> 
> View the [features](https://surrealdb.com/features), the latest [releases](https://surrealdb.com/releases), and [documentation](https://surrealdb.com/docs).

This notebook shows how to use functionality related to the `SurrealDBStore`.

## Setup

Uncomment the below cells to install surrealdb.

```python
# %pip install --upgrade --quiet  surrealdb langchain langchain-community
```

## Using SurrealDBStore

```python
# add this import for running in jupyter notebook
import nest_asyncio

nest_asyncio.apply()
```

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SurrealDB"}, {"imported": "SurrealDBStore", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.surrealdb.SurrealDBStore.html", "title": "SurrealDB"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "SurrealDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SurrealDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import SurrealDBStore
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```

```python
documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = HuggingFaceEmbeddings()
```

### Creating a SurrealDBStore object

```python
db = SurrealDBStore(
    dburl="ws://localhost:8000/rpc",  # url for the hosted SurrealDB database
    embedding_function=embeddings,
    db_user="root",  # SurrealDB credentials if needed: db username
    db_pass="root",  # SurrealDB credentials if needed: db password
    # ns="langchain", # namespace to use for vectorstore
    # db="database",  # database to use for vectorstore
    # collection="documents", #collection to use for vectorstore
)

# this is needed to initialize the underlying async library for SurrealDB
await db.initialize()

# delete all existing documents from the vectorstore collection
await db.adelete()

# add documents to the vectorstore
ids = await db.aadd_documents(docs)

# document ids of the added documents
ids[:5]
```

```output
['documents:38hz49bv1p58f5lrvrdc',
 'documents:niayw63vzwm2vcbh6w2s',
 'documents:it1fa3ktplbuye43n0ch',
 'documents:il8f7vgbbp9tywmsn98c',
 'documents:vza4c6cqje0avqd58gal']
```

### (alternatively) Create a SurrealDBStore object and add documents

```python
await db.adelete()

db = await SurrealDBStore.afrom_documents(
    dburl="ws://localhost:8000/rpc",  # url for the hosted SurrealDB database
    embedding=embeddings,
    documents=docs,
    db_user="root",  # SurrealDB credentials if needed: db username
    db_pass="root",  # SurrealDB credentials if needed: db password
    # ns="langchain", # namespace to use for vectorstore
    # db="database",  # database to use for vectorstore
    # collection="documents", #collection to use for vectorstore
)
```

### Similarity search

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = await db.asimilarity_search(query)
```

```python
print(docs[0].page_content)
```
```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```
### Similarity search with score

The returned distance score is cosine distance. Therefore, a lower score is better.

```python
docs = await db.asimilarity_search_with_score(query)
```

```python
docs[0]
```

```output
(Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'id': 'documents:slgdlhjkfknhqo15xz0w', 'source': '../../how_to/state_of_the_union.txt'}),
 0.39839531721941895)
```

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)