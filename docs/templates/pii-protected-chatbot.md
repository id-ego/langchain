---
description: 이 템플릿은 PII를 플래그하고 LLM에 전달하지 않는 챗봇을 생성하는 방법을 안내합니다. 환경 설정 및 사용법을 포함합니다.
---

# pii-protected-chatbot

이 템플릿은 들어오는 PII를 플래그하고 이를 LLM에 전달하지 않는 챗봇을 생성합니다.

## 환경 설정

다음 환경 변수를 설정해야 합니다:

`OPENAI_API_KEY` 환경 변수를 설정하여 OpenAI 모델에 접근합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package pii-protected-chatbot
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add pii-protected-chatbot
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from pii_protected_chatbot.chain import chain as pii_protected_chatbot

add_routes(app, pii_protected_chatbot, path="/openai-functions-agent")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음과 같이 LangServe 인스턴스를 직접 실행할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/pii_protected_chatbot/playground](http://127.0.0.1:8000/pii_protected_chatbot/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/pii_protected_chatbot")
```