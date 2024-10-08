---
canonical: https://python.langchain.com/v0.2/docs/integrations/stores/cassandra/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/cassandra.ipynb
sidebar_label: Cassandra
---

# CassandraByteStore

This will help you get started with Cassandra [key-value stores](/docs/concepts/#key-value-stores). For detailed documentation of all `CassandraByteStore` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html).

## Overview

[Cassandra](https://cassandra.apache.org/) is a NoSQL, row-oriented, highly scalable and highly available database.

### Integration details

| Class | Package | Local | [JS support](https://js.langchain.com/v0.2/docs/integrations/stores/cassandra_storage) | Package downloads | Package latest |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [CassandraByteStore](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

## Setup

The `CassandraByteStore` is an implementation of `ByteStore` that stores the data in your Cassandra instance.
The store keys must be strings and will be mapped to the `row_id` column of the Cassandra table.
The store `bytes` values are mapped to the `body_blob` column of the Cassandra table.

### Installation

The LangChain `CassandraByteStore` integration lives in the `langchain_community` package. You'll also need to install the `cassio` package or the `cassandra-driver` package as a peer dependency depending on which initialization method you're using:

```python
%pip install -qU langchain_community
%pip install -qU cassandra-driver
%pip install -qU cassio
```

You'll also need to create a `cassandra.cluster.Session` object, as described in the [Cassandra driver documentation](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster). The details vary (e.g. with network settings and authentication), but this might be something like:

## Instantiation

You'll first need to create a `cassandra.cluster.Session` object, as described in the [Cassandra driver documentation](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster). The details vary (e.g. with network settings and authentication), but this might be something like:

```python
from cassandra.cluster import Cluster

cluster = Cluster()
session = cluster.connect()
```

Then you can create your store! You'll also need to provide the name of an existing keyspace of the Cassandra instance:

```python
<!--IMPORTS:[{"imported": "CassandraByteStore", "source": "langchain_community.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html", "title": "CassandraByteStore"}]-->
from langchain_community.storage import CassandraByteStore

kv_store = CassandraByteStore(
    table="my_store",
    session=session,
    keyspace="<YOUR KEYSPACE>",
)
```

## Usage

You can set data under keys like this using the `mset` method:

```python
kv_store.mset(
    [
        ["key1", b"value1"],
        ["key2", b"value2"],
    ]
)

kv_store.mget(
    [
        "key1",
        "key2",
    ]
)
```

And you can delete data using the `mdelete` method:

```python
kv_store.mdelete(
    [
        "key1",
        "key2",
    ]
)

kv_store.mget(
    [
        "key1",
        "key2",
    ]
)
```

## Init using `cassio`

It's also possible to use cassio to configure the session and keyspace.

```python
import cassio

cassio.init(contact_points="127.0.0.1", keyspace="<YOUR KEYSPACE>")

store = CassandraByteStore(
    table="my_store",
)

store.mset([("k1", b"v1"), ("k2", b"v2")])
print(store.mget(["k1", "k2"]))
```

## API reference

For detailed documentation of all `CassandraByteStore` features and configurations, head to the API reference: https://api.python.langchain.com/en/latest/storage/langchain_community.storage.cassandra.CassandraByteStore.html

## Related

- [Key-value store conceptual guide](/docs/concepts/#key-value-stores)