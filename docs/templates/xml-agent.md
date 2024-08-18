---
description: 이 패키지는 XML 구문을 사용하여 의사 결정을 전달하는 에이전트를 생성하며, Anthropic의 Claude 모델을 활용합니다.
---

# xml-agent

이 패키지는 XML 구문을 사용하여 어떤 행동을 취할지 결정하는 에이전트를 생성합니다. XML 구문 작성을 위해 Anthropic의 Claude 모델을 사용하며, 선택적으로 DuckDuckGo를 사용하여 인터넷에서 정보를 검색할 수 있습니다.

## 환경 설정

두 개의 환경 변수를 설정해야 합니다:

- `ANTHROPIC_API_KEY`: Anthropic을 사용하기 위해 필요합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package xml-agent
```


기존 프로젝트에 추가하고 싶다면, 다음 명령어를 실행하면 됩니다:

```shell
langchain app add xml-agent
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from xml_agent import agent_executor as xml_agent_chain

add_routes(app, xml_agent_chain, path="/xml-agent")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.
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


이렇게 하면 FastAPI 앱이 시작되며, 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/xml-agent/playground](http://127.0.0.1:8000/xml-agent/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/xml-agent")
```