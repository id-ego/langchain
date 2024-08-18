---
description: 이 문서는 Chroma와 OpenAI를 사용하여 RAG를 수행하는 템플릿에 대한 설명과 환경 설정, 사용 방법을 안내합니다.
---

# rag-chroma

이 템플릿은 Chroma와 OpenAI를 사용하여 RAG를 수행합니다.

벡터 저장소는 `chain.py`에서 생성되며 기본적으로 질문-답변을 위해 [에이전트에 대한 인기 블로그 게시물](https://lilianweng.github.io/posts/2023-06-23-agent/)을 인덱싱합니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-chroma
```


기존 프로젝트에 추가하고 싶다면 다음을 실행하면 됩니다:

```shell
langchain app add rag-chroma
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_chroma import chain as rag_chroma_chain

add_routes(app, rag_chroma_chain, path="/rag-chroma")
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


이 디렉토리 안에 있다면 다음과 같이 LangServe 인스턴스를 직접 실행할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-chroma/playground](http://127.0.0.1:8000/rag-chroma/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-chroma")
```