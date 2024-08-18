---
description: 이 문서는 LLM 기반 지식 그래프 추출과 Neo4j AuraDB를 결합한 템플릿을 제공합니다. 데이터베이스 설정 및 사용법을
  안내합니다.
---

# neo4j-generation

이 템플릿은 LLM 기반 지식 그래프 추출을 Neo4j AuraDB와 결합합니다. Neo4j AuraDB는 완전 관리형 클라우드 그래프 데이터베이스입니다.

[Neo4j Aura](https://neo4j.com/cloud/platform/aura-graph-database?utm_source=langchain&utm_content=langserve)에서 무료 인스턴스를 생성할 수 있습니다.

무료 데이터베이스 인스턴스를 시작하면 데이터베이스에 접근할 수 있는 자격 증명을 받게 됩니다.

이 템플릿은 유연하며 사용자가 노드 레이블 및 관계 유형 목록을 지정하여 추출 프로세스를 안내할 수 있습니다.

이 패키지의 기능 및 능력에 대한 자세한 내용은 [이 블로그 게시물](https://blog.langchain.dev/constructing-knowledge-graphs-from-text-using-openai-functions/)을 참조하십시오.

## 환경 설정

다음 환경 변수를 설정해야 합니다:

```
OPENAI_API_KEY=<YOUR_OPENAI_API_KEY>
NEO4J_URI=<YOUR_NEO4J_URI>
NEO4J_USERNAME=<YOUR_NEO4J_USERNAME>
NEO4J_PASSWORD=<YOUR_NEO4J_PASSWORD>
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package neo4j-generation
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add neo4j-generation
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from neo4j_generation.chain import chain as neo4j_generation_chain

add_routes(app, neo4j_generation_chain, path="/neo4j-generation")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/neo4j-generation/playground](http://127.0.0.1:8000/neo4j-generation/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-generation")
```