---
description: 이 문서는 Apache Cassandra® 또는 Astra DB를 사용하여 RAG를 수행하는 템플릿을 제공합니다. 환경 설정
  및 사용 방법을 안내합니다.
---

# cassandra-entomology-rag

이 템플릿은 CQL(`Cassandra` 벡터 저장소 클래스)을 통해 Apache Cassandra® 또는 Astra DB를 사용하여 RAG를 수행합니다.

## 환경 설정

설정을 위해 다음이 필요합니다:
- [Astra](https://astra.datastax.com) 벡터 데이터베이스. [데이터베이스 관리자 토큰](https://awesome-astra.github.io/docs/pages/astra/create-token/#c-procedure), 특히 `AstraCS:...`로 시작하는 문자열이 필요합니다.
- [데이터베이스 ID](https://awesome-astra.github.io/docs/pages/astra/faq/#where-should-i-find-a-database-identifier).
- **OpenAI API 키**. (자세한 정보는 [여기](https://cassio.org/start_here/#llm-access)에서 확인하세요.)

일반 Cassandra 클러스터를 사용할 수도 있습니다. 이 경우 `.env.template`에 표시된 대로 `USE_CASSANDRA_CLUSTER` 항목과 후속 환경 변수를 제공하여 연결 방법을 지정해야 합니다.

연결 매개변수와 비밀은 환경 변수를 통해 제공되어야 합니다. 필요한 변수는 `.env.template`을 참조하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package cassandra-entomology-rag
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add cassandra-entomology-rag
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from cassandra_entomology_rag import chain as cassandra_entomology_rag_chain

add_routes(app, cassandra_entomology_rag_chain, path="/cassandra-entomology-rag")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되고 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/cassandra-entomology-rag/playground](http://127.0.0.1:8000/cassandra-entomology-rag/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/cassandra-entomology-rag")
```


## 참고

LangServe 체인이 포함된 독립형 리포지토리: [여기](https://github.com/hemidactylus/langserve_cassandra_entomology_rag).