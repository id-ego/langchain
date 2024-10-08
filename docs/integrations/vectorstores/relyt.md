---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/relyt/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/relyt.ipynb
---

# Relyt

> [Relyt](https://docs.relyt.cn/docs/vector-engine/use/) is a cloud native data warehousing service that is designed to analyze large volumes of data online.

> `Relyt` is compatible with the ANSI SQL 2003 syntax and the PostgreSQL and Oracle database ecosystems. Relyt also supports row store and column store. Relyt processes petabytes of data offline at a high performance level and supports highly concurrent online queries.

This notebook shows how to use functionality related to the `Relyt` vector database.
To run, you should have an [Relyt](https://docs.relyt.cn/) instance up and running:
- Using [Relyt Vector Database](https://docs.relyt.cn/docs/vector-engine/use/). Click here to fast deploy it.

```python
%pip install "pgvecto_rs[sdk]" langchain-community
```

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Relyt"}, {"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Relyt"}, {"imported": "Relyt", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.relyt.Relyt.html", "title": "Relyt"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Relyt"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores import Relyt
from langchain_text_splitters import CharacterTextSplitter
```

Split documents and get embeddings by call community API

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = FakeEmbeddings(size=1536)
```

Connect to Relyt by setting related ENVIRONMENTS.
```
export PG_HOST={your_relyt_hostname}
export PG_PORT={your_relyt_port} # Optional, default is 5432
export PG_DATABASE={your_database} # Optional, default is postgres
export PG_USER={database_username}
export PG_PASSWORD={database_password}
```

Then store your embeddings and documents into Relyt

```python
import os

connection_string = Relyt.connection_string_from_db_params(
    driver=os.environ.get("PG_DRIVER", "psycopg2cffi"),
    host=os.environ.get("PG_HOST", "localhost"),
    port=int(os.environ.get("PG_PORT", "5432")),
    database=os.environ.get("PG_DATABASE", "postgres"),
    user=os.environ.get("PG_USER", "postgres"),
    password=os.environ.get("PG_PASSWORD", "postgres"),
)

vector_db = Relyt.from_documents(
    docs,
    embeddings,
    connection_string=connection_string,
)
```

Query and retrieve data

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)
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

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)