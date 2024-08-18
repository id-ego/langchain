---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/hugegraph.ipynb
description: HugeGraph는 Apache TinkerPop3 프레임워크와 Gremlin 쿼리 언어와 호환되는 효율적이고 적응 가능한
  그래프 데이터베이스입니다.
---

# HugeGraph

> [HugeGraph](https://hugegraph.apache.org/)는 `Apache TinkerPop3` 프레임워크 및 `Gremlin` 쿼리 언어와 호환되는 편리하고 효율적이며 적응 가능한 그래프 데이터베이스입니다.
> 
> [Gremlin](https://en.wikipedia.org/wiki/Gremlin_(query_language))은 `Apache Software Foundation`의 `Apache TinkerPop`에 의해 개발된 그래프 탐색 언어 및 가상 머신입니다.

이 노트북은 LLM을 사용하여 [HugeGraph](https://hugegraph.apache.org/cn/) 데이터베이스에 자연어 인터페이스를 제공하는 방법을 보여줍니다.

## 설정

실행 중인 HugeGraph 인스턴스가 필요합니다.
다음 스크립트를 실행하여 로컬 도커 컨테이너를 실행할 수 있습니다:

```
docker run \
    --name=graph \
    -itd \
    -p 8080:8080 \
    hugegraph/hugegraph
```


애플리케이션에서 HugeGraph에 연결하려면 python sdk를 설치해야 합니다:

```
pip3 install hugegraph-python
```


도커 컨테이너를 사용하는 경우 데이터베이스가 시작될 때까지 몇 초 기다려야 하며, 그 후에 스키마를 생성하고 데이터베이스에 그래프 데이터를 작성해야 합니다.

```python
from hugegraph.connection import PyHugeGraph

client = PyHugeGraph("localhost", "8080", user="admin", pwd="admin", graph="hugegraph")
```


먼저, 간단한 영화 데이터베이스를 위한 스키마를 생성합니다:

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


그런 다음 일부 데이터를 삽입할 수 있습니다.

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


## `HugeGraphQAChain` 생성

이제 `HugeGraph` 및 `HugeGraphQAChain`을 생성할 수 있습니다. `HugeGraph`를 생성하려면 데이터베이스 객체를 `HugeGraph` 생성자에 전달하면 됩니다.

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


## 그래프 스키마 정보 새로 고침

데이터베이스의 스키마가 변경되면 Gremlin 문을 생성하는 데 필요한 스키마 정보를 새로 고칠 수 있습니다.

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

## 그래프 쿼리

이제 그래프 Gremlin QA 체인을 사용하여 그래프에 질문을 할 수 있습니다.

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