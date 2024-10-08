---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/surrealdb/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/surrealdb.ipynb
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

This notebook shows how to use functionality related to the `SurrealDBLoader`.

## Overview

The SurrealDB Document Loader returns a list of Langchain Documents from a SurrealDB database.

The Document Loader takes the following optional parameters:

* `dburl`: connection string to the websocket endpoint. default: `ws://localhost:8000/rpc`
* `ns`: name of the namespace. default: `langchain`
* `db`: name of the database. default: `database`
* `table`: name of the table. default: `documents`
* `db_user`: SurrealDB credentials if needed: db username.
* `db_pass`: SurrealDB credentails if needed: db password.
* `filter_criteria`: dictionary to construct the `WHERE` clause for filtering results from table.

The output `Document` takes the following shape:
```
Document(
    page_content=<json encoded string containing the result document>,
    metadata={
        'id': <document id>,
        'ns': <namespace name>,
        'db': <database_name>,
        'table': <table name>,
        ... <additional fields from metadata property of the document>
    }
)
```

## Setup

Uncomment the below cells to install surrealdb and langchain.

```python
# %pip install --upgrade --quiet  surrealdb langchain langchain-community
```

```python
# add this import for running in jupyter notebook
import nest_asyncio

nest_asyncio.apply()
```

```python
<!--IMPORTS:[{"imported": "SurrealDBLoader", "source": "langchain_community.document_loaders.surrealdb", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.surrealdb.SurrealDBLoader.html", "title": "SurrealDB"}]-->
import json

from langchain_community.document_loaders.surrealdb import SurrealDBLoader
```

```python
loader = SurrealDBLoader(
    dburl="ws://localhost:8000/rpc",
    ns="langchain",
    db="database",
    table="documents",
    db_user="root",
    db_pass="root",
    filter_criteria={},
)
docs = loader.load()
len(docs)
```

```output
42
```

```python
doc = docs[-1]
doc.metadata
```

```output
{'id': 'documents:zzz434sa584xl3b4ohvk',
 'source': '../../how_to/state_of_the_union.txt',
 'ns': 'langchain',
 'db': 'database',
 'table': 'documents'}
```

```python
len(doc.page_content)
```

```output
18078
```

```python
page_content = json.loads(doc.page_content)
```

```python
page_content["text"]
```

```output
'When we use taxpayer dollars to rebuild America – we are going to Buy American: buy American products to support American jobs. \n\nThe federal government spends about $600 Billion a year to keep the country safe and secure. \n\nThere’s been a law on the books for almost a century \nto make sure taxpayers’ dollars support American jobs and businesses. \n\nEvery Administration says they’ll do it, but we are actually doing it. \n\nWe will buy American to make sure everything from the deck of an aircraft carrier to the steel on highway guardrails are made in America. \n\nBut to compete for the best jobs of the future, we also need to level the playing field with China and other competitors. \n\nThat’s why it is so important to pass the Bipartisan Innovation Act sitting in Congress that will make record investments in emerging technologies and American manufacturing. \n\nLet me give you one example of why it’s so important to pass it.'
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)