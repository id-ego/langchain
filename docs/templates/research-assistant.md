---
description: 이 문서는 연구 에이전트를 위한 템플릿으로, 환경 설정 및 사용 방법을 안내합니다. LangChain과 API 키 설정이 포함됩니다.
---

# research-assistant

이 템플릿은 연구 에이전트의 시작점으로 사용할 수 있는\
[GPT Researcher](https://github.com/assafelovic/gpt-researcher) 버전을 구현합니다.

## 환경 설정

기본 템플릿은 ChatOpenAI와 DuckDuckGo에 의존하므로 다음 환경 변수가 필요합니다:

- `OPENAI_API_KEY`

그리고 Tavily LLM 최적화 검색 엔진을 사용하려면 다음이 필요합니다:

- `TAVILY_API_KEY`

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package research-assistant
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add research-assistant
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from research_assistant import chain as research_assistant_chain

add_routes(app, research_assistant_chain, path="/research-assistant")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/research-assistant/playground](http://127.0.0.1:8000/research-assistant/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/research-assistant")
```