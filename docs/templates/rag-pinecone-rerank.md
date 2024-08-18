---
description: 이 템플릿은 Pinecone과 OpenAI를 사용하여 RAG를 수행하고, Cohere를 통해 반환된 문서를 재정렬하는 방법을
  제공합니다.
---

# rag-pinecone-rerank

이 템플릿은 Pinecone과 OpenAI를 사용하여 RAG를 수행하며, [Cohere를 사용하여 반환된 문서에 대해 재정렬을 수행합니다](https://txt.cohere.com/rerank/).

재정렬은 지정된 필터나 기준을 사용하여 검색된 문서의 순위를 매기는 방법을 제공합니다.

## 환경 설정

이 템플릿은 벡터 저장소로 Pinecone을 사용하며, `PINECONE_API_KEY`, `PINECONE_ENVIRONMENT`, 및 `PINECONE_INDEX`가 설정되어야 합니다.

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정합니다.

Cohere ReRank에 접근하기 위해 `COHERE_API_KEY` 환경 변수를 설정합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-pinecone-rerank
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-pinecone-rerank
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from rag_pinecone_rerank import chain as rag_pinecone_rerank_chain

add_routes(app, rag_pinecone_rerank_chain, path="/rag-pinecone-rerank")
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


이 디렉토리 안에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 볼 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-pinecone-rerank/playground](http://127.0.0.1:8000/rag-pinecone-rerank/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-pinecone-rerank")
```