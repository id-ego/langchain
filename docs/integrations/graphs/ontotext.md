---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/ontotext.ipynb
description: Ontotext GraphDB는 RDF 및 SPARQL을 지원하는 그래프 데이터베이스로, 자연어 쿼리 기능을 제공합니다.
---

# Ontotext GraphDB

> [Ontotext GraphDB](https://graphdb.ontotext.com/)는 [RDF](https://www.w3.org/RDF/) 및 [SPARQL](https://www.w3.org/TR/sparql11-query/)을 준수하는 그래프 데이터베이스 및 지식 발견 도구입니다.

> 이 노트북은 `Ontotext GraphDB`에 대한 자연어 쿼리(NLQ에서 SPARQL로, `text2sparql`이라고도 함)를 제공하기 위해 LLM을 사용하는 방법을 보여줍니다.

## GraphDB LLM 기능

`GraphDB`는 [여기](https://github.com/w3c/sparql-dev/issues/193)에서 설명된 일부 LLM 통합 기능을 지원합니다:

[gpt-queries](https://graphdb.ontotext.com/documentation/10.5/gpt-queries.html)

* 지식 그래프(KG)의 데이터를 사용하여 LLM에 텍스트, 목록 또는 테이블을 요청하는 매직 프레디케이트
* 쿼리 설명
* 결과 설명, 요약, 재구성, 번역

[retrieval-graphdb-connector](https://graphdb.ontotext.com/documentation/10.5/retrieval-graphdb-connector.html)

* 벡터 데이터베이스에서 KG 엔티티 인덱싱
* 모든 텍스트 임베딩 알고리즘 및 벡터 데이터베이스 지원
* GraphDB가 Elastic, Solr, Lucene에 대해 사용하는 동일한 강력한 커넥터(인덱싱) 언어 사용
* RDF 데이터의 변경 사항을 KG 엔티티 인덱스에 자동으로 동기화
* 중첩 객체 지원(GraphDB 버전 10.5에서는 UI 지원 없음)
* KG 엔티티를 다음과 같이 텍스트로 직렬화(예: Wines 데이터셋):

```
Franvino:
- is a RedWine.
- made from grape Merlo.
- made from grape Cabernet Franc.
- has sugar dry.
- has year 2012.
```


[talk-to-graph](https://graphdb.ontotext.com/documentation/10.5/talk-to-graph.html)

* 정의된 KG 엔티티 인덱스를 사용하는 간단한 챗봇

이 튜토리얼에서는 GraphDB LLM 통합을 사용하지 않고 NLQ에서 SPARQL 생성을 사용할 것입니다. `Star Wars API`(`SWAPI`) 온톨로지 및 데이터셋을 사용할 것이며, 이는 [여기](https://github.com/Ontotext-AD/langchain-graphdb-qa-chain-demo/blob/main/starwars-data.trig)에서 확인할 수 있습니다.

## 설정

실행 중인 GraphDB 인스턴스가 필요합니다. 이 튜토리얼은 [GraphDB Docker 이미지](https://hub.docker.com/r/ontotext/graphdb)를 사용하여 데이터베이스를 로컬에서 실행하는 방법을 보여줍니다. Star Wars 데이터셋으로 GraphDB를 채우는 도커 컴포즈 설정을 제공합니다. 이 노트북을 포함한 모든 필요한 파일은 [GitHub 리포지토리 langchain-graphdb-qa-chain-demo](https://github.com/Ontotext-AD/langchain-graphdb-qa-chain-demo)에서 다운로드할 수 있습니다.

* [Docker](https://docs.docker.com/get-docker/)를 설치합니다. 이 튜토리얼은 [Docker Compose](https://docs.docker.com/compose/)를 포함하는 Docker 버전 `24.0.7`을 사용하여 생성되었습니다. 이전 Docker 버전에서는 Docker Compose를 별도로 설치해야 할 수 있습니다.
* 로컬 컴퓨터의 폴더에 [GitHub 리포지토리 langchain-graphdb-qa-chain-demo](https://github.com/Ontotext-AD/langchain-graphdb-qa-chain-demo)를 클론합니다.
* 다음 스크립트를 동일한 폴더에서 실행하여 GraphDB를 시작합니다.

```
docker build --tag graphdb .
docker compose up -d graphdb
```


데이터베이스가 `http://localhost:7200/`에서 시작될 때까지 몇 초 기다려야 합니다. Star Wars 데이터셋 `starwars-data.trig`는 자동으로 `langchain` 리포지토리에 로드됩니다. 로컬 SPARQL 엔드포인트 `http://localhost:7200/repositories/langchain`를 사용하여 쿼리를 실행할 수 있습니다. 또한 좋아하는 웹 브라우저에서 GraphDB 워크벤치를 열 수 있습니다 `http://localhost:7200/sparql`에서 대화형으로 쿼리를 만들 수 있습니다.
* 작업 환경 설정

`conda`를 사용하는 경우 새 conda 환경을 생성하고 활성화합니다(예: `conda create -n graph_ontotext_graphdb_qa python=3.9.18`).

다음 라이브러리를 설치합니다:

```
pip install jupyter==1.0.0
pip install openai==1.6.1
pip install rdflib==7.0.0
pip install langchain-openai==0.0.2
pip install langchain>=0.1.5
```


Jupyter를 실행합니다:
```
jupyter notebook
```


## 온톨로지 지정

LLM이 SPARQL을 생성할 수 있도록 하려면 지식 그래프 스키마(온톨로지)를 알아야 합니다. 이는 `OntotextGraphDBGraph` 클래스의 두 개의 매개변수 중 하나를 사용하여 제공할 수 있습니다:

* `query_ontology`: SPARQL 엔드포인트에서 실행되고 KG 스키마 문을 반환하는 `CONSTRUCT` 쿼리입니다. 온톨로지를 자체 이름이 있는 그래프에 저장하는 것이 좋으며, 이는 관련 문만 쉽게 가져오는 데 도움이 됩니다(아래 예와 같이). `DESCRIBE` 쿼리는 지원되지 않으며, `DESCRIBE`는 대칭 간결 제한 설명(SCBD)을 반환하므로, 즉 들어오는 클래스 링크도 포함됩니다. 백만 개의 인스턴스가 있는 대규모 그래프의 경우 비효율적입니다. https://github.com/eclipse-rdf4j/rdf4j/issues/4857를 확인하세요.
* `local_file`: 로컬 RDF 온톨로지 파일입니다. 지원되는 RDF 형식은 `Turtle`, `RDF/XML`, `JSON-LD`, `N-Triples`, `Notation-3`, `Trig`, `Trix`, `N-Quads`입니다.

어느 쪽이든 온톨로지 덤프는 다음을 포함해야 합니다:

* 클래스, 속성, 클래스에 대한 속성 첨부(사용: rdfs:domain, schema:domainIncludes 또는 OWL 제한) 및 분류(중요한 개인)에 대한 충분한 정보를 포함해야 합니다.
* SPARQL 구성을 도와주지 않는 지나치게 장황하고 관련 없는 정의 및 예제를 포함하지 않아야 합니다.

```python
<!--IMPORTS:[{"imported": "OntotextGraphDBGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.ontotext_graphdb_graph.OntotextGraphDBGraph.html", "title": "Ontotext GraphDB"}]-->
from langchain_community.graphs import OntotextGraphDBGraph

# feeding the schema using a user construct query

graph = OntotextGraphDBGraph(
    query_endpoint="http://localhost:7200/repositories/langchain",
    query_ontology="CONSTRUCT {?s ?p ?o} FROM <https://swapi.co/ontology/> WHERE {?s ?p ?o}",
)
```


```python
# feeding the schema using a local RDF file

graph = OntotextGraphDBGraph(
    query_endpoint="http://localhost:7200/repositories/langchain",
    local_file="/path/to/langchain_graphdb_tutorial/starwars-ontology.nt",  # change the path here
)
```


어느 쪽이든 온톨로지(스키마)는 `Turtle`로 LLM에 제공됩니다. 적절한 접두사가 있는 `Turtle`이 가장 간결하고 LLM이 기억하기 쉽기 때문입니다.

Star Wars 온톨로지는 클래스에 대한 많은 특정 트리플을 포함하고 있어 다소 특이합니다. 예를 들어 종 `:Aleena`가 `<planet/38>`에 살고 있으며, `:Reptile`의 하위 클래스이고 특정 전형적인 특성(평균 키, 평균 수명, 피부색)을 가지며 특정 개인(캐릭터)이 해당 클래스의 대표자입니다:

```
@prefix : <https://swapi.co/vocabulary/> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

:Aleena a owl:Class, :Species ;
    rdfs:label "Aleena" ;
    rdfs:isDefinedBy <https://swapi.co/ontology/> ;
    rdfs:subClassOf :Reptile, :Sentient ;
    :averageHeight 80.0 ;
    :averageLifespan "79" ;
    :character <https://swapi.co/resource/aleena/47> ;
    :film <https://swapi.co/resource/film/4> ;
    :language "Aleena" ;
    :planet <https://swapi.co/resource/planet/38> ;
    :skinColor "blue", "gray" .

    ...

```


이 튜토리얼을 간단하게 유지하기 위해 보안이 설정되지 않은 GraphDB를 사용합니다. GraphDB가 보안이 설정된 경우 `OntotextGraphDBGraph` 초기화 전에 환경 변수 'GRAPHDB_USERNAME' 및 'GRAPHDB_PASSWORD'를 설정해야 합니다.

```python
os.environ["GRAPHDB_USERNAME"] = "graphdb-user"
os.environ["GRAPHDB_PASSWORD"] = "graphdb-password"

graph = OntotextGraphDBGraph(
    query_endpoint=...,
    query_ontology=...
)
```


## StarWars 데이터셋에 대한 질문 응답

이제 `OntotextGraphDBQAChain`을 사용하여 몇 가지 질문을 할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "OntotextGraphDBQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.ontotext_graphdb.OntotextGraphDBQAChain.html", "title": "Ontotext GraphDB"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Ontotext GraphDB"}]-->
import os

from langchain.chains import OntotextGraphDBQAChain
from langchain_openai import ChatOpenAI

# We'll be using an OpenAI model which requires an OpenAI API Key.
# However, other models are available as well:
# https://python.langchain.com/docs/integrations/chat/

# Set the environment variable `OPENAI_API_KEY` to your OpenAI API key
os.environ["OPENAI_API_KEY"] = "sk-***"

# Any available OpenAI model can be used here.
# We use 'gpt-4-1106-preview' because of the bigger context window.
# The 'gpt-4-1106-preview' model_name will deprecate in the future and will change to 'gpt-4-turbo' or similar,
# so be sure to consult with the OpenAI API https://platform.openai.com/docs/models for the correct naming.

chain = OntotextGraphDBQAChain.from_llm(
    ChatOpenAI(temperature=0, model_name="gpt-4-1106-preview"),
    graph=graph,
    verbose=True,
)
```


간단한 질문을 해보겠습니다.

```python
chain.invoke({chain.input_key: "What is the climate on Tatooine?"})[chain.output_key]
```

```output


[1m> Entering new OntotextGraphDBQAChain chain...[0m
Generated SPARQL:
[32;1m[1;3mPREFIX : <https://swapi.co/vocabulary/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?climate
WHERE {
  ?planet rdfs:label "Tatooine" ;
          :climate ?climate .
}[0m

[1m> Finished chain.[0m
```


```output
'The climate on Tatooine is arid.'
```


조금 더 복잡한 질문도 해보겠습니다.

```python
chain.invoke({chain.input_key: "What is the climate on Luke Skywalker's home planet?"})[
    chain.output_key
]
```

```output


[1m> Entering new OntotextGraphDBQAChain chain...[0m
Generated SPARQL:
[32;1m[1;3mPREFIX : <https://swapi.co/vocabulary/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?climate
WHERE {
  ?character rdfs:label "Luke Skywalker" .
  ?character :homeworld ?planet .
  ?planet :climate ?climate .
}[0m

[1m> Finished chain.[0m
```


```output
"The climate on Luke Skywalker's home planet is arid."
```


더 복잡한 질문도 할 수 있습니다.

```python
chain.invoke(
    {
        chain.input_key: "What is the average box office revenue for all the Star Wars movies?"
    }
)[chain.output_key]
```

```output


[1m> Entering new OntotextGraphDBQAChain chain...[0m
Generated SPARQL:
[32;1m[1;3mPREFIX : <https://swapi.co/vocabulary/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (AVG(?boxOffice) AS ?averageBoxOffice)
WHERE {
  ?film a :Film .
  ?film :boxOffice ?boxOfficeValue .
  BIND(xsd:decimal(?boxOfficeValue) AS ?boxOffice)
}
[0m

[1m> Finished chain.[0m
```


```output
'The average box office revenue for all the Star Wars movies is approximately 754.1 million dollars.'
```


## 체인 수정자

Ontotext GraphDB QA 체인은 QA 체인의 추가 개선 및 앱의 전반적인 사용자 경험 향상을 위한 프롬프트 수정을 허용합니다.

### "SPARQL 생성" 프롬프트

프롬프트는 사용자 질문 및 KG 스키마를 기반으로 SPARQL 쿼리 생성을 위해 사용됩니다.

- `sparql_generation_prompt`
  
  기본값:
  ```python
    GRAPHDB_SPARQL_GENERATION_TEMPLATE = """
    Write a SPARQL SELECT query for querying a graph database.
    The ontology schema delimited by triple backticks in Turtle format is:
  ```

  {schema}
  ```
  Use only the classes and properties provided in the schema to construct the SPARQL query.
  Do not use any classes or properties that are not explicitly provided in the SPARQL query.
  Include all necessary prefixes.
  Do not include any explanations or apologies in your responses.
  Do not wrap the query in backticks.
  Do not include any text except the SPARQL query generated.
  The question delimited by triple backticks is:
  ```

  {prompt}
  ```
  """
  GRAPHDB_SPARQL_GENERATION_PROMPT = PromptTemplate(
      input_variables=["schema", "prompt"],
      template=GRAPHDB_SPARQL_GENERATION_TEMPLATE,
  )
  ```


### "SPARQL 수정" 프롬프트

때때로 LLM이 구문 오류가 있거나 접두사가 누락된 SPARQL 쿼리를 생성할 수 있습니다. 체인은 LLM에게 이를 수정하도록 특정 횟수만큼 프롬프트를 제공하여 수정하려고 합니다.

- `sparql_fix_prompt`
  
  기본값:
  ```python
    GRAPHDB_SPARQL_FIX_TEMPLATE = """
    This following SPARQL query delimited by triple backticks
  ```

  {generated_sparql}
  ```
  is not valid.
  The error delimited by triple backticks is
  ```

  {error_message}
  ```
  Give me a correct version of the SPARQL query.
  Do not change the logic of the query.
  Do not include any explanations or apologies in your responses.
  Do not wrap the query in backticks.
  Do not include any text except the SPARQL query generated.
  The ontology schema delimited by triple backticks in Turtle format is:
  ```

  {schema}
  ```
  """
  
  GRAPHDB_SPARQL_FIX_PROMPT = PromptTemplate(
      input_variables=["error_message", "generated_sparql", "schema"],
      template=GRAPHDB_SPARQL_FIX_TEMPLATE,
  )
  ```

- `max_fix_retries`
  
  기본값: `5`

### "응답" 프롬프트

프롬프트는 데이터베이스에서 반환된 결과와 초기 사용자 질문을 기반으로 질문에 답하는 데 사용됩니다. 기본적으로 LLM은 반환된 결과에서만 정보를 사용하도록 지시됩니다. 결과 집합이 비어 있는 경우 LLM은 질문에 답할 수 없다고 알려야 합니다.

- `qa_prompt`
  
  기본값:
  ```python
    GRAPHDB_QA_TEMPLATE = """Task: Generate a natural language response from the results of a SPARQL query.
    You are an assistant that creates well-written and human understandable answers.
    The information part contains the information provided, which you can use to construct an answer.
    The information provided is authoritative, you must never doubt it or try to use your internal knowledge to correct it.
    Make your response sound like the information is coming from an AI assistant, but don't add any information.
    Don't use internal knowledge to answer the question, just say you don't know if no information is available.
    Information:
    {context}
    
    Question: {prompt}
    Helpful Answer:"""
    GRAPHDB_QA_PROMPT = PromptTemplate(
        input_variables=["context", "prompt"], template=GRAPHDB_QA_TEMPLATE
    )
  ```


GraphDB와 함께 QA를 마치면 다음 명령어를 실행하여 Docker 환경을 종료할 수 있습니다.
`docker compose down -v --remove-orphans`
Docker 컴포즈 파일이 있는 디렉토리에서.