---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/neo4j_cypher.ipynb
description: Neo4j는 그래프 데이터베이스 관리 시스템으로, 노드와 엣지를 저장하며 Cypher 쿼리 언어로 데이터에 접근할 수 있습니다.
---

# Neo4j

> [Neo4j](https://neo4j.com/docs/getting-started/)는 `Neo4j, Inc`에서 개발한 그래프 데이터베이스 관리 시스템입니다.

> `Neo4j`가 저장하는 데이터 요소는 노드, 이를 연결하는 엣지, 그리고 노드와 엣지의 속성입니다. 개발자들에 의해 ACID 준수 트랜잭션 데이터베이스로 설명되며, 네이티브 그래프 저장 및 처리 기능을 갖춘 `Neo4j`는 GNU 일반 공용 라이선스의 수정판으로 라이선스된 비오픈 소스 "커뮤니티 에디션"으로 제공되며, 온라인 백업 및 고가용성 확장은 폐쇄 소스 상업 라이선스 하에 라이선스됩니다. Neo는 또한 이러한 확장을 폐쇄 소스 상업 조건 하에 `Neo4j`에 라이선스합니다.

> 이 노트북은 LLM을 사용하여 `Cypher` 쿼리 언어로 쿼리할 수 있는 그래프 데이터베이스에 자연어 인터페이스를 제공하는 방법을 보여줍니다.

> [Cypher](https://en.wikipedia.org/wiki/Cypher_(query_language))는 속성 그래프에서 표현력 있고 효율적인 데이터 쿼리를 허용하는 선언적 그래프 쿼리 언어입니다.

## 설정

실행 중인 `Neo4j` 인스턴스가 필요합니다. 한 가지 옵션은 [그들의 Aura 클라우드 서비스에서 무료 Neo4j 데이터베이스 인스턴스를 생성하는 것](https://neo4j.com/cloud/platform/aura-graph-database/)입니다. [Neo4j Desktop 애플리케이션](https://neo4j.com/download/)을 사용하여 로컬에서 데이터베이스를 실행하거나 도커 컨테이너를 실행할 수도 있습니다.
로컬 도커 컨테이너를 실행하려면 다음 스크립트를 실행하십시오:

```
docker run \
    --name neo4j \
    -p 7474:7474 -p 7687:7687 \
    -d \
    -e NEO4J_AUTH=neo4j/password \
    -e NEO4J_PLUGINS=\[\"apoc\"\]  \
    neo4j:latest
```


도커 컨테이너를 사용하는 경우, 데이터베이스가 시작될 때까지 몇 초를 기다려야 합니다.

```python
<!--IMPORTS:[{"imported": "GraphCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher.GraphCypherQAChain.html", "title": "Neo4j"}, {"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "Neo4j"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Neo4j"}]-->
from langchain.chains import GraphCypherQAChain
from langchain_community.graphs import Neo4jGraph
from langchain_openai import ChatOpenAI
```


```python
graph = Neo4jGraph(url="bolt://localhost:7687", username="neo4j", password="password")
```


## 데이터베이스 초기화

데이터베이스가 비어 있다고 가정하면 Cypher 쿼리 언어를 사용하여 데이터를 채울 수 있습니다. 다음 Cypher 문은 아이도포턴트이며, 이는 한 번 또는 여러 번 실행해도 데이터베이스 정보가 동일하다는 것을 의미합니다.

```python
graph.query(
    """
MERGE (m:Movie {name:"Top Gun", runtime: 120})
WITH m
UNWIND ["Tom Cruise", "Val Kilmer", "Anthony Edwards", "Meg Ryan"] AS actor
MERGE (a:Actor {name:actor})
MERGE (a)-[:ACTED_IN]->(m)
"""
)
```


```output
[]
```


## 그래프 스키마 정보 새로 고침
데이터베이스의 스키마가 변경되면 Cypher 문을 생성하는 데 필요한 스키마 정보를 새로 고칠 수 있습니다.

```python
graph.refresh_schema()
```


```python
print(graph.schema)
```

```output
Node properties:
Movie {runtime: INTEGER, name: STRING}
Actor {name: STRING}
Relationship properties:

The relationships:
(:Actor)-[:ACTED_IN]->(:Movie)
```

## 향상된 스키마 정보
향상된 스키마 버전을 선택하면 시스템이 데이터베이스 내의 예제 값을 자동으로 스캔하고 일부 분포 메트릭을 계산할 수 있습니다. 예를 들어, 노드 속성이 10개 미만의 고유 값을 가지면 스키마에서 가능한 모든 값을 반환합니다. 그렇지 않으면 노드 및 관계 속성당 단일 예제 값만 반환합니다.

```python
enhanced_graph = Neo4jGraph(
    url="bolt://localhost:7687",
    username="neo4j",
    password="password",
    enhanced_schema=True,
)
print(enhanced_graph.schema)
```

```output
Node properties:
- **Movie**
  - `runtime`: INTEGER Min: 120, Max: 120
  - `name`: STRING Available options: ['Top Gun']
- **Actor**
  - `name`: STRING Available options: ['Tom Cruise', 'Val Kilmer', 'Anthony Edwards', 'Meg Ryan']
Relationship properties:

The relationships:
(:Actor)-[:ACTED_IN]->(:Movie)
```

## 그래프 쿼리

이제 그래프에 질문하기 위해 그래프 사이퍼 QA 체인을 사용할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True
)
```


```python
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan played in Top Gun.'}
```


## 결과 수 제한
`top_k` 매개변수를 사용하여 Cypher QA 체인에서 결과 수를 제한할 수 있습니다.
기본값은 10입니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True, top_k=2
)
```


```python
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer played in Top Gun.'}
```


## 중간 결과 반환
`return_intermediate_steps` 매개변수를 사용하여 Cypher QA 체인에서 중간 단계를 반환할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True, return_intermediate_steps=True
)
```


```python
result = chain.invoke({"query": "Who played in Top Gun?"})
print(f"Intermediate steps: {result['intermediate_steps']}")
print(f"Final answer: {result['result']}")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
Intermediate steps: [{'query': "MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)\nWHERE m.name = 'Top Gun'\nRETURN a.name"}, {'context': [{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}]}]
Final answer: Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan played in Top Gun.
```

## 직접 결과 반환
`return_direct` 매개변수를 사용하여 Cypher QA 체인에서 직접 결과를 반환할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True, return_direct=True
)
```


```python
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': [{'a.name': 'Tom Cruise'},
  {'a.name': 'Val Kilmer'},
  {'a.name': 'Anthony Edwards'},
  {'a.name': 'Meg Ryan'}]}
```


## Cypher 생성 프롬프트에 예제 추가
특정 질문에 대해 LLM이 생성할 Cypher 문을 정의할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts.prompt", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Neo4j"}]-->
from langchain_core.prompts.prompt import PromptTemplate

CYPHER_GENERATION_TEMPLATE = """Task:Generate Cypher statement to query a graph database.
Instructions:
Use only the provided relationship types and properties in the schema.
Do not use any other relationship types or properties that are not provided.
Schema:
{schema}
Note: Do not include any explanations or apologies in your responses.
Do not respond to any questions that might ask anything else than for you to construct a Cypher statement.
Do not include any text except the generated Cypher statement.
Examples: Here are a few examples of generated Cypher statements for particular questions:
# How many people played in Top Gun?
MATCH (m:Movie {{name:"Top Gun"}})<-[:ACTED_IN]-()
RETURN count(*) AS numberOfActors

The question is:
{question}"""

CYPHER_GENERATION_PROMPT = PromptTemplate(
    input_variables=["schema", "question"], template=CYPHER_GENERATION_TEMPLATE
)

chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0),
    graph=graph,
    verbose=True,
    cypher_prompt=CYPHER_GENERATION_PROMPT,
)
```


```python
chain.invoke({"query": "How many people played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (m:Movie {name:"Top Gun"})<-[:ACTED_IN]-()
RETURN count(*) AS numberOfActors[0m
Full Context:
[32;1m[1;3m[{'numberOfActors': 4}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'How many people played in Top Gun?',
 'result': 'There were 4 actors in Top Gun.'}
```


## Cypher 및 답변 생성을 위한 별도의 LLM 사용
`cypher_llm` 및 `qa_llm` 매개변수를 사용하여 서로 다른 LLM을 정의할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    graph=graph,
    cypher_llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo"),
    qa_llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo-16k"),
    verbose=True,
)
```


```python
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan played in Top Gun.'}
```


## 지정된 노드 및 관계 유형 무시

`include_types` 또는 `exclude_types`를 사용하여 Cypher 문을 생성할 때 그래프 스키마의 일부를 무시할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    graph=graph,
    cypher_llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo"),
    qa_llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo-16k"),
    verbose=True,
    exclude_types=["Movie"],
)
```


```python
# Inspect graph schema
print(chain.graph_schema)
```

```output
Node properties are the following:
Actor {name: STRING}
Relationship properties are the following:

The relationships are the following:
```

## 생성된 Cypher 문 검증
`validate_cypher` 매개변수를 사용하여 생성된 Cypher 문에서 관계 방향을 검증하고 수정할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo"),
    graph=graph,
    verbose=True,
    validate_cypher=True,
)
```


```python
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan played in Top Gun.'}
```


## 데이터베이스 결과에서 도구/함수 출력으로 컨텍스트 제공

`use_function_response` 매개변수를 사용하여 데이터베이스 결과에서 LLM으로 컨텍스트를 도구/함수 출력으로 전달할 수 있습니다. 이 방법은 LLM이 제공된 컨텍스트를 더 밀접하게 따르므로 응답의 정확성과 관련성을 향상시킵니다.
*이 기능을 사용하려면 네이티브 함수 호출 지원이 있는 LLM을 사용해야 합니다*.

```python
chain = GraphCypherQAChain.from_llm(
    llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo"),
    graph=graph,
    verbose=True,
    use_function_response=True,
)
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'The main actors in Top Gun are Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan.'}
```


함수 응답 기능을 사용할 때 `function_response_system`을 제공하여 모델이 답변을 생성하는 방법에 대한 사용자 지정 시스템 메시지를 제공할 수 있습니다.

*`use_function_response`를 사용할 때 `qa_prompt`는 효과가 없습니다*.

```python
chain = GraphCypherQAChain.from_llm(
    llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo"),
    graph=graph,
    verbose=True,
    use_function_response=True,
    function_response_system="Respond as a pirate!",
)
chain.invoke({"query": "Who played in Top Gun?"})
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'a.name': 'Tom Cruise'}, {'a.name': 'Val Kilmer'}, {'a.name': 'Anthony Edwards'}, {'a.name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': "Arrr matey! In the film Top Gun, ye be seein' Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan sailin' the high seas of the sky! Aye, they be a fine crew of actors, they be!"}
```