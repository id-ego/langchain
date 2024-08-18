---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/graph.ipynb
description: 그래프 데이터베이스에 대한 질문 응답 애플리케이션을 구축하는 방법을 안내합니다. 자연어로 질문에 답변을 제공합니다.
sidebar_position: 0
---

# 그래프 데이터베이스에 대한 질문 답변 애플리케이션 구축

이 가이드에서는 그래프 데이터베이스에서 Q&A 체인을 생성하는 기본 방법을 살펴보겠습니다. 이러한 시스템은 그래프 데이터베이스의 데이터에 대한 질문을 하고 자연어 답변을 받을 수 있게 해줍니다.

## ⚠️ 보안 노트 ⚠️

그래프 데이터베이스의 Q&A 시스템을 구축하려면 모델이 생성한 그래프 쿼리를 실행해야 합니다. 이로 인해 고유한 위험이 발생할 수 있습니다. 데이터베이스 연결 권한이 항상 체인/에이전트의 필요에 맞게 최대한 좁게 설정되어 있는지 확인하세요. 이는 모델 기반 시스템 구축의 위험을 완화하지만 완전히 제거하지는 않습니다. 일반적인 보안 모범 사례에 대한 자세한 내용은 [여기](https://docs/security)를 참조하세요.

## 아키텍처

대체로 대부분의 그래프 체인의 단계는 다음과 같습니다:

1. **질문을 그래프 데이터베이스 쿼리로 변환**: 모델이 사용자 입력을 그래프 데이터베이스 쿼리(예: Cypher)로 변환합니다.
2. **그래프 데이터베이스 쿼리 실행**: 그래프 데이터베이스 쿼리를 실행합니다.
3. **질문에 답하기**: 모델이 쿼리 결과를 사용하여 사용자 입력에 응답합니다.

![sql_usecase.png](../../static/img/graph_usecase.png)

## 설정

먼저 필요한 패키지를 가져오고 환경 변수를 설정합니다. 이 예제에서는 Neo4j 그래프 데이터베이스를 사용할 것입니다.

```python
%pip install --upgrade --quiet  langchain langchain-community langchain-openai neo4j
```


이 가이드에서는 OpenAI 모델을 기본으로 사용합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Uncomment the below to use LangSmith. Not required.
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
```

```output
 ········
```

다음으로 Neo4j 자격 증명을 정의해야 합니다. Neo4j 데이터베이스를 설정하려면 [이 설치 단계](https://neo4j.com/docs/operations-manual/current/installation/)를 따르세요.

```python
os.environ["NEO4J_URI"] = "bolt://localhost:7687"
os.environ["NEO4J_USERNAME"] = "neo4j"
os.environ["NEO4J_PASSWORD"] = "password"
```


아래 예제는 Neo4j 데이터베이스와 연결을 생성하고 영화 및 그 배우에 대한 예제 데이터로 채웁니다.

```python
<!--IMPORTS:[{"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "Build a Question Answering application over a Graph Database"}]-->
from langchain_community.graphs import Neo4jGraph

graph = Neo4jGraph()

# Import movie information

movies_query = """
LOAD CSV WITH HEADERS FROM 
'https://raw.githubusercontent.com/tomasonjo/blog-datasets/main/movies/movies_small.csv'
AS row
MERGE (m:Movie {id:row.movieId})
SET m.released = date(row.released),
    m.title = row.title,
    m.imdbRating = toFloat(row.imdbRating)
FOREACH (director in split(row.director, '|') | 
    MERGE (p:Person {name:trim(director)})
    MERGE (p)-[:DIRECTED]->(m))
FOREACH (actor in split(row.actors, '|') | 
    MERGE (p:Person {name:trim(actor)})
    MERGE (p)-[:ACTED_IN]->(m))
FOREACH (genre in split(row.genres, '|') | 
    MERGE (g:Genre {name:trim(genre)})
    MERGE (m)-[:IN_GENRE]->(g))
"""

graph.query(movies_query)
```


```output
[]
```


## 그래프 스키마

LLM이 Cypher 문을 생성할 수 있으려면 그래프 스키마에 대한 정보가 필요합니다. 그래프 객체를 인스턴스화하면 그래프 스키마에 대한 정보를 검색합니다. 나중에 그래프에 변경 사항을 만들면 `refresh_schema` 메서드를 실행하여 스키마 정보를 새로 고칠 수 있습니다.

```python
graph.refresh_schema()
print(graph.schema)
```

```output
Node properties are the following:
Movie {imdbRating: FLOAT, id: STRING, released: DATE, title: STRING},Person {name: STRING},Genre {name: STRING},Chunk {id: STRING, question: STRING, query: STRING, text: STRING, embedding: LIST}
Relationship properties are the following:

The relationships are the following:
(:Movie)-[:IN_GENRE]->(:Genre),(:Person)-[:DIRECTED]->(:Movie),(:Person)-[:ACTED_IN]->(:Movie)
```

좋습니다! 이제 쿼리할 수 있는 그래프 데이터베이스가 생겼습니다. 이제 이를 LLM에 연결해 보겠습니다.

## 체인

질문을 받아 Cypher 쿼리로 변환하고 쿼리를 실행한 다음 결과를 사용하여 원래 질문에 답하는 간단한 체인을 사용해 보겠습니다.

![graph_chain.webp](../../static/img/graph_chain.webp)

LangChain은 Neo4j와 함께 작동하도록 설계된 이 워크플로우에 대한 내장 체인을 제공합니다: [GraphCypherQAChain](/docs/integrations/graphs/neo4j_cypher)

```python
<!--IMPORTS:[{"imported": "GraphCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher.GraphCypherQAChain.html", "title": "Build a Question Answering application over a Graph Database"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Build a Question Answering application over a Graph Database"}]-->
from langchain.chains import GraphCypherQAChain
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
chain = GraphCypherQAChain.from_llm(graph=graph, llm=llm, verbose=True)
response = chain.invoke({"query": "What was the cast of the Casino?"})
response
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (:Movie {title: "Casino"})<-[:ACTED_IN]-(actor:Person)
RETURN actor.name[0m
Full Context:
[32;1m[1;3m[{'actor.name': 'Joe Pesci'}, {'actor.name': 'Robert De Niro'}, {'actor.name': 'Sharon Stone'}, {'actor.name': 'James Woods'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'What was the cast of the Casino?',
 'result': 'The cast of Casino included Joe Pesci, Robert De Niro, Sharon Stone, and James Woods.'}
```


# 관계 방향 검증

LLM은 생성된 Cypher 문에서 관계 방향에 어려움을 겪을 수 있습니다. 그래프 스키마가 미리 정의되어 있으므로 `validate_cypher` 매개변수를 사용하여 생성된 Cypher 문에서 관계 방향을 검증하고 선택적으로 수정할 수 있습니다.

```python
chain = GraphCypherQAChain.from_llm(
    graph=graph, llm=llm, verbose=True, validate_cypher=True
)
response = chain.invoke({"query": "What was the cast of the Casino?"})
response
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (:Movie {title: "Casino"})<-[:ACTED_IN]-(actor:Person)
RETURN actor.name[0m
Full Context:
[32;1m[1;3m[{'actor.name': 'Joe Pesci'}, {'actor.name': 'Robert De Niro'}, {'actor.name': 'Sharon Stone'}, {'actor.name': 'James Woods'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'What was the cast of the Casino?',
 'result': 'The cast of Casino included Joe Pesci, Robert De Niro, Sharon Stone, and James Woods.'}
```


### 다음 단계

보다 복잡한 쿼리 생성을 위해 몇 가지 샘플 프롬프트를 만들거나 쿼리 확인 단계를 추가할 수 있습니다. 이러한 고급 기술 및 기타에 대한 자세한 내용은 다음을 확인하세요:

* [프롬프트 전략](/docs/how_to/graph_prompting): 고급 프롬프트 엔지니어링 기술.
* [값 매핑](/docs/how_to/graph_mapping): 질문에서 데이터베이스로 값을 매핑하는 기술.
* [시맨틱 레이어](/docs/how_to/graph_semantic): 시맨틱 레이어를 구현하는 기술.
* [그래프 구성](/docs/how_to/graph_constructing): 지식 그래프를 구성하는 기술.