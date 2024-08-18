---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/apache_age.ipynb
description: Apache AGE는 PostgreSQL 확장으로 그래프 데이터베이스 기능을 제공하며, 관계형 및 그래프 모델 데이터를 단일
  저장소에서 처리할 수 있습니다.
---

# 아파치 AGE

> [아파치 AGE](https://age.apache.org/)는 그래프 데이터베이스 기능을 제공하는 PostgreSQL 확장입니다. AGE는 A Graph Extension의 약자로, Bitnine의 PostgreSQL 10 포크인 AgensGraph에서 영감을 받았으며, 이는 다중 모델 데이터베이스입니다. 이 프로젝트의 목표는 관계형 및 그래프 모델 데이터를 모두 처리할 수 있는 단일 저장소를 만드는 것으로, 사용자가 표준 ANSI SQL과 그래프 쿼리 언어인 openCypher를 함께 사용할 수 있도록 하는 것입니다. `Apache AGE`가 저장하는 데이터 요소는 노드, 이를 연결하는 엣지, 그리고 노드와 엣지의 속성입니다.

> 이 노트북은 LLM을 사용하여 `Cypher` 쿼리 언어로 쿼리할 수 있는 그래프 데이터베이스에 자연어 인터페이스를 제공하는 방법을 보여줍니다.

> [Cypher](https://en.wikipedia.org/wiki/Cypher_(query_language))는 속성 그래프에서 표현력 있고 효율적인 데이터 쿼리를 가능하게 하는 선언적 그래프 쿼리 언어입니다.

## 설정하기

AGE 확장이 설치된 `Postgre` 인스턴스가 실행 중이어야 합니다. 테스트를 위한 한 가지 옵션은 공식 AGE 도커 이미지를 사용하여 도커 컨테이너를 실행하는 것입니다. 다음 스크립트를 실행하여 로컬 도커 컨테이너를 실행할 수 있습니다:

```
docker run \
    --name age  \
    -p 5432:5432 \
    -e POSTGRES_USER=postgresUser \
    -e POSTGRES_PASSWORD=postgresPW \
    -e POSTGRES_DB=postgresDB \
    -d \
    apache/age
```


도커에서 실행하는 방법에 대한 추가 지침은 [여기](https://hub.docker.com/r/apache/age)에서 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "GraphCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher.GraphCypherQAChain.html", "title": "Apache AGE"}, {"imported": "AGEGraph", "source": "langchain_community.graphs.age_graph", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.age_graph.AGEGraph.html", "title": "Apache AGE"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Apache AGE"}]-->
from langchain.chains import GraphCypherQAChain
from langchain_community.graphs.age_graph import AGEGraph
from langchain_openai import ChatOpenAI
```


```python
conf = {
    "database": "postgresDB",
    "user": "postgresUser",
    "password": "postgresPW",
    "host": "localhost",
    "port": 5432,
}

graph = AGEGraph(graph_name="age_test", conf=conf)
```


## 데이터베이스 초기화

데이터베이스가 비어 있다고 가정하면 Cypher 쿼리 언어를 사용하여 데이터를 채울 수 있습니다. 다음 Cypher 문장은 아이도포턴트이며, 이는 한 번 또는 여러 번 실행해도 데이터베이스 정보가 동일하다는 것을 의미합니다.

```python
graph.query(
    """
MERGE (m:Movie {name:"Top Gun"})
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
데이터베이스의 스키마가 변경되면 Cypher 문장을 생성하는 데 필요한 스키마 정보를 새로 고칠 수 있습니다.

```python
graph.refresh_schema()
```


```python
print(graph.schema)
```

```output

        Node properties are the following:
        [{'properties': [{'property': 'name', 'type': 'STRING'}], 'labels': 'Actor'}, {'properties': [{'property': 'property_a', 'type': 'STRING'}], 'labels': 'LabelA'}, {'properties': [], 'labels': 'LabelB'}, {'properties': [], 'labels': 'LabelC'}, {'properties': [{'property': 'name', 'type': 'STRING'}], 'labels': 'Movie'}]
        Relationship properties are the following:
        [{'properties': [], 'type': 'ACTED_IN'}, {'properties': [{'property': 'rel_prop', 'type': 'STRING'}], 'type': 'REL_TYPE'}]
        The relationships are the following:
        ['(:`Actor`)-[:`ACTED_IN`]->(:`Movie`)', '(:`LabelA`)-[:`REL_TYPE`]->(:`LabelB`)', '(:`LabelA`)-[:`REL_TYPE`]->(:`LabelC`)']
```


## 그래프 쿼리하기

이제 그래프에 대한 질문을 하기 위해 그래프 Cypher QA 체인을 사용할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True
)
```


```python
chain.invoke("Who played in Top Gun?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
``````output
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'name': 'Tom Cruise'}, {'name': 'Val Kilmer'}, {'name': 'Anthony Edwards'}, {'name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer, Anthony Edwards, Meg Ryan played in Top Gun.'}
```


## 결과 수 제한
`top_k` 매개변수를 사용하여 Cypher QA 체인에서 결과 수를 제한할 수 있습니다. 기본값은 10입니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True, top_k=2
)
```


```python
chain.invoke("Who played in Top Gun?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie {name: 'Top Gun'})
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'name': 'Tom Cruise'}, {'name': 'Val Kilmer'}][0m

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
result = chain("Who played in Top Gun?")
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
[32;1m[1;3m[{'name': 'Tom Cruise'}, {'name': 'Val Kilmer'}, {'name': 'Anthony Edwards'}, {'name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
Intermediate steps: [{'query': "MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)\nWHERE m.name = 'Top Gun'\nRETURN a.name"}, {'context': [{'name': 'Tom Cruise'}, {'name': 'Val Kilmer'}, {'name': 'Anthony Edwards'}, {'name': 'Meg Ryan'}]}]
Final answer: Tom Cruise, Val Kilmer, Anthony Edwards, Meg Ryan played in Top Gun.
```


## 직접 결과 반환
`return_direct` 매개변수를 사용하여 Cypher QA 체인에서 직접 결과를 반환할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True, return_direct=True
)
```


```python
chain.invoke("Who played in Top Gun?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie {name: 'Top Gun'})
RETURN a.name[0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': [{'name': 'Tom Cruise'},
  {'name': 'Val Kilmer'},
  {'name': 'Anthony Edwards'},
  {'name': 'Meg Ryan'}]}
```


## Cypher 생성 프롬프트에 예제 추가
특정 질문에 대해 LLM이 생성하기를 원하는 Cypher 문장을 정의할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts.prompt", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Apache AGE"}]-->
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
MATCH (m:Movie {{title:"Top Gun"}})<-[:ACTED_IN]-()
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
chain.invoke("How many people played in Top Gun?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
``````output
Generated Cypher:
[32;1m[1;3mMATCH (:Movie {name:"Top Gun"})<-[:ACTED_IN]-(:Actor)
RETURN count(*) AS numberOfActors[0m
Full Context:
[32;1m[1;3m[{'numberofactors': 4}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'How many people played in Top Gun?',
 'result': "I don't know the answer."}
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
chain.invoke("Who played in Top Gun?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
``````output
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'name': 'Tom Cruise'}, {'name': 'Val Kilmer'}, {'name': 'Anthony Edwards'}, {'name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer, Anthony Edwards, and Meg Ryan played in Top Gun.'}
```


## 지정된 노드 및 관계 유형 무시

Cypher 문장을 생성할 때 그래프 스키마의 일부를 무시하기 위해 `include_types` 또는 `exclude_types`를 사용할 수 있습니다.

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
Actor {name: STRING},LabelA {property_a: STRING},LabelB {},LabelC {}
Relationship properties are the following:
ACTED_IN {},REL_TYPE {rel_prop: STRING}
The relationships are the following:
(:LabelA)-[:REL_TYPE]->(:LabelB),(:LabelA)-[:REL_TYPE]->(:LabelC)
```


## 생성된 Cypher 문장 검증
`validate_cypher` 매개변수를 사용하여 생성된 Cypher 문장에서 관계 방향을 검증하고 수정할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo"),
    graph=graph,
    verbose=True,
    validate_cypher=True,
)
```


```python
chain.invoke("Who played in Top Gun?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE m.name = 'Top Gun'
RETURN a.name[0m
Full Context:
[32;1m[1;3m[{'name': 'Tom Cruise'}, {'name': 'Val Kilmer'}, {'name': 'Anthony Edwards'}, {'name': 'Meg Ryan'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who played in Top Gun?',
 'result': 'Tom Cruise, Val Kilmer, Anthony Edwards, Meg Ryan played in Top Gun.'}
```