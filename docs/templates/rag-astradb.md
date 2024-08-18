---
description: 이 문서는 Astra DB를 사용하여 RAG(정보 검색 및 생성)를 수행하는 템플릿에 대한 환경 설정 및 사용법을 안내합니다.
---

# rag-astradb

이 템플릿은 Astra DB(`AstraDB` 벡터 저장소 클래스)를 사용하여 RAG를 수행합니다.

## 환경 설정

[Astra DB](https://astra.datastax.com) 데이터베이스가 필요하며, 무료 티어로 충분합니다.

- 데이터베이스 **API 엔드포인트**(예: `https://0123...-us-east1.apps.astra.datastax.com`)가 필요합니다...
- ... 그리고 **토큰**(`AstraCS:...`)이 필요합니다.

또한, **OpenAI API 키**가 필요합니다. *기본적으로 이 데모는 OpenAI만 지원하며, 코드를 수정하지 않는 한 그렇습니다.*

환경 변수를 통해 연결 매개변수와 비밀을 제공하십시오. 변수 이름은 `.env.template`을 참조하십시오.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새 LangChain 프로젝트를 만들고 이 패키지만 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package rag-astradb
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-astradb
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from astradb_entomology_rag import chain as astradb_entomology_rag_chain

add_routes(app, astradb_entomology_rag_chain, path="/rag-astradb")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음을 통해 LangServe 인스턴스를 직접 실행할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-astradb/playground](http://127.0.0.1:8000/rag-astradb/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-astradb")
```


## 참고

LangServe 체인이 포함된 독립형 레포: [여기](https://github.com/hemidactylus/langserve_astradb_entomology_rag).