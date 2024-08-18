---
description: 이 템플릿은 Pinecone과 OpenAI를 사용하여 사용자 쿼리 기반으로 다중 쿼리를 생성하고 RAG를 수행합니다.
---

# rag-pinecone-multi-query

이 템플릿은 Pinecone과 OpenAI를 사용하여 다중 쿼리 검색기를 통해 RAG를 수행합니다.

사용자의 입력 쿼리를 기반으로 다양한 관점에서 여러 쿼리를 생성하기 위해 LLM을 사용합니다.

각 쿼리에 대해 관련 문서 집합을 검색하고, 답변 합성을 위해 모든 쿼리의 고유한 합집합을 취합니다.

## 환경 설정

이 템플릿은 벡터 저장소로 Pinecone을 사용하며 `PINECONE_API_KEY`, `PINECONE_ENVIRONMENT`, 및 `PINECONE_INDEX`가 설정되어야 합니다.

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 만들고 이 패키지를 설치하려면 다음을 수행하세요:

```shell
langchain app new my-app --package rag-pinecone-multi-query
```


기존 프로젝트에 이 패키지를 추가하려면 다음을 실행하세요:

```shell
langchain app add rag-pinecone-multi-query
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:

```python
from rag_pinecone_multi_query import chain as rag_pinecone_multi_query_chain

add_routes(app, rag_pinecone_multi_query_chain, path="/rag-pinecone-multi-query")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다. LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다. LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요. 접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 [http://localhost:8000](http://localhost:8000)에서 로컬로 실행 중인 서버와 함께 FastAPI 앱이 시작됩니다.

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-pinecone-multi-query/playground](http://127.0.0.1:8000/rag-pinecone-multi-query/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면 다음을 사용하세요:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-pinecone-multi-query")
```