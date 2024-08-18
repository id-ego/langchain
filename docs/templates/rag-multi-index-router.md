---
description: 사용자 질문에 따라 도메인별 검색기를 라우팅하는 QA 애플리케이션에 대한 환경 설정 및 사용법을 설명합니다.
---

# RAG with Multiple Indexes (Routing)

사용자 질문에 따라 다양한 도메인 특화 검색기 간에 라우팅하는 QA 애플리케이션입니다.

## 환경 설정

이 애플리케이션은 PubMed, ArXiv, Wikipedia 및 [Kay AI](https://www.kay.ai) (SEC 제출 문서용)를 쿼리합니다.

무료 Kay AI 계정을 생성하고 [여기에서 API 키를 받으세요](https://www.kay.ai).
그런 다음 환경 변수를 설정합니다:

```bash
export KAY_API_KEY="<YOUR_API_KEY>"
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package rag-multi-index-router
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-multi-index-router
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_multi_index_router import chain as rag_multi_index_router_chain

add_routes(app, rag_multi_index_router_chain, path="/rag-multi-index-router")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적하고 모니터링하며 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기에서 가입할 수 있습니다](https://smith.langchain.com/).
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-multi-index-router/playground](http://127.0.0.1:8000/rag-multi-index-router/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-multi-index-router")
```