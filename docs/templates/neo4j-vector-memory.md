---
description: 이 템플릿은 Neo4j를 벡터 저장소로 사용하여 LLM과 통합하고, 사용자 세션의 대화 기록을 그래프로 저장합니다.
---

# neo4j-vector-memory

이 템플릿은 Neo4j를 벡터 저장소로 사용하여 LLM과 벡터 기반 검색 시스템을 통합할 수 있게 해줍니다.  
또한, 특정 사용자의 세션의 대화 기록을 저장하고 검색하기 위해 Neo4j 데이터베이스의 그래프 기능을 사용합니다.  
대화 기록을 그래프로 저장하면 원활한 대화 흐름을 제공할 뿐만 아니라, 그래프 분석을 통해 사용자 행동 및 텍스트 청크 검색을 분석할 수 있는 능력을 부여합니다.

## 환경 설정

다음 환경 변수를 정의해야 합니다.

```
OPENAI_API_KEY=<YOUR_OPENAI_API_KEY>
NEO4J_URI=<YOUR_NEO4J_URI>
NEO4J_USERNAME=<YOUR_NEO4J_USERNAME>
NEO4J_PASSWORD=<YOUR_NEO4J_PASSWORD>
```


## 데이터로 채우기

DB를 예제 데이터로 채우고 싶다면, `python ingest.py`를 실행할 수 있습니다.  
이 스크립트는 `dune.txt` 파일의 텍스트 섹션을 처리하고 Neo4j 그래프 데이터베이스에 저장합니다.  
또한, 이러한 임베딩의 효율적인 쿼리를 위해 `dune`이라는 벡터 인덱스가 생성됩니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이를 유일한 패키지로 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package neo4j-vector-memory
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add neo4j-vector-memory
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from neo4j_vector_memory import chain as neo4j_vector_memory_chain

add_routes(app, neo4j_vector_memory_chain, path="/neo4j-vector-memory")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.  
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.  
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.  
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 로컬에서 서버가 실행됩니다.  
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.  
플레이그라운드는 [http://127.0.0.1:8000/neo4j-vector-memory/playground](http://127.0.0.1:8000/neo4j-parent/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-vector-memory")
```