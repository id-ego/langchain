---
canonical: https://python.langchain.com/v0.2/docs/integrations/stores/upstash_redis/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/upstash_redis.ipynb
sidebar_label: Upstash Redis
---

# UpstashRedisByteStore

This will help you get started with Upstash redis [key-value stores](/docs/concepts/#key-value-stores). For detailed documentation of all `UpstashRedisByteStore` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html).

## Overview

The `UpstashRedisStore` is an implementation of `ByteStore` that stores everything in your [Upstash](https://upstash.com/)-hosted Redis instance.

To use the base `RedisStore` instead, see [this guide](/docs/integrations/stores/redis/).

### Integration details

| Class | Package | Local | [JS support](https://js.langchain.com/v0.2/docs/integrations/stores/upstash_redis_storage) | Package downloads | Package latest |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [UpstashRedisByteStore](https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_community?style=flat-square&label=%20) |

## Setup

You'll first need to [sign up for an Upstash account](https://upstash.com/docs/redis/overall/getstarted). Next, you'll need to create a Redis database to connect to.

### Credentials

Once you've created your database, get your database URL (don't forget the `https://`!) and token:

```python
from getpass import getpass

URL = getpass("Enter your Upstash URL")
TOKEN = getpass("Enter your Upstash REST token")
```

### Installation

The LangChain Upstash integration lives in the `langchain_community` package. You'll also need to install the `upstash-redis` package as a peer dependency:

```python
%pip install -qU langchain_community upstash-redis
```

## Instantiation

Now we can instantiate our byte store:

```python
<!--IMPORTS:[{"imported": "UpstashRedisByteStore", "source": "langchain_community.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html", "title": "UpstashRedisByteStore"}]-->
from langchain_community.storage import UpstashRedisByteStore
from upstash_redis import Redis

redis_client = Redis(url=URL, token=TOKEN)
kv_store = UpstashRedisByteStore(client=redis_client, ttl=None, namespace="test-ns")
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

```output
[b'value1', b'value2']
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

```output
[None, None]
```

## API reference

For detailed documentation of all `UpstashRedisByteStore` features and configurations, head to the API reference: https://api.python.langchain.com/en/latest/storage/langchain_community.storage.upstash_redis.UpstashRedisByteStore.html

## Related

- [Key-value store conceptual guide](/docs/concepts/#key-value-stores)