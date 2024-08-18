---
description: 위 문서는 위키피디아에서 질문에 대한 답변을 찾는 가상 연구 도우미를 만드는 템플릿에 대해 설명합니다.
---

# anthropic-iterative-search

이 템플릿은 질문에 대한 답을 찾기 위해 Wikipedia를 검색할 수 있는 가상 연구 보조자를 생성합니다.

이는 [이 노트북](https://github.com/anthropics/anthropic-cookbook/blob/main/long_context/wikipedia-search-cookbook.ipynb)에서 많은 영감을 받았습니다.

## 환경 설정

`ANTHROPIC_API_KEY` 환경 변수를 설정하여 Anthropic 모델에 접근합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이 패키지만 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package anthropic-iterative-search
```


기존 프로젝트에 추가하고 싶다면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add anthropic-iterative-search
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from anthropic_iterative_search import chain as anthropic_iterative_search_chain

add_routes(app, anthropic_iterative_search_chain, path="/anthropic-iterative-search")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음 명령어로 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/anthropic-iterative-search/playground](http://127.0.0.1:8000/anthropic-iterative-search/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/anthropic-iterative-search")
```