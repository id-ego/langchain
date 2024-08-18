---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/diffbot.ipynb
description: Diffbot은 웹 데이터를 구조화하는 ML 기반 제품 모음으로, NLP API를 통해 비정형 텍스트에서 의미와 관계를 추출합니다.
---

# Diffbot

> [Diffbot](https://docs.diffbot.com/docs/getting-started-with-diffbot)은 웹 데이터를 구조화하는 데 쉽게 사용할 수 있는 ML 기반 제품 모음입니다.
> 
> Diffbot의 [자연어 처리 API](https://www.diffbot.com/products/natural-language/)는 비구조화된 텍스트 데이터에서 엔티티, 관계 및 의미론적 의미를 추출할 수 있게 해줍니다.
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/graphs/diffbot.ipynb)

## 사용 사례

텍스트 데이터는 종종 다양한 분석, 추천 엔진 또는 지식 관리 애플리케이션에 사용되는 풍부한 관계와 통찰력을 포함하고 있습니다.

`Diffbot의 NLP API`와 그래프 데이터베이스인 `Neo4j`를 결합하면 텍스트에서 추출된 정보를 기반으로 강력하고 동적인 그래프 구조를 생성할 수 있습니다. 이러한 그래프 구조는 완전히 쿼리 가능하며 다양한 애플리케이션에 통합될 수 있습니다.

이 조합은 다음과 같은 사용 사례를 허용합니다:

* 텍스트 문서, 웹사이트 또는 소셜 미디어 피드에서 [Diffbot의 지식 그래프](https://www.diffbot.com/products/knowledge-graph/)와 같은 지식 그래프 구축.
* 데이터의 의미론적 관계를 기반으로 추천 생성.
* 엔티티 간의 관계를 이해하는 고급 검색 기능 생성.
* 사용자가 데이터의 숨겨진 관계를 탐색할 수 있는 분석 대시보드 구축.

## 개요

LangChain은 그래프 데이터베이스와 상호작용할 수 있는 도구를 제공합니다:

1. 텍스트를 사용하여 그래프 변환기 및 저장소 통합을 통해 지식 그래프 구축
2. 쿼리 생성 및 실행을 위한 체인을 사용하여 그래프 데이터베이스 쿼리
3. 강력하고 유연한 쿼리를 위한 에이전트를 사용하여 그래프 데이터베이스와 상호작용 

## 설정

먼저 필요한 패키지를 가져오고 환경 변수를 설정합니다:

```python
%pip install --upgrade --quiet  langchain langchain-experimental langchain-openai neo4j wikipedia
```


### Diffbot NLP API

`Diffbot의 NLP API`는 비구조화된 텍스트 데이터에서 엔티티, 관계 및 의미론적 맥락을 추출하는 도구입니다.
추출된 정보는 지식 그래프를 구축하는 데 사용될 수 있습니다.
API를 사용하려면 [Diffbot에서 무료 API 토큰을 얻어야](https://app.diffbot.com/get-started/) 합니다.

```python
<!--IMPORTS:[{"imported": "DiffbotGraphTransformer", "source": "langchain_experimental.graph_transformers.diffbot", "docs": "https://api.python.langchain.com/en/latest/graph_transformers/langchain_experimental.graph_transformers.diffbot.DiffbotGraphTransformer.html", "title": "Diffbot"}]-->
from langchain_experimental.graph_transformers.diffbot import DiffbotGraphTransformer

diffbot_api_key = "DIFFBOT_KEY"
diffbot_nlp = DiffbotGraphTransformer(diffbot_api_key=diffbot_api_key)
```


이 코드는 "Warren Buffett"에 대한 위키피디아 기사를 가져온 다음 `DiffbotGraphTransformer`를 사용하여 엔티티와 관계를 추출합니다.
`DiffbotGraphTransformer`는 그래프 데이터베이스를 채우는 데 사용할 수 있는 구조화된 데이터 `GraphDocument`를 출력합니다.
Diffbot의 [API 요청당 문자 제한](https://docs.diffbot.com/reference/introduction-to-natural-language-api)으로 인해 텍스트 청크 처리는 피해야 합니다.

```python
<!--IMPORTS:[{"imported": "WikipediaLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.wikipedia.WikipediaLoader.html", "title": "Diffbot"}]-->
from langchain_community.document_loaders import WikipediaLoader

query = "Warren Buffett"
raw_documents = WikipediaLoader(query=query).load()
graph_documents = diffbot_nlp.convert_to_graph_documents(raw_documents)
```


## 지식 그래프에 데이터 로드하기

실행 중인 Neo4j 인스턴스가 필요합니다. 한 가지 옵션은 [그들의 Aura 클라우드 서비스에서 무료 Neo4j 데이터베이스 인스턴스 생성](https://neo4j.com/cloud/platform/aura-graph-database/)입니다. [Neo4j Desktop 애플리케이션](https://neo4j.com/download/)을 사용하여 로컬에서 데이터베이스를 실행하거나 도커 컨테이너를 실행할 수 있습니다. 다음 스크립트를 실행하여 로컬 도커 컨테이너를 실행할 수 있습니다:
```
docker run \
    --name neo4j \
    -p 7474:7474 -p 7687:7687 \
    -d \
    -e NEO4J_AUTH=neo4j/password \
    -e NEO4J_PLUGINS=\[\"apoc\"\]  \
    neo4j:latest
```

도커 컨테이너를 사용하는 경우 데이터베이스가 시작될 때까지 몇 초 기다려야 합니다.

```python
<!--IMPORTS:[{"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "Diffbot"}]-->
from langchain_community.graphs import Neo4jGraph

url = "bolt://localhost:7687"
username = "neo4j"
password = "password"

graph = Neo4jGraph(url=url, username=username, password=password)
```


`GraphDocuments`는 `add_graph_documents` 메서드를 사용하여 지식 그래프에 로드할 수 있습니다.

```python
graph.add_graph_documents(graph_documents)
```


## 그래프 스키마 정보 새로 고침
데이터베이스의 스키마가 변경되면 Cypher 문을 생성하는 데 필요한 스키마 정보를 새로 고칠 수 있습니다.

```python
graph.refresh_schema()
```


## 그래프 쿼리
이제 그래프에 대한 질문을 하기 위해 그래프 Cypher QA 체인을 사용할 수 있습니다. 최상의 경험을 위해 **gpt-4**를 사용하여 Cypher 쿼리를 구성하는 것이 좋습니다.

```python
<!--IMPORTS:[{"imported": "GraphCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher.GraphCypherQAChain.html", "title": "Diffbot"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Diffbot"}]-->
from langchain.chains import GraphCypherQAChain
from langchain_openai import ChatOpenAI

chain = GraphCypherQAChain.from_llm(
    cypher_llm=ChatOpenAI(temperature=0, model_name="gpt-4"),
    qa_llm=ChatOpenAI(temperature=0, model_name="gpt-3.5-turbo"),
    graph=graph,
    verbose=True,
)
```


```python
chain.run("Which university did Warren Buffett attend?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person {name: "Warren Buffett"})-[:EDUCATED_AT]->(o:Organization)
RETURN o.name[0m
Full Context:
[32;1m[1;3m[{'o.name': 'New York Institute of Finance'}, {'o.name': 'Alice Deal Junior High School'}, {'o.name': 'Woodrow Wilson High School'}, {'o.name': 'University of Nebraska'}][0m

[1m> Finished chain.[0m
```


```output
'Warren Buffett attended the University of Nebraska.'
```


```python
chain.run("Who is or was working at Berkshire Hathaway?")
```

```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person)-[r:EMPLOYEE_OR_MEMBER_OF]->(o:Organization) WHERE o.name = 'Berkshire Hathaway' RETURN p.name[0m
Full Context:
[32;1m[1;3m[{'p.name': 'Charlie Munger'}, {'p.name': 'Oliver Chace'}, {'p.name': 'Howard Buffett'}, {'p.name': 'Howard'}, {'p.name': 'Susan Buffett'}, {'p.name': 'Warren Buffett'}][0m

[1m> Finished chain.[0m
```


```output
'Charlie Munger, Oliver Chace, Howard Buffett, Susan Buffett, and Warren Buffett are or were working at Berkshire Hathaway.'
```