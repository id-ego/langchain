---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/graph_prompting.ipynb
description: 그래프 데이터베이스 쿼리 생성을 개선하기 위한 프롬프트 전략과 Neo4j 데이터베이스 설정 방법을 안내하는 가이드입니다.
sidebar_position: 2
---

# 그래프-RAG에 대한 최적의 프롬프트 방법

이 가이드에서는 그래프 데이터베이스 쿼리 생성을 개선하기 위한 프롬프트 전략에 대해 설명합니다. 우리는 주로 프롬프트에서 관련 데이터베이스 특정 정보를 얻는 방법에 집중할 것입니다.

## 설정

먼저, 필요한 패키지를 가져오고 환경 변수를 설정합니다:

```python
%pip install --upgrade --quiet  langchain langchain-community langchain-openai neo4j
```

```output
Note: you may need to restart the kernel to use updated packages.
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

다음으로, Neo4j 자격 증명을 정의해야 합니다.
[이 설치 단계](https://neo4j.com/docs/operations-manual/current/installation/)를 따라 Neo4j 데이터베이스를 설정하세요.

```python
os.environ["NEO4J_URI"] = "bolt://localhost:7687"
os.environ["NEO4J_USERNAME"] = "neo4j"
os.environ["NEO4J_PASSWORD"] = "password"
```


아래 예제는 Neo4j 데이터베이스와 연결을 생성하고 영화 및 그 배우에 대한 예제 데이터로 채웁니다.

```python
<!--IMPORTS:[{"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "How to best prompt for Graph-RAG"}]-->
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


# 그래프 스키마 필터링

때때로 Cypher 문을 생성할 때 그래프 스키마의 특정 하위 집합에 집중해야 할 필요가 있습니다.
다음 그래프 스키마를 다룬다고 가정해 보겠습니다:

```python
graph.refresh_schema()
print(graph.schema)
```

```output
Node properties are the following:
Movie {imdbRating: FLOAT, id: STRING, released: DATE, title: STRING},Person {name: STRING},Genre {name: STRING}
Relationship properties are the following:

The relationships are the following:
(:Movie)-[:IN_GENRE]->(:Genre),(:Person)-[:DIRECTED]->(:Movie),(:Person)-[:ACTED_IN]->(:Movie)
```

*장르* 노드를 LLM에 전달하는 스키마 표현에서 제외하고 싶다고 가정해 보겠습니다.
GraphCypherQAChain 체인의 `exclude` 매개변수를 사용하여 이를 달성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "GraphCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher.GraphCypherQAChain.html", "title": "How to best prompt for Graph-RAG"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to best prompt for Graph-RAG"}]-->
from langchain.chains import GraphCypherQAChain
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
chain = GraphCypherQAChain.from_llm(
    graph=graph, llm=llm, exclude_types=["Genre"], verbose=True
)
```


```python
print(chain.graph_schema)
```

```output
Node properties are the following:
Movie {imdbRating: FLOAT, id: STRING, released: DATE, title: STRING},Person {name: STRING}
Relationship properties are the following:

The relationships are the following:
(:Person)-[:DIRECTED]->(:Movie),(:Person)-[:ACTED_IN]->(:Movie)
```

## 몇 가지 샷 예제

프롬프트에 자연어 질문이 데이터베이스에 대한 유효한 Cypher 쿼리로 변환되는 예제를 포함하면 모델 성능이 향상되는 경우가 많습니다. 특히 복잡한 쿼리의 경우 더욱 그렇습니다.

다음과 같은 예제가 있다고 가정해 보겠습니다:

```python
examples = [
    {
        "question": "How many artists are there?",
        "query": "MATCH (a:Person)-[:ACTED_IN]->(:Movie) RETURN count(DISTINCT a)",
    },
    {
        "question": "Which actors played in the movie Casino?",
        "query": "MATCH (m:Movie {{title: 'Casino'}})<-[:ACTED_IN]-(a) RETURN a.name",
    },
    {
        "question": "How many movies has Tom Hanks acted in?",
        "query": "MATCH (a:Person {{name: 'Tom Hanks'}})-[:ACTED_IN]->(m:Movie) RETURN count(m)",
    },
    {
        "question": "List all the genres of the movie Schindler's List",
        "query": "MATCH (m:Movie {{title: 'Schindler\\'s List'}})-[:IN_GENRE]->(g:Genre) RETURN g.name",
    },
    {
        "question": "Which actors have worked in movies from both the comedy and action genres?",
        "query": "MATCH (a:Person)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g1:Genre), (a)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g2:Genre) WHERE g1.name = 'Comedy' AND g2.name = 'Action' RETURN DISTINCT a.name",
    },
    {
        "question": "Which directors have made movies with at least three different actors named 'John'?",
        "query": "MATCH (d:Person)-[:DIRECTED]->(m:Movie)<-[:ACTED_IN]-(a:Person) WHERE a.name STARTS WITH 'John' WITH d, COUNT(DISTINCT a) AS JohnsCount WHERE JohnsCount >= 3 RETURN d.name",
    },
    {
        "question": "Identify movies where directors also played a role in the film.",
        "query": "MATCH (p:Person)-[:DIRECTED]->(m:Movie), (p)-[:ACTED_IN]->(m) RETURN m.title, p.name",
    },
    {
        "question": "Find the actor with the highest number of movies in the database.",
        "query": "MATCH (a:Actor)-[:ACTED_IN]->(m:Movie) RETURN a.name, COUNT(m) AS movieCount ORDER BY movieCount DESC LIMIT 1",
    },
]
```


이들을 사용하여 몇 가지 샷 프롬프트를 다음과 같이 만들 수 있습니다:

```python
<!--IMPORTS:[{"imported": "FewShotPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotPromptTemplate.html", "title": "How to best prompt for Graph-RAG"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to best prompt for Graph-RAG"}]-->
from langchain_core.prompts import FewShotPromptTemplate, PromptTemplate

example_prompt = PromptTemplate.from_template(
    "User input: {question}\nCypher query: {query}"
)
prompt = FewShotPromptTemplate(
    examples=examples[:5],
    example_prompt=example_prompt,
    prefix="You are a Neo4j expert. Given an input question, create a syntactically correct Cypher query to run.\n\nHere is the schema information\n{schema}.\n\nBelow are a number of examples of questions and their corresponding Cypher queries.",
    suffix="User input: {question}\nCypher query: ",
    input_variables=["question", "schema"],
)
```


```python
print(prompt.format(question="How many artists are there?", schema="foo"))
```

```output
You are a Neo4j expert. Given an input question, create a syntactically correct Cypher query to run.

Here is the schema information
foo.

Below are a number of examples of questions and their corresponding Cypher queries.

User input: How many artists are there?
Cypher query: MATCH (a:Person)-[:ACTED_IN]->(:Movie) RETURN count(DISTINCT a)

User input: Which actors played in the movie Casino?
Cypher query: MATCH (m:Movie {title: 'Casino'})<-[:ACTED_IN]-(a) RETURN a.name

User input: How many movies has Tom Hanks acted in?
Cypher query: MATCH (a:Person {name: 'Tom Hanks'})-[:ACTED_IN]->(m:Movie) RETURN count(m)

User input: List all the genres of the movie Schindler's List
Cypher query: MATCH (m:Movie {title: 'Schindler\'s List'})-[:IN_GENRE]->(g:Genre) RETURN g.name

User input: Which actors have worked in movies from both the comedy and action genres?
Cypher query: MATCH (a:Person)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g1:Genre), (a)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g2:Genre) WHERE g1.name = 'Comedy' AND g2.name = 'Action' RETURN DISTINCT a.name

User input: How many artists are there?
Cypher query:
```

## 동적 몇 가지 샷 예제

충분한 예제가 있다면, 모델의 컨텍스트 창에 맞지 않거나 긴 예제 목록이 모델을 방해하기 때문에 가장 관련성이 높은 예제만 프롬프트에 포함하고 싶을 수 있습니다. 특히, 주어진 입력에 대해 가장 관련성이 높은 예제를 포함하고 싶습니다.

우리는 ExampleSelector를 사용하여 이를 수행할 수 있습니다. 이 경우 [SemanticSimilarityExampleSelector](https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html)를 사용하여 선택한 벡터 데이터베이스에 예제를 저장합니다. 런타임에 입력과 예제 간의 유사성 검색을 수행하고 가장 의미적으로 유사한 예제를 반환합니다:

```python
<!--IMPORTS:[{"imported": "Neo4jVector", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.neo4j_vector.Neo4jVector.html", "title": "How to best prompt for Graph-RAG"}, {"imported": "SemanticSimilarityExampleSelector", "source": "langchain_core.example_selectors", "docs": "https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html", "title": "How to best prompt for Graph-RAG"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to best prompt for Graph-RAG"}]-->
from langchain_community.vectorstores import Neo4jVector
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_openai import OpenAIEmbeddings

example_selector = SemanticSimilarityExampleSelector.from_examples(
    examples,
    OpenAIEmbeddings(),
    Neo4jVector,
    k=5,
    input_keys=["question"],
)
```


```python
example_selector.select_examples({"question": "how many artists are there?"})
```


```output
[{'query': 'MATCH (a:Person)-[:ACTED_IN]->(:Movie) RETURN count(DISTINCT a)',
  'question': 'How many artists are there?'},
 {'query': "MATCH (a:Person {{name: 'Tom Hanks'}})-[:ACTED_IN]->(m:Movie) RETURN count(m)",
  'question': 'How many movies has Tom Hanks acted in?'},
 {'query': "MATCH (a:Person)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g1:Genre), (a)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g2:Genre) WHERE g1.name = 'Comedy' AND g2.name = 'Action' RETURN DISTINCT a.name",
  'question': 'Which actors have worked in movies from both the comedy and action genres?'},
 {'query': "MATCH (d:Person)-[:DIRECTED]->(m:Movie)<-[:ACTED_IN]-(a:Person) WHERE a.name STARTS WITH 'John' WITH d, COUNT(DISTINCT a) AS JohnsCount WHERE JohnsCount >= 3 RETURN d.name",
  'question': "Which directors have made movies with at least three different actors named 'John'?"},
 {'query': 'MATCH (a:Actor)-[:ACTED_IN]->(m:Movie) RETURN a.name, COUNT(m) AS movieCount ORDER BY movieCount DESC LIMIT 1',
  'question': 'Find the actor with the highest number of movies in the database.'}]
```


사용하려면, ExampleSelector를 직접 FewShotPromptTemplate에 전달할 수 있습니다:

```python
prompt = FewShotPromptTemplate(
    example_selector=example_selector,
    example_prompt=example_prompt,
    prefix="You are a Neo4j expert. Given an input question, create a syntactically correct Cypher query to run.\n\nHere is the schema information\n{schema}.\n\nBelow are a number of examples of questions and their corresponding Cypher queries.",
    suffix="User input: {question}\nCypher query: ",
    input_variables=["question", "schema"],
)
```


```python
print(prompt.format(question="how many artists are there?", schema="foo"))
```

```output
You are a Neo4j expert. Given an input question, create a syntactically correct Cypher query to run.

Here is the schema information
foo.

Below are a number of examples of questions and their corresponding Cypher queries.

User input: How many artists are there?
Cypher query: MATCH (a:Person)-[:ACTED_IN]->(:Movie) RETURN count(DISTINCT a)

User input: How many movies has Tom Hanks acted in?
Cypher query: MATCH (a:Person {name: 'Tom Hanks'})-[:ACTED_IN]->(m:Movie) RETURN count(m)

User input: Which actors have worked in movies from both the comedy and action genres?
Cypher query: MATCH (a:Person)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g1:Genre), (a)-[:ACTED_IN]->(:Movie)-[:IN_GENRE]->(g2:Genre) WHERE g1.name = 'Comedy' AND g2.name = 'Action' RETURN DISTINCT a.name

User input: Which directors have made movies with at least three different actors named 'John'?
Cypher query: MATCH (d:Person)-[:DIRECTED]->(m:Movie)<-[:ACTED_IN]-(a:Person) WHERE a.name STARTS WITH 'John' WITH d, COUNT(DISTINCT a) AS JohnsCount WHERE JohnsCount >= 3 RETURN d.name

User input: Find the actor with the highest number of movies in the database.
Cypher query: MATCH (a:Actor)-[:ACTED_IN]->(m:Movie) RETURN a.name, COUNT(m) AS movieCount ORDER BY movieCount DESC LIMIT 1

User input: how many artists are there?
Cypher query:
```


```python
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
chain = GraphCypherQAChain.from_llm(
    graph=graph, llm=llm, cypher_prompt=prompt, verbose=True
)
```


```python
chain.invoke("How many actors are in the graph?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (a:Person)-[:ACTED_IN]->(:Movie) RETURN count(DISTINCT a)[0m
Full Context:
[32;1m[1;3m[{'count(DISTINCT a)': 967}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'How many actors are in the graph?',
 'result': 'There are 967 actors in the graph.'}
```