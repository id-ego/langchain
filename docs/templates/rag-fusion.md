---
description: 이 템플릿은 RAG 융합을 가능하게 하며, 여러 쿼리 생성과 역순위 융합을 통해 검색 결과를 재정렬합니다.
---

# rag-fusion

이 템플릿은 [여기](https://github.com/Raudaschl/rag-fusion)에서 찾은 프로젝트의 재구현을 사용하여 RAG 융합을 가능하게 합니다.

여러 쿼리 생성을 수행하고 검색 결과를 재정렬하기 위해 Reciprocal Rank Fusion을 사용합니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-fusion
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-fusion
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_fusion.chain import chain as rag_fusion_chain

add_routes(app, rag_fusion_chain, path="/rag-fusion")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근할 수 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 실행할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-fusion/playground](http://127.0.0.1:8000/rag-fusion/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-fusion")
```