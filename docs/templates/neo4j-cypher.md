---
description: 이 문서는 자연어 질문을 Neo4j 그래프 데이터베이스의 Cypher 쿼리로 변환하여 실행하고, 결과를 자연어로 제공하는 방법을
  설명합니다.
---

# neo4j_cypher

이 템플릿은 OpenAI LLM을 사용하여 자연어로 Neo4j 그래프 데이터베이스와 상호작용할 수 있게 해줍니다.

자연어 질문을 Cypher 쿼리(Neo4j 데이터베이스에서 데이터를 가져오는 데 사용됨)로 변환하고, 쿼리를 실행하며, 쿼리 결과에 기반한 자연어 응답을 제공합니다.

[](https://medium.com/neo4j/langchain-cypher-search-tips-tricks-f7c9e9abca4d)

## 환경 설정

다음 환경 변수를 정의하십시오:

```
OPENAI_API_KEY=<YOUR_OPENAI_API_KEY>
NEO4J_URI=<YOUR_NEO4J_URI>
NEO4J_USERNAME=<YOUR_NEO4J_USERNAME>
NEO4J_PASSWORD=<YOUR_NEO4J_PASSWORD>
```


## Neo4j 데이터베이스 설정

Neo4j 데이터베이스를 설정하는 방법은 여러 가지가 있습니다.

### Neo4j Aura

Neo4j AuraDB는 완전 관리형 클라우드 그래프 데이터베이스 서비스입니다.
[Neo4j Aura](https://neo4j.com/cloud/platform/aura-graph-database?utm_source=langchain&utm_content=langserve)에서 무료 인스턴스를 생성하세요.
무료 데이터베이스 인스턴스를 시작하면 데이터베이스에 접근할 수 있는 자격 증명을 받게 됩니다.

## 데이터로 채우기

DB를 예제 데이터로 채우고 싶다면 `python ingest.py`를 실행할 수 있습니다.
이 스크립트는 데이터베이스에 샘플 영화 데이터를 채웁니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package neo4j-cypher
```


기존 프로젝트에 추가하고 싶다면 다음을 실행하면 됩니다:

```shell
langchain app add neo4j-cypher
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from neo4j_cypher import chain as neo4j_cypher_chain

add_routes(app, neo4j_cypher_chain, path="/neo4j-cypher")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/neo4j_cypher/playground](http://127.0.0.1:8000/neo4j_cypher/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-cypher")
```