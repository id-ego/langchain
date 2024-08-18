---
description: 이 문서는 Python 코드 생성을 위한 에이전트로, `black`, `ruff`, `mypy`를 사용하여 코드 품질을 보장합니다.
---

# python-lint

이 에이전트는 적절한 포맷팅과 린팅에 중점을 두고 고품질 Python 코드를 생성하는 데 특화되어 있습니다. `black`, `ruff`, 및 `mypy`를 사용하여 코드가 표준 품질 검사를 충족하도록 보장합니다.

이것은 이러한 검사를 통합하고 이에 응답함으로써 코딩 프로세스를 간소화하여 신뢰할 수 있고 일관된 코드 출력을 생성합니다.

작성한 코드를 실제로 실행할 수는 없으며, 코드 실행은 추가 종속성과 잠재적인 보안 취약점을 도입할 수 있습니다. 이는 에이전트를 코드 생성 작업에 대한 안전하고 효율적인 솔루션으로 만듭니다.

Python 코드를 직접 생성하거나 계획 및 실행 에이전트와 네트워크를 구성하여 사용할 수 있습니다.

## 환경 설정

- `black`, `ruff`, 및 `mypy` 설치: `pip install -U black ruff mypy`
- `OPENAI_API_KEY` 환경 변수를 설정합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package python-lint
```


기존 프로젝트에 추가하려면 다음 명령을 실행하면 됩니다:

```shell
langchain app add python-lint
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from python_lint import agent_executor as python_lint_agent

add_routes(app, python_lint_agent, path="/python-lint")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/python-lint/playground](http://127.0.0.1:8000/python-lint/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/python-lint")
```