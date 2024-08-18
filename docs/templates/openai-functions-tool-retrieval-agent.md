---
description: 이 문서는 에이전트 쿼리에 대한 도구 선택을 위한 검색 기반 접근 방식을 소개하며, 실제 도구와 가짜 도구를 활용한 예제를
  제공합니다.
---

# openai-functions-tool-retrieval-agent

이 템플릿에서 소개된 새로운 아이디어는 에이전트 쿼리에 답하기 위해 사용할 도구 세트를 선택하는 데 검색을 사용하는 것입니다. 이는 선택할 수 있는 도구가 많을 때 유용합니다. 모든 도구의 설명을 프롬프트에 넣을 수는 없기 때문에(문맥 길이 문제로 인해) 대신 실행 시간에 사용하고자 하는 N개의 도구를 동적으로 선택합니다.

이 템플릿에서는 다소 억지스러운 예제를 만들 것입니다. 하나의 합법적인 도구(검색)와 99개의 헛소리 도구를 가질 것입니다. 그런 다음 사용자 입력을 가져와 쿼리와 관련된 도구를 검색하는 단계를 프롬프트 템플릿에 추가할 것입니다.

이 템플릿은 [이 에이전트 사용법](https://python.langchain.com/v0.2/docs/templates/openai-functions-agent/)을 기반으로 합니다.

## 환경 설정

다음 환경 변수를 설정해야 합니다:

`OPENAI_API_KEY` 환경 변수를 설정하여 OpenAI 모델에 접근합니다.

`TAVILY_API_KEY` 환경 변수를 설정하여 Tavily에 접근합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package openai-functions-tool-retrieval-agent
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add openai-functions-tool-retrieval-agent
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from openai_functions_tool_retrieval_agent import agent_executor as openai_functions_tool_retrieval_agent_chain

add_routes(app, openai_functions_tool_retrieval_agent_chain, path="/openai-functions-tool-retrieval-agent")
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


이렇게 하면 FastAPI 앱이 시작되고 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 볼 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/openai-functions-tool-retrieval-agent/playground](http://127.0.0.1:8000/openai-functions-tool-retrieval-agent/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/openai-functions-tool-retrieval-agent")
```