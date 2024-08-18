---
description: 이 문서는 Vectara와 함께 RAG(검색 증강 생성)를 수행하는 방법과 환경 설정, 사용법을 안내합니다.
---

# rag-vectara

이 템플릿은 vectara로 RAG를 수행합니다.

## 환경 설정

다음 환경 변수가 설정되어 있는지 확인하십시오:
* `VECTARA_CUSTOMER_ID`
* `VECTARA_CORPUS_ID`
* `VECTARA_API_KEY`

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-vectara
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-vectara
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_vectara import chain as rag_vectara_chain

add_routes(app, rag_vectara_chain, path="/rag-vectara")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움이 됩니다.
여기에서 LangSmith에 가입할 수 있습니다 [여기](https://smith.langchain.com/).
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "vectara-demo"
```


이 디렉토리 내에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되고 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-vectara/playground](http://127.0.0.1:8000/rag-vectara/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-vectara")
```