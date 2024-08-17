---
canonical: https://python.langchain.com/v0.2/docs/integrations/llm_caching/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llm_caching.ipynb
---

# Model caches

This notebook covers how to cache results of individual LLM calls using different caches.

First, let's install some dependencies


```python
%pip install -qU langchain-openai langchain-community

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_llm_cache.html", "title": "Model caches"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Model caches"}]-->
from langchain.globals import set_llm_cache
from langchain_openai import OpenAI

# To make the caching really obvious, lets use a slower and older model.
# Caching supports newer chat models as well.
llm = OpenAI(model="gpt-3.5-turbo-instruct", n=2, best_of=2)
```

## `In Memory` Cache


```python
<!--IMPORTS:[{"imported": "InMemoryCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.InMemoryCache.html", "title": "Model caches"}]-->
from langchain_community.cache import InMemoryCache

set_llm_cache(InMemoryCache())
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 7.57 ms, sys: 8.22 ms, total: 15.8 ms
Wall time: 649 ms
```


```output
"\n\nWhy couldn't the bicycle stand up by itself? Because it was two-tired!"
```



```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```
```output
CPU times: user 551 µs, sys: 221 µs, total: 772 µs
Wall time: 1.23 ms
```


```output
"\n\nWhy couldn't the bicycle stand up by itself? Because it was two-tired!"
```


## `SQLite` Cache


```python
!rm .langchain.db
```


```python
<!--IMPORTS:[{"imported": "SQLiteCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLiteCache.html", "title": "Model caches"}]-->
# We can do the same thing with a SQLite cache
from langchain_community.cache import SQLiteCache

set_llm_cache(SQLiteCache(database_path=".langchain.db"))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 12.6 ms, sys: 3.51 ms, total: 16.1 ms
Wall time: 486 ms
```


```output
"\n\nWhy couldn't the bicycle stand up by itself? Because it was two-tired!"
```



```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```
```output
CPU times: user 52.6 ms, sys: 57.7 ms, total: 110 ms
Wall time: 113 ms
```


```output
"\n\nWhy couldn't the bicycle stand up by itself? Because it was two-tired!"
```


## `Upstash Redis` Cache

### Standard Cache
Use [Upstash Redis](https://upstash.com) to cache prompts and responses with a serverless HTTP API.


```python
%pip install -qU upstash_redis
```


```python
<!--IMPORTS:[{"imported": "UpstashRedisCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.UpstashRedisCache.html", "title": "Model caches"}]-->
import langchain
from langchain_community.cache import UpstashRedisCache
from upstash_redis import Redis

URL = "<UPSTASH_REDIS_REST_URL>"
TOKEN = "<UPSTASH_REDIS_REST_TOKEN>"

langchain.llm_cache = UpstashRedisCache(redis_=Redis(url=URL, token=TOKEN))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 7.56 ms, sys: 2.98 ms, total: 10.5 ms
Wall time: 1.14 s
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```



```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```
```output
CPU times: user 2.78 ms, sys: 1.95 ms, total: 4.73 ms
Wall time: 82.9 ms
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```


### Semantic Cache
Use [Upstash Vector](https://upstash.com/docs/vector/overall/whatisvector) to do a semantic similarity search and cache the most similar response in the database. The vectorization is automatically done by the selected embedding model while creating Upstash Vector database. 


```python
%pip install upstash-semantic-cache
```


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_llm_cache.html", "title": "Model caches"}]-->
from langchain.globals import set_llm_cache
from upstash_semantic_cache import SemanticCache
```


```python
UPSTASH_VECTOR_REST_URL = "<UPSTASH_VECTOR_REST_URL>"
UPSTASH_VECTOR_REST_TOKEN = "<UPSTASH_VECTOR_REST_TOKEN>"

cache = SemanticCache(
    url=UPSTASH_VECTOR_REST_URL, token=UPSTASH_VECTOR_REST_TOKEN, min_proximity=0.7
)
```


```python
set_llm_cache(cache)
```


```python
%%time
llm.invoke("Which city is the most crowded city in the USA?")
```
```output
CPU times: user 28.4 ms, sys: 3.93 ms, total: 32.3 ms
Wall time: 1.89 s
```


```output
'\n\nNew York City is the most crowded city in the USA.'
```



```python
%%time
llm.invoke("Which city has the highest population in the USA?")
```
```output
CPU times: user 3.22 ms, sys: 940 μs, total: 4.16 ms
Wall time: 97.7 ms
```


```output
'\n\nNew York City is the most crowded city in the USA.'
```


## `Redis` Cache

### Standard Cache
Use [Redis](/docs/integrations/providers/redis) to cache prompts and responses.


```python
%pip install -qU redis
```


```python
<!--IMPORTS:[{"imported": "RedisCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.RedisCache.html", "title": "Model caches"}]-->
# We can do the same thing with a Redis cache
# (make sure your local Redis instance is running first before running this example)
from langchain_community.cache import RedisCache
from redis import Redis

set_llm_cache(RedisCache(redis_=Redis()))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 6.88 ms, sys: 8.75 ms, total: 15.6 ms
Wall time: 1.04 s
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```



```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```
```output
CPU times: user 1.59 ms, sys: 610 µs, total: 2.2 ms
Wall time: 5.58 ms
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```


### Semantic Cache
Use [Redis](/docs/integrations/providers/redis) to cache prompts and responses and evaluate hits based on semantic similarity.


```python
%pip install -qU redis
```


```python
<!--IMPORTS:[{"imported": "RedisSemanticCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.RedisSemanticCache.html", "title": "Model caches"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
from langchain_community.cache import RedisSemanticCache
from langchain_openai import OpenAIEmbeddings

set_llm_cache(
    RedisSemanticCache(redis_url="redis://localhost:6379", embedding=OpenAIEmbeddings())
)
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 351 ms, sys: 156 ms, total: 507 ms
Wall time: 3.37 s
```


```output
"\n\nWhy don't scientists trust atoms?\nBecause they make up everything."
```



```python
%%time
# The second time, while not a direct hit, the question is semantically similar to the original question,
# so it uses the cached result!
llm.invoke("Tell me one joke")
```
```output
CPU times: user 6.25 ms, sys: 2.72 ms, total: 8.97 ms
Wall time: 262 ms
```


```output
"\n\nWhy don't scientists trust atoms?\nBecause they make up everything."
```


## `GPTCache`

We can use [GPTCache](https://github.com/zilliztech/GPTCache) for exact match caching OR to cache results based on semantic similarity

Let's first start with an example of exact match


```python
%pip install -qU gptcache
```


```python
<!--IMPORTS:[{"imported": "GPTCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.GPTCache.html", "title": "Model caches"}]-->
import hashlib

from gptcache import Cache
from gptcache.manager.factory import manager_factory
from gptcache.processor.pre import get_prompt
from langchain_community.cache import GPTCache


def get_hashed_name(name):
    return hashlib.sha256(name.encode()).hexdigest()


def init_gptcache(cache_obj: Cache, llm: str):
    hashed_llm = get_hashed_name(llm)
    cache_obj.init(
        pre_embedding_func=get_prompt,
        data_manager=manager_factory(manager="map", data_dir=f"map_cache_{hashed_llm}"),
    )


set_llm_cache(GPTCache(init_gptcache))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 21.5 ms, sys: 21.3 ms, total: 42.8 ms
Wall time: 6.2 s
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```



```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```
```output
CPU times: user 571 µs, sys: 43 µs, total: 614 µs
Wall time: 635 µs
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```


Let's now show an example of similarity caching


```python
<!--IMPORTS:[{"imported": "GPTCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.GPTCache.html", "title": "Model caches"}]-->
import hashlib

from gptcache import Cache
from gptcache.adapter.api import init_similar_cache
from langchain_community.cache import GPTCache


def get_hashed_name(name):
    return hashlib.sha256(name.encode()).hexdigest()


def init_gptcache(cache_obj: Cache, llm: str):
    hashed_llm = get_hashed_name(llm)
    init_similar_cache(cache_obj=cache_obj, data_dir=f"similar_cache_{hashed_llm}")


set_llm_cache(GPTCache(init_gptcache))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 1.42 s, sys: 279 ms, total: 1.7 s
Wall time: 8.44 s
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side.'
```



```python
%%time
# This is an exact match, so it finds it in the cache
llm.invoke("Tell me a joke")
```
```output
CPU times: user 866 ms, sys: 20 ms, total: 886 ms
Wall time: 226 ms
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side.'
```



```python
%%time
# This is not an exact match, but semantically within distance so it hits!
llm.invoke("Tell me joke")
```
```output
CPU times: user 853 ms, sys: 14.8 ms, total: 868 ms
Wall time: 224 ms
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side.'
```


## `MongoDB Atlas` Cache

[MongoDB Atlas](https://www.mongodb.com/docs/atlas/) is a fully-managed cloud database available in AWS, Azure, and GCP. It has native support for 
Vector Search on the MongoDB document data.
Use [MongoDB Atlas Vector Search](/docs/integrations/providers/mongodb_atlas) to semantically cache prompts and responses.

### `MongoDBCache`
An abstraction to store a simple cache in MongoDB. This does not use Semantic Caching, nor does it require an index to be made on the collection before generation.

To import this cache, first install the required dependency:

```bash
%pip install -qU langchain-mongodb
```

```python
<!--IMPORTS:[{"imported": "MongoDBCache", "source": "langchain_mongodb.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_mongodb.cache.MongoDBCache.html", "title": "Model caches"}]-->
from langchain_mongodb.cache import MongoDBCache
```


To use this cache with your LLMs:
```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain_core.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain_core.globals.set_llm_cache.html", "title": "Model caches"}]-->
from langchain_core.globals import set_llm_cache

# use any embedding provider...
from tests.integration_tests.vectorstores.fake_embeddings import FakeEmbeddings

mongodb_atlas_uri = "<YOUR_CONNECTION_STRING>"
COLLECTION_NAME="<YOUR_CACHE_COLLECTION_NAME>"
DATABASE_NAME="<YOUR_DATABASE_NAME>"

set_llm_cache(MongoDBCache(
    connection_string=mongodb_atlas_uri,
    collection_name=COLLECTION_NAME,
    database_name=DATABASE_NAME,
))
```


### `MongoDBAtlasSemanticCache`
Semantic caching allows users to retrieve cached prompts based on semantic similarity between the user input and previously cached results. Under the hood it blends MongoDBAtlas as both a cache and a vectorstore.
The MongoDBAtlasSemanticCache inherits from `MongoDBAtlasVectorSearch` and needs an Atlas Vector Search Index defined to work. Please look at the [usage example](/docs/integrations/vectorstores/mongodb_atlas) on how to set up the index.

To import this cache:
```python
<!--IMPORTS:[{"imported": "MongoDBAtlasSemanticCache", "source": "langchain_mongodb.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_mongodb.cache.MongoDBAtlasSemanticCache.html", "title": "Model caches"}]-->
from langchain_mongodb.cache import MongoDBAtlasSemanticCache
```

To use this cache with your LLMs:
```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain_core.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain_core.globals.set_llm_cache.html", "title": "Model caches"}]-->
from langchain_core.globals import set_llm_cache

# use any embedding provider...
from tests.integration_tests.vectorstores.fake_embeddings import FakeEmbeddings

mongodb_atlas_uri = "<YOUR_CONNECTION_STRING>"
COLLECTION_NAME="<YOUR_CACHE_COLLECTION_NAME>"
DATABASE_NAME="<YOUR_DATABASE_NAME>"

set_llm_cache(MongoDBAtlasSemanticCache(
    embedding=FakeEmbeddings(),
    connection_string=mongodb_atlas_uri,
    collection_name=COLLECTION_NAME,
    database_name=DATABASE_NAME,
))
```

To find more resources about using MongoDBSemanticCache visit [here](https://www.mongodb.com/blog/post/introducing-semantic-caching-dedicated-mongodb-lang-chain-package-gen-ai-apps)

## `Momento` Cache
Use [Momento](/docs/integrations/providers/momento) to cache prompts and responses.

Requires momento to use, uncomment below to install:


```python
%pip install -qU momento
```

You'll need to get a Momento auth token to use this class. This can either be passed in to a momento.CacheClient if you'd like to instantiate that directly, as a named parameter `auth_token` to `MomentoChatMessageHistory.from_client_params`, or can just be set as an environment variable `MOMENTO_AUTH_TOKEN`.


```python
<!--IMPORTS:[{"imported": "MomentoCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.MomentoCache.html", "title": "Model caches"}]-->
from datetime import timedelta

from langchain_community.cache import MomentoCache

cache_name = "langchain"
ttl = timedelta(days=1)
set_llm_cache(MomentoCache.from_client_params(cache_name, ttl))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 40.7 ms, sys: 16.5 ms, total: 57.2 ms
Wall time: 1.73 s
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```



```python
%%time
# The second time it is, so it goes faster
# When run in the same region as the cache, latencies are single digit ms
llm.invoke("Tell me a joke")
```
```output
CPU times: user 3.16 ms, sys: 2.98 ms, total: 6.14 ms
Wall time: 57.9 ms
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```


## `SQLAlchemy` Cache

You can use `SQLAlchemyCache` to cache with any SQL database supported by `SQLAlchemy`.


```python
<!--IMPORTS:[{"imported": "SQLAlchemyCache", "source": "langchain.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLAlchemyCache.html", "title": "Model caches"}]-->
# from langchain.cache import SQLAlchemyCache
# from sqlalchemy import create_engine

# engine = create_engine("postgresql://postgres:postgres@localhost:5432/postgres")
# set_llm_cache(SQLAlchemyCache(engine))
```

### Custom SQLAlchemy Schemas


```python
<!--IMPORTS:[{"imported": "SQLAlchemyCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLAlchemyCache.html", "title": "Model caches"}]-->
# You can define your own declarative SQLAlchemyCache child class to customize the schema used for caching. For example, to support high-speed fulltext prompt indexing with Postgres, use:

from langchain_community.cache import SQLAlchemyCache
from sqlalchemy import Column, Computed, Index, Integer, Sequence, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy_utils import TSVectorType

Base = declarative_base()


class FulltextLLMCache(Base):  # type: ignore
    """Postgres table for fulltext-indexed LLM Cache"""

    __tablename__ = "llm_cache_fulltext"
    id = Column(Integer, Sequence("cache_id"), primary_key=True)
    prompt = Column(String, nullable=False)
    llm = Column(String, nullable=False)
    idx = Column(Integer)
    response = Column(String)
    prompt_tsv = Column(
        TSVectorType(),
        Computed("to_tsvector('english', llm || ' ' || prompt)", persisted=True),
    )
    __table_args__ = (
        Index("idx_fulltext_prompt_tsv", prompt_tsv, postgresql_using="gin"),
    )


engine = create_engine("postgresql://postgres:postgres@localhost:5432/postgres")
set_llm_cache(SQLAlchemyCache(engine, FulltextLLMCache))
```

## `Cassandra` caches

> [Apache Cassandra®](https://cassandra.apache.org/) is a NoSQL, row-oriented, highly scalable and highly available database. Starting with version 5.0, the database ships with [vector search capabilities](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html).

You can use Cassandra for caching LLM responses, choosing from the exact-match `CassandraCache` or the (vector-similarity-based) `CassandraSemanticCache`.

Let's see both in action. The next cells guide you through the (little) required setup, and the following cells showcase the two available cache classes.

### Required dependency


```python
%pip install -qU "cassio>=0.1.4"
```

### Connect to the DB

The Cassandra caches shown in this page can be used with Cassandra as well as other derived databases, such as Astra DB, which use the CQL (Cassandra Query Language) protocol.

> DataStax [Astra DB](https://docs.datastax.com/en/astra-serverless/docs/vector-search/quickstart.html) is a managed serverless database built on Cassandra, offering the same interface and strengths.

Depending on whether you connect to a Cassandra cluster or to Astra DB through CQL, you will provide different parameters when instantiating the cache (through initialization of a CassIO connection).

#### Connecting to a Cassandra cluster

You first need to create a `cassandra.cluster.Session` object, as described in the [Cassandra driver documentation](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster). The details vary (e.g. with network settings and authentication), but this might be something like:


```python
from cassandra.cluster import Cluster

cluster = Cluster(["127.0.0.1"])
session = cluster.connect()
```

You can now set the session, along with your desired keyspace name, as a global CassIO parameter:


```python
import cassio

CASSANDRA_KEYSPACE = input("CASSANDRA_KEYSPACE = ")

cassio.init(session=session, keyspace=CASSANDRA_KEYSPACE)
```
```output
CASSANDRA_KEYSPACE =  demo_keyspace
```
#### Connecting to Astra DB through CQL

In this case you initialize CassIO with the following connection parameters:

- the Database ID, e.g. `01234567-89ab-cdef-0123-456789abcdef`
- the Token, e.g. `AstraCS:6gBhNmsk135....` (it must be a "Database Administrator" token)
- Optionally a Keyspace name (if omitted, the default one for the database will be used)


```python
import getpass

ASTRA_DB_ID = input("ASTRA_DB_ID = ")
ASTRA_DB_APPLICATION_TOKEN = getpass.getpass("ASTRA_DB_APPLICATION_TOKEN = ")

desired_keyspace = input("ASTRA_DB_KEYSPACE (optional, can be left empty) = ")
if desired_keyspace:
    ASTRA_DB_KEYSPACE = desired_keyspace
else:
    ASTRA_DB_KEYSPACE = None
```
```output
ASTRA_DB_ID =  01234567-89ab-cdef-0123-456789abcdef
ASTRA_DB_APPLICATION_TOKEN =  ········
ASTRA_DB_KEYSPACE (optional, can be left empty) =  my_keyspace
```

```python
import cassio

cassio.init(
    database_id=ASTRA_DB_ID,
    token=ASTRA_DB_APPLICATION_TOKEN,
    keyspace=ASTRA_DB_KEYSPACE,
)
```

### Cassandra: Exact cache

This will avoid invoking the LLM when the supplied prompt is _exactly_ the same as one encountered already:


```python
<!--IMPORTS:[{"imported": "CassandraCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.CassandraCache.html", "title": "Model caches"}, {"imported": "set_llm_cache", "source": "langchain_core.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain_core.globals.set_llm_cache.html", "title": "Model caches"}]-->
from langchain_community.cache import CassandraCache
from langchain_core.globals import set_llm_cache

set_llm_cache(CassandraCache())
```


```python
%%time

print(llm.invoke("Why is the Moon always showing the same side?"))
```
```output


The Moon is tidally locked with the Earth, which means that its rotation on its own axis is synchronized with its orbit around the Earth. This results in the Moon always showing the same side to the Earth. This is because the gravitational forces between the Earth and the Moon have caused the Moon's rotation to slow down over time, until it reached a point where it takes the same amount of time for the Moon to rotate on its axis as it does to orbit around the Earth. This phenomenon is common among satellites in close orbits around their parent planets and is known as tidal locking.
CPU times: user 92.5 ms, sys: 8.89 ms, total: 101 ms
Wall time: 1.98 s
```

```python
%%time

print(llm.invoke("Why is the Moon always showing the same side?"))
```
```output


The Moon is tidally locked with the Earth, which means that its rotation on its own axis is synchronized with its orbit around the Earth. This results in the Moon always showing the same side to the Earth. This is because the gravitational forces between the Earth and the Moon have caused the Moon's rotation to slow down over time, until it reached a point where it takes the same amount of time for the Moon to rotate on its axis as it does to orbit around the Earth. This phenomenon is common among satellites in close orbits around their parent planets and is known as tidal locking.
CPU times: user 5.51 ms, sys: 0 ns, total: 5.51 ms
Wall time: 5.78 ms
```
### Cassandra: Semantic cache

This cache will do a semantic similarity search and return a hit if it finds a cached entry that is similar enough, For this, you need to provide an `Embeddings` instance of your choice.


```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
from langchain_openai import OpenAIEmbeddings

embedding = OpenAIEmbeddings()
```


```python
<!--IMPORTS:[{"imported": "CassandraSemanticCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.CassandraSemanticCache.html", "title": "Model caches"}, {"imported": "set_llm_cache", "source": "langchain_core.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain_core.globals.set_llm_cache.html", "title": "Model caches"}]-->
from langchain_community.cache import CassandraSemanticCache
from langchain_core.globals import set_llm_cache

set_llm_cache(
    CassandraSemanticCache(
        embedding=embedding,
        table_name="my_semantic_cache",
    )
)
```


```python
%%time

print(llm.invoke("Why is the Moon always showing the same side?"))
```
```output


The Moon is always showing the same side because of a phenomenon called synchronous rotation. This means that the Moon rotates on its axis at the same rate that it orbits around the Earth, which takes approximately 27.3 days. This results in the same side of the Moon always facing the Earth. This is due to the gravitational forces between the Earth and the Moon, which have caused the Moon's rotation to gradually slow down and become synchronized with its orbit. This is a common occurrence among many moons in our solar system.
CPU times: user 49.5 ms, sys: 7.38 ms, total: 56.9 ms
Wall time: 2.55 s
```

```python
%%time

print(llm.invoke("How come we always see one face of the moon?"))
```
```output


The Moon is always showing the same side because of a phenomenon called synchronous rotation. This means that the Moon rotates on its axis at the same rate that it orbits around the Earth, which takes approximately 27.3 days. This results in the same side of the Moon always facing the Earth. This is due to the gravitational forces between the Earth and the Moon, which have caused the Moon's rotation to gradually slow down and become synchronized with its orbit. This is a common occurrence among many moons in our solar system.
CPU times: user 21.2 ms, sys: 3.38 ms, total: 24.6 ms
Wall time: 532 ms
```
#### Attribution statement

>Apache Cassandra, Cassandra and Apache are either registered trademarks or trademarks of the [Apache Software Foundation](http://www.apache.org/) in the United States and/or other countries.

## `Astra DB` Caches

You can easily use [Astra DB](https://docs.datastax.com/en/astra/home/astra.html) as an LLM cache, with either the "exact" or the "semantic-based" cache.

Make sure you have a running database (it must be a Vector-enabled database to use the Semantic cache) and get the required credentials on your Astra dashboard:

- the API Endpoint looks like `https://01234567-89ab-cdef-0123-456789abcdef-us-east1.apps.astra.datastax.com`
- the Token looks like `AstraCS:6gBhNmsk135....`


```python
%pip install -qU langchain_astradb

import getpass

ASTRA_DB_API_ENDPOINT = input("ASTRA_DB_API_ENDPOINT = ")
ASTRA_DB_APPLICATION_TOKEN = getpass.getpass("ASTRA_DB_APPLICATION_TOKEN = ")
```
```output
ASTRA_DB_API_ENDPOINT =  https://01234567-89ab-cdef-0123-456789abcdef-us-east1.apps.astra.datastax.com
ASTRA_DB_APPLICATION_TOKEN =  ········
```
### Astra DB exact LLM cache

This will avoid invoking the LLM when the supplied prompt is _exactly_ the same as one encountered already:


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_llm_cache.html", "title": "Model caches"}, {"imported": "AstraDBCache", "source": "langchain_astradb", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_astradb.cache.AstraDBCache.html", "title": "Model caches"}]-->
from langchain.globals import set_llm_cache
from langchain_astradb import AstraDBCache

set_llm_cache(
    AstraDBCache(
        api_endpoint=ASTRA_DB_API_ENDPOINT,
        token=ASTRA_DB_APPLICATION_TOKEN,
    )
)
```


```python
%%time

print(llm.invoke("Is a true fakery the same as a fake truth?"))
```
```output


There is no definitive answer to this question as it depends on the interpretation of the terms "true fakery" and "fake truth". However, one possible interpretation is that a true fakery is a counterfeit or imitation that is intended to deceive, whereas a fake truth is a false statement that is presented as if it were true.
CPU times: user 70.8 ms, sys: 4.13 ms, total: 74.9 ms
Wall time: 2.06 s
```

```python
%%time

print(llm.invoke("Is a true fakery the same as a fake truth?"))
```
```output


There is no definitive answer to this question as it depends on the interpretation of the terms "true fakery" and "fake truth". However, one possible interpretation is that a true fakery is a counterfeit or imitation that is intended to deceive, whereas a fake truth is a false statement that is presented as if it were true.
CPU times: user 15.1 ms, sys: 3.7 ms, total: 18.8 ms
Wall time: 531 ms
```
### Astra DB Semantic cache

This cache will do a semantic similarity search and return a hit if it finds a cached entry that is similar enough, For this, you need to provide an `Embeddings` instance of your choice.


```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
from langchain_openai import OpenAIEmbeddings

embedding = OpenAIEmbeddings()
```


```python
<!--IMPORTS:[{"imported": "AstraDBSemanticCache", "source": "langchain_astradb", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_astradb.cache.AstraDBSemanticCache.html", "title": "Model caches"}]-->
from langchain_astradb import AstraDBSemanticCache

set_llm_cache(
    AstraDBSemanticCache(
        api_endpoint=ASTRA_DB_API_ENDPOINT,
        token=ASTRA_DB_APPLICATION_TOKEN,
        embedding=embedding,
        collection_name="demo_semantic_cache",
    )
)
```


```python
%%time

print(llm.invoke("Are there truths that are false?"))
```
```output


There is no definitive answer to this question since it presupposes a great deal about the nature of truth itself, which is a matter of considerable philosophical debate. It is possible, however, to construct scenarios in which something could be considered true despite being false, such as if someone sincerely believes something to be true even though it is not.
CPU times: user 65.6 ms, sys: 15.3 ms, total: 80.9 ms
Wall time: 2.72 s
```

```python
%%time

print(llm.invoke("Is is possible that something false can be also true?"))
```
```output


There is no definitive answer to this question since it presupposes a great deal about the nature of truth itself, which is a matter of considerable philosophical debate. It is possible, however, to construct scenarios in which something could be considered true despite being false, such as if someone sincerely believes something to be true even though it is not.
CPU times: user 29.3 ms, sys: 6.21 ms, total: 35.5 ms
Wall time: 1.03 s
```
## Azure Cosmos DB Semantic Cache

You can use this integrated [vector database](https://learn.microsoft.com/en-us/azure/cosmos-db/vector-database) for caching.


```python
<!--IMPORTS:[{"imported": "AzureCosmosDBSemanticCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.AzureCosmosDBSemanticCache.html", "title": "Model caches"}, {"imported": "CosmosDBSimilarityType", "source": "langchain_community.vectorstores.azure_cosmos_db", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.azure_cosmos_db.CosmosDBSimilarityType.html", "title": "Model caches"}, {"imported": "CosmosDBVectorSearchType", "source": "langchain_community.vectorstores.azure_cosmos_db", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.azure_cosmos_db.CosmosDBVectorSearchType.html", "title": "Model caches"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
from langchain_community.cache import AzureCosmosDBSemanticCache
from langchain_community.vectorstores.azure_cosmos_db import (
    CosmosDBSimilarityType,
    CosmosDBVectorSearchType,
)
from langchain_openai import OpenAIEmbeddings

# Read more about Azure CosmosDB Mongo vCore vector search here https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/vcore/vector-search

NAMESPACE = "langchain_test_db.langchain_test_collection"
CONNECTION_STRING = (
    "Please provide your azure cosmos mongo vCore vector db connection string"
)

DB_NAME, COLLECTION_NAME = NAMESPACE.split(".")

# Default value for these params
num_lists = 3
dimensions = 1536
similarity_algorithm = CosmosDBSimilarityType.COS
kind = CosmosDBVectorSearchType.VECTOR_IVF
m = 16
ef_construction = 64
ef_search = 40
score_threshold = 0.9
application_name = "LANGCHAIN_CACHING_PYTHON"


set_llm_cache(
    AzureCosmosDBSemanticCache(
        cosmosdb_connection_string=CONNECTION_STRING,
        cosmosdb_client=None,
        embedding=OpenAIEmbeddings(),
        database_name=DB_NAME,
        collection_name=COLLECTION_NAME,
        num_lists=num_lists,
        similarity=similarity_algorithm,
        kind=kind,
        dimensions=dimensions,
        m=m,
        ef_construction=ef_construction,
        ef_search=ef_search,
        score_threshold=score_threshold,
        application_name=application_name,
    )
)
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 45.6 ms, sys: 19.7 ms, total: 65.3 ms
Wall time: 2.29 s
```


```output
'\n\nWhy was the math book sad? Because it had too many problems.'
```



```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 9.61 ms, sys: 3.42 ms, total: 13 ms
Wall time: 474 ms
```


```output
'\n\nWhy was the math book sad? Because it had too many problems.'
```


## `Elasticsearch` Cache
A caching layer for LLMs that uses Elasticsearch.

First install the LangChain integration with Elasticsearch.


```python
%pip install -qU langchain-elasticsearch
```

Use the class `ElasticsearchCache`.

Simple example:


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_llm_cache.html", "title": "Model caches"}, {"imported": "ElasticsearchCache", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchCache.html", "title": "Model caches"}]-->
from langchain.globals import set_llm_cache
from langchain_elasticsearch import ElasticsearchCache

set_llm_cache(
    ElasticsearchCache(
        es_url="http://localhost:9200",
        index_name="llm-chat-cache",
        metadata={"project": "my_chatgpt_project"},
    )
)
```

The `index_name` parameter can also accept aliases. This allows to use the 
[ILM: Manage the index lifecycle](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-lifecycle-management.html)
that we suggest to consider for managing retention and controlling cache growth.

Look at the class docstring for all parameters.

### Index the generated text

The cached data won't be searchable by default.
The developer can customize the building of the Elasticsearch document in order to add indexed text fields,
where to put, for example, the text generated by the LLM.

This can be done by subclassing end overriding methods.
The new cache class can be applied also to a pre-existing cache index:


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_llm_cache.html", "title": "Model caches"}, {"imported": "ElasticsearchCache", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchCache.html", "title": "Model caches"}]-->
import json
from typing import Any, Dict, List

from langchain.globals import set_llm_cache
from langchain_core.caches import RETURN_VAL_TYPE
from langchain_elasticsearch import ElasticsearchCache


class SearchableElasticsearchCache(ElasticsearchCache):
    @property
    def mapping(self) -> Dict[str, Any]:
        mapping = super().mapping
        mapping["mappings"]["properties"]["parsed_llm_output"] = {
            "type": "text",
            "analyzer": "english",
        }
        return mapping

    def build_document(
        self, prompt: str, llm_string: str, return_val: RETURN_VAL_TYPE
    ) -> Dict[str, Any]:
        body = super().build_document(prompt, llm_string, return_val)
        body["parsed_llm_output"] = self._parse_output(body["llm_output"])
        return body

    @staticmethod
    def _parse_output(data: List[str]) -> List[str]:
        return [
            json.loads(output)["kwargs"]["message"]["kwargs"]["content"]
            for output in data
        ]


set_llm_cache(
    SearchableElasticsearchCache(
        es_url="http://localhost:9200", index_name="llm-chat-cache"
    )
)
```

When overriding the mapping and the document building, 
please only make additive modifications, keeping the base mapping intact.

## Optional Caching
You can also turn off caching for specific LLMs should you choose. In the example below, even though global caching is enabled, we turn it off for a specific LLM


```python
llm = OpenAI(model="gpt-3.5-turbo-instruct", n=2, best_of=2, cache=False)
```


```python
%%time
llm.invoke("Tell me a joke")
```
```output
CPU times: user 5.8 ms, sys: 2.71 ms, total: 8.51 ms
Wall time: 745 ms
```


```output
'\n\nWhy did the chicken cross the road?\n\nTo get to the other side!'
```



```python
%%time
llm.invoke("Tell me a joke")
```
```output
CPU times: user 4.91 ms, sys: 2.64 ms, total: 7.55 ms
Wall time: 623 ms
```


```output
'\n\nTwo guys stole a calendar. They got six months each.'
```


## Optional Caching in Chains
You can also turn off caching for particular nodes in chains. Note that because of certain interfaces, its often easier to construct the chain first, and then edit the LLM afterwards.

As an example, we will load a summarizer map-reduce chain. We will cache results for the map-step, but then not freeze it for the combine step.


```python
llm = OpenAI(model="gpt-3.5-turbo-instruct")
no_cache_llm = OpenAI(model="gpt-3.5-turbo-instruct", cache=False)
```


```python
<!--IMPORTS:[{"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Model caches"}]-->
from langchain_text_splitters import CharacterTextSplitter

text_splitter = CharacterTextSplitter()
```


```python
with open("../how_to/state_of_the_union.txt") as f:
    state_of_the_union = f.read()
texts = text_splitter.split_text(state_of_the_union)
```


```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Model caches"}, {"imported": "load_summarize_chain", "source": "langchain.chains.summarize", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.summarize.chain.load_summarize_chain.html", "title": "Model caches"}]-->
from langchain_core.documents import Document

docs = [Document(page_content=t) for t in texts[:3]]
from langchain.chains.summarize import load_summarize_chain
```


```python
chain = load_summarize_chain(llm, chain_type="map_reduce", reduce_llm=no_cache_llm)
```


```python
%%time
chain.invoke(docs)
```
```output
CPU times: user 176 ms, sys: 23.2 ms, total: 199 ms
Wall time: 4.42 s
```


```output
{'input_documents': [Document(page_content='Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\nWith a duty to one another to the American people to the Constitution. \n\nAnd with an unwavering resolve that freedom will always triumph over tyranny. \n\nSix days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. \n\nHe thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. \n\nHe met the Ukrainian people. \n\nFrom President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world. \n\nGroups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. \n\nIn this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. \n\nLet each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. \n\nPlease rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. \n\nThroughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos.   \n\nThey keep moving.   \n\nAnd the costs and the threats to America and the world keep rising.   \n\nThat’s why the NATO Alliance was created to secure peace and stability in Europe after World War 2. \n\nThe United States is a member along with 29 other nations. \n\nIt matters. American diplomacy matters. American resolve matters. \n\nPutin’s latest attack on Ukraine was premeditated and unprovoked. \n\nHe rejected repeated efforts at diplomacy. \n\nHe thought the West and NATO wouldn’t respond. And he thought he could divide us at home. Putin was wrong. We were ready.  Here is what we did.   \n\nWe prepared extensively and carefully. \n\nWe spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin. \n\nI spent countless hours unifying our European allies. We shared with the world in advance what we knew Putin was planning and precisely how he would try to falsely justify his aggression.  \n\nWe countered Russia’s lies with truth.   \n\nAnd now that he has acted the free world is holding him accountable. \n\nAlong with twenty-seven members of the European Union including France, Germany, Italy, as well as countries like the United Kingdom, Canada, Japan, Korea, Australia, New Zealand, and many others, even Switzerland. \n\nWe are inflicting pain on Russia and supporting the people of Ukraine. Putin is now isolated from the world more than ever. \n\nTogether with our allies –we are right now enforcing powerful economic sanctions. \n\nWe are cutting off Russia’s largest banks from the international financial system.  \n\nPreventing Russia’s central bank from defending the Russian Ruble making Putin’s $630 Billion “war fund” worthless.   \n\nWe are choking off Russia’s access to technology that will sap its economic strength and weaken its military for years to come.  \n\nTonight I say to the Russian oligarchs and corrupt leaders who have bilked billions of dollars off this violent regime no more. \n\nThe U.S. Department of Justice is assembling a dedicated task force to go after the crimes of Russian oligarchs.  \n\nWe are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains.'),
  Document(page_content='We are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains. \n\nAnd tonight I am announcing that we will join our allies in closing off American air space to all Russian flights – further isolating Russia – and adding an additional squeeze –on their economy. The Ruble has lost 30% of its value. \n\nThe Russian stock market has lost 40% of its value and trading remains suspended. Russia’s economy is reeling and Putin alone is to blame. \n\nTogether with our allies we are providing support to the Ukrainians in their fight for freedom. Military assistance. Economic assistance. Humanitarian assistance. \n\nWe are giving more than $1 Billion in direct assistance to Ukraine. \n\nAnd we will continue to aid the Ukrainian people as they defend their country and to help ease their suffering.  \n\nLet me be clear, our forces are not engaged and will not engage in conflict with Russian forces in Ukraine.  \n\nOur forces are not going to Europe to fight in Ukraine, but to defend our NATO Allies – in the event that Putin decides to keep moving west.  \n\nFor that purpose we’ve mobilized American ground forces, air squadrons, and ship deployments to protect NATO countries including Poland, Romania, Latvia, Lithuania, and Estonia. \n\nAs I have made crystal clear the United States and our Allies will defend every inch of territory of NATO countries with the full force of our collective power.  \n\nAnd we remain clear-eyed. The Ukrainians are fighting back with pure courage. But the next few days weeks, months, will be hard on them.  \n\nPutin has unleashed violence and chaos.  But while he may make gains on the battlefield – he will pay a continuing high price over the long run. \n\nAnd a proud Ukrainian people, who have known 30 years  of independence, have repeatedly shown that they will not tolerate anyone who tries to take their country backwards.  \n\nTo all Americans, I will be honest with you, as I’ve always promised. A Russian dictator, invading a foreign country, has costs around the world. \n\nAnd I’m taking robust action to make sure the pain of our sanctions  is targeted at Russia’s economy. And I will use every tool at our disposal to protect American businesses and consumers. \n\nTonight, I can announce that the United States has worked with 30 other countries to release 60 Million barrels of oil from reserves around the world.  \n\nAmerica will lead that effort, releasing 30 Million barrels from our own Strategic Petroleum Reserve. And we stand ready to do more if necessary, unified with our allies.  \n\nThese steps will help blunt gas prices here at home. And I know the news about what’s happening can seem alarming. \n\nBut I want you to know that we are going to be okay. \n\nWhen the history of this era is written Putin’s war on Ukraine will have left Russia weaker and the rest of the world stronger. \n\nWhile it shouldn’t have taken something so terrible for people around the world to see what’s at stake now everyone sees it clearly. \n\nWe see the unity among leaders of nations and a more unified Europe a more unified West. And we see unity among the people who are gathering in cities in large crowds around the world even in Russia to demonstrate their support for Ukraine.  \n\nIn the battle between democracy and autocracy, democracies are rising to the moment, and the world is clearly choosing the side of peace and security. \n\nThis is a real test. It’s going to take time. So let us continue to draw inspiration from the iron will of the Ukrainian people. \n\nTo our fellow Ukrainian Americans who forge a deep bond that connects our two nations we stand with you. \n\nPutin may circle Kyiv with tanks, but he will never gain the hearts and souls of the Ukrainian people. \n\nHe will never extinguish their love of freedom. He will never weaken the resolve of the free world. \n\nWe meet tonight in an America that has lived through two of the hardest years this nation has ever faced.'),
  Document(page_content='We meet tonight in an America that has lived through two of the hardest years this nation has ever faced. \n\nThe pandemic has been punishing. \n\nAnd so many families are living paycheck to paycheck, struggling to keep up with the rising cost of food, gas, housing, and so much more. \n\nI understand. \n\nI remember when my Dad had to leave our home in Scranton, Pennsylvania to find work. I grew up in a family where if the price of food went up, you felt it. \n\nThat’s why one of the first things I did as President was fight to pass the American Rescue Plan.  \n\nBecause people were hurting. We needed to act, and we did. \n\nFew pieces of legislation have done more in a critical moment in our history to lift us out of crisis. \n\nIt fueled our efforts to vaccinate the nation and combat COVID-19. It delivered immediate economic relief for tens of millions of Americans.  \n\nHelped put food on their table, keep a roof over their heads, and cut the cost of health insurance. \n\nAnd as my Dad used to say, it gave people a little breathing room. \n\nAnd unlike the $2 Trillion tax cut passed in the previous administration that benefitted the top 1% of Americans, the American Rescue Plan helped working people—and left no one behind. \n\nAnd it worked. It created jobs. Lots of jobs. \n\nIn fact—our economy created over 6.5 Million new jobs just last year, more jobs created in one year  \nthan ever before in the history of America. \n\nOur economy grew at a rate of 5.7% last year, the strongest growth in nearly 40 years, the first step in bringing fundamental change to an economy that hasn’t worked for the working people of this nation for too long.  \n\nFor the past 40 years we were told that if we gave tax breaks to those at the very top, the benefits would trickle down to everyone else. \n\nBut that trickle-down theory led to weaker economic growth, lower wages, bigger deficits, and the widest gap between those at the top and everyone else in nearly a century. \n\nVice President Harris and I ran for office with a new economic vision for America. \n\nInvest in America. Educate Americans. Grow the workforce. Build the economy from the bottom up  \nand the middle out, not from the top down.  \n\nBecause we know that when the middle class grows, the poor have a ladder up and the wealthy do very well. \n\nAmerica used to have the best roads, bridges, and airports on Earth. \n\nNow our infrastructure is ranked 13th in the world. \n\nWe won’t be able to compete for the jobs of the 21st Century if we don’t fix that. \n\nThat’s why it was so important to pass the Bipartisan Infrastructure Law—the most sweeping investment to rebuild America in history. \n\nThis was a bipartisan effort, and I want to thank the members of both parties who worked to make it happen. \n\nWe’re done talking about infrastructure weeks. \n\nWe’re going to have an infrastructure decade. \n\nIt is going to transform America and put us on a path to win the economic competition of the 21st Century that we face with the rest of the world—particularly with China.  \n\nAs I’ve told Xi Jinping, it is never a good bet to bet against the American people. \n\nWe’ll create good jobs for millions of Americans, modernizing roads, airports, ports, and waterways all across America. \n\nAnd we’ll do it all to withstand the devastating effects of the climate crisis and promote environmental justice. \n\nWe’ll build a national network of 500,000 electric vehicle charging stations, begin to replace poisonous lead pipes—so every child—and every American—has clean water to drink at home and at school, provide affordable high-speed internet for every American—urban, suburban, rural, and tribal communities. \n\n4,000 projects have already been announced. \n\nAnd tonight, I’m announcing that this year we will start fixing over 65,000 miles of highway and 1,500 bridges in disrepair. \n\nWhen we use taxpayer dollars to rebuild America – we are going to Buy American: buy American products to support American jobs.')],
 'output_text': " The speaker addresses the unity and strength of Americans and discusses the recent conflict with Russia and actions taken by the US and its allies. They announce closures of airspace, support for Ukraine, and measures to target corrupt Russian leaders. President Biden reflects on past hardships and highlights efforts to pass the American Rescue Plan. He criticizes the previous administration's policies and shares plans for the economy, including investing in America, education, rebuilding infrastructure, and supporting American jobs. "}
```


When we run it again, we see that it runs substantially faster but the final answer is different. This is due to caching at the map steps, but not at the reduce step.


```python
%%time
chain.invoke(docs)
```
```output
CPU times: user 7 ms, sys: 1.94 ms, total: 8.94 ms
Wall time: 1.06 s
```


```output
{'input_documents': [Document(page_content='Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\nWith a duty to one another to the American people to the Constitution. \n\nAnd with an unwavering resolve that freedom will always triumph over tyranny. \n\nSix days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. \n\nHe thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. \n\nHe met the Ukrainian people. \n\nFrom President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world. \n\nGroups of citizens blocking tanks with their bodies. Everyone from students to retirees teachers turned soldiers defending their homeland. \n\nIn this struggle as President Zelenskyy said in his speech to the European Parliament “Light will win over darkness.” The Ukrainian Ambassador to the United States is here tonight. \n\nLet each of us here tonight in this Chamber send an unmistakable signal to Ukraine and to the world. \n\nPlease rise if you are able and show that, Yes, we the United States of America stand with the Ukrainian people. \n\nThroughout our history we’ve learned this lesson when dictators do not pay a price for their aggression they cause more chaos.   \n\nThey keep moving.   \n\nAnd the costs and the threats to America and the world keep rising.   \n\nThat’s why the NATO Alliance was created to secure peace and stability in Europe after World War 2. \n\nThe United States is a member along with 29 other nations. \n\nIt matters. American diplomacy matters. American resolve matters. \n\nPutin’s latest attack on Ukraine was premeditated and unprovoked. \n\nHe rejected repeated efforts at diplomacy. \n\nHe thought the West and NATO wouldn’t respond. And he thought he could divide us at home. Putin was wrong. We were ready.  Here is what we did.   \n\nWe prepared extensively and carefully. \n\nWe spent months building a coalition of other freedom-loving nations from Europe and the Americas to Asia and Africa to confront Putin. \n\nI spent countless hours unifying our European allies. We shared with the world in advance what we knew Putin was planning and precisely how he would try to falsely justify his aggression.  \n\nWe countered Russia’s lies with truth.   \n\nAnd now that he has acted the free world is holding him accountable. \n\nAlong with twenty-seven members of the European Union including France, Germany, Italy, as well as countries like the United Kingdom, Canada, Japan, Korea, Australia, New Zealand, and many others, even Switzerland. \n\nWe are inflicting pain on Russia and supporting the people of Ukraine. Putin is now isolated from the world more than ever. \n\nTogether with our allies –we are right now enforcing powerful economic sanctions. \n\nWe are cutting off Russia’s largest banks from the international financial system.  \n\nPreventing Russia’s central bank from defending the Russian Ruble making Putin’s $630 Billion “war fund” worthless.   \n\nWe are choking off Russia’s access to technology that will sap its economic strength and weaken its military for years to come.  \n\nTonight I say to the Russian oligarchs and corrupt leaders who have bilked billions of dollars off this violent regime no more. \n\nThe U.S. Department of Justice is assembling a dedicated task force to go after the crimes of Russian oligarchs.  \n\nWe are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains.'),
  Document(page_content='We are joining with our European allies to find and seize your yachts your luxury apartments your private jets. We are coming for your ill-begotten gains. \n\nAnd tonight I am announcing that we will join our allies in closing off American air space to all Russian flights – further isolating Russia – and adding an additional squeeze –on their economy. The Ruble has lost 30% of its value. \n\nThe Russian stock market has lost 40% of its value and trading remains suspended. Russia’s economy is reeling and Putin alone is to blame. \n\nTogether with our allies we are providing support to the Ukrainians in their fight for freedom. Military assistance. Economic assistance. Humanitarian assistance. \n\nWe are giving more than $1 Billion in direct assistance to Ukraine. \n\nAnd we will continue to aid the Ukrainian people as they defend their country and to help ease their suffering.  \n\nLet me be clear, our forces are not engaged and will not engage in conflict with Russian forces in Ukraine.  \n\nOur forces are not going to Europe to fight in Ukraine, but to defend our NATO Allies – in the event that Putin decides to keep moving west.  \n\nFor that purpose we’ve mobilized American ground forces, air squadrons, and ship deployments to protect NATO countries including Poland, Romania, Latvia, Lithuania, and Estonia. \n\nAs I have made crystal clear the United States and our Allies will defend every inch of territory of NATO countries with the full force of our collective power.  \n\nAnd we remain clear-eyed. The Ukrainians are fighting back with pure courage. But the next few days weeks, months, will be hard on them.  \n\nPutin has unleashed violence and chaos.  But while he may make gains on the battlefield – he will pay a continuing high price over the long run. \n\nAnd a proud Ukrainian people, who have known 30 years  of independence, have repeatedly shown that they will not tolerate anyone who tries to take their country backwards.  \n\nTo all Americans, I will be honest with you, as I’ve always promised. A Russian dictator, invading a foreign country, has costs around the world. \n\nAnd I’m taking robust action to make sure the pain of our sanctions  is targeted at Russia’s economy. And I will use every tool at our disposal to protect American businesses and consumers. \n\nTonight, I can announce that the United States has worked with 30 other countries to release 60 Million barrels of oil from reserves around the world.  \n\nAmerica will lead that effort, releasing 30 Million barrels from our own Strategic Petroleum Reserve. And we stand ready to do more if necessary, unified with our allies.  \n\nThese steps will help blunt gas prices here at home. And I know the news about what’s happening can seem alarming. \n\nBut I want you to know that we are going to be okay. \n\nWhen the history of this era is written Putin’s war on Ukraine will have left Russia weaker and the rest of the world stronger. \n\nWhile it shouldn’t have taken something so terrible for people around the world to see what’s at stake now everyone sees it clearly. \n\nWe see the unity among leaders of nations and a more unified Europe a more unified West. And we see unity among the people who are gathering in cities in large crowds around the world even in Russia to demonstrate their support for Ukraine.  \n\nIn the battle between democracy and autocracy, democracies are rising to the moment, and the world is clearly choosing the side of peace and security. \n\nThis is a real test. It’s going to take time. So let us continue to draw inspiration from the iron will of the Ukrainian people. \n\nTo our fellow Ukrainian Americans who forge a deep bond that connects our two nations we stand with you. \n\nPutin may circle Kyiv with tanks, but he will never gain the hearts and souls of the Ukrainian people. \n\nHe will never extinguish their love of freedom. He will never weaken the resolve of the free world. \n\nWe meet tonight in an America that has lived through two of the hardest years this nation has ever faced.'),
  Document(page_content='We meet tonight in an America that has lived through two of the hardest years this nation has ever faced. \n\nThe pandemic has been punishing. \n\nAnd so many families are living paycheck to paycheck, struggling to keep up with the rising cost of food, gas, housing, and so much more. \n\nI understand. \n\nI remember when my Dad had to leave our home in Scranton, Pennsylvania to find work. I grew up in a family where if the price of food went up, you felt it. \n\nThat’s why one of the first things I did as President was fight to pass the American Rescue Plan.  \n\nBecause people were hurting. We needed to act, and we did. \n\nFew pieces of legislation have done more in a critical moment in our history to lift us out of crisis. \n\nIt fueled our efforts to vaccinate the nation and combat COVID-19. It delivered immediate economic relief for tens of millions of Americans.  \n\nHelped put food on their table, keep a roof over their heads, and cut the cost of health insurance. \n\nAnd as my Dad used to say, it gave people a little breathing room. \n\nAnd unlike the $2 Trillion tax cut passed in the previous administration that benefitted the top 1% of Americans, the American Rescue Plan helped working people—and left no one behind. \n\nAnd it worked. It created jobs. Lots of jobs. \n\nIn fact—our economy created over 6.5 Million new jobs just last year, more jobs created in one year  \nthan ever before in the history of America. \n\nOur economy grew at a rate of 5.7% last year, the strongest growth in nearly 40 years, the first step in bringing fundamental change to an economy that hasn’t worked for the working people of this nation for too long.  \n\nFor the past 40 years we were told that if we gave tax breaks to those at the very top, the benefits would trickle down to everyone else. \n\nBut that trickle-down theory led to weaker economic growth, lower wages, bigger deficits, and the widest gap between those at the top and everyone else in nearly a century. \n\nVice President Harris and I ran for office with a new economic vision for America. \n\nInvest in America. Educate Americans. Grow the workforce. Build the economy from the bottom up  \nand the middle out, not from the top down.  \n\nBecause we know that when the middle class grows, the poor have a ladder up and the wealthy do very well. \n\nAmerica used to have the best roads, bridges, and airports on Earth. \n\nNow our infrastructure is ranked 13th in the world. \n\nWe won’t be able to compete for the jobs of the 21st Century if we don’t fix that. \n\nThat’s why it was so important to pass the Bipartisan Infrastructure Law—the most sweeping investment to rebuild America in history. \n\nThis was a bipartisan effort, and I want to thank the members of both parties who worked to make it happen. \n\nWe’re done talking about infrastructure weeks. \n\nWe’re going to have an infrastructure decade. \n\nIt is going to transform America and put us on a path to win the economic competition of the 21st Century that we face with the rest of the world—particularly with China.  \n\nAs I’ve told Xi Jinping, it is never a good bet to bet against the American people. \n\nWe’ll create good jobs for millions of Americans, modernizing roads, airports, ports, and waterways all across America. \n\nAnd we’ll do it all to withstand the devastating effects of the climate crisis and promote environmental justice. \n\nWe’ll build a national network of 500,000 electric vehicle charging stations, begin to replace poisonous lead pipes—so every child—and every American—has clean water to drink at home and at school, provide affordable high-speed internet for every American—urban, suburban, rural, and tribal communities. \n\n4,000 projects have already been announced. \n\nAnd tonight, I’m announcing that this year we will start fixing over 65,000 miles of highway and 1,500 bridges in disrepair. \n\nWhen we use taxpayer dollars to rebuild America – we are going to Buy American: buy American products to support American jobs.')],
 'output_text': '\n\nThe speaker addresses the unity of Americans and discusses the conflict with Russia and support for Ukraine. The US and allies are taking action against Russia and targeting corrupt leaders. There is also support and assurance for the American people. President Biden reflects on recent hardships and highlights efforts to pass the American Rescue Plan. He also shares plans for economic growth and investment in America. '}
```



```python
!rm .langchain.db sqlite.db
```
```output
rm: sqlite.db: No such file or directory
```
## OpenSearch Semantic Cache
Use [OpenSearch](https://python.langchain.com/docs/integrations/vectorstores/opensearch/) as a semantic cache to cache prompts and responses and evaluate hits based on semantic similarity.


```python
<!--IMPORTS:[{"imported": "OpenSearchSemanticCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.OpenSearchSemanticCache.html", "title": "Model caches"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
from langchain_community.cache import OpenSearchSemanticCache
from langchain_openai import OpenAIEmbeddings

set_llm_cache(
    OpenSearchSemanticCache(
        opensearch_url="http://localhost:9200", embedding=OpenAIEmbeddings()
    )
)
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 39.4 ms, sys: 11.8 ms, total: 51.2 ms
Wall time: 1.55 s
```


```output
"\n\nWhy don't scientists trust atoms?\n\nBecause they make up everything."
```



```python
%%time
# The second time, while not a direct hit, the question is semantically similar to the original question,
# so it uses the cached result!
llm.invoke("Tell me one joke")
```
```output
CPU times: user 4.66 ms, sys: 1.1 ms, total: 5.76 ms
Wall time: 113 ms
```


```output
"\n\nWhy don't scientists trust atoms?\n\nBecause they make up everything."
```


## SingleStoreDB Semantic Cache
You can use [SingleStoreDB](https://python.langchain.com/docs/integrations/vectorstores/singlestoredb/) as a semantic cache to cache prompts and responses.


```python
<!--IMPORTS:[{"imported": "SingleStoreDBSemanticCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SingleStoreDBSemanticCache.html", "title": "Model caches"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
from langchain_community.cache import SingleStoreDBSemanticCache
from langchain_openai import OpenAIEmbeddings

set_llm_cache(
    SingleStoreDBSemanticCache(
        embedding=OpenAIEmbeddings(),
        host="root:pass@localhost:3306/db",
    )
)
```

## Couchbase Caches

Use [Couchbase](https://couchbase.com/) as a cache for prompts and responses.

### Couchbase Cache

The standard cache that looks for an exact match of the user prompt.


```python
%pip install -qU langchain_couchbase couchbase
```


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Model caches"}]-->
# Create couchbase connection object
from datetime import timedelta

from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions
from langchain_couchbase.cache import CouchbaseCache
from langchain_openai import ChatOpenAI

COUCHBASE_CONNECTION_STRING = (
    "couchbase://localhost"  # or "couchbases://localhost" if using TLS
)
DB_USERNAME = "Administrator"
DB_PASSWORD = "Password"

auth = PasswordAuthenticator(DB_USERNAME, DB_PASSWORD)
options = ClusterOptions(auth)
cluster = Cluster(COUCHBASE_CONNECTION_STRING, options)

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))
```


```python
# Specify the bucket, scope and collection to store the cached documents
BUCKET_NAME = "langchain-testing"
SCOPE_NAME = "_default"
COLLECTION_NAME = "_default"

set_llm_cache(
    CouchbaseCache(
        cluster=cluster,
        bucket_name=BUCKET_NAME,
        scope_name=SCOPE_NAME,
        collection_name=COLLECTION_NAME,
    )
)
```


```python
%%time
# The first time, it is not yet in the cache, so it should take longer
llm.invoke("Tell me a joke")
```
```output
CPU times: user 22.2 ms, sys: 14 ms, total: 36.2 ms
Wall time: 938 ms
```


```output
"\n\nWhy couldn't the bicycle stand up by itself? Because it was two-tired!"
```



```python
%%time
# The second time, it is in the cache, so it should be much faster
llm.invoke("Tell me a joke")
```
```output
CPU times: user 53 ms, sys: 29 ms, total: 82 ms
Wall time: 84.2 ms
```


```output
"\n\nWhy couldn't the bicycle stand up by itself? Because it was two-tired!"
```


### Couchbase Semantic Cache
Semantic caching allows users to retrieve cached prompts based on semantic similarity between the user input and previously cached inputs. Under the hood it uses Couchbase as both a cache and a vectorstore. This needs an appropriate Vector Search Index defined to work. Please look at the usage example on how to set up the index.


```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Model caches"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Model caches"}]-->
# Create Couchbase connection object
from datetime import timedelta

from couchbase.auth import PasswordAuthenticator
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions
from langchain_couchbase.cache import CouchbaseSemanticCache
from langchain_openai import ChatOpenAI, OpenAIEmbeddings

COUCHBASE_CONNECTION_STRING = (
    "couchbase://localhost"  # or "couchbases://localhost" if using TLS
)
DB_USERNAME = "Administrator"
DB_PASSWORD = "Password"

auth = PasswordAuthenticator(DB_USERNAME, DB_PASSWORD)
options = ClusterOptions(auth)
cluster = Cluster(COUCHBASE_CONNECTION_STRING, options)

# Wait until the cluster is ready for use.
cluster.wait_until_ready(timedelta(seconds=5))
```

Notes:
- The search index for the semantic cache needs to be defined before using the semantic cache. 
- The optional parameter, `score_threshold` in the Semantic Cache that you can use to tune the results of the semantic search.

### How to Import an Index to the Full Text Search service?
 - [Couchbase Server](https://docs.couchbase.com/server/current/search/import-search-index.html)
     - Click on Search -> Add Index -> Import
     - Copy the following Index definition in the Import screen
     - Click on Create Index to create the index.
 - [Couchbase Capella](https://docs.couchbase.com/cloud/search/import-search-index.html)
     - Copy the index definition to a new file `index.json`
     - Import the file in Capella using the instructions in the documentation.
     - Click on Create Index to create the index.

#### Example index for the vector search. 
  ```
  {
    "type": "fulltext-index",
    "name": "langchain-testing._default.semantic-cache-index",
    "sourceType": "gocbcore",
    "sourceName": "langchain-testing",
    "planParams": {
      "maxPartitionsPerPIndex": 1024,
      "indexPartitions": 16
    },
    "params": {
      "doc_config": {
        "docid_prefix_delim": "",
        "docid_regexp": "",
        "mode": "scope.collection.type_field",
        "type_field": "type"
      },
      "mapping": {
        "analysis": {},
        "default_analyzer": "standard",
        "default_datetime_parser": "dateTimeOptional",
        "default_field": "_all",
        "default_mapping": {
          "dynamic": true,
          "enabled": false
        },
        "default_type": "_default",
        "docvalues_dynamic": false,
        "index_dynamic": true,
        "store_dynamic": true,
        "type_field": "_type",
        "types": {
          "_default.semantic-cache": {
            "dynamic": false,
            "enabled": true,
            "properties": {
              "embedding": {
                "dynamic": false,
                "enabled": true,
                "fields": [
                  {
                    "dims": 1536,
                    "index": true,
                    "name": "embedding",
                    "similarity": "dot_product",
                    "type": "vector",
                    "vector_index_optimized_for": "recall"
                  }
                ]
              },
              "metadata": {
                "dynamic": true,
                "enabled": true
              },
              "text": {
                "dynamic": false,
                "enabled": true,
                "fields": [
                  {
                    "index": true,
                    "name": "text",
                    "store": true,
                    "type": "text"
                  }
                ]
              }
            }
          }
        }
      },
      "store": {
        "indexType": "scorch",
        "segmentVersion": 16
      }
    },
    "sourceParams": {}
  }
  ```


```python
BUCKET_NAME = "langchain-testing"
SCOPE_NAME = "_default"
COLLECTION_NAME = "semantic-cache"
INDEX_NAME = "semantic-cache-index"
embeddings = OpenAIEmbeddings()

cache = CouchbaseSemanticCache(
    cluster=cluster,
    embedding=embeddings,
    bucket_name=BUCKET_NAME,
    scope_name=SCOPE_NAME,
    collection_name=COLLECTION_NAME,
    index_name=INDEX_NAME,
    score_threshold=0.8,
)

set_llm_cache(cache)
```


```python
%%time
# The first time, it is not yet in the cache, so it should take longer
print(llm.invoke("How long do dogs live?"))
```
```output


The average lifespan of a dog is around 12 years, but this can vary depending on the breed, size, and overall health of the individual dog. Some smaller breeds may live longer, while larger breeds may have shorter lifespans. Proper care, diet, and exercise can also play a role in extending a dog's lifespan.
CPU times: user 826 ms, sys: 2.46 s, total: 3.28 s
Wall time: 2.87 s
```

```python
%%time
# The second time, it is in the cache, so it should be much faster
print(llm.invoke("What is the expected lifespan of a dog?"))
```
```output


The average lifespan of a dog is around 12 years, but this can vary depending on the breed, size, and overall health of the individual dog. Some smaller breeds may live longer, while larger breeds may have shorter lifespans. Proper care, diet, and exercise can also play a role in extending a dog's lifespan.
CPU times: user 9.82 ms, sys: 2.61 ms, total: 12.4 ms
Wall time: 311 ms
```
## Cache classes: summary table

**Cache** classes are implemented by inheriting the [BaseCache](https://api.python.langchain.com/en/latest/caches/langchain_core.caches.BaseCache.html) class.

This table lists all 21 derived classes with links to the API Reference.


| Namespace 🔻 | Class |
|------------|---------|
| langchain_astradb.cache | [AstraDBCache](https://api.python.langchain.com/en/latest/cache/langchain_astradb.cache.AstraDBCache.html) |
| langchain_astradb.cache | [AstraDBSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_astradb.cache.AstraDBSemanticCache.html) |
| langchain_community.cache | [AstraDBCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.AstraDBCache.html) |
| langchain_community.cache | [AstraDBSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.AstraDBSemanticCache.html) |
| langchain_community.cache | [AzureCosmosDBSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.AzureCosmosDBSemanticCache.html) |
| langchain_community.cache | [CassandraCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.CassandraCache.html) |
| langchain_community.cache | [CassandraSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.CassandraSemanticCache.html) |
| langchain_community.cache | [GPTCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.GPTCache.html) |
| langchain_community.cache | [InMemoryCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.InMemoryCache.html) |
| langchain_community.cache | [MomentoCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.MomentoCache.html) |
| langchain_community.cache | [OpenSearchSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.OpenSearchSemanticCache.html) |
| langchain_community.cache | [RedisSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.RedisSemanticCache.html) |
| langchain_community.cache | [SingleStoreDBSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SingleStoreDBSemanticCache.html) |
| langchain_community.cache | [SQLAlchemyCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLAlchemyCache.html) |
| langchain_community.cache | [SQLAlchemyMd5Cache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLAlchemyMd5Cache.html) |
| langchain_community.cache | [UpstashRedisCache](https://api.python.langchain.com/en/latest/cache/langchain_community.cache.UpstashRedisCache.html) |
| langchain_core.caches | [InMemoryCache](https://api.python.langchain.com/en/latest/caches/langchain_core.caches.InMemoryCache.html) |
| langchain_elasticsearch.cache | [ElasticsearchCache](https://api.python.langchain.com/en/latest/cache/langchain_elasticsearch.cache.ElasticsearchCache.html) |
| langchain_mongodb.cache | [MongoDBAtlasSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_mongodb.cache.MongoDBAtlasSemanticCache.html) |
| langchain_mongodb.cache | [MongoDBCache](https://api.python.langchain.com/en/latest/cache/langchain_mongodb.cache.MongoDBCache.html) |
| langchain_couchbase.cache | [CouchbaseCache](https://api.python.langchain.com/en/latest/cache/langchain_couchbase.cache.CouchbaseCache.html) |
| langchain_couchbase.cache | [CouchbaseSemanticCache](https://api.python.langchain.com/en/latest/cache/langchain_couchbase.cache.CouchbaseSemanticCache.html) |