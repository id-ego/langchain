---
description: 이 템플릿은 Robocorp Action Server를 도구로 사용하여 LangChain 에이전트를 위한 작업을 수행하는 방법을
  안내합니다.
---

# Langchain - Robocorp Action Server

이 템플릿은 [Robocorp Action Server](https://github.com/robocorp/robocorp)에서 제공하는 액션을 에이전트의 도구로 사용할 수 있게 해줍니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이 패키지만 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package robocorp-action-server
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add robocorp-action-server
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:

```python
from robocorp_action_server import agent_executor as action_server_chain

add_routes(app, action_server_chain, path="/robocorp-action-server")
```


### 액션 서버 실행하기

액션 서버를 실행하려면 Robocorp Action Server가 설치되어 있어야 합니다.

```bash
pip install -U robocorp-action-server
```


그런 다음 다음 명령어로 액션 서버를 실행할 수 있습니다:

```bash
action-server new
cd ./your-project-name
action-server start
```


### LangSmith 구성하기 (선택 사항)

LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


### LangServe 인스턴스 시작하기

이 디렉토리 안에 있다면 다음 명령어로 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이 명령어는 FastAPI 앱을 시작하며 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/robocorp-action-server/playground](http://127.0.0.1:8000/robocorp-action-server/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/robocorp-action-server")
```