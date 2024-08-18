---
description: 이 템플릿은 OpenAI 기능 호출을 통해 Neo4j 그래프 데이터베이스와 상호작용할 수 있는 에이전트를 구현하는 데 사용됩니다.
---

# neo4j-semantic-layer

이 템플릿은 OpenAI 함수 호출을 통해 그래프 데이터베이스인 Neo4j와 상호작용할 수 있는 에이전트를 구현하기 위해 설계되었습니다.  
시맨틱 레이어는 에이전트에게 강력한 도구 모음을 제공하여 사용자의 의도에 따라 그래프 데이터베이스와 상호작용할 수 있게 합니다.  
시맨틱 레이어 템플릿에 대한 자세한 내용은 [해당 블로그 게시물](https://medium.com/towards-data-science/enhancing-interaction-between-language-models-and-graph-databases-via-a-semantic-layer-0a78ad3eba49)에서 확인하세요.

## 도구

에이전트는 Neo4j 그래프 데이터베이스와 효과적으로 상호작용하기 위해 여러 도구를 활용합니다:

1. **정보 도구**:
   - 영화나 개인에 대한 데이터를 검색하여 에이전트가 최신의 가장 관련성 높은 정보에 접근할 수 있도록 합니다.
2. **추천 도구**:
   - 사용자 선호도와 입력에 기반하여 영화 추천을 제공합니다.
3. **메모리 도구**:
   - 지식 그래프에 사용자 선호도에 대한 정보를 저장하여 여러 상호작용에 걸쳐 개인화된 경험을 가능하게 합니다.

## 환경 설정

다음 환경 변수를 정의해야 합니다.

```
OPENAI_API_KEY=<YOUR_OPENAI_API_KEY>
NEO4J_URI=<YOUR_NEO4J_URI>
NEO4J_USERNAME=<YOUR_NEO4J_USERNAME>
NEO4J_PASSWORD=<YOUR_NEO4J_PASSWORD>
```


## 데이터로 채우기

예제 영화 데이터셋으로 DB를 채우고 싶다면 `python ingest.py`를 실행할 수 있습니다.  
스크립트는 영화와 사용자에 의한 평점에 대한 정보를 가져옵니다.  
또한, 스크립트는 사용자 입력의 정보를 데이터베이스에 매핑하는 데 사용되는 두 개의 [전체 텍스트 인덱스](https://neo4j.com/docs/cypher-manual/current/indexes-for-full-text-search/)를 생성합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package neo4j-semantic-layer
```


기존 프로젝트에 추가하고 싶다면 다음을 실행하면 됩니다:

```shell
langchain app add neo4j-semantic-layer
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from neo4j_semantic_layer import agent_executor as neo4j_semantic_agent

add_routes(app, neo4j_semantic_agent, path="/neo4j-semantic-layer")
```


(선택사항) 이제 LangSmith를 구성해 보겠습니다.  
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.  
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.  
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면 다음과 같이 LangServe 인스턴스를 직접 실행할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버는 로컬에서 실행됩니다.  
[http://localhost:8000](http://localhost:8000)에서 확인할 수 있습니다.

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.  
플레이그라운드는 [http://127.0.0.1:8000/neo4j-semantic-layer/playground](http://127.0.0.1:8000/neo4j-semantic-layer/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-semantic-layer")
```