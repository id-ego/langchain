---
description: 이 템플릿은 문서를 작은 청크로 나누어 정확한 임베딩과 맥락 유지를 통해 Neo4j 벡터 인덱스를 활용합니다.
---

# neo4j-parent

이 템플릿은 문서를 더 작은 조각으로 나누고 원래 또는 더 큰 텍스트 정보를 검색하여 정확한 임베딩과 맥락 유지를 균형 있게 할 수 있도록 합니다.

Neo4j 벡터 인덱스를 사용하여 패키지는 벡터 유사성 검색을 통해 자식 노드를 쿼리하고 적절한 `retrieval_query` 매개변수를 정의하여 해당 부모의 텍스트를 검색합니다.

## 환경 설정

다음 환경 변수를 정의해야 합니다.

```
OPENAI_API_KEY=<YOUR_OPENAI_API_KEY>
NEO4J_URI=<YOUR_NEO4J_URI>
NEO4J_USERNAME=<YOUR_NEO4J_USERNAME>
NEO4J_PASSWORD=<YOUR_NEO4J_PASSWORD>
```


## 데이터 채우기

DB에 예제 데이터를 채우고 싶다면 `python ingest.py`를 실행할 수 있습니다. 
스크립트는 `dune.txt` 파일의 텍스트 섹션을 처리하고 Neo4j 그래프 데이터베이스에 저장합니다. 
먼저 텍스트는 더 큰 조각("부모")으로 나뉘고, 그 후 더 작은 조각("자식")으로 다시 세분화되며, 부모와 자식 조각은 맥락을 유지하기 위해 약간 겹칩니다. 
이 조각들을 데이터베이스에 저장한 후, OpenAI의 임베딩을 사용하여 자식 노드의 임베딩을 계산하고 이를 그래프에 다시 저장하여 향후 검색 또는 분석에 사용합니다. 
또한, 이러한 임베딩의 효율적인 쿼리를 위해 `retrieval`이라는 벡터 인덱스가 생성됩니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package neo4j-parent
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add neo4j-parent
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from neo4j_parent import chain as neo4j_parent_chain

add_routes(app, neo4j_parent_chain, path="/neo4j-parent")
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


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/neo4j-parent/playground](http://127.0.0.1:8000/neo4j-parent/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-parent")
```