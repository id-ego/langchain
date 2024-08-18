---
description: 이 문서는 CSV 에이전트를 사용하여 텍스트 데이터와 상호작용하는 방법을 설명하며, 환경 설정 및 사용법을 안내합니다.
---

# csv-agent

이 템플릿은 [csv agent](https://python.langchain.com/docs/integrations/toolkits/csv)를 사용하여 텍스트 데이터와의 상호작용(질문-답변)을 위한 도구(파이썬 REPL)와 메모리(벡터스토어)를 포함합니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정합니다.

환경을 설정하기 위해 `ingest.py` 스크립트를 실행하여 벡터스토어로의 수집을 처리해야 합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이 패키지만 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package csv-agent
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add csv-agent
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from csv_agent.agent import agent_executor as csv_agent_chain

add_routes(app, csv_agent_chain, path="/csv-agent")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/csv-agent/playground](http://127.0.0.1:8000/csv-agent/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/csv-agent")
```