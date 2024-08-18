---
description: 이 템플릿은 정밀한 임베딩과 맥락 유지를 균형 있게 구현하는 고급 검색 전략을 제공합니다.
---

# neo4j-advanced-rag

이 템플릿은 고급 검색 전략을 구현하여 정확한 임베딩과 컨텍스트 유지의 균형을 맞출 수 있게 해줍니다.

## 전략

1. **전형적인 RAG**:
   - 인덱싱된 정확한 데이터가 검색되는 전통적인 방법입니다.
2. **부모 검색기**:
   - 전체 문서를 인덱싱하는 대신, 데이터는 부모 문서와 자식 문서라고 불리는 더 작은 조각으로 나뉩니다.
   - 자식 문서는 특정 개념의 더 나은 표현을 위해 인덱싱되고, 부모 문서는 컨텍스트 유지를 보장하기 위해 검색됩니다.
3. **가설 질문**:
   - 문서는 답변할 수 있는 잠재적 질문을 결정하기 위해 처리됩니다.
   - 이러한 질문은 특정 개념의 더 나은 표현을 위해 인덱싱되고, 부모 문서는 컨텍스트 유지를 보장하기 위해 검색됩니다.
4. **요약**:
   - 전체 문서를 인덱싱하는 대신, 문서의 요약을 생성하고 인덱싱합니다.
   - 유사하게, RAG 애플리케이션에서 부모 문서가 검색됩니다.

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
이 스크립트는 `dune.txt` 파일의 텍스트 섹션을 Neo4j 그래프 데이터베이스에 처리하고 저장합니다.
먼저, 텍스트는 더 큰 조각("부모")으로 나뉘고, 그 후 더 작은 조각("자식")으로 세분화되며, 부모와 자식 조각은 컨텍스트 유지를 위해 약간 겹칩니다.
이 조각들을 데이터베이스에 저장한 후, 자식 노드에 대한 임베딩은 OpenAI의 임베딩을 사용하여 계산되고, 향후 검색이나 분석을 위해 그래프에 다시 저장됩니다.
각 부모 노드에 대해 가설 질문과 요약이 생성되고, 임베딩되어 데이터베이스에 추가됩니다.
또한, 이러한 임베딩의 효율적인 쿼리를 위해 각 검색 전략에 대한 벡터 인덱스가 생성됩니다.

*가설 질문과 요약을 생성하는 LLM의 속도로 인해 데이터 수집에는 1~2분이 걸릴 수 있습니다.*

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새로운 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package neo4j-advanced-rag
```


기존 프로젝트에 추가하고 싶다면 다음을 실행하면 됩니다:

```shell
langchain app add neo4j-advanced-rag
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from neo4j_advanced_rag import chain as neo4j_advanced_chain

add_routes(app, neo4j_advanced_chain, path="/neo4j-advanced-rag")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적하고 모니터링하며 디버그하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/neo4j-advanced-rag/playground](http://127.0.0.1:8000/neo4j-advanced-rag/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-advanced-rag")
```