---
canonical: https://python.langchain.com/v0.2/docs/integrations/graphs/hugegraph/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/hugegraph.ipynb
---

# HugeGraph

> [HugeGraph](https://hugegraph.apache.org/) is a convenient, efficient, and adaptable graph database compatible with
the `Apache TinkerPop3` framework and the `Gremlin` query language.
> 
> [Gremlin](https://en.wikipedia.org/wiki/Gremlin_(query_language)) is a graph traversal language and virtual machine developed by `Apache TinkerPop` of the `Apache Software Foundation`.

This notebook shows how to use LLMs to provide a natural language interface to [HugeGraph](https://hugegraph.apache.org/cn/) database.

## Setting up

You will need to have a running HugeGraph instance.
You can run a local docker container by running the executing the following script:

```
docker run \
    --name=graph \
    -itd \
    -p 8080:8080 \
    hugegraph/hugegraph
```

If we want to connect HugeGraph in the application, we need to install python sdk:

```
pip3 install hugegraph-python
```

If you are using the docker container, you need to wait a couple of second for the database to start, and then we need create schema and write graph data for the database.

```python
from hugegraph.connection import PyHugeGraph

client = PyHugeGraph("localhost", "8080", user="admin", pwd="admin", graph="hugegraph")
```

First, we create the schema for a simple movie database:

```python
"""schema"""
schema = client.schema()
schema.propertyKey("name").asText().ifNotExist().create()
schema.propertyKey("birthDate").asText().ifNotExist().create()
schema.vertexLabel("Person").properties(
    "name", "birthDate"
).usePrimaryKeyId().primaryKeys("name").ifNotExist().create()
schema.vertexLabel("Movie").properties("name").usePrimaryKeyId().primaryKeys(
    "name"
).ifNotExist().create()
schema.edgeLabel("ActedIn").sourceLabel("Person").targetLabel(
    "Movie"
).ifNotExist().create()
```

```output
'create EdgeLabel success, Detail: "b\'{"id":1,"name":"ActedIn","source_label":"Person","target_label":"Movie","frequency":"SINGLE","sort_keys":[],"nullable_keys":[],"index_labels":[],"properties":[],"status":"CREATED","ttl":0,"enable_label_index":true,"user_data":{"~create_time":"2023-07-04 10:48:47.908"}}\'"'
```

Then we can insert some data.

```python
"""graph"""
g = client.graph()
g.addVertex("Person", {"name": "Al Pacino", "birthDate": "1940-04-25"})
g.addVertex("Person", {"name": "Robert De Niro", "birthDate": "1943-08-17"})
g.addVertex("Movie", {"name": "The Godfather"})
g.addVertex("Movie", {"name": "The Godfather Part II"})
g.addVertex("Movie", {"name": "The Godfather Coda The Death of Michael Corleone"})

g.addEdge("ActedIn", "1:Al Pacino", "2:The Godfather", {})
g.addEdge("ActedIn", "1:Al Pacino", "2:The Godfather Part II", {})
g.addEdge(
    "ActedIn", "1:Al Pacino", "2:The Godfather Coda The Death of Michael Corleone", {}
)
g.addEdge("ActedIn", "1:Robert De Niro", "2:The Godfather Part II", {})
```

```output
1:Robert De Niro--ActedIn-->2:The Godfather Part II
```

## Creating `HugeGraphQAChain`

We can now create the `HugeGraph` and `HugeGraphQAChain`. To create the `HugeGraph` we simply need to pass the database object to the `HugeGraph` constructor.

```python
<!--IMPORTS:[{"imported": "HugeGraphQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.hugegraph.HugeGraphQAChain.html", "title": "HugeGraph"}, {"imported": "HugeGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.hugegraph.HugeGraph.html", "title": "HugeGraph"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "HugeGraph"}]-->
from langchain.chains import HugeGraphQAChain
from langchain_community.graphs import HugeGraph
from langchain_openai import ChatOpenAI
```

```python
graph = HugeGraph(
    username="admin",
    password="admin",
    address="localhost",
    port=8080,
    graph="hugegraph",
)
```

## Refresh graph schema information

If the schema of database changes, you can refresh the schema information needed to generate Gremlin statements.

```python
# graph.refresh_schema()
```

```python
print(graph.get_schema)
```
```output
Node properties: [name: Person, primary_keys: ['name'], properties: ['name', 'birthDate'], name: Movie, primary_keys: ['name'], properties: ['name']]
Edge properties: [name: ActedIn, properties: []]
Relationships: ['Person--ActedIn-->Movie']
```
## Querying the graph

We can now use the graph Gremlin QA chain to ask question of the graph

```python
chain = HugeGraphQAChain.from_llm(ChatOpenAI(temperature=0), graph=graph, verbose=True)
```

```python
chain.run("Who played in The Godfather?")
```
```output


[1m> Entering new  chain...[0m
Generated gremlin:
[32;1m[1;3mg.V().has('Movie', 'name', 'The Godfather').in('ActedIn').valueMap(true)[0m
Full Context:
[32;1m[1;3m[{'id': '1:Al Pacino', 'label': 'Person', 'name': ['Al Pacino'], 'birthDate': ['1940-04-25']}][0m

[1m> Finished chain.[0m
```

```output
'Al Pacino played in The Godfather.'
```