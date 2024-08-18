---
description: 이 문서는 사용자 입력을 해적 말로 변환하는 템플릿을 설정하고 사용하는 방법에 대해 설명합니다.
---

# 해적 말투

이 템플릿은 사용자 입력을 해적 말투로 변환합니다.

## 환경 설정

`OPENAI_API_KEY` 환경 변수를 설정하여 OpenAI 모델에 접근합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이 패키지를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package pirate-speak
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add pirate-speak
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from pirate_speak.chain import chain as pirate_speak_chain

add_routes(app, pirate_speak_chain, path="/pirate-speak")
```


(선택 사항) 이제 LangSmith를 설정해 보겠습니다.
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


이 명령은 FastAPI 앱을 시작하며 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/pirate-speak/playground](http://127.0.0.1:8000/pirate-speak/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/pirate-speak")
```