---
description: 이 템플릿을 사용하여 Gmail 계정을 관리하는 AI 비서를 만들고 사용자 맞춤형으로 설정할 수 있습니다.
---

# OpenAI Functions Agent - Gmail

받은 편지함 제로에 도달하는 데 어려움을 겪으셨나요? 

이 템플릿을 사용하여 Gmail 계정을 관리할 수 있는 AI 어시스턴트를 생성하고 사용자 정의할 수 있습니다. 기본 Gmail 도구를 사용하여 이메일을 읽고, 검색하고, 대신 응답할 이메일 초안을 작성할 수 있습니다. 또한 Tavily 검색 엔진에 접근할 수 있어 이메일 스레드의 주제나 사람에 대한 관련 정보를 검색한 후 작성하여 초안이 잘 알고 있는 것처럼 들리는 데 필요한 모든 관련 정보를 포함하도록 합니다.

## 세부 사항

이 어시스턴트는 OpenAI의 [function calling](https://python.langchain.com/docs/modules/chains/how_to/openai_functions) 지원을 사용하여 제공한 도구를 신뢰성 있게 선택하고 호출합니다.

이 템플릿은 또한 적절한 경우 [langchain-core](https://pypi.org/project/langchain-core/) 및 [`langchain-community`](https://pypi.org/project/langchain-community/)에서 직접 가져옵니다. 우리는 LangChain을 재구성하여 사용 사례에 필요한 특정 통합을 선택할 수 있도록 했습니다. 여전히 `langchain`에서 가져올 수 있지만(이전 호환성을 유지하고 있습니다), 대부분의 클래스의 소유권을 반영하고 종속성 목록을 가볍게 만들기 위해 대부분의 클래스의 위치를 분리했습니다. 필요한 대부분의 통합은 `langchain-community` 패키지에서 찾을 수 있으며, 핵심 표현 언어 API만 사용하는 경우 `langchain-core`만으로도 구축할 수 있습니다.

## 환경 설정

다음 환경 변수를 설정해야 합니다:

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정합니다.

Tavily 검색에 접근하기 위해 `TAVILY_API_KEY` 환경 변수를 설정합니다.

Gmail에서 OAuth 클라이언트 ID를 포함하는 [`credentials.json`](https://developers.google.com/gmail/api/quickstart/python#authorize_credentials_for_a_desktop_application) 파일을 생성합니다. 인증을 사용자 정의하려면 아래 [Customize Auth](#customize-auth) 섹션을 참조하세요.

**참고:** 이 앱을 처음 실행할 때 사용자 인증 흐름을 거치도록 강제됩니다.

(선택 사항): "Send" 도구에 대한 접근을 제공하기 위해 `GMAIL_AGENT_ENABLE_SEND`를 `true`로 설정하거나 이 템플릿의 `agent.py` 파일을 수정합니다. 이렇게 하면 어시스턴트가 귀하의 명시적인 검토 없이 이메일을 보낼 수 있는 권한을 부여받게 되며, 이는 권장되지 않습니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package openai-functions-agent-gmail
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add openai-functions-agent-gmail
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from openai_functions_agent import agent_executor as openai_functions_agent_chain

add_routes(app, openai_functions_agent_chain, path="/openai-functions-agent-gmail")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움이 됩니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/openai-functions-agent-gmail/playground](http://127.0.0.1:8000/openai-functions-agent/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/openai-functions-agent-gmail")
```


## 인증 사용자 정의

```
from langchain_community.tools.gmail.utils import build_resource_service, get_gmail_credentials

# Can review scopes here https://developers.google.com/gmail/api/auth/scopes
# For instance, readonly scope is 'https://www.googleapis.com/auth/gmail.readonly'
credentials = get_gmail_credentials(
    token_file="token.json",
    scopes=["https://mail.google.com/"],
    client_secrets_file="credentials.json",
)
api_resource = build_resource_service(credentials=credentials)
toolkit = GmailToolkit(api_resource=api_resource)
```