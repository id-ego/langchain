---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/azure_cosmosdb_gremlin.ipynb
description: Azure Cosmos DB for Apache Gremlin은 대규모 그래프를 저장하고 밀리초 단위로 쿼리할 수 있는 그래프
  데이터베이스 서비스입니다.
---

# Azure Cosmos DB for Apache Gremlin

> [Azure Cosmos DB for Apache Gremlin](https://learn.microsoft.com/en-us/azure/cosmos-db/gremlin/introduction)는 수십억 개의 정점과 엣지를 가진 대규모 그래프를 저장하는 데 사용할 수 있는 그래프 데이터베이스 서비스입니다. 밀리초 단위의 지연으로 그래프를 쿼리할 수 있으며 그래프 구조를 쉽게 발전시킬 수 있습니다.
> 
> [Gremlin](https://en.wikipedia.org/wiki/Gremlin_(query_language))은 `Apache Software Foundation`의 `Apache TinkerPop`에서 개발한 그래프 탐색 언어 및 가상 머신입니다.

이 노트북은 LLM을 사용하여 `Gremlin` 쿼리 언어로 쿼리할 수 있는 그래프 데이터베이스에 자연어 인터페이스를 제공하는 방법을 보여줍니다.

## 설정하기

라이브러리를 설치하십시오:

```python
!pip3 install gremlinpython
```


Azure CosmosDB 그래프 데이터베이스 인스턴스가 필요합니다. 한 가지 옵션은 [Azure에서 무료 CosmosDB 그래프 데이터베이스 인스턴스를 만드는 것입니다](https://learn.microsoft.com/en-us/azure/cosmos-db/free-tier).

Cosmos DB 계정 및 그래프를 생성할 때 `/type`을 파티션 키로 사용하십시오.

```python
cosmosdb_name = "mycosmosdb"
cosmosdb_db_id = "graphtesting"
cosmosdb_db_graph_id = "mygraph"
cosmosdb_access_Key = "longstring=="
```


```python
<!--IMPORTS:[{"imported": "GremlinQAChain", "source": "langchain_community.chains.graph_qa.gremlin", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.gremlin.GremlinQAChain.html", "title": "Azure Cosmos DB for Apache Gremlin"}, {"imported": "GremlinGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.gremlin_graph.GremlinGraph.html", "title": "Azure Cosmos DB for Apache Gremlin"}, {"imported": "GraphDocument", "source": "langchain_community.graphs.graph_document", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.graph_document.GraphDocument.html", "title": "Azure Cosmos DB for Apache Gremlin"}, {"imported": "Node", "source": "langchain_community.graphs.graph_document", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.graph_document.Node.html", "title": "Azure Cosmos DB for Apache Gremlin"}, {"imported": "Relationship", "source": "langchain_community.graphs.graph_document", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.graph_document.Relationship.html", "title": "Azure Cosmos DB for Apache Gremlin"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Azure Cosmos DB for Apache Gremlin"}, {"imported": "AzureChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.azure.AzureChatOpenAI.html", "title": "Azure Cosmos DB for Apache Gremlin"}]-->
import nest_asyncio
from langchain_community.chains.graph_qa.gremlin import GremlinQAChain
from langchain_community.graphs import GremlinGraph
from langchain_community.graphs.graph_document import GraphDocument, Node, Relationship
from langchain_core.documents import Document
from langchain_openai import AzureChatOpenAI
```


```python
graph = GremlinGraph(
    url=f"=wss://{cosmosdb_name}.gremlin.cosmos.azure.com:443/",
    username=f"/dbs/{cosmosdb_db_id}/colls/{cosmosdb_db_graph_id}",
    password=cosmosdb_access_Key,
)
```


## 데이터베이스 초기화

데이터베이스가 비어 있다고 가정하면 GraphDocuments를 사용하여 데이터를 채울 수 있습니다.

Gremlin의 경우 각 노드에 'label'이라는 속성을 항상 추가하십시오. 
라벨이 설정되지 않은 경우 Node.type이 라벨로 사용됩니다. 
자연 ID를 사용하는 Cosmos는 그래프 탐색기에서 볼 수 있으므로 의미가 있습니다.

```python
source_doc = Document(
    page_content="Matrix is a movie where Keanu Reeves, Laurence Fishburne and Carrie-Anne Moss acted."
)
movie = Node(id="The Matrix", properties={"label": "movie", "title": "The Matrix"})
actor1 = Node(id="Keanu Reeves", properties={"label": "actor", "name": "Keanu Reeves"})
actor2 = Node(
    id="Laurence Fishburne", properties={"label": "actor", "name": "Laurence Fishburne"}
)
actor3 = Node(
    id="Carrie-Anne Moss", properties={"label": "actor", "name": "Carrie-Anne Moss"}
)
rel1 = Relationship(
    id=5, type="ActedIn", source=actor1, target=movie, properties={"label": "ActedIn"}
)
rel2 = Relationship(
    id=6, type="ActedIn", source=actor2, target=movie, properties={"label": "ActedIn"}
)
rel3 = Relationship(
    id=7, type="ActedIn", source=actor3, target=movie, properties={"label": "ActedIn"}
)
rel4 = Relationship(
    id=8,
    type="Starring",
    source=movie,
    target=actor1,
    properties={"label": "Strarring"},
)
rel5 = Relationship(
    id=9,
    type="Starring",
    source=movie,
    target=actor2,
    properties={"label": "Strarring"},
)
rel6 = Relationship(
    id=10,
    type="Straring",
    source=movie,
    target=actor3,
    properties={"label": "Strarring"},
)
graph_doc = GraphDocument(
    nodes=[movie, actor1, actor2, actor3],
    relationships=[rel1, rel2, rel3, rel4, rel5, rel6],
    source=source_doc,
)
```


```python
# The underlying python-gremlin has a problem when running in notebook
# The following line is a workaround to fix the problem
nest_asyncio.apply()

# Add the document to the CosmosDB graph.
graph.add_graph_documents([graph_doc])
```


## 그래프 스키마 정보 새로 고침
데이터베이스의 스키마가 변경되면(업데이트 후) 스키마 정보를 새로 고칠 수 있습니다.

```python
graph.refresh_schema()
```


```python
print(graph.schema)
```


## 그래프 쿼리하기

이제 gremlin QA 체인을 사용하여 그래프에 질문을 할 수 있습니다.

```python
chain = GremlinQAChain.from_llm(
    AzureChatOpenAI(
        temperature=0,
        azure_deployment="gpt-4-turbo",
    ),
    graph=graph,
    verbose=True,
)
```


```python
chain.invoke("Who played in The Matrix?")
```


```python
chain.run("How many people played in The Matrix?")
```