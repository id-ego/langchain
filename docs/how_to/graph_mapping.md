---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/graph_mapping.ipynb
description: 사용자 입력 값을 그래프 데이터베이스에 매핑하여 쿼리 생성을 개선하는 전략을 다루는 가이드입니다.
sidebar_position: 1
---

# 그래프 데이터베이스에 값을 매핑하는 방법

이 가이드에서는 사용자 입력의 값을 데이터베이스에 매핑하여 그래프 데이터베이스 쿼리 생성을 개선하는 전략을 살펴보겠습니다. 내장 그래프 체인을 사용할 때 LLM은 그래프 스키마를 인식하지만 데이터베이스에 저장된 속성의 값에 대한 정보는 없습니다. 따라서 값을 정확하게 매핑하기 위해 그래프 데이터베이스 QA 시스템에 새로운 단계를 도입할 수 있습니다.

## 설정

먼저 필요한 패키지를 가져오고 환경 변수를 설정합니다:

```python
%pip install --upgrade --quiet  langchain langchain-community langchain-openai neo4j
```


이 가이드에서는 OpenAI 모델을 기본으로 사용하지만, 원하는 모델 제공자로 교체할 수 있습니다.

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

다음으로 Neo4j 자격 증명을 정의해야 합니다. [이 설치 단계](https://neo4j.com/docs/operations-manual/current/installation/)를 따라 Neo4j 데이터베이스를 설정하세요.

```python
os.environ["NEO4J_URI"] = "bolt://localhost:7687"
os.environ["NEO4J_USERNAME"] = "neo4j"
os.environ["NEO4J_PASSWORD"] = "password"
```


아래 예제는 Neo4j 데이터베이스와 연결을 생성하고 영화 및 그 배우에 대한 예제 데이터로 채웁니다.

```python
<!--IMPORTS:[{"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "How to map values to a graph database"}]-->
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


## 사용자 입력에서 엔티티 감지
우리는 그래프 데이터베이스에 매핑할 엔티티/값의 유형을 추출해야 합니다. 이 예제에서는 영화 그래프를 다루고 있으므로 영화와 사람을 데이터베이스에 매핑할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to map values to a graph database"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to map values to a graph database"}]-->
from typing import List, Optional

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)


class Entities(BaseModel):
    """Identifying information about entities."""

    names: List[str] = Field(
        ...,
        description="All the person or movies appearing in the text",
    )


prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are extracting person and movies from the text.",
        ),
        (
            "human",
            "Use the given format to extract information from the following "
            "input: {question}",
        ),
    ]
)


entity_chain = prompt | llm.with_structured_output(Entities)
```


엔티티 추출 체인을 테스트할 수 있습니다.

```python
entities = entity_chain.invoke({"question": "Who played in Casino movie?"})
entities
```


```output
Entities(names=['Casino'])
```


우리는 엔티티를 데이터베이스에 매칭하기 위해 간단한 `CONTAINS` 절을 활용할 것입니다. 실제로는 약간의 철자 오류를 허용하기 위해 퍼지 검색이나 전체 텍스트 인덱스를 사용하는 것이 좋습니다.

```python
match_query = """MATCH (p:Person|Movie)
WHERE p.name CONTAINS $value OR p.title CONTAINS $value
RETURN coalesce(p.name, p.title) AS result, labels(p)[0] AS type
LIMIT 1
"""


def map_to_database(entities: Entities) -> Optional[str]:
    result = ""
    for entity in entities.names:
        response = graph.query(match_query, {"value": entity})
        try:
            result += f"{entity} maps to {response[0]['result']} {response[0]['type']} in database\n"
        except IndexError:
            pass
    return result


map_to_database(entities)
```


```output
'Casino maps to Casino Movie in database\n'
```


## 사용자 정의 Cypher 생성 체인

우리는 엔티티 매핑 정보와 스키마, 사용자 질문을 사용하여 Cypher 문을 구성하는 사용자 정의 Cypher 프롬프트를 정의해야 합니다. 이를 위해 LangChain 표현 언어를 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to map values to a graph database"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to map values to a graph database"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

# Generate Cypher statement based on natural language input
cypher_template = """Based on the Neo4j graph schema below, write a Cypher query that would answer the user's question:
{schema}
Entities in the question map to the following database values:
{entities_list}
Question: {question}
Cypher query:"""

cypher_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Given an input question, convert it to a Cypher query. No pre-amble.",
        ),
        ("human", cypher_template),
    ]
)

cypher_response = (
    RunnablePassthrough.assign(names=entity_chain)
    | RunnablePassthrough.assign(
        entities_list=lambda x: map_to_database(x["names"]),
        schema=lambda _: graph.get_schema,
    )
    | cypher_prompt
    | llm.bind(stop=["\nCypherResult:"])
    | StrOutputParser()
)
```


```python
cypher = cypher_response.invoke({"question": "Who played in Casino movie?"})
cypher
```


```output
'MATCH (:Movie {title: "Casino"})<-[:ACTED_IN]-(actor)\nRETURN actor.name'
```


## 데이터베이스 결과를 기반으로 답변 생성

이제 Cypher 문을 생성하는 체인이 있으므로, 데이터베이스에 대해 Cypher 문을 실행하고 데이터베이스 결과를 LLM에 다시 보내 최종 답변을 생성해야 합니다. 다시 말해, 우리는 LCEL을 사용할 것입니다.

```python
<!--IMPORTS:[{"imported": "CypherQueryCorrector", "source": "langchain_community.chains.graph_qa.cypher_utils", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher_utils.CypherQueryCorrector.html", "title": "How to map values to a graph database"}, {"imported": "Schema", "source": "langchain_community.chains.graph_qa.cypher_utils", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher_utils.Schema.html", "title": "How to map values to a graph database"}]-->
from langchain_community.chains.graph_qa.cypher_utils import (
    CypherQueryCorrector,
    Schema,
)

# Cypher validation tool for relationship directions
corrector_schema = [
    Schema(el["start"], el["type"], el["end"])
    for el in graph.structured_schema.get("relationships")
]
cypher_validation = CypherQueryCorrector(corrector_schema)

# Generate natural language response based on database results
response_template = """Based on the the question, Cypher query, and Cypher response, write a natural language response:
Question: {question}
Cypher query: {query}
Cypher Response: {response}"""

response_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Given an input question and Cypher response, convert it to a natural"
            " language answer. No pre-amble.",
        ),
        ("human", response_template),
    ]
)

chain = (
    RunnablePassthrough.assign(query=cypher_response)
    | RunnablePassthrough.assign(
        response=lambda x: graph.query(cypher_validation(x["query"])),
    )
    | response_prompt
    | llm
    | StrOutputParser()
)
```


```python
chain.invoke({"question": "Who played in Casino movie?"})
```


```output
'Robert De Niro, James Woods, Joe Pesci, and Sharon Stone played in the movie "Casino".'
```