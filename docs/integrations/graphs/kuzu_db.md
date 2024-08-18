---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/kuzu_db.ipynb
description: Kùzu는 쿼리 속도와 확장성을 위해 설계된 임베디드 속성 그래프 데이터베이스 관리 시스템입니다. Cypher를 사용하여 효율적인
  데이터 쿼리를 제공합니다.
---

# Kuzu

> [Kùzu](https://kuzudb.com)는 쿼리 속도와 확장성을 위해 구축된 임베디드 속성 그래프 데이터베이스 관리 시스템입니다.
> 
> Kùzu는 관대한 (MIT) 오픈 소스 라이센스를 가지고 있으며, 속성 그래프에서 표현력 있고 효율적인 데이터 쿼리를 허용하는 선언적 그래프 쿼리 언어인 [Cypher](https://en.wikipedia.org/wiki/Cypher_(query_language))를 구현합니다. 
열 저장소를 사용하며, 쿼리 프로세서에는 쿼리 성능을 희생하지 않고 매우 큰 그래프에 확장할 수 있는 새로운 조인 알고리즘이 포함되어 있습니다.
> 
> 이 노트북은 LLM을 사용하여 [Kùzu](https://kuzudb.com) 데이터베이스에 Cypher를 통해 자연어 인터페이스를 제공하는 방법을 보여줍니다.

## 설정하기

Kùzu는 임베디드 데이터베이스(프로세스 내에서 실행됨)로, 관리할 서버가 없습니다.
단순히 Python 패키지를 통해 설치합니다:

```bash
pip install kuzu
```


로컬 머신에 데이터베이스를 생성하고 연결합니다:

```python
import kuzu

db = kuzu.Database("test_db")
conn = kuzu.Connection(db)
```


먼저, 간단한 영화 데이터베이스의 스키마를 생성합니다:

```python
conn.execute("CREATE NODE TABLE Movie (name STRING, PRIMARY KEY(name))")
conn.execute(
    "CREATE NODE TABLE Person (name STRING, birthDate STRING, PRIMARY KEY(name))"
)
conn.execute("CREATE REL TABLE ActedIn (FROM Person TO Movie)")
```


```output
<kuzu.query_result.QueryResult at 0x103a72290>
```


그런 다음 일부 데이터를 삽입할 수 있습니다.

```python
conn.execute("CREATE (:Person {name: 'Al Pacino', birthDate: '1940-04-25'})")
conn.execute("CREATE (:Person {name: 'Robert De Niro', birthDate: '1943-08-17'})")
conn.execute("CREATE (:Movie {name: 'The Godfather'})")
conn.execute("CREATE (:Movie {name: 'The Godfather: Part II'})")
conn.execute(
    "CREATE (:Movie {name: 'The Godfather Coda: The Death of Michael Corleone'})"
)
conn.execute(
    "MATCH (p:Person), (m:Movie) WHERE p.name = 'Al Pacino' AND m.name = 'The Godfather' CREATE (p)-[:ActedIn]->(m)"
)
conn.execute(
    "MATCH (p:Person), (m:Movie) WHERE p.name = 'Al Pacino' AND m.name = 'The Godfather: Part II' CREATE (p)-[:ActedIn]->(m)"
)
conn.execute(
    "MATCH (p:Person), (m:Movie) WHERE p.name = 'Al Pacino' AND m.name = 'The Godfather Coda: The Death of Michael Corleone' CREATE (p)-[:ActedIn]->(m)"
)
conn.execute(
    "MATCH (p:Person), (m:Movie) WHERE p.name = 'Robert De Niro' AND m.name = 'The Godfather: Part II' CREATE (p)-[:ActedIn]->(m)"
)
```


```output
<kuzu.query_result.QueryResult at 0x103a9e750>
```


## `KuzuQAChain` 생성하기

이제 `KuzuGraph`와 `KuzuQAChain`을 생성할 수 있습니다. `KuzuGraph`를 생성하려면 데이터베이스 객체를 `KuzuGraph` 생성자에 전달하기만 하면 됩니다.

```python
<!--IMPORTS:[{"imported": "KuzuQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.kuzu.KuzuQAChain.html", "title": "Kuzu"}, {"imported": "KuzuGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.kuzu_graph.KuzuGraph.html", "title": "Kuzu"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Kuzu"}]-->
from langchain.chains import KuzuQAChain
from langchain_community.graphs import KuzuGraph
from langchain_openai import ChatOpenAI
```


```python
graph = KuzuGraph(db)
```


```python
chain = KuzuQAChain.from_llm(
    llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo-16k"),
    graph=graph,
    verbose=True,
)
```


## 그래프 스키마 정보 새로 고침

데이터베이스의 스키마가 변경되면 Cypher 문을 생성하는 데 필요한 스키마 정보를 새로 고칠 수 있습니다.
아래와 같이 Kùzu 그래프의 스키마를 표시할 수도 있습니다.

```python
# graph.refresh_schema()
```


```python
print(graph.get_schema)
```

```output
Node properties: [{'properties': [('name', 'STRING')], 'label': 'Movie'}, {'properties': [('name', 'STRING'), ('birthDate', 'STRING')], 'label': 'Person'}]
Relationships properties: [{'properties': [], 'label': 'ActedIn'}]
Relationships: ['(:Person)-[:ActedIn]->(:Movie)']
```


## 그래프 쿼리하기

이제 `KuzuQAChain`을 사용하여 그래프에 질문할 수 있습니다.

```python
chain.invoke("Who acted in The Godfather: Part II?")
```

```output


[1m> Entering new KuzuQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person)-[:ActedIn]->(m:Movie)
WHERE m.name = 'The Godfather: Part II'
RETURN p.name[0m
Full Context:
[32;1m[1;3m[{'p.name': 'Al Pacino'}, {'p.name': 'Robert De Niro'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who acted in The Godfather: Part II?',
 'result': 'Al Pacino, Robert De Niro acted in The Godfather: Part II.'}
```


```python
chain.invoke("Robert De Niro played in which movies?")
```

```output


[1m> Entering new KuzuQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person)-[:ActedIn]->(m:Movie)
WHERE p.name = 'Robert De Niro'
RETURN m.name[0m
Full Context:
[32;1m[1;3m[{'m.name': 'The Godfather: Part II'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Robert De Niro played in which movies?',
 'result': 'Robert De Niro played in The Godfather: Part II.'}
```


```python
chain.invoke("How many actors played in the Godfather: Part II?")
```

```output


[1m> Entering new KuzuQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (:Person)-[:ActedIn]->(:Movie {name: 'Godfather: Part II'})
RETURN count(*)[0m
Full Context:
[32;1m[1;3m[{'COUNT_STAR()': 0}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'How many actors played in the Godfather: Part II?',
 'result': "I don't know the answer."}
```


```python
chain.invoke("Who is the oldest actor who played in The Godfather: Part II?")
```

```output


[1m> Entering new KuzuQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person)-[:ActedIn]->(m:Movie {name: 'The Godfather: Part II'})
RETURN p.name
ORDER BY p.birthDate ASC
LIMIT 1[0m
Full Context:
[32;1m[1;3m[{'p.name': 'Al Pacino'}][0m

[1m> Finished chain.[0m
```


```output
{'query': 'Who is the oldest actor who played in The Godfather: Part II?',
 'result': 'Al Pacino is the oldest actor who played in The Godfather: Part II.'}
```


## Cypher 및 답변 생성을 위한 별도의 LLM 사용하기

Cypher 생성 및 답변 생성을 위해 서로 다른 LLM을 사용하려면 `cypher_llm`과 `qa_llm`을 별도로 지정할 수 있습니다.

```python
chain = KuzuQAChain.from_llm(
    cypher_llm=ChatOpenAI(temperature=0, model="gpt-3.5-turbo-16k"),
    qa_llm=ChatOpenAI(temperature=0, model="gpt-4"),
    graph=graph,
    verbose=True,
)
```

```output
/Users/prrao/code/langchain/.venv/lib/python3.11/site-packages/langchain_core/_api/deprecation.py:119: LangChainDeprecationWarning: The class `LLMChain` was deprecated in LangChain 0.1.17 and will be removed in 0.3.0. Use RunnableSequence, e.g., `prompt | llm` instead.
  warn_deprecated(
```


```python
chain.invoke("How many actors played in The Godfather: Part II?")
```

```output


[1m> Entering new KuzuQAChain chain...[0m
``````output
/Users/prrao/code/langchain/.venv/lib/python3.11/site-packages/langchain_core/_api/deprecation.py:119: LangChainDeprecationWarning: The method `Chain.run` was deprecated in langchain 0.1.0 and will be removed in 0.2.0. Use invoke instead.
  warn_deprecated(
``````output
Generated Cypher:
[32;1m[1;3mMATCH (:Person)-[:ActedIn]->(:Movie {name: 'The Godfather: Part II'})
RETURN count(*)[0m
Full Context:
[32;1m[1;3m[{'COUNT_STAR()': 2}][0m
``````output
/Users/prrao/code/langchain/.venv/lib/python3.11/site-packages/langchain_core/_api/deprecation.py:119: LangChainDeprecationWarning: The method `Chain.__call__` was deprecated in langchain 0.1.0 and will be removed in 0.2.0. Use invoke instead.
  warn_deprecated(
``````output

[1m> Finished chain.[0m
```


```output
{'query': 'How many actors played in The Godfather: Part II?',
 'result': 'Two actors played in The Godfather: Part II.'}
```